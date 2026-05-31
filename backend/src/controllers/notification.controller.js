import pool from "../db/pool.js";

export const updateFcmToken = async (req, res) => {
  try {

    console.log("FCM TOKEN REQUEST");
    console.log(req.user);
    console.log(req.body);

    const { token } = req.body;

    const result = await pool.query(
      `
      UPDATE users
      SET fcm_token = $1
      WHERE id = $2
      RETURNING *
      `,
      [token, req.user.userId] // <-- use userId
    );

    console.log(result.rows);

    res.json({
      success: true,
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
    });
  }
};