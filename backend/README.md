# Nucleus Backend

A minimal FastAPI stub (`/health` only) — the real services described in
[`../docs/PLAN.md`](../docs/PLAN.md) under "Recommended Architecture" (account/token vault,
metadata index, relay orchestrator, provider catalog, security service) are not implemented
yet. This exists so the Docker/setup/update workflow is real and testable before those
services land, per parabyte-ca dev-sop.

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

## Running locally

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
curl http://127.0.0.1:8000/health
```

## Docker / Linux deployment

```bash
./setup.sh   # first run: builds the image and starts the container
./update.sh  # subsequent deploys: pulls latest, rebuilds, restarts
```

Runs on port **8181** (see `dev-sop/ports.md`), proxied to container port 8000. Deployment
target is the homelab TrueNAS box; external access (if/when needed) goes through a
**Cloudflare Tunnel** rather than forwarding the port directly, matching the pattern used by
other parabyte-ca homelab services (e.g. `menu.moot.es`).
