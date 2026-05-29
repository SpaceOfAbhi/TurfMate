import jwt from "jsonwebtoken";

export const authMiddleware = (
    req,
    res,
    next
) => {

    try {

        const authHeader =
            req.headers.authorization;


        console.log("AUTH HEADER:", authHeader);
        if (!authHeader) {

            return res.status(401).json({
                success: false,
                message: "No token provided",
            });
        }

        const token =
            authHeader.split(" ")[1];

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        req.user = decoded;

        next();

    } catch (error) {

        return res.status(401).json({
            success: false,
            message: "Invalid token",
        });
    }
};