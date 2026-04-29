import { Router, Response } from "express";
import { randomUUID } from "crypto";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * GET /api/v1/board
 * List all non-expired +1 Board posts.
 * Supports ?event_type= filter, ?limit= (default 20), ?offset= (default 0).
 * Orders by event_date ascending.
 * Excludes posts from users the current user has blocked.
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

      const eventType = req.query.event_type as string | undefined;
      const limit = parseInt(req.query.limit as string, 10) || 20;
      const offset = parseInt(req.query.offset as string, 10) || 0;

      // Get blocked user IDs for current user
      const { data: blockedRows, error: blockedError } = await supabaseAdmin
        .from("blocked_users")
        .select("blocked_id")
        .eq("blocker_id", userId);

      if (blockedError) {
        res.status(500).json({ error: blockedError.message });
        return;
      }

      const blockedIds = (blockedRows ?? []).map(
        (row: Record<string, unknown>) => row.blocked_id as string
      );

      // Build query for non-expired posts
      let query = supabaseAdmin
        .from("plus_one_posts")
        .select(
          "*, poster:users!plus_one_posts_user_id_fkey(id, first_name, last_name, photos)"
        )
        .gte("expires_at", new Date().toISOString())
        .order("event_date", { ascending: true })
        .range(offset, offset + limit - 1);

      if (eventType) {
        query = query.eq("event_type", eventType);
      }

      if (blockedIds.length > 0) {
        // Exclude posts from blocked users
        // Supabase PostgREST uses "not.in" filter
        query = query.not(
          "user_id",
          "in",
          `(${blockedIds.join(",")})`
        );
      }

      const { data: posts, error: postsError } = await query;

      if (postsError) {
        res.status(500).json({ error: postsError.message });
        return;
      }

      res.json({ posts: posts ?? [] });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * POST /api/v1/board
 * Create a new +1 Board post. Auth-protected.
 * Body: { event_name, event_type, event_date, location_name, latitude?, longitude?,
 *         dress_code?, vibe?, ticket_included, description }
 * Auto-sets expires_at to event_date.
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

      const {
        event_name,
        event_type,
        event_date,
        location_name,
        latitude,
        longitude,
        dress_code,
        vibe,
        ticket_included,
        description,
      } = req.body;

      if (!event_name || !event_type || !event_date || !location_name || ticket_included === undefined || !description) {
        res.status(400).json({
          error:
            "event_name, event_type, event_date, location_name, ticket_included, and description are required",
        });
        return;
      }

      const validEventTypes = [
        "wedding",
        "gala",
        "concert",
        "party",
        "sports",
        "other",
      ];
      if (!validEventTypes.includes(event_type)) {
        res.status(400).json({
          error: `event_type must be one of: ${validEventTypes.join(", ")}`,
        });
        return;
      }

      const { data: post, error } = await supabaseAdmin
        .from("plus_one_posts")
        .insert({
          user_id: userId,
          event_name,
          event_type,
          event_date,
          location_name,
          latitude: latitude || null,
          longitude: longitude || null,
          dress_code: dress_code || null,
          vibe: vibe || null,
          ticket_included,
          description,
          expires_at: event_date,
        })
        .select()
        .single();

      if (error) {
        res.status(500).json({ error: error.message });
        return;
      }

      res.status(201).json({ post });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * GET /api/v1/board/:id
 * Get a single +1 Board post with poster profile info.
 */
router.get(
  "/:id",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;

      const { data: post, error } = await supabaseAdmin
        .from("plus_one_posts")
        .select(
          "*, poster:users!plus_one_posts_user_id_fkey(id, first_name, last_name, photos)"
        )
        .eq("id", id)
        .maybeSingle();

      if (error) {
        res.status(500).json({ error: error.message });
        return;
      }

      if (!post) {
        res.status(404).json({ error: "Post not found" });
        return;
      }

      res.json({ post });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * POST /api/v1/board/:id/interest
 * Express interest in a +1 Board post. Auth-protected.
 * Body: { note? }
 */
router.post(
  "/:id/interest",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { id } = req.params;
      const { note } = req.body;

      // Verify the post exists
      const { data: post, error: postError } = await supabaseAdmin
        .from("plus_one_posts")
        .select("id, user_id")
        .eq("id", id)
        .maybeSingle();

      if (postError) {
        res.status(500).json({ error: postError.message });
        return;
      }

      if (!post) {
        res.status(404).json({ error: "Post not found" });
        return;
      }

      // Prevent self-interest
      if (post.user_id === userId) {
        res
          .status(400)
          .json({ error: "You cannot express interest in your own post" });
        return;
      }

      // Insert interest
      const { data: interest, error: insertError } = await supabaseAdmin
        .from("plus_one_interests")
        .insert({
          post_id: id,
          user_id: userId,
          note: note || null,
          status: "pending",
        })
        .select()
        .single();

      if (insertError) {
        // Unique constraint violation — duplicate interest
        if (insertError.code === "23505") {
          res
            .status(409)
            .json({ error: "You have already expressed interest in this post" });
          return;
        }
        res.status(500).json({ error: insertError.message });
        return;
      }

      res.status(201).json({ interest });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * GET /api/v1/board/:id/interests
 * Get all interests for a +1 Board post. Auth-protected.
 * Only the post creator can view this list.
 */
router.get(
  "/:id/interests",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { id } = req.params;

      // Verify the post exists and the current user is the creator
      const { data: post, error: postError } = await supabaseAdmin
        .from("plus_one_posts")
        .select("id, user_id")
        .eq("id", id)
        .maybeSingle();

      if (postError) {
        res.status(500).json({ error: postError.message });
        return;
      }

      if (!post) {
        res.status(404).json({ error: "Post not found" });
        return;
      }

      if (post.user_id !== userId) {
        res
          .status(403)
          .json({ error: "Only the post creator can view interests" });
        return;
      }

      const { data: interests, error: interestsError } = await supabaseAdmin
        .from("plus_one_interests")
        .select(
          "*, user:users!plus_one_interests_user_id_fkey(id, first_name, last_name, photos)"
        )
        .eq("post_id", id);

      if (interestsError) {
        res.status(500).json({ error: interestsError.message });
        return;
      }

      res.json({ interests: interests ?? [] });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * POST /api/v1/board/:id/interests/:interestId/accept
 * Accept an interest. Auth-protected. Only the post creator can accept.
 * Updates interest status to 'accepted' and creates a match record.
 */
router.post(
  "/:id/interests/:interestId/accept",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { id, interestId } = req.params;

      // Verify the post exists and the current user is the creator
      const { data: post, error: postError } = await supabaseAdmin
        .from("plus_one_posts")
        .select("id, user_id")
        .eq("id", id)
        .maybeSingle();

      if (postError) {
        res.status(500).json({ error: postError.message });
        return;
      }

      if (!post) {
        res.status(404).json({ error: "Post not found" });
        return;
      }

      if (post.user_id !== userId) {
        res
          .status(403)
          .json({ error: "Only the post creator can accept interests" });
        return;
      }

      // Get the interest record
      const { data: interest, error: interestError } = await supabaseAdmin
        .from("plus_one_interests")
        .select("*")
        .eq("id", interestId)
        .eq("post_id", id)
        .maybeSingle();

      if (interestError) {
        res.status(500).json({ error: interestError.message });
        return;
      }

      if (!interest) {
        res.status(404).json({ error: "Interest not found" });
        return;
      }

      // Update interest status to accepted
      const { error: updateError } = await supabaseAdmin
        .from("plus_one_interests")
        .update({ status: "accepted" })
        .eq("id", interestId);

      if (updateError) {
        res.status(500).json({ error: updateError.message });
        return;
      }

      // Create a match record
      const chatChannelId = `match_${randomUUID()}`;

      const { data: match, error: matchError } = await supabaseAdmin
        .from("matches")
        .insert({
          user_a: userId,
          user_b: interest.user_id,
          plus_one_post_id: id,
          status: "matched",
          chat_channel_id: chatChannelId,
        })
        .select()
        .single();

      if (matchError) {
        res.status(500).json({ error: matchError.message });
        return;
      }

      res.json({ match });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * POST /api/v1/board/:id/interests/:interestId/pass
 * Pass on an interest. Auth-protected. Only the post creator can pass.
 * Updates interest status to 'passed'.
 */
router.post(
  "/:id/interests/:interestId/pass",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      const { id, interestId } = req.params;

      // Verify the post exists and the current user is the creator
      const { data: post, error: postError } = await supabaseAdmin
        .from("plus_one_posts")
        .select("id, user_id")
        .eq("id", id)
        .maybeSingle();

      if (postError) {
        res.status(500).json({ error: postError.message });
        return;
      }

      if (!post) {
        res.status(404).json({ error: "Post not found" });
        return;
      }

      if (post.user_id !== userId) {
        res
          .status(403)
          .json({ error: "Only the post creator can pass on interests" });
        return;
      }

      // Verify the interest exists
      const { data: interest, error: interestError } = await supabaseAdmin
        .from("plus_one_interests")
        .select("id")
        .eq("id", interestId)
        .eq("post_id", id)
        .maybeSingle();

      if (interestError) {
        res.status(500).json({ error: interestError.message });
        return;
      }

      if (!interest) {
        res.status(404).json({ error: "Interest not found" });
        return;
      }

      // Update interest status to passed
      const { error: updateError } = await supabaseAdmin
        .from("plus_one_interests")
        .update({ status: "passed" })
        .eq("id", interestId);

      if (updateError) {
        res.status(500).json({ error: updateError.message });
        return;
      }

      res.json({ message: "Interest passed" });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
