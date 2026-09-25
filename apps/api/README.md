# SetupNooK API

Deno Deploy project. Separate from the pnpm workspace by design (see repo
root kickoff docs) — own `deno.json`, own dependency resolution.

## Before first run or deploy

Regenerate the Prisma client and sync the auth config from `packages/db`
(this project doesn't own either — they're generated/copied in):

```bash
# from repo root
pnpm --filter @setupnook/db generate
```

This produces `apps/api/generated/prisma-deno/` and
`apps/api/generated/auth-config.ts`, both gitignored.

## Local dev

```bash
cp .env.example .env   # fill in real values
deno task dev
```

## Deploying

Use the `deno deploy` CLI (not legacy `deployctl` — different platform,
incompatible auth token).

**Known bug**: `deno.json`'s `deploy.runtime.entrypoint` field is not
reliably honored by the current pre-1.0 `deno deploy` CLI. Set the
entrypoint (`main.ts`) via the Deno Deploy **web dashboard** — App
Configuration → Runtime Configuration → Entrypoint — not via `deno.json`.

```bash
deno deploy --app setupnook-api --json --non-interactive .
```
