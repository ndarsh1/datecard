import { Router, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";

const router = Router();

/**
 * POST /api/v1/users/profile
 * Create or update user profile.
 */
router.post("/profile", requireAuth, async (_req: AuthenticatedRequest, res: Response) => {
  // TODO: Upsert user profile in Supabase
  res.status(501).json({ message: "Not implemented yet" });
});

export default router;
