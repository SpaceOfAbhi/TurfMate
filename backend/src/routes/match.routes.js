import express from "express";
import {
  createMatch,
  getNearbyMatches,
} from "../controllers/match.controller.js";


const router = express.Router();

router.post("/", createMatch);
router.get("/nearby", getNearbyMatches);

export default router;