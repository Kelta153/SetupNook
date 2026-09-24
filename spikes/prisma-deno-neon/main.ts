// Spike: does Prisma + @prisma/adapter-neon actually work on Deno Deploy's
// real edge isolate? This is the exact combo the SetupNooK API needs, since
// Deploy's runtime restricts plain TCP (only Neon's HTTP/WebSocket driver
// gets through) AND can't load native .dll/.so binaries (so we must force
// Prisma's WASM query engine, not its default native one).
//
// Deploy requires an HTTP handler as the entrypoint — a run-once script
// with no listener has nothing for the platform to route requests to,
// which is why the first deploy failed with "no entrypoint".

import { createRequire } from "node:module";
import { PrismaNeon } from "@prisma/adapter-neon";
import { neonConfig } from "@neondatabase/serverless";

// Deno's CJS->ESM interop only applies to npm-resolved modules, not local
// relative files — a bare `import` of this generated CJS client statically
// resolves to zero exports. createRequire runs it through actual Node
// require() semantics instead, which returns the real (dynamic) exports.
// index.js is the one variant already confirmed (locally) to do a full,
// real create/read/write cycle against Neon end to end. Whether Deploy's
// isolate can actually load whatever engine it pulls in (native binary vs
// wasm) is the open question this deploy is meant to answer directly,
// rather than guessing at it from wasm.js/edge.js in the abstract.
const require = createRequire(import.meta.url);
const { PrismaClient } = require("./generated/prisma/index.js");

const databaseUrl = Deno.env.get("DATABASE_URL");
if (!databaseUrl) {
  throw new Error("DATABASE_URL is not set. Configure it as a Deploy env var.");
}

neonConfig.webSocketConstructor = WebSocket;

const adapter = new PrismaNeon({ connectionString: databaseUrl });
const prisma = new PrismaClient({ adapter });

async function runSpike(): Promise<Record<string, unknown>> {
  const raw = await prisma.$queryRaw`select now() as now, version() as pg_version`;

  const created = await prisma.spikeCheck.create({
    data: { note: `edge spike run at ${new Date().toISOString()}` },
  });

  const recent = await prisma.spikeCheck.findMany({
    orderBy: { createdAt: "desc" },
    take: 5,
  });

  return { raw, created, recent };
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  if (url.pathname !== "/spike") {
    return new Response("SetupNooK Prisma+Deno Deploy+Neon spike. GET /spike to run it.", {
      status: 200,
    });
  }

  try {
    const result = await runSpike();
    return Response.json({ ok: true, ...result }, { status: 200 });
  } catch (err) {
    console.error(err);
    return Response.json(
      { ok: false, error: err instanceof Error ? err.message : String(err), stack: err instanceof Error ? err.stack : undefined },
      { status: 500 },
    );
  }
});
