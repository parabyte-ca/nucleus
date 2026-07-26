# Nucleus Backend (planned)

Not implemented yet. This directory is a placeholder for the services described in
[`../docs/PLAN.md`](../docs/PLAN.md) under "Recommended Architecture", needed starting
Phase 1 (harmonized index, provider catalog) and Phase 2 (cloud-relay mode).

## Planned services

- **Account/token vault** — envelope-encrypted OAuth tokens, least-privilege provider scopes.
- **Metadata index** — harmonized file index (path, provider, size, hash, mtime) powering the
  harmonized view, dedupe, and cross-provider search.
- **Job/relay orchestrator** — queue-based execution of opted-in background replication jobs,
  built on the same `rclone` engine the client uses.
- **Provider catalog service** — curated, periodically-verified provider pricing/jurisdiction/
  encryption dataset feeding cost analysis and the discovery tool.
- **Security service** — public share-link exposure audits, ransomware-pattern anomaly
  detection over metadata deltas.

## Planned port

Reserved: **8181** (`nucleus-api`) — see `dev-sop/ports.md`. Not yet running.

## Conventions

Once implemented, this service follows parabyte-ca dev-sop: `Dockerfile` at its own root,
`setup.sh`/`update.sh` for first-run and incremental deploys, SemVer tracked in its own
`VERSION` file, changes logged in the root `CHANGELOG.md`.
