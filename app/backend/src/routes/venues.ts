import { Router, Request, Response } from "express";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * GET /api/v1/venues/:id
 * Fetch a venue by ID, including its packages.
 */
router.get("/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const { data: venue, error } = await supabaseAdmin
      .from("venues")
      .select("*, venue_packages(*)")
      .eq("id", id)
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        res.status(404).json({ error: "Venue not found" });
        return;
      }
      res.status(500).json({ error: error.message });
      return;
    }

    res.json({ venue });
  } catch {
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * GET /api/v1/venues/:id/packages
 * Fetch all packages for a venue.
 */
router.get("/:id/packages", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const { data: packages, error } = await supabaseAdmin
      .from("venue_packages")
      .select("*")
      .eq("venue_id", id);

    if (error) {
      res.status(500).json({ error: error.message });
      return;
    }

    res.json({ packages: packages ?? [] });
  } catch {
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
