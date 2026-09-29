import { copyFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const destDir = join(root, "..", "..", "..", "apps", "api", "generated");
mkdirSync(destDir, { recursive: true });
// Sync auth-options.ts, NOT auth-config.ts — auth-config.ts additionally
// imports the Node-targeted Prisma client for the `auth` CLI's own use,
// which doesn't exist at the right relative path once copied, and isn't
// needed by apps/api anyway (it builds its own Deno/Neon-wired client).
copyFileSync(join(root, "..", "auth-options.ts"), join(destDir, "auth-options.ts"));
console.log(`Synced auth-options.ts -> ${join(destDir, "auth-options.ts")}`);

// Deliberately NOT stripping the local-platform engine binary here — this
// same generated client is what apps/api's local dev (`deno task dev`)
// loads directly, so it needs a working engine for whatever OS you're
// developing on. The dead binary is stripped explicitly, only right
// before deploying, by scripts/strip-deploy-binaries.mjs (see apps/api's
// README for when to run it).
