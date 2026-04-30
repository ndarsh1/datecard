import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";

import authRoutes from "./routes/auth";
import usersRoutes from "./routes/users";
import experiencesRoutes from "./routes/experiences";
import matchesRoutes from "./routes/matches";
import boardRoutes from "./routes/board";
import bookingsRoutes from "./routes/bookings";
import datesRoutes from "./routes/dates";
import blockingRoutes from "./routes/blocking";
import venueRoutes from "./routes/venues";

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

// Mount routes
app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/users", usersRoutes);
app.use("/api/v1/experiences", experiencesRoutes);
app.use("/api/v1/matches", matchesRoutes);
app.use("/api/v1/board", boardRoutes);
app.use("/api/v1/bookings", bookingsRoutes);
app.use("/api/v1/dates", datesRoutes);
app.use("/api/v1/blocking", blockingRoutes);
app.use("/api/v1/venues", venueRoutes);

// Start server
app.listen(PORT, () => {
  console.log(`DateCard API server running on port ${PORT}`);
});

export default app;
