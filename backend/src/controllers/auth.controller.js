import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";

import pool from "../db/pool.js";

const client = new OAuth2Client();

export const googleLogin = async (req, res) => {

    try {

        const { idToken } = req.body;

        const ticket = await client.verifyIdToken({
            idToken,
        });

        const payload = ticket.getPayload();

        const {
            email,
            name,
        } = payload;

        // Check existing user
        let userResult = await pool.query(
            `
      SELECT *
      FROM users
      WHERE email = $1
      `,
            [email]
        );

        let user;

        // Create user if not exists
        if (userResult.rows.length === 0) {

            const newUser = await pool.query(
                `
        INSERT INTO users (
          name,
          email
        )
        VALUES ($1,$2)
        RETURNING *
        `,
                [name, email]
            );

            user = newUser.rows[0];

        } else {

            user = userResult.rows[0];
        }

        // Generate JWT
        const token = jwt.sign(

            {
                userId: user.id,
            },

            process.env.JWT_SECRET,

            {
                expiresIn: "7d",
            }
        );

        res.status(200).json({
            success: true,
            token,
            user,
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            success: false,
            message: "Authentication failed",
        });

    }
};