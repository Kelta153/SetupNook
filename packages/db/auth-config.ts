import { createAuth } from "./auth-options.ts";

// ---------------------------------------------------------------------
// Node-only default instance. Exists ONLY for the `auth` CLI
// (`pnpm auth:generate`) to introspect config and (re)generate the
// Better-Auth-owned models in prisma/schema.prisma. The CLI resolves a
// config module by looking for a named `auth` export specifically —
// this export name is load-bearing, don't rename it. apps/api does NOT
// import this file — it imports createAuth() directly from the synced
// auth-options.ts and builds its own Deno/Neon-wired client.
import { PrismaClient } from "./generated/prisma-node/index.js";
export const auth = createAuth(new PrismaClient());
