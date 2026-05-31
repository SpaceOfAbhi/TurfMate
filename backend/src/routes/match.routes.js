import express from "express";
import {
  createMatch,
  getNearbyMatches,
  joinMatch,
  getMatchDetails,
  getMyCreatedMatches,
  getMyJoinedMatches,
  getMatchPlayers,
  leaveMatch,
  deleteMatch
} from "../controllers/match.controller.js";
import {
  authMiddleware,
} from "../middleware/auth.middleware.js";


const router = express.Router();

router.post("/", authMiddleware, createMatch);
router.get("/nearby", authMiddleware, getNearbyMatches);
router.post("/:id/join", authMiddleware, joinMatch);
router.get("/my-created",authMiddleware,getMyCreatedMatches);
router.get("/my-joined",authMiddleware,getMyJoinedMatches);
router.delete("/:id/leave",authMiddleware,leaveMatch);
router.get("/:id/players",authMiddleware,getMatchPlayers);
router.delete("/:id",authMiddleware,deleteMatch);
router.get("/:id", authMiddleware, getMatchDetails);


export default router;
