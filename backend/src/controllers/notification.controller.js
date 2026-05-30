import pool from "../db/pool.js";

export const updateFcmToken = async (req, res) => {
  try {
    const { token } = req.body;

    await pool.query(
      `
      UPDATE users
      SET fcm_token = $1
      WHERE id = $2
      `,
      [token, req.user.id]
    );

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