import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.routes.js";
import matchRoutes from "./routes/match.routes.js";

const app = express();

app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/matches", matchRoutes);

app.get("/", (req, res) => {
  res.send("API Running");
});

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});