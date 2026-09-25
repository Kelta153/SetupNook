// apps/api entrypoint — both the local dev server (`deno task dev`) and
// the file set as this app's entrypoint in the Deno Deploy dashboard.
// (deno.json's `deploy.runtime.entrypoint` is NOT reliably honored by
// the current pre-1.0 `deno deploy` CLI — confirmed by two real deploy
// tests during the prisma-deno-neon spike. Set it in the dashboard.)
//
// ./generated/prisma-deno and ./generated/auth-options.ts are NOT
// hand-edited here — they're produced by
// `pnpm --filter @setupnook/db generate` (run from repo root).

import { createRequire } from "node:module";
import { PrismaNeon } from "@prisma/adapter-neon";
import { neonConfig } from "@neondatabase/serverless";
import { createAuth } from "./generated/auth-options.ts";

// Deno's CJS->ESM interop only applies to npm-resolved modules, not
// local relative files — a bare `import` of this generated CJS client
// statically resolves to zero exports. createRequire runs it through
// real Node require() semantics instead (proven in the spike).
const require = createRequire(import.meta.url);
const { PrismaClient } = require("./generated/prisma-deno/index.js");

const databaseUrl = Deno.env.get("DATABASE_URL");
if (!databaseUrl) {
  throw new Error("DATABASE_URL is not set. Configure it as a Deploy env var (or in .env for local dev).");
}

neonConfig.webSocketConstructor = WebSocket;
const adapter = new PrismaNeon({ connectionString: databaseUrl });
const prisma = new PrismaClient({ adapter });

const auth = createAuth(prisma, {
  secret: Deno.env.get("BETTER_AUTH_SECRET"),
  baseURL: Deno.env.get("BETTER_AUTH_URL"),
});

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);

  if (url.pathname === "/health") {
    try {
      await prisma.$queryRaw`select 1`;
      return Response.json({ ok: true, service: "setupnook-api", db: "reachable" });
    } catch (err) {
      console.error("health check DB failure:", err);
      return Response.json({ ok: false, service: "setupnook-api", db: "unreachable" }, { status: 503 });
    }
  }

  if (url.pathname.startsWith("/api/auth")) {
    return auth.handler(req);
  }

  return new Response("Not found", { status: 404 });
});
