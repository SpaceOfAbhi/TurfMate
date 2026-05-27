import express from "express";
import {
  createMatch,
  getNearbyMatches,
  joinMatch,
  getMatchDetails,
} from "../controllers/match.controller.js";


const router = express.Router();

router.post("/", createMatch);
router.get("/nearby", getNearbyMatches);
router.get("/:id", getMatchDetails);
router.post("/:id/join", joinMatch);


export default router;