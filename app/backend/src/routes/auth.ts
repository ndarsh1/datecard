import { Router, Request, Response } from "express";
import { requireAuth, AuthenticatedRequest } from "../middleware/auth";

const router = Router();

/**
 * POST /api/v1/auth/phone
 * Initiate phone-based authentication (sends OTP via Supabase).
 */
router.post("/phone", async (_req: Request, res: Response) => {
  // TODO: Proxy to Supabase auth.signInWithOtp({ phone })
  res.status(501).json({ message: "Not implemented yet" });
});

/**
 * POST /api/v1/auth/verify
 * Verify the OTP code sent to the user's phone.
 */
router.post("/verify", async (_req: Request, res: Response) => {
  // TODO: Proxy to Supabase auth.verifyOtp({ phone, token })
  res.status(501).json({ message: "Not implemented yet" });
});

/**
 * POST /api/v1/auth/stream-token
 * Generate a Stream Chat token for the authenticated user.
 */
router.post(
  "/stream-token",
  requireAuth,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.userId;
      if (!userId) {
        res.status(401).json({ error: "User not authenticated" });
        return;
      }

      // TODO: Implement real Stream Chat token generation using the Stream server SDK
      // Example:
      //   import { StreamChat } from 'stream-chat';
      //   const serverClient = StreamChat.getInstance(apiKey, apiSecret);
      //   const token = serverClient.createToken(userId);
      //   res.json({ token });

      res.json({ token: "stream-token-placeholder" });
    } catch {
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

export default router;
