# Cloud Storage Aggregator — Product & Architecture Plan

## Context

Users routinely spread files across several cloud providers (free tiers, employer-provided
accounts, provider-specific apps like iCloud Photos, self-hosted NAS shares) and lose track
of what lives where, pay for overlapping/underused storage, and have no easy way to shop
for a new provider on criteria that matter to them (jurisdiction, encryption model, price).
This plan defines a cross-platform app (macOS, Windows, iOS, Android, web) that gives a
single harmonized view over all connected cloud storage, lets users move/replicate/dedupe
files across providers, analyzes cost, and helps them pick new providers by sovereignty,
encryption, cost, and free-tier capacity.

This is a greenfield product. It will be built in the `parabyte-ca/nucleus` GitHub repo,
which is currently empty (no commits) — there is no existing code to build on, so this plan
defines the initial project structure from scratch. (The `truesecure` repo referenced
earlier is an unrelated existing TrueNAS security scanner and is not part of this project.)

**Decisions locked in during planning (see below for detail):**
- Sync model: **hybrid** — local-agent execution by default, optional opt-in cloud relay for background jobs.
- Stack: **Flutter** (single codebase for macOS/Windows/iOS/Android + Flutter Web).
- Business model: **freemium subscription + provider affiliate revenue** on the comparison tool.
- iCloud: **out of MVP scope** (no public file-access API — see Known Gaps).
- Launch order: **web + desktop first**, mobile as a later phase.
- Primary v1 user: **privacy/cost-conscious individual power users**, not teams/B2B.

---

## Competitive Baseline

| Product | Model | Strengths | Weaknesses |
|---|---|---|---|
| **MultCloud** | Web, server-relay, 30+ providers | Easiest cloud-to-cloud transfer/sync/backup, no install | No real desktop/mobile app, no cost analysis, no encryption overlay, no dedupe-by-cost logic |
| **CloudMounter** | Mac/Win, mounts clouds as local drives | Native Finder/Explorer feel, drag-and-drop | No scheduled replication, no cost analysis, no mobile/web |
| **Air Explorer** | Mac/Win native, 50+ providers | Strong sync modes, has basic duplicate finder, optional E2E encryption | Dated UI, no mobile/web, dedupe isn't cost-aware, no provider-discovery tool |
| **Odrive** | Desktop virtual filesystem | Unified local folder across providers, placeholder/on-demand files | Development has stagnated, no mobile parity, no cost analysis |
| **rclone** | CLI, 40+ backends | The most robust open transfer engine that exists; scriptable | No GUI, no mobile, no automation UI — a power-user tool, not a product |

**Gaps every competitor shares** (= your differentiation opportunities):
1. **No cost intelligence.** Nobody analyzes your actual usage against your subscriptions to tell you the cheapest way to store what you have, or ties duplicate-detection to "keep the copy on the cheapest provider."
2. **No new-account discovery/comparison tool.** Choosing a *new* provider by sovereignty/encryption/price today means reading blog comparisons (cloudwards.net, priviy.com) by hand — nobody builds this into the account-management tool itself.
3. **No real cross-platform parity.** Every competitor above is desktop-only or web-only; none has a genuinely full-featured mobile app.
4. **No uniform client-side encryption layer.** Tools like Cryptomator add E2E encryption but don't aggregate; aggregators aggregate but don't add encryption. Nobody does both.
5. **No security posture.** None audit public share-links for exposure or watch for ransomware-pattern file changes across connected accounts — a natural extension given your security-tooling background.
6. **No backup-policy framing.** "Automatic replication" exists as raw sync jobs, but nobody productizes it as a 3-2-1 backup wizard.

**Your differentiators to lead with:** cost/dedupe intelligence, a security-first posture (share-link audit, anomaly detection, optional E2E overlay), an integrated sovereignty-aware provider-shopping tool, and true native parity across all 5 surfaces.

---

## Recommended Architecture

**Transfer engine: build on `rclone`, don't reimplement per-provider clients.**
rclone (MIT-licensed) already implements OAuth + transfer logic for Google Drive, OneDrive,
Dropbox, Box, Mega, pCloud, WebDAV, S3, and 40+ other backends, and exposes an embeddable
`librclone` binding plus an `rclone rc` JSON-RPC daemon mode. Building the harmonized-view /
dedupe / cost-analysis / UI layer *on top of* rclone turns "8+ provider integrations" from a
multi-quarter effort into a wrapper + product layer — this is the single biggest
scope-reduction decision available. Providers rclone doesn't support well (sync.com's newer
API surface, Proton Drive, Filen, Drime) get thin custom adapters behind the same internal
interface, added incrementally.

**Client:** Flutter app targeting macOS, Windows, iOS, Android, and Flutter Web. Desktop
builds add a system-tray/menu-bar background process that runs the local rclone-based agent.

**Sync/replication model — hybrid:**
- *Local-agent mode (default):* the desktop/mobile app runs rclone jobs directly; provider
  tokens stay on-device; replication only runs while the app/agent is running.
- *Cloud-relay mode (opt-in, per job):* a backend service holds a narrowly-scoped, encrypted
  copy of the OAuth token for that specific job and runs the transfer server-side (via the
  same rclone engine, hosted), so scheduled replication keeps working with the device off.
  This is the bigger trust/liability surface, so it must be explicit opt-in per provider/job,
  never a silent default.

**Backend services (only needed for relay mode, the harmonized index, and the discovery tool):**
- *Account/token vault* — envelope-encrypted OAuth tokens, least-privilege scopes where a
  provider supports them (e.g. Google Drive's `drive.file` scope).
- *Metadata index* — harmonized file index (path, provider, size, hash, mtime) built from
  each linked account; powers the harmonized view, dedupe, and cross-provider search without
  necessarily storing file contents server-side.
- *Job/relay orchestrator* — queue-based execution of opted-in background replication jobs.
- *Provider catalog service* — curated, periodically-verified dataset of provider plans,
  pricing, free-tier size, jurisdiction, and encryption model; feeds both the cost-analysis
  feature and the new-account discovery tool.
- *Security service* — share-link exposure audits, anomaly/ransomware-pattern detection over
  metadata deltas.

**Deployment target:** self-hosted on the owner's TrueNAS box, not a third-party cloud host —
consistent with the rest of the parabyte-ca homelab (AutoRrent, Francine, The Menu, etc.).
Backend services run as Docker containers there (see `backend/setup.sh`/`update.sh`, port
`8181` reserved in `dev-sop/ports.md`). The webapp and any backend API endpoints that need
external access are exposed via a **Cloudflare Tunnel** rather than direct port-forwarding —
the same pattern already used for other homelab services (e.g. `menu.moot.es`). This
actually improves the cloud-relay trust story from the "Sync/replication model" tradeoff
above: the OAuth token vault lives on hardware the user themselves controls, not a
third-party SaaS vendor's infrastructure, which meaningfully lowers the stakes of the
"biggest trust/liability surface" concern called out there. Practical implications:
- No public cloud infra cost/ops burden for the backend in early phases.
- The Flutter web build needs a place to be served — either a static file host alongside the
  API (nginx, matching the `website-lantix`/`website-postnorth` pattern) or served directly
  by the backend, fronted by its own Cloudflare Tunnel hostname.
- Availability is bounded by the homelab's own uptime (no multi-region failover) — acceptable
  for the individual-power-user MVP target, worth revisiting only if/when this grows beyond
  a single self-hosted user base.

---

## Core Features (as requested)

1. **Harmonized file view** — single tree/grid across all connected providers; every file
   shows a provider badge/flag; filter/group by provider, duplicate status, or "at risk"
   (e.g. publicly shared).
2. **Cross-provider copy** — pick a file/folder, choose a destination provider; executed via
   the rclone engine (server-side copy where the provider API supports it, otherwise
   streamed through the agent/relay).
3. **Automatic replication** — user-defined rules ("mirror folder X from A to B on schedule
   / on change"), executed locally by default, or via relay if the user opts a rule into
   background mode.
4. **Duplicate detection + cheapest-copy resolution** — hash-based exact-duplicate scan
   across all linked accounts; when duplicates are found, cross-reference the provider
   catalog service to recommend which copy to keep based on the user's actual plan costs
   (not just "keep the newest").
5. **Cost analysis** — ingest the user's connected plans + actual usage per provider, compare
   against the provider catalog (including tier breakpoints), and surface concrete
   recommendations ("downgrade OneDrive to the 100GB tier and consolidate onto pCloud to
   save $X/yr").

---

## Additional Feature Ideas (ranked)

| Feature | Value | Difficulty | Priority |
|---|---|---|---|
| Storage quota/renewal-date dashboard with alerts | High | Low | P0 (MVP) |
| Cost-optimization recommendations (you're overpaying for unused quota) | High | Low–Med | P0 (MVP) |
| Migration wizard (bulk "leave this provider" flow) | High | Low–Med | P1 |
| Backup-policy templates (3-2-1 rule wizard on top of replication) | High | Med | P1 |
| Unified cross-provider search (filename/metadata) | High | Med | P1 |
| Public share-link security audit (find & flag exposed links) | High | Med | P1 |
| Ransomware/anomaly detection (mass-encrypt pattern → alert, pause sync) | High | Med–High | P2 |
| Client-side E2E encryption overlay (Cryptomator-compatible vaults) | High | High | P2 |
| Selective sync / on-demand local caching across all providers | High | High | P2 |
| Smart tiering / auto-archival of cold files to cheapest provider | High | High | P3 |
| Perceptual-hash photo/screenshot dedupe (not just exact matches) | Med | High | P3 |
| Family/multi-account plan-consolidation optimizer | Med | Med | P3 |
| Browser extension: "save this download to my preferred cloud" | Med | Low | P2 |
| CLI companion for power users (thin wrapper over the same engine) | Med | Low | P2 |
| Universal trash/recycle bin view + recovery across providers | Med | Med | P2 |
| Breach/dark-web monitoring tied to connected provider accounts | Med | Low–Med | P3 |
| Zapier/Make/webhook automation triggers | Low–Med | Low | P3 |

---

## Provider Discovery / Sovereignty Tool

A sortable/filterable comparison table for users choosing a **new** account, backed by the
same provider catalog service used for cost analysis. Suggested dimensions beyond what you
listed (sovereignty, encryption, cost, free tier):

- Data-center jurisdiction / legal exposure (e.g. US CLOUD Act vs. EU/Swiss vs. Canadian residency)
- Encryption model detail: none / server-side-only / zero-knowledge / zero-knowledge-but-not-on-shared-links (a real gap even in "zero-knowledge" providers like Sync.com and pCloud)
- Open-source client availability (independently auditable, e.g. Filen)
- Post-quantum encryption roadmap
- Compliance certifications (GDPR, HIPAA, SOC 2)
- File size limits and versioning/retention window
- Bandwidth/API rate limits (relevant to *our* automation features working well on that provider)
- Family/multi-user plan pricing, not just individual tiers
- Data portability/export ease (ironic but real — how hard is it to leave)
- Provider API availability (whether we can even integrate at all — flag providers we can't support yet, e.g. iCloud, Proton Drive)
- Signup bonus / referral bonus size (ties into affiliate monetization)
- Track record: uptime history, company stability/ownership changes

---

## MVP Provider List & Known Gaps

**MVP (rclone-backed):** Google Drive, OneDrive, Dropbox, Box, Mega, sync.com, pCloud,
self-hosted (WebDAV / Nextcloud / Seafile / generic S3-compatible incl. MinIO).

**Explicitly out of MVP, flagged as research spikes:**
- **iCloud** — Apple exposes no general-purpose file API (CloudKit is app-sandboxed; the
  Files picker is one-file-at-a-time). Per your decision, skipped for MVP. A macOS/iOS-only
  fast-follow could treat the local iCloud Drive folder (synced by the OS itself) as a
  pseudo-provider for view/copy purposes, but this is filesystem-based, not API-based, and
  won't work on Windows/Android or via the relay.
- **Proton Drive** — no public third-party API today either; same category of risk as
  iCloud. Needs a feasibility spike before committing to a phase.
- **Drime, Filen** — newer providers; check rclone backend support (Filen has some
  community support in progress) vs. needing a thin custom adapter.

---

## Business Model

Freemium: free tier covers 2 connected accounts, manual copy, one-shot dedupe scan, and the
cost/quota dashboard. Paid tier unlocks unlimited accounts, scheduled replication rules,
relay-mode (offline) execution, and the advanced security features (P1/P2 above). The
provider discovery/comparison tool carries affiliate links; recommendations must be
computed from the same objective catalog data used for cost analysis (not biased toward
affiliate partners) to preserve trust — this should be a stated principle in the product,
not just an implementation detail.

---

## Phased Roadmap

**Phase 0 — Engine spike:** validate rclone (via `librclone`/`rclone rc`) against each MVP
provider's actual OAuth/consent flow and server-side-copy support from within a Flutter
shell; validate the hashing strategy for dedupe against a real multi-provider test dataset.

**Phase 1 — MVP (web + desktop, individual power users):** harmonized view, manual
cross-provider copy, exact-hash dedupe with cost-aware "keep cheapest" suggestion, cost
analysis dashboard, provider discovery/comparison tool, local-agent-only scheduled
replication (single "mirror folder A→B" job type). Freemium gating live from day one.

**Phase 2 — Desktop/web fast-follow:** opt-in cloud-relay for offline replication, quota/
renewal alerts, migration wizard, 3-2-1 backup templates, share-link security audit,
affiliate tracking wired into the comparison tool.

**Phase 3 — Mobile:** iOS/Android Flutter apps — camera-roll auto-upload, harmonized
browse/search, manual copy, push alerts; scheduled replication relies on relay mode (mobile
background execution isn't reliable enough to be the source of truth). Revisit iCloud via
the local-folder bridge specifically here.

**Phase 4 — Advanced:** ransomware/anomaly detection, client-side E2E encryption overlay,
perceptual-hash photo dedupe, smart tiering/auto-archival.

---

## Verification

Since this is a greenfield build, "verification" at each phase means:
1. Phase 0 spike must produce a working OAuth-connect → list-files → copy-file round trip
   against every MVP provider from an actual Flutter desktop build before Phase 1 starts.
2. Dedupe hashing validated against a hand-built test dataset with known duplicates spread
   across ≥3 providers, confirming correct "cheapest to keep" recommendations against sample
   pricing data.
3. Provider catalog data spot-checked against each provider's current published pricing page
   before the discovery tool ships (pricing changes; this needs a refresh process, not a
   one-time import).
4. End-to-end manual test on macOS, Windows, and web builds (connect real test accounts on
   at least 3 providers, run a harmonized view, a cross-provider copy, a dedupe scan, and a
   scheduled replication job) before calling Phase 1 "done" — per the run/browser-testing
   guidance, this must be exercised in the real app, not just unit-tested.
