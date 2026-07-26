# Changelog

## [0.2.0] - 2026-07-26
### Added
- `backend/` — minimal FastAPI stub (`/health` endpoint) with a `Dockerfile`, `setup.sh`,
  and `update.sh` for Linux Docker deployment, following parabyte-ca dev-sop conventions.
  Verified by running the app directly (venv + uvicorn); the Docker image build itself
  couldn't be verified in the dev sandbox (egress policy blocks Docker Hub's CDN there) but
  should build normally on a real Docker host.

## [0.1.0] - 2026-07-26
### Added
- Initial project scaffold: README, CHANGELOG, VERSION, `.gitignore`.
- `docs/PLAN.md` — full product & architecture plan (competitive baseline, feature backlog,
  phased roadmap).
- `app/` — Flutter multi-platform client shell (macOS, Windows, web, Linux) with a
  placeholder harmonized-view home screen.
- `backend/README.md` — planned backend services design (account vault, metadata index,
  relay orchestrator, provider catalog, security service).
