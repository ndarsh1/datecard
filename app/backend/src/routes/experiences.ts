import { Router, Request, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * GET /api/v1/experiences
 * List available date experiences.
 * Supports ?category=, ?limit=, ?offset= query params.
 */
router.get("/", async (req: Request, res: Response) => {
  try {
    const { category, limit, offset } = req.query;

    const pageLimit = limit ? parseInt(limit as string, 10) : 20;
    const pageOffset = offset ? parseInt(offset as string, 10) : 0;

    let query = supabaseAdmin
      .from("date_experiences")
      .select("*")
      .order("created_at", { ascending: false })
      .range(pageOffset, pageOffset + pageLimit - 1);

    if (category && typeof category === "string") {
      query = query.eq("category", category);
    }

    const { data, error } = await query;

    if (error) {
      res.status(500).json({ error: error.message });
      return;
    }

    res.json({ experiences: data });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * GET /api/v1/experiences/:id
 * Get a single experience by ID.
 */
router.get("/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabaseAdmin
      .from("date_experiences")
      .select("*")
      .eq("id", id)
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        res.status(404).json({ error: "Experience not found" });
        return;
      }
      res.status(500).json({ error: error.message });
      return;
    }

    res.json({ experience: data });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * POST /api/v1/experiences/:id/optin
 * Opt in to a specific experience. Requires auth.
 */
router.post(
  "/:id/optin",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;
      const userId = req.userId;

      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      // Check that the experience exists
      const { data: experience, error: expError } = await supabaseAdmin
        .from("date_experiences")
        .select("id")
        .eq("id", id)
        .single();

      if (expError || !experience) {
        res.status(404).json({ error: "Experience not found" });
        return;
      }

      // Insert opt-in record
      const { error: optInError } = await supabaseAdmin
        .from("opt_ins")
        .insert({ user_id: userId, experience_id: id });

      if (optInError) {
        // Unique constraint violation means user already opted in
        if (optInError.code === "23505") {
          res
            .status(409)
            .json({ error: "You have already opted in to this experience" });
          return;
        }
        res.status(500).json({ error: optInError.message });
        return;
      }

      // Increment opt_in_count on the experience
      const { error: updateError } = await supabaseAdmin.rpc("increment", {
        row_id: id,
        table_name: "date_experiences",
        column_name: "opt_in_count",
      });

      // Fallback: if the RPC doesn't exist, do a manual increment
      if (updateError) {
        const { data: current } = await supabaseAdmin
          .from("date_experiences")
          .select("opt_in_count")
          .eq("id", id)
          .single();

        const newCount = ((current as { opt_in_count: number } | null)?.opt_in_count ?? 0) + 1;

        await supabaseAdmin
          .from("date_experiences")
          .update({ opt_in_count: newCount })
          .eq("id", id);
      }

      res.status(201).json({ message: "Opted in successfully" });
    } catch (err) {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

/**
 * GET /api/v1/experiences/:id/pool
 * Get the pool of users who opted in to this experience.
 * Requires the requesting user to have also opted in.
 */
router.get(
  "/:id/pool",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;
      const userId = req.userId;

      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      // Verify the requesting user has opted in
      const { data: userOptIn, error: checkError } = await supabaseAdmin
        .from("opt_ins")
        .select("id")
        .eq("user_id", userId)
        .eq("experience_id", id)
        .single();

      if (checkError || !userOptIn) {
        res
          .status(403)
          .json({ error: "You must opt in to this experience to view the pool" });
        return;
      }

      // Fetch all users who opted in, joining with the users table
      const { data: optIns, error: poolError } = await supabaseAdmin
        .from("opt_ins")
        .select(
          "user_id, users(id, first_name, last_name, avatar_url, bio)"
        )
        .eq("experience_id", id);

      if (poolError) {
        res.status(500).json({ error: poolError.message });
        return;
      }

      const pool = (optIns ?? []).map((entry: Record<string, unknown>) => entry.users);

      res.json({ pool });
    } catch (err) {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
