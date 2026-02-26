# Changelog

All notable project-level changes are documented here.

This changelog captures historical implementation context that should not live in `AGENTS.md`.

## [Unreleased]

## [1.2.2] - 2026-02-26

### Documentation
- Added `CHANGELOG.md` to preserve historical engineering context.
- Added `docs/troubleshooting.md` for operational runbooks and incident triage.
- Kept `AGENTS.md` focused on agent execution guidance.
- Moved `security-checklist.md` to `docs/security-checklist.md` and updated references.

## [2025-07-28]

### Removed
- Removed webhook infrastructure after migration to GitHub Actions deployment.
- Removed webhook-related scripts, configs, and service files.

### Operational Notes
- Manual DNS cleanup required for `webhook.xbonell.com` if still present.
- Proxy restart may be needed after DNS cleanup: `docker-compose restart nginx-proxy`.

## [2025-Q3]

### Changed
- Enabled custom per-site nginx config mounts for:
  - `sites/xbonell.com/nginx.conf`
  - `sites/bgespecialitats.com/nginx.conf`
- Moved site-level `root` and error-page handling into site containers (instead of proxy vhost snippets).

### Added
- Custom 404 handling for `xbonell.com` via `/error` endpoint.
- Language-aware 404 handling for `bgespecialitats.com` (`/ca/404` and `/es/404`).

## [2025-Q3]

### Performance
- Enabled gzip compression for text-based assets on both site containers.
- Added long-term static asset caching for `bgespecialitats.com`:
  - CSS/JS/fonts/images with 1-year expiration and immutable cache control.

## [2025-Q3]

### SEO / Routing
- Switched language redirects from `302` to `301` for canonical behavior.
- Simplified `www.*` host handling to redirect-only patterns (canonical non-www).

## [2025-Q3]

### Security / Reliability
- Added health checks for proxy, acme-companion, and static site services.
- Added container log rotation (`max-size: 10m`, `max-file: 3`).
- Applied explicit CPU and memory limits in Compose for non-Swarm environments.

## [1.2.1]

### Snapshot
- Current stack is a Docker Compose reverse-proxy setup with nginx-proxy + acme-companion.
- Security-first defaults are preserved (resource limits, `no-new-privileges`, selective read-only mounts).
