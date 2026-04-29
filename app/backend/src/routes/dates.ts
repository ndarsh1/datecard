import { Router, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";

const router = Router();

/**
 * POST /api/v1/dates/:matchId/checkin
 * Check in to a date (confirm attendance).
 */
router.post("/:matchId/checkin", requireAuth, async (_req: AuthenticatedRequest, res: Response) => {
  // TODO: Record check-in for the date
  res.status(501).json({ message: "Not implemented yet" });
});

/**
 * POST /api/v1/dates/:matchId/rating
 * Submit a rating/review after a date.
 */
router.post("/:matchId/rating", requireAuth, async (_req: AuthenticatedRequest, res: Response) => {
  // TODO: Save post-date rating
  res.status(501).json({ message: "Not implemented yet" });
});

export default router;
