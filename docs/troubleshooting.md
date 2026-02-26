# Troubleshooting Runbook

Operational troubleshooting for the Outer Rim stack.

## Scope

Use this runbook for runtime and configuration issues in:
- `nginx-proxy`
- `acme-companion`
- static site containers (`xbonell.com`, `bgespecialitats.com`)

## Quick Triage

```bash
# Compose config validity
docker-compose config

# Service status and health
docker-compose ps

# Recent logs across stack
docker-compose logs --tail=100

# Follow logs live
docker-compose logs -f
```

If `docker-compose config` fails, fix interpolation/syntax first before checking runtime logs.

## HTTPS / Certificate Issues

### Symptom: HTTP works, HTTPS fails

Checks:
```bash
docker-compose logs acme-companion
docker exec acme-companion acme.sh --list
```

Likely causes and fixes:
- DNS A/AAAA not pointing to host serving this stack.
- Ports `80` and `443` not reachable from internet.
- `LETSENCRYPT_EMAIL` missing or placeholder value in `.env`.
- `ACME_CA_URI` set to staging (certs generated but not browser-trusted).

Recommended production value:
```bash
ACME_CA_URI=https://acme-v02.api.letsencrypt.org/directory
```

### Symptom: No cert generated for a service

Validate service config includes all three:
- `VIRTUAL_HOST`
- `LETSENCRYPT_HOST`
- `LETSENCRYPT_EMAIL` (or safe env expansion)

Then confirm service is attached to `web` network.

## Nginx Routing / Config Issues

### Validate nginx syntax inside containers

```bash
docker-compose exec nginx-proxy nginx -t
docker-compose exec xbonell.com nginx -t
docker-compose exec bgespecialitats.com nginx -t
```

If site behavior is wrong but syntax is valid:
- Check proxy-level rules in `nginx/vhost.d/*.com`.
- Check site-level server behavior in `sites/*/nginx.conf`.
- Verify canonical redirect rules and trailing slash logic.

## Domain / DNS Validation

```bash
curl -I https://xbonell.com
curl -I https://bgespecialitats.com
```

Expected:
- valid HTTPS response (2xx/3xx as configured)
- expected redirect behavior for canonical host/language root

If DNS is suspect, validate records from your DNS tooling before repeating ACME attempts.

## Container Health and Resources

```bash
docker-compose ps
docker stats --no-stream
```

Look for:
- unhealthy containers due to failed health checks
- memory/cpu pressure causing restarts or latency

## File/Permission Issues

Critical permissions:
```bash
chmod 600 .env
chmod 600 nginx/certs/
```

If setup was manual, ensure required directories exist:
- `nginx/certs`
- `nginx/vhost.d`
- `nginx/html`
- `nginx/conf.d`
- `acme`

## Safe Recovery Sequence

When configs were changed and state is uncertain:
```bash
# 1) Validate configs
docker-compose config

# 2) Pull current images (optional but recommended)
docker-compose pull

# 3) Recreate services
docker-compose up -d

# 4) Verify service state
docker-compose ps

# 5) Validate target nginx service
docker-compose exec nginx-proxy nginx -t
```

## Incident Notes Template

When recording incidents, capture:
- timestamp and impacted domains
- failing command and exact error output
- config files changed
- rollback or fix applied
- verification commands/results

Store incident notes in your team runbook or issue tracker; keep sensitive values out of git.
