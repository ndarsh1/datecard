import { Router, Response } from "express";
import { randomUUID } from "crypto";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * POST /api/v1/matches
 * Create a match request between the authenticated user and a target user
 * for a specific experience.
 *
 * Body: { targetUserId: string, experienceId: string }
 */
router.post(
  "/",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { targetUserId, experienceId } = req.body;

      if (!targetUserId || !experienceId) {
        res
          .status(400)
          .json({ error: "targetUserId and experienceId are required" });
        return;
      }

      if (targetUserId === userId) {
        res.status(400).json({ error: "You cannot match with yourself" });
        return;
      }

      // Verify both users opted into the same experience
      const { data: optIns, error: optInError } = await supabaseAdmin
        .from("opt_ins")
        .select("user_id")
        .eq("experience_id", experienceId)
        .in("user_id", [userId, targetUserId]);

      if (optInError) {
        res.status(500).json({ error: optInError.message });
        return;
      }

      const optedInUserIds = (optIns ?? []).map(
        (o: Record<string, unknown>) => o.user_id
      );
      if (
        !optedInUserIds.includes(userId) ||
        !optedInUserIds.includes(targetUserId)
      ) {
        res.status(400).json({
          error:
            "Both users must have opted into this experience to create a match",
        });
        return;
      }

      // Check if a match request already exists from requester -> target for this experience
      const { data: existingMatch, error: existingError } = await supabaseAdmin
        .from("matches")
        .select("*")
        .eq("user_a", userId)
        .eq("user_b", targetUserId)
        .eq("experience_id", experienceId)
        .maybeSingle();

      if (existingError) {
        res.status(500).json({ error: existingError.message });
        return;
      }

      if (existingMatch) {
        res.status(409).json({
          error: "You have already sent a match request for this experience",
          match: existingMatch,
        });
        return;
      }

      // Check if the target has already sent a match request to the requester (mutual match)
      const { data: reverseMatch, error: reverseError } = await supabaseAdmin
        .from("matches")
        .select("*")
        .eq("user_a", targetUserId)
        .eq("user_b", userId)
        .eq("experience_id", experienceId)
        .maybeSingle();

      if (reverseError) {
        res.status(500).json({ error: reverseError.message });
        return;
      }

      if (reverseMatch) {
        // Mutual match! Update the existing reverse match to 'matched' and generate a chat channel
        const chatChannelId = `match_${randomUUID()}`;

        const { error: updateError } = await supabaseAdmin
          .from("matches")
          .update({ status: "matched", chat_channel_id: chatChannelId })
          .eq("id", reverseMatch.id);

        if (updateError) {
          res.status(500).json({ error: updateError.message });
          return;
        }

        // Create the requester's match record as 'matched' too
        const { data: newMatch, error: insertError } = await supabaseAdmin
          .from("matches")
          .insert({
            user_a: userId,
            user_b: targetUserId,
            experience_id: experienceId,
            status: "matched",
            chat_channel_id: chatChannelId,
          })
          .select()
          .single();

        if (insertError) {
          res.status(500).json({ error: insertError.message });
          return;
        }

        res.status(201).json({ match: newMatch, mutual: true });
        return;
      }

      // No reverse match — create a pending match request
      const { data: newMatch, error: insertError } = await supabaseAdmin
        .from("matches")
        .insert({
          user_a: userId,
          user_b: targetUserId,
          experience_id: experienceId,
          status: "pending",
        })
        .select()
        .single();

      if (insertError) {
        res.status(500).json({ error: insertError.message });
        return;
      }

      res.status(201).json({ match: newMatch, mutual: false });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * GET /api/v1/matches
 * Get all matches for the current user, with populated user and experience data.
 */
router.get(
  "/",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      // Fetch matches where the current user is user_a
      const { data: matchesAsA, error: errorA } = await supabaseAdmin
        .from("matches")
        .select(
          "*, user_b_profile:users!matches_user_b_fkey(id, first_name, last_name, avatar_url, photos, date_style_card), experience:date_experiences(id, title)"
        )
        .eq("user_a", userId);

      if (errorA) {
        res.status(500).json({ error: errorA.message });
        return;
      }

      // Fetch matches where the current user is user_b
      const { data: matchesAsB, error: errorB } = await supabaseAdmin
        .from("matches")
        .select(
          "*, user_a_profile:users!matches_user_a_fkey(id, first_name, last_name, avatar_url, photos, date_style_card), experience:date_experiences(id, title)"
        )
        .eq("user_b", userId);

      if (errorB) {
        res.status(500).json({ error: errorB.message });
        return;
      }

      // Normalize: always include `other_user` for the other party
      const normalizedA = (matchesAsA ?? []).map(
        (m: Record<string, unknown>) => ({
          ...m,
          other_user: m.user_b_profile,
          user_b_profile: undefined,
        })
      );

      const normalizedB = (matchesAsB ?? []).map(
        (m: Record<string, unknown>) => ({
          ...m,
          other_user: m.user_a_profile,
          user_a_profile: undefined,
        })
      );

      const allMatches = [...normalizedA, ...normalizedB];

      res.json({ matches: allMatches });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
