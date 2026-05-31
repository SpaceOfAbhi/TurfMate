import pool from "../db/pool.js";
import { getDistance } from "geolib";
import { sendNotification }
  from "../services/notification.services.js";


export const createMatch = async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      sport,
      turf_id,
      turfName,
      latitude,
      longitude,
      startTime,
      endTime,
      totalSlots,
      amountPerPerson,

    } = req.body;

    const creatorId = req.user.userId;

    await client.query("BEGIN");

    // Create match
    const matchQuery = `
      INSERT INTO matches (
        sport,
        turf_id,
        turf_name,
        latitude,
        longitude,
        start_time,
        end_time,
        total_slots,
        available_slots,
        amount_per_person,
        creator_id
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
      RETURNING *
    `;

    const matchValues = [
      sport,
      turf_id,
      turfName,
      latitude,
      longitude,
      startTime,
      endTime,
      totalSlots,
      totalSlots,
      amountPerPerson,
      creatorId,
    ];

    const matchResult = await client.query(
      matchQuery,
      matchValues
    );

    const createdMatch = matchResult.rows[0];

    // Add creator as player
    const playerQuery = `
      INSERT INTO match_players (
        user_id,
        match_id
      )
      VALUES ($1,$2)
    `;

    await client.query(playerQuery, [
      creatorId,
      createdMatch.id,
    ]);

    await client.query("COMMIT");

    res.status(201).json({
      success: true,
      match: createdMatch,
    });

  } catch (error) {

    await client.query("ROLLBACK");

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to create match",
    });

  } finally {
    client.release();
  }
};

export const getNearbyMatches = async (req, res) => {
  try {

    const {
      latitude,
      longitude,
      radius,
    } = req.query;

    // Fetch active matches
    const result = await pool.query(`
      SELECT
    m.*,
    t.location_name
    FROM matches m
    LEFT JOIN turfs t
    ON m.turf_id = t.id
    WHERE m.start_time > NOW() + INTERVAL '5 minutes'
    ORDER BY m.start_time
    `);

    const matches = result.rows;

    // Filter nearby matches
    const nearbyMatches = matches.filter((match) => {

      const distanceInMeters = getDistance(
        {
          latitude: Number(latitude),
          longitude: Number(longitude),
        },
        {
          latitude: Number(match.latitude),
          longitude: Number(match.longitude),
        }
      );

      const distanceInKm = distanceInMeters / 1000;

      return distanceInKm <= Number(radius);
    });

    res.status(200).json({
      success: true,
      matches: nearbyMatches,
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch nearby matches",
    });

  }
};

export const joinMatch = async (req, res) => {

  const client = await pool.connect();

  try {

    const { id } = req.params;
    const userId = req.user.userId;

    await client.query("BEGIN");

    // Lock match row
    const matchResult = await client.query(
      `
      SELECT *
      FROM matches
      WHERE id = $1
      FOR UPDATE
      `,
      [id]
    );

    const match = matchResult.rows[0];

    // Match not found
    if (!match) {

      await client.query("ROLLBACK");

      return res.status(404).json({
        success: false,
        message: "Match not found",
      });
    }

    // Match full
    if (match.available_slots <= 0) {

      await client.query("ROLLBACK");

      return res.status(400).json({
        success: false,
        message: "No slots available",
      });
    }

    // Already joined check
    const existingPlayer = await client.query(
      `
      SELECT *
      FROM match_players
      WHERE user_id = $1
      AND match_id = $2
      `,
      [userId, id]
    );

    if (existingPlayer.rows.length > 0) {

      await client.query("ROLLBACK");

      return res.status(400).json({
        success: false,
        message: "User already joined",
      });
    }

    // Add player
    await client.query(
      `
      INSERT INTO match_players (
        user_id,
        match_id
      )
      VALUES ($1,$2)
      `,
      [userId, id]
    );

    const creatorResult =
      await client.query(
        `
    SELECT
      u.fcm_token,
      u.name
    FROM users u
    JOIN matches m
    ON m.creator_id = u.id
    WHERE m.id = $1
    `,
        [id]
      );


    const playerResult =
      await client.query(
        `
    SELECT name
    FROM users
    WHERE id = $1
    `,
        [userId]
      );
    // Reduce slots
    await client.query(
      `
      UPDATE matches
      SET available_slots = available_slots-1
      WHERE id = $1
      `,
      [id]
    );

    const creator =
      creatorResult.rows[0];

    const player =
      playerResult.rows[0];

    if (
      creator?.fcm_token &&
      match.creator_id !== userId
    ) {
      console.log("SENDING NOTIFICATION");
      console.log("TOKEN:", creator?.fcm_token);
      await sendNotification(

        creator.fcm_token,

        "⚽ New Player Joined",

        `${player.name} joined your match`
      );
      console.log("NOTIFICATION SENT");
    }

    await client.query("COMMIT");

    res.status(200).json({
      success: true,
      message: "Joined match successfully",
    });

  } catch (error) {

    await client.query("ROLLBACK");

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to join match",
    });

  } finally {

    client.release();

  }
};

export const getMatchDetails = async (req, res) => {

  try {

    const { id } = req.params;

    const query = `
      SELECT
        m.*,

        u.id AS creator_id,
        u.name AS creator_name,
        u.email AS creator_email,

        COALESCE(
          json_agg(
            json_build_object(
              'id', p.id,
              'name', p.name,
              'email', p.email
            )
          ) FILTER (WHERE p.id IS NOT NULL),
          '[]'
        ) AS players

      FROM matches m

      JOIN users u
      ON m.creator_id = u.id

      LEFT JOIN match_players mp
      ON m.id = mp.match_id

      LEFT JOIN users p
      ON mp.user_id = p.id

      WHERE m.id = $1

      GROUP BY m.id, u.id
    `;

    const result = await pool.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Match not found",
      });
    }

    res.status(200).json({
      success: true,
      match: result.rows[0],
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch match details",
    });

  }
};

export const getMyCreatedMatches = async (req, res) => {

  try {

    const userId =
      req.user.userId;

    const result =
      await pool.query(
        `
        SELECT
    m.*,
    t.location_name
    FROM matches m
    LEFT JOIN turfs t
    ON m.turf_id = t.id
    WHERE m.creator_id = $1
    ORDER BY m.start_time DESC
        `,
        [userId]
      );

    res.status(200).json({
      success: true,
      matches: result.rows,
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message:
        "Failed to fetch matches",
    });
  }
};

export const getMyJoinedMatches = async (req, res) => {

  try {

    const userId =
      req.user.userId;

    const result =
      await pool.query(
        `
      SELECT
    m.*,
    t.location_name
    FROM matches m
    JOIN match_players mp
    ON mp.match_id = m.id
    LEFT JOIN turfs t
    ON m.turf_id = t.id
    WHERE mp.user_id = $1
    ORDER BY m.start_time DESC
        `,
        [userId]
      );

    res.status(200).json({
      success: true,
      matches: result.rows,
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message:
        "Failed to fetch matches",
    });
  }
};

export const getMatchPlayers = async (req, res) => {

  try {

    const { id } = req.params;

    const userId =
      req.user.userId;

    // Check match exists
    const matchResult =
      await pool.query(
        `
        SELECT creator_id
        FROM matches
        WHERE id = $1
        `,
        [id]
      );

    if (
      matchResult.rows.length === 0
    ) {

      return res.status(404).json({
        success: false,
        message: "Match not found",
      });
    }

    // Only creator can view players
    if (
      matchResult.rows[0]
        .creator_id !== userId
    ) {

      return res.status(403).json({
        success: false,
        message:
          "Not authorized",
      });
    }

    // Get all players joined
    const playersResult =
      await pool.query(
        `
        SELECT
          u.id,
          u.name,
          u.email,
          u.location_name

        FROM users u

        JOIN match_players mp
        ON mp.user_id = u.id

        WHERE mp.match_id = $1

        ORDER BY u.name
        `,
        [id]
      );

    return res.status(200).json({
      success: true,
      count:
        playersResult.rows.length,
      players:
        playersResult.rows,
    });

  } catch (error) {

    console.error(error);

    return res.status(500).json({
      success: false,
      message:
        "Failed to fetch players",
    });
  }
};

export const leaveMatch = async (req, res) => {

  const client =
    await pool.connect();

  try {

    const { id } = req.params;

    const userId =
      req.user.userId;

    const creatorResult = await client.query(
      `
        SELECT creator_id
        FROM matches
        WHERE id = $1
  `,
      [id]
    );

    const creatorId =
      creatorResult.rows[0]?.creator_id;


    const tokenResult = await client.query(
      `
      SELECT fcm_token
      FROM users
      WHERE id = $1
  `,
      [creatorId]
    );

    const creatorToken =
      tokenResult.rows[0]?.fcm_token;


    await client.query(
      "BEGIN"
    );

    const playerResult =
      await client.query(
        `
      SELECT *
      FROM match_players
      WHERE user_id = $1
      AND match_id = $2
      `,
        [userId, id]
      );

    if (
      playerResult.rows.length === 0
    ) {

      await client.query(
        "ROLLBACK"
      );

      return res.status(400).json({
        success: false,
        message:
          "User not in match",
      });
    }
    const playerName = playerResult.rows[0]?.name;
    await client.query(
      `
      DELETE FROM match_players
      WHERE user_id = $1
      AND match_id = $2
      `,
      [userId, id]
    );

    await client.query(
      `
      UPDATE matches
      SET available_slots =
      available_slots + 1
      WHERE id = $1
      `,
      [id]
    );

    if (
      creatorToken &&
      creatorId !== userId
    ) {

      await sendNotification(
        creatorToken,
        "⚠️ Player Left",
        `${playerName} left your match`
      );

    }
    await client.query(
      "COMMIT"
    );

    res.status(200).json({
      success: true,
      message:
        "Left match successfully",
    });

  } catch (error) {

    await client.query(
      "ROLLBACK"
    );

    console.error(error);

    res.status(500).json({
      success: false,
      message:
        "Failed to leave match",
    });

  } finally {

    client.release();
  }
};

export const deleteMatch = async (
  req,
  res
) => {

  const client =
    await pool.connect();

  try {

    const { id } = req.params;

    const userId =
      req.user.userId;

    const playersResult =
      await client.query(
        `
    SELECT
      u.fcm_token,
      u.name
    FROM match_players mp
    JOIN users u
      ON mp.user_id = u.id
    WHERE mp.match_id = $1
    `,
        [id]
      );

    await client.query(
      "BEGIN"
    );

    const matchResult =
      await client.query(
        `
      SELECT creator_id
      FROM matches
      WHERE id = $1
      `,
        [id]
      );
    const sport =
      matchResult.rows[0]?.sport;
    if (
      matchResult.rows.length === 0
    ) {

      await client.query(
        "ROLLBACK"
      );

      return res.status(404).json({
        success: false,
        message:
          "Match not found",
      });
    }

    if (
      matchResult.rows[0]
        .creator_id !== userId
    ) {

      await client.query(
        "ROLLBACK"
      );

      return res.status(403).json({
        success: false,
        message:
          "Not authorized",
      });
    }

    await client.query(
      `
      DELETE FROM match_players
      WHERE match_id = $1
      `,
      [id]
    );

    await client.query(
      `
      DELETE FROM matches
      WHERE id = $1
      `,
      [id]
    );

    await sendNotification(
      player.fcm_token,
      "⚠️ Match Cancelled",
      `${sport} match has been cancelled`
    );

    await client.query(
      "COMMIT"
    );

    res.status(200).json({
      success: true,
      message:
        "Match deleted",
    });

  } catch (error) {

    await client.query(
      "ROLLBACK"
    );

    console.error(error);

    res.status(500).json({
      success: false,
      message:
        "Failed to delete match",
    });

  } finally {

    client.release();
  }
};