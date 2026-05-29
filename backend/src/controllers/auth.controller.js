import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import pool from "../db/pool.js";

export const signup = async (req, res) => {
    try {
        const {
            name,
            email,
            password,
            latitude,
            longitude,
            locationName,
        } = req.body;

        const existingUser = await pool.query(
            `
      SELECT * FROM users
      WHERE email = $1
      `,
            [email]
        );

        if (existingUser.rows.length > 0) {
            return res.status(400).json({
                success: false,
                message: "Email already exists",
            });
        }

        const hashedPassword = await bcrypt.hash(
            password,
            10
        );

        const result = await pool.query(
            `
      INSERT INTO users (
        name,
        email,
        password,
        latitude,
        longitude,
        location_name
      )
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING id,name,email,location_name
      `,
            [
                name,
                email,
                hashedPassword,
                latitude,
                longitude,
                locationName,
            ]
        );

        const user = result.rows[0];

        const token = jwt.sign(
            {
                userId: user.id,
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "7d",
            }
        );

        return res.status(201).json({
            success: true,
            token,
            user,
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            success: false,
            message: "Signup failed",
        });
    }
};

export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const result = await pool.query(
            `
      SELECT *
      FROM users
      WHERE email = $1
      `,
            [email]
        );

        if (result.rows.length === 0) {
            return res.status(400).json({
                success: false,
                message: "Invalid credentials",
            });
        }

        const user = result.rows[0];

        const isMatch = await bcrypt.compare(
            password,
            user.password
        );

        if (!isMatch) {
            return res.status(400).json({
                success: false,
                message: "Invalid credentials",
            });
        }

        const token = jwt.sign(
            {
                userId: user.id,
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "7d",
            }
        );

        return res.status(200).json({
            success: true,
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                location_name: user.location_name,
            },
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            success: false,
            message: "Login failed",
        });
    }
};