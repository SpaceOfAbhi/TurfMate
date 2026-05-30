import express from "express";

import {
  getAllTurfs,
} from "../controllers/turf.controller.js";

const router = express.Router();

router.get(
  "/",
  getAllTurfs
);

export default router;