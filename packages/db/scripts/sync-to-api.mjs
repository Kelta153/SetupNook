import { copyFileSync, mkdirSync, rmSync, existsSync } from "node:fs";
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

// Prisma's engine cache re-copies the locally-detected "native" binary
// into this generator's output on every generate, even though
// client_deno's binaryTargets only declares "debian-openssl-3.0.x" —
// observed behavior, not something binaryTargets alone stops. That
// binary can never run on Deno Deploy (Debian-only containers) and adds
// ~21MB of dead weight to every deploy upload, so delete it explicitly.
const deadWindowsBinary = join(destDir, "prisma-deno", "query_engine-windows.dll.node");
if (existsSync(deadWindowsBinary)) {
  rmSync(deadWindowsBinary);
  console.log(`Removed dead binary -> ${deadWindowsBinary}`);
}
