import pool from "../db/pool.js";
import { getDistance } from "geolib";

export const createMatch = async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      sport,
      turfName,
      latitude,
      longitude,
      startTime,
      endTime,
      totalSlots,
      amountPerPerson,
      creatorId,
    } = req.body;

    await client.query("BEGIN");

    // Create match
    const matchQuery = `
      INSERT INTO matches (
        sport,
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
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      RETURNING *
    `;

    const matchValues = [
      sport,
      turfName,
      latitude,
      longitude,
      startTime,
      endTime,
      totalSlots,
      totalSlots - 1,
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
      SELECT * FROM matches
      WHERE is_active = true
      AND end_time > NOW()
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
    const { userId } = req.body;

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

    // Reduce slots
    await client.query(
      `
      UPDATE matches
      SET available_slots = available_slots - 1
      WHERE id = $1
      `,
      [id]
    );

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