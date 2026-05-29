import express from "express";
import {
  createMatch,
  getNearbyMatches,
  joinMatch,
  getMatchDetails,
} from "../controllers/match.controller.js";
import {
  authMiddleware,
} from "../middleware/auth.middleware.js";


const router = express.Router();

router.post("/", authMiddleware, createMatch);
router.get("/nearby", getNearbyMatches);
router.get("/:id", getMatchDetails);
router.post("/:id/join", authMiddleware, joinMatch);


export default router;
