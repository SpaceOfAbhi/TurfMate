import pool from "../db/pool.js";

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