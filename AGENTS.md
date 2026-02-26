# AGENTS.md

Agent-facing guide for working in `outer-rim`.

## 1) Project Overview
Outer Rim is a Docker Compose reverse proxy stack:
- `nginxproxy/nginx-proxy` routes by `VIRTUAL_HOST`
- `nginxproxy/acme-companion` manages Let's Encrypt certs
- static nginx site containers for `xbonell.com` and `bgespecialitats.com`
Primary goals: simple multi-domain hosting, automatic HTTPS, security-first defaults.

## 2) Rule Sources (Cursor/Copilot)
Checked for additional AI rules in:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`
Current status: no Cursor/Copilot rule files exist in this repository.
If any of those files are added later, treat them as additional constraints and update this file.

## 3) Repo Map
- `docker-compose.yml`: core runtime definition
- `setup.sh`: bootstrap/validation script for local or server setup
- `env.example`: template environment variables
- `nginx/vhost.d/*.com`: proxy-level nginx snippets (redirects, headers)
- `sites/*/nginx.conf`: per-site nginx server config mounted into site containers
- `docs/security-checklist.md`: operational security checklist
- `README.md`: user docs and ops references
- `CHANGELOG.md`: historical project changes and migrations
- `docs/troubleshooting.md`: operational troubleshooting runbook

## 3.1) Docs Structure (Source of Truth)
- `AGENTS.md`: instructions for coding agents (execution workflow, style, safety guardrails).
- `README.md`: human-facing setup and usage documentation.
- `CHANGELOG.md`: historical changes and migration notes.
- `docs/troubleshooting.md`: runbook for diagnosis and recovery.
- `docs/security-checklist.md`: recurring security review checklist.
- Keep `AGENTS.md` concise; move long historical/operational narratives into `CHANGELOG.md` or `docs/`.

## 4) Build / Lint / Test Commands
This repo has no unit-test framework (no Jest/Pytest/Go test/etc.). Validation is infra/config-oriented.

### Core Commands
```bash
# Validate Compose syntax and interpolation
docker-compose config

# Pull images (acts as dependency refresh)
docker-compose pull

# Start or recreate services
docker-compose up -d

# Service/process status (includes health)
docker-compose ps

# Follow logs for all services
docker-compose logs -f
```

### Lint-Like Checks
```bash
# Validate proxy container nginx config
docker-compose exec nginx-proxy nginx -t

# Validate xbonell site nginx config
docker-compose exec xbonell.com nginx -t

# Validate bgespecialitats site nginx config
docker-compose exec bgespecialitats.com nginx -t

# Validate setup script syntax
bash -n setup.sh
```

### Single-Test Equivalents (target one thing)
Use these when an agent asks to "run one test" in this repo.
```bash
# 1) Single service config validation (closest to one test)
docker-compose exec nginx-proxy nginx -t

# 2) Single service health/status check
docker-compose ps nginx-proxy

# 3) Single endpoint smoke check (replace domain)
curl -I https://xbonell.com

# 4) Single service logs tail
docker-compose logs --tail=50 xbonell.com
```

### SSL/Certificate Verification
```bash
# ACME companion logs
docker-compose logs acme-companion

# List certificates from inside companion
docker exec acme-companion acme.sh --list
```

## 5) Change Workflow for Agents
1. Read related config before editing (`docker-compose.yml`, target `nginx.conf`, and matching `vhost.d` snippet).
2. Make minimal, scoped changes; preserve security defaults.
3. Run targeted validation first (single-service `nginx -t`), then broader checks (`docker-compose config`, `docker-compose ps`).
4. For routing/header changes, verify with `curl -I` against relevant host.
5. Do not commit secrets, generated certs, or `.env`.

## 6) Code Style Guidelines
This repository is mostly YAML, nginx config, Bash, and Markdown. Follow language-specific style below.

### 6.1 Cross-Cutting Conventions
- Keep changes deterministic and explicit; avoid "magic" behavior.
- Prioritize secure defaults (read-only mounts/fs, no-new-privileges, resource limits).
- Preserve backward-compatible behavior unless task explicitly requests change.
- Prefer small edits over broad rewrites.
- Comments should explain "why" when logic is non-obvious; avoid noisy commentary.

### 6.2 Docker Compose / YAML
- Use 2-space indentation; no tabs.
- Keep service keys ordered consistently: `image`, `container_name`, `restart`, `logging`, `healthcheck`, `env_file`/`environment`, `volumes`, `depends_on`, `networks`, `security_opt`, `read_only`, `tmpfs`, resource limits.
- Keep environment variables in list form (`- KEY=value`) to match existing style.
- Quote strings when needed for clarity (`"10m"`, cpu strings like `'0.5'`).
- For new proxied services, include all of:
  - `VIRTUAL_HOST`
  - `LETSENCRYPT_HOST`
  - `LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL:?...}` or equivalent safe pattern
  - `networks: [web]`
- Maintain health checks for every long-running service.

### 6.3 Nginx Configuration
- Use 4-space indentation inside blocks.
- Keep block order stable: redirects/canonicalization, security headers, hardening, caching/static rules, fallback `location /`, error-page handling.
- Use `return 301` for canonical redirects unless temporary behavior is explicitly needed.
- Keep security headers explicit and consistent across domains unless domain-specific policy differs.
- Use `try_files` for static/fallback resolution; avoid unnecessary rewrites.
- When adding new file-type caching, group by asset type and include immutable cache headers when appropriate.

### 6.4 Bash Scripts
- Start scripts with `#!/bin/bash` and `set -e` (or stronger if refactoring script-wide).
- Use descriptive helper functions for repeated output/actions.
- Quote variable expansions unless intentional word splitting is required.
- Prefer `[[ ... ]]` over `[ ... ]` for Bash conditionals.
- Validate prerequisites early (commands, files, env vars) and fail fast with clear errors.
- Keep script output actionable for operators.

### 6.5 Markdown / Docs
- Use concise sections with operationally useful commands.
- Keep examples copy-pastable and production-safe by default.
- Mark risky/destructive steps clearly.
- Keep terminology consistent: "docker-compose" (current repo usage), "nginx-proxy", "acme-companion".

## 7) Imports, Types, Naming, Error Handling
These are limited in this repo, but follow these rules when applicable.
- Imports: not applicable to current codebase; if introducing app code, use standard-library first, then third-party, then local modules.
- Types: not currently applicable; if introducing typed language code, prefer explicit types for public interfaces and config schemas.
- Naming:
  - Compose service names: domain-like or purpose-revealing, lowercase.
  - File names: lowercase with hyphen/period conventions already present.
  - Env vars: uppercase snake case.
  - Bash functions: lowercase snake case.
- Error handling:
  - Fail closed for security-sensitive config.
  - Emit clear operator-facing errors with resolution hints.
  - Validate config (`docker-compose config`, `nginx -t`) before restart/redeploy.

## 8) Security Guardrails
- Never commit `.env`, certs, private keys, or generated ACME material.
- Keep sensitive mounts read-only where possible.
- Preserve `no-new-privileges:true` and resource caps unless explicitly asked to change.
- Do not weaken TLS/security headers without explicit rationale.

## 9) Quick Pre-PR Checklist for Agents
- `docker-compose config` passes
- Targeted `nginx -t` passes for changed service(s)
- `docker-compose ps` shows healthy/running services (where environment allows running)
- Docs updated if behavior or ops workflow changed
- No secrets or generated artifacts added to git
