import { Router, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * POST /api/v1/dates/:matchId/checkin
 * Check in to a date (confirm attendance).
 * Returns success and lets the client track check-in state via the match.
 * Real-time sync happens via Stream Chat events on the client side.
 */
router.post(
  "/:matchId/checkin",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { matchId } = req.params;

      // Verify the user is part of this match
      const { data: match, error: matchError } = await supabaseAdmin
        .from("matches")
        .select("*")
        .eq("id", matchId)
        .single();

      if (matchError || !match) {
        res.status(404).json({ error: "Match not found" });
        return;
      }

      if (match.user_a !== userId && match.user_b !== userId) {
        res.status(403).json({ error: "You are not part of this match" });
        return;
      }

      // TODO: Implement persistent check-in tracking (e.g. checked_in_users
      // column on matches, or a separate date_checkins table). For now, return
      // success so the client can track state via Stream Chat events.
      res.json({ checkedIn: true, matchId });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * POST /api/v1/dates/:matchId/rating
 * Submit a rating/review after a date.
 * Body: { overall_score (1-5), would_go_again (bool), feedback_text? }
 */
router.post(
  "/:matchId/rating",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { matchId } = req.params;
      const { overall_score, would_go_again, feedback_text } = req.body;

      if (overall_score == null || would_go_again == null) {
        res
          .status(400)
          .json({ error: "overall_score and would_go_again are required" });
        return;
      }

      if (
        typeof overall_score !== "number" ||
        overall_score < 1 ||
        overall_score > 5
      ) {
        res
          .status(400)
          .json({ error: "overall_score must be an integer between 1 and 5" });
        return;
      }

      if (typeof would_go_again !== "boolean") {
        res.status(400).json({ error: "would_go_again must be a boolean" });
        return;
      }

      // Verify the user is part of this match
      const { data: match, error: matchError } = await supabaseAdmin
        .from("matches")
        .select("*")
        .eq("id", matchId)
        .single();

      if (matchError || !match) {
        res.status(404).json({ error: "Match not found" });
        return;
      }

      if (match.user_a !== userId && match.user_b !== userId) {
        res.status(403).json({ error: "You are not part of this match" });
        return;
      }

      // Insert the rating
      const { data: rating, error: ratingError } = await supabaseAdmin
        .from("date_ratings")
        .insert({
          match_id: matchId,
          user_id: userId,
          overall_score,
          would_go_again,
          feedback_text: feedback_text ?? null,
        })
        .select()
        .single();

      if (ratingError) {
        // Handle duplicate rating (unique constraint on match_id + user_id)
        if (ratingError.code === "23505") {
          res
            .status(409)
            .json({ error: "You have already rated this date" });
          return;
        }
        res.status(500).json({ error: ratingError.message });
        return;
      }

      // Check if both users have now rated — if so, mark match as completed
      const { count, error: countError } = await supabaseAdmin
        .from("date_ratings")
        .select("id", { count: "exact", head: true })
        .eq("match_id", matchId);

      if (!countError && count !== null && count >= 2) {
        await supabaseAdmin
          .from("matches")
          .update({ status: "completed" })
          .eq("id", matchId);
      }

      res.status(201).json({ rating });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
