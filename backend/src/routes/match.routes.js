import express from "express";
import { createMatch } from "../controllers/match.controller.js";

const router = express.Router();

router.post("/", createMatch);

export default router;