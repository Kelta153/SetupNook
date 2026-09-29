import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";

// better-auth's own type for this parameter is an intentionally-empty
// structural interface (`interface PrismaClient {}` in
// @better-auth/prisma-adapter) — it duck-types at runtime and doesn't
// care which concrete generated client you pass. Reusing that same
// (already-generic) type here means this factory works unmodified with
// both apps/api's Deno/Neon-adapter-wired client and the plain
// node-targeted client used by jobs/ or auth-config.ts's CLI-only instance.
type PrismaClientLike = Parameters<typeof prismaAdapter>[0];

export interface CreateAuthOptions {
  /** Session/cookie signing secret. Required in production. */
  secret?: string;
  /** Public URL this auth instance is served from. */
  baseURL?: string;
  /**
   * Origins allowed to make credentialed requests against this auth
   * instance (Better Auth's own request-origin check — NOT the browser
   * CORS headers; those are set separately in apps/api/main.ts because
   * trustedOrigins alone doesn't emit Access-Control-Allow-Origin/
   * -Credentials or handle OPTIONS preflight — see
   * better-auth/better-auth#4052, #4343).
   */
  trustedOrigins?: string[];
}

/**
 * Shared Better Auth configuration. Every runtime (apps/api on Deno,
 * jobs/ or local tooling on Node) builds its OWN Prisma client — wired
 * for whatever driver adapter that runtime needs — and passes it in
 * here. This file only owns the *options*, never a concrete PrismaClient
 * instance or env access, so nothing here assumes a runtime — that's
 * also why this is a separate file from auth-config.ts: this one is
 * synced verbatim into apps/api/generated/ and must not contain any
 * Node-specific (or otherwise runtime-specific) imports.
 */
export function createAuth(prisma: PrismaClientLike, options: CreateAuthOptions = {}) {
  return betterAuth({
    database: prismaAdapter(prisma, {
      provider: "postgresql",
    }),
    emailAndPassword: {
      enabled: true,
    },
    secret: options.secret,
    baseURL: options.baseURL,
    trustedOrigins: options.trustedOrigins,
    advanced: {
      // apps/web and apps/api are permanently on unrelated domains
      // (Cloudflare Pages vs Deno Deploy), not subdomains of a shared
      // parent — so the session cookie must be SameSite=None; Secure or
      // it won't be attached to cross-site fetch() calls at all.
      defaultCookieAttributes: {
        sameSite: "none",
        secure: true,
      },
    },
  });
}
