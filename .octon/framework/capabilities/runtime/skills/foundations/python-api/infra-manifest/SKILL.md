---
name: python-infra-manifest
description: >
  Generate docker-compose.local.yml for declared infrastructure dependencies
  and alembic setup for database migrations. Invoke with the project name and
  list of services needed (postgres, nats, redis, minio, temporal).
skill_sets: [specialist]
capabilities: [phased, external-dependent]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(/.octon/state/evidence/runs/skills/*) Bash(mkdir) Bash(docker) Bash(alembic)
---

# Infrastructure Manifest

Generate the local development infrastructure: Docker Compose services with
health checks and named volumes, plus Alembic migration scaffolding.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (used for container name prefix and database name)
- **List of services**: subset of `postgres`, `nats`, `redis`, `minio`, `temporal`
- **Optional**: specific image versions, port overrides
- **Optional**: initial migration description (e.g., "create metadata tables")

Example: `myapp postgres nats redis minio temporal`

## Pre-flight Checks

1. Check if `docker-compose.local.yml` already exists. If yes, read it and
   only add new services.
2. Check if `alembic.ini` exists. If yes, do not overwrite.
3. Check if `alembic/` directory exists.
4. Read `.env.local.example` if it exists, to align connection strings.

## Generation Steps

### Step 1: `docker-compose.local.yml`

Use the service blocks in [references/compose-service-patterns.yaml](references/compose-service-patterns.yaml).

Rules:
- Use `version: "3.9"`.
- Container naming: `<project-short>-<service>` (e.g., `myapp-postgres`).
- For each declared service, include the corresponding block.
- `minio-init` is auto-included when `minio` is declared.
- `temporal-ui` is auto-included when `temporal` is declared.
- If `temporal` is declared but `postgres` is not, warn that temporal
  auto-setup requires postgres.
- Add a `volumes:` section listing all named volumes.

### Step 2: `alembic.ini`

Generate only if postgres is declared and `alembic.ini` does not exist.

- `script_location = %(here)s/alembic`
- `sqlalchemy.url` pointing to compose postgres with `postgresql+psycopg://` prefix.
- Standard logging sections (root, sqlalchemy, alembic).

### Step 3: `alembic/env.py`

Use the pattern in [references/alembic-env-pattern.py](references/alembic-env-pattern.py).

Key features:
- `_normalize_sqlalchemy_url()` converting `postgresql://` to `postgresql+psycopg://`.
- `_configure_database_url()` reading `POSTGRES_DSN` or `DATABASE_URL` from env.
- `run_migrations_offline()` and `run_migrations_online()` with `compare_type=True`.

### Step 4: `alembic/versions/` directory

Create if it does not exist. Create `alembic/README` with brief usage instructions.

### Step 5: Initial migration (optional)

If an initial migration description is provided in `$ARGUMENTS`, generate a
migration file using the patterns in [references/migration-template.py](references/migration-template.py).

Rules:
- Use explicit `sa.Enum()` for all enum types.
- Create enums in `upgrade()` with `checkfirst=True`.
- Drop enums in `downgrade()` with `checkfirst=True`.
- Use `sa.CheckConstraint` for value range constraints.
- Use `op.create_index` for operational query patterns.
- Timestamps with `server_default=sa.text("now()")`.

## Edge Cases

- If compose file already exists, read it and only add new service blocks.
- If alembic is already set up, do not regenerate.
- If temporal is declared without postgres, add a comment warning about the dependency.

## Cross-references

- **Depends on**: `/scaffold-package` (project name)
- **Complements**: `/dev-toolchain` (justfile docker targets reference this compose file)
- **Feeds into**: `/test-harness` (integration test fixtures use these connection strings)

## When to Use

- Generating local infrastructure manifests (compose + migrations) for declared backend dependencies
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
