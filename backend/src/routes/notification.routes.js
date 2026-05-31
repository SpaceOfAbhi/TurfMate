import express from "express";
import { authMiddleware } from "../middleware/auth.middleware.js";
import {
  updateFcmToken,
} from "../controllers/notification.controller.js";

const router = express.Router();

router.post(
  "/fcm-token",
  authMiddleware,
  updateFcmToken,
);

router.get("/test-notification", async (req, res) => {

  await sendNotification(
    "PASTE_FCM_TOKEN_HERE",
    "Test Notification",
    "Firebase is working 🚀"
  );

  res.json({
    success: true,
  });
});

export default router;