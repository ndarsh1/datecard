import { Router, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * POST /api/v1/blocking/block
 * Block another user.
 *
 * Body: { blockedUserId: string }
 */
router.post(
  "/block",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { blockedUserId } = req.body;

      if (!blockedUserId) {
        res.status(400).json({ error: "blockedUserId is required" });
        return;
      }

      if (blockedUserId === userId) {
        res.status(400).json({ error: "You cannot block yourself" });
        return;
      }

      const { error } = await supabaseAdmin
        .from("blocked_users")
        .insert({ blocker_id: userId, blocked_id: blockedUserId });

      if (error) {
        // Unique constraint violation — already blocked
        if (error.code === "23505") {
          res.status(409).json({ error: "User is already blocked" });
          return;
        }
        res.status(500).json({ error: error.message });
        return;
      }

      res.status(201).json({ message: "User blocked successfully" });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * POST /api/v1/blocking/report
 * Report another user.
 *
 * Body: { reportedUserId: string, reason: string, details?: string }
 */
router.post(
  "/report",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { reportedUserId, reason, details } = req.body;

      if (!reportedUserId || !reason) {
        res
          .status(400)
          .json({ error: "reportedUserId and reason are required" });
        return;
      }

      if (reportedUserId === userId) {
        res.status(400).json({ error: "You cannot report yourself" });
        return;
      }

      const { error } = await supabaseAdmin.from("reports").insert({
        reporter_id: userId,
        reported_id: reportedUserId,
        reason,
        details: details || null,
      });

      if (error) {
        res.status(500).json({ error: error.message });
        return;
      }

      res.status(201).json({ message: "Report submitted successfully" });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * GET /api/v1/blocking/blocked
 * Get list of blocked user IDs for the current user.
 */
router.get(
  "/blocked",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { data, error } = await supabaseAdmin
        .from("blocked_users")
        .select("blocked_id")
        .eq("blocker_id", userId);

      if (error) {
        res.status(500).json({ error: error.message });
        return;
      }

      const blockedIds = (data ?? []).map(
        (row: Record<string, unknown>) => row.blocked_id
      );

      res.json({ blockedUserIds: blockedIds });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
