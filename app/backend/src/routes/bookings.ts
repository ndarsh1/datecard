import { Router, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";
import { supabaseAdmin } from "../services/supabase";

const router = Router();

/**
 * POST /api/v1/bookings
 * Create a booking for a date experience.
 * Body: { venue_id, package_id, match_id?, amount_cents }
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

      const { venue_id, package_id, match_id, amount_cents } = req.body;

      if (!venue_id || !package_id || amount_cents == null) {
        res
          .status(400)
          .json({ error: "venue_id, package_id, and amount_cents are required" });
        return;
      }

      if (typeof amount_cents !== "number" || amount_cents < 0) {
        res.status(400).json({ error: "amount_cents must be a non-negative number" });
        return;
      }

      const { data: booking, error } = await supabaseAdmin
        .from("bookings")
        .insert({
          user_id: userId,
          venue_id,
          package_id,
          match_id: match_id ?? null,
          amount_cents,
          status: "pending",
        })
        .select()
        .single();

      if (error) {
        res.status(500).json({ error: error.message });
        return;
      }

      // TODO: Replace with real Stripe PaymentIntent creation
      const clientSecret = `pi_stub_${booking.id}_secret_placeholder`;

      res.status(201).json({ booking, client_secret: clientSecret });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
