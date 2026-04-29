import { Router, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";

const router = Router();

/**
 * POST /api/v1/bookings
 * Create a booking for a date experience (will integrate Stripe later).
 */
router.post("/", requireAuth, async (_req: AuthenticatedRequest, res: Response) => {
  // TODO: Create booking and process payment via Stripe
  res.status(501).json({ message: "Not implemented yet" });
});

export default router;
