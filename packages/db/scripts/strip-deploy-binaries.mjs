// Run this ONLY right before `deno deploy` — not part of the regular
// `generate` script, since apps/api's local dev needs the local-platform
// engine binary intact (see sync-to-api.mjs). Deno Deploy's containers
// are always Debian Linux, so every other platform's engine binary is
// dead weight for the actual upload — leaving them in inflates the
// upload size and build memory usage for nothing.
import { existsSync, readdirSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const prismaDenoDir = join(root, "..", "..", "..", "apps", "api", "generated", "prisma-deno");

if (!existsSync(prismaDenoDir)) {
  console.error(`Not found: ${prismaDenoDir} — run "pnpm --filter @setupnook/db generate" first.`);
  process.exit(1);
}

const keep = "libquery_engine-debian-openssl-3.0.x.so.node";
const enginePattern = /^(query_engine|libquery_engine)-.*\.node$/;

for (const file of readdirSync(prismaDenoDir)) {
  if (enginePattern.test(file) && file !== keep) {
    rmSync(join(prismaDenoDir, file));
    console.log(`Stripped non-Debian engine binary -> ${file}`);
  }
}
