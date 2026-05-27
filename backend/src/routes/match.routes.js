import express from "express";
import {
  createMatch,
  getNearbyMatches,
  joinMatch,
} from "../controllers/match.controller.js";


const router = express.Router();

router.post("/", createMatch);
router.get("/nearby", getNearbyMatches);
router.post("/:id/join", joinMatch);

export default router;