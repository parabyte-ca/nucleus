# Nucleus

> A cross-platform cloud storage aggregator: one harmonized view, copy/replicate/dedupe across providers, and cost-aware provider comparison.

![Version](https://img.shields.io/badge/version-0.2.0-blue)

## Overview

Nucleus lets you manage all your cloud storage accounts (Google Drive, OneDrive, Dropbox,
Box, Mega, sync.com, pCloud, self-hosted WebDAV/S3/Nextcloud, and more) through a single
interface on macOS, Windows, iOS, Android, and the web. It shows one harmonized file view
across every connected provider, lets you copy or automatically replicate files between
them, finds duplicates and recommends keeping the cheapest copy, and analyzes your actual
usage against subscription costs to suggest savings. It also includes a sovereignty/
encryption/cost comparison tool for choosing new providers.

See [`docs/PLAN.md`](docs/PLAN.md) for the full product & architecture plan, including the
competitive baseline, ranked feature backlog, and phased roadmap this project follows.

**Status:** Phase 0 — initial project scaffold. No functional sync/transfer engine yet.

## Features

- [ ] Harmonized file view across all connected providers, with per-file provider badges
- [ ] Cross-provider copy
- [ ] Scheduled/automatic replication between providers
- [ ] Duplicate detection with cost-aware "keep cheapest" recommendation
- [ ] Cost analysis dashboard (usage vs. subscription cost, savings suggestions)
- [ ] Provider discovery/comparison tool (sovereignty, encryption, price, free tier)
- [x] Backend API stub (`/health`) with Docker deployment (`setup.sh`/`update.sh`)

## Requirements

- Flutter 3.x (stable channel) — client app
- Docker — backend services (Phase 2+)

## Setup

Client (Flutter app):

```bash
cd app
flutter pub get
flutter run -d macos   # or windows / chrome / linux
```

Backend (Docker, Linux):

```bash
cd backend
./setup.sh   # first run
```

See [`backend/README.md`](backend/README.md) — only a `/health` stub today, the real
services are planned per `docs/PLAN.md`.

## Update

Backend: `cd backend && ./update.sh`.

## Configuration

No environment variables yet. Provider OAuth client IDs/secrets and backend endpoints will
be documented here once the account-linking flow is implemented (Phase 1).

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## License

TBD.
