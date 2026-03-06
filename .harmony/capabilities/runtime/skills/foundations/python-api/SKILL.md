---
name: python-api
description: >
  Foundation skill set for Python API services. Provides context about
  the available skills, their dependencies, and the recommended workflow.
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Grep Glob
---

# Python API Foundation

Background context for Claude — not invoked directly. This skill set
targets **Python API services** following contract-first design. Claude
should use this to guide skill suggestions, sequencing, and stack assumptions.

## Stack Assumptions

These skills encode a specific technology stack. They apply when the
project matches most of these choices:

| Layer           | Choice                                    |
|-----------------|-------------------------------------------|
| Language        | Python ≥3.12                              |
| Web framework   | FastAPI                                   |
| Validation      | Pydantic v2 (`extra="forbid"` on contracts) |
| Config          | pydantic-settings                         |
| Package manager | uv                                        |
| Linting         | ruff + mypy                               |
| Testing         | pytest (unit / contract / integration)    |
| Task runner     | just                                      |
| Migrations      | Alembic + SQLAlchemy                      |
| Containers      | Docker Compose (local dev)                |
| CI              | GitHub Actions                            |
| Optional infra  | Postgres, NATS, Redis, MinIO/S3, Temporal |

**When not to suggest these skills:** Node.js projects, Go CLIs, Python
ML-only projects without an API layer, or projects using a fundamentally
different web framework (Django, Flask). If the user's stack diverges on
more than two rows, these skills will produce friction rather than value.

## Child Skills

| Skill                  | Purpose                                              |
|------------------------|------------------------------------------------------|
| `/python-scaffold-package`    | Package structure, pyproject.toml, typed config, logging, health endpoints |
| `/python-contract-first-api`  | OpenAPI spec, JSON schemas, Pydantic models, contract tests, fixtures |
| `/python-test-harness`        | Three-tier test pyramid, conftest fixtures, integration scaffolding |
| `/python-dev-toolchain`       | justfile, pre-commit, ruff/mypy config, .gitignore, .env.local.example |
| `/python-infra-manifest`      | docker-compose.local.yml, Alembic migration setup    |
| `/python-contributor-guide`   | AGENT.md, CONTRIBUTING.md, PR template, CI workflow   |

## Dependency Graph

```text
scaffold-package ──┬── contract-first-api ──┐
                   │                        ├── test-harness
                   ├── infra-manifest ──────┘       │
                   │                                │
                   ├── dev-toolchain ◄───────────────┘
                   │
                   └────────────────────────────── contributor-guide
```

## Recommended Sequencing

When a user asks to "set up a Python API project" or similar, suggest
running the skills in this order:

1. **`/python-scaffold-package`** — always first. Creates the package tree,
   pyproject.toml, settings, logging, and health endpoints that every
   other skill reads.

2. **`/python-contract-first-api`** and **`/python-infra-manifest`** — run in either
   order (no dependency between them). Both only require scaffold-package.
   If the user has a domain model ready, start with contracts. If they
   want to get services running first, start with infra.

3. **`/python-test-harness`** — after contracts and infra. It discovers JSON
   schemas from `/python-contract-first-api` and reads connection strings from
   `/python-infra-manifest` to generate integration fixtures. Running it earlier
   is safe but produces incomplete coverage.

4. **`/python-dev-toolchain`** — after scaffold-package at minimum; benefits
   from running after test-harness (pytest config) and contract-first-api
   (validate-schemas targets). Can run in parallel with test-harness if
   needed.

5. **`/python-contributor-guide`** — always last. It reads the outputs of every
   other skill (module layout, justfile targets, contracts, CI config)
   to generate accurate documentation.

## Partial Runs

Not every project needs all six skills. Common subsets:

- **Minimal API**: scaffold-package → contract-first-api → dev-toolchain
- **Full foundation**: all six in order above
- **Adding contracts to existing project**: contract-first-api → test-harness
  (assuming package structure already exists)
- **Infrastructure only**: scaffold-package → infra-manifest → dev-toolchain

When suggesting a partial run, verify the dependencies are met — each
skill's pre-flight checks will warn about missing prerequisites, but
Claude should proactively suggest the right sequence.
