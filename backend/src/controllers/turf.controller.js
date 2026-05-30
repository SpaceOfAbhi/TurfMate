import  pool  from "../db/pool.js";

export const getAllTurfs = async (
    req,
    res
) => {

    try {

        const result =
            await pool.query(`
        SELECT *
        FROM turfs
        ORDER BY name
      `);

        res.status(200).json({
            success: true,
            turfs: result.rows,
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            success: false,
            message:
                "Failed to fetch turfs",
        });
    }
};