import { Request, Response, NextFunction } from "express";

/**
 * Extends Express Request to include authenticated user ID.
 */
export interface AuthenticatedRequest extends Request {
  userId?: string;
}

/**
 * Middleware that verifies the Supabase JWT from the Authorization header
 * and attaches the userId to the request object.
 */
export async function requireAuth(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    res.status(401).json({ error: "Missing or invalid Authorization header" });
    return;
  }

  const token = authHeader.split(" ")[1];

  try {
    // TODO: Verify the JWT using Supabase
    // import { supabaseAdmin } from "../services/supabase";
    // const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
    // if (error || !user) {
    //   res.status(401).json({ error: "Invalid or expired token" });
    //   return;
    // }
    // req.userId = user.id;

    // Stub: extract user ID from token payload without verification
    // Replace this with real verification above before going to production
    const payloadBase64 = token.split(".")[1];
    if (!payloadBase64) {
      res.status(401).json({ error: "Malformed token" });
      return;
    }

    const payload = JSON.parse(Buffer.from(payloadBase64, "base64").toString());
    req.userId = payload.sub as string;

    next();
  } catch {
    res.status(401).json({ error: "Token verification failed" });
  }
}
