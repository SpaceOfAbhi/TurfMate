import express from "express";
import {
  createMatch,
  getNearbyMatches,
  joinMatch,
  getMatchDetails,
  getMyCreatedMatches,
  getMyJoinedMatches,
  getMatchPlayers,
} from "../controllers/match.controller.js";
import {
  authMiddleware,
} from "../middleware/auth.middleware.js";


const router = express.Router();

router.post("/", authMiddleware, createMatch);
router.get("/nearby", getNearbyMatches);

router.post("/:id/join", authMiddleware, joinMatch);
router.get("/my-created",authMiddleware,getMyCreatedMatches);
router.get("/my-joined",authMiddleware,getMyJoinedMatches);
router.get("/:id/players",authMiddleware,getMatchPlayers);
router.get("/:id", getMatchDetails);


export default router;
