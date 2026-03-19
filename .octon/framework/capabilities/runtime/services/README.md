# Services

Domain capabilities with typed contracts for invocation-driven composite behavior.

## Independence Requirement

Production services in this harness are self-contained and must not require or reference external kit implementations.

## Contents

| File/Dir | Purpose |
|---|---|
| `manifest.yml` | Service discovery index |
| `registry.yml` | Extended service metadata |
| `manifest.runtime.yml` | Executable runtime Tier 1 discovery index (`services-manifest-v1`) |
| `registry.runtime.yml` | Executable runtime Tier 2 metadata (`services-registry-v1`) |
| `capabilities.yml` | Service capability schema and constraints |
| `conventions/` | Harness-wide cross-cutting contracts (errors, run records, observability, idempotency, rich contracts, declarative rules, fixtures, validation tiers, implementation generation) |
| `conventions/rich-contracts.md` | Rich contract completeness and compatibility profile requirements |
| `conventions/declarative-rules.md` | Declarative rule schema, ordering, and fail-closed semantics |
| `conventions/fixtures.md` | Fixture format and semantic anchoring requirements |
| `conventions/validation-tiers.md` | Tier 1 deterministic and Tier 2 semantic validation contract |
| `conventions/implementation-generation.md` | Contract-derived implementation generation workflow |
| `_scaffold/template/` | Service scaffold template |
| `_ops/scripts/validate-services.sh` | Structural and contract validator |
| `_ops/scripts/validate-service-independence.sh` | Independence validator (forbidden external package references) |
| `_ops/scripts/compile-deny-by-default-policy.sh` | Generates normalized service policy catalog for runtime/CI review |
| `/.octon/state/evidence/runs/services/` | Service logs and run state |
| `/.octon/state/control/capabilities/deny-by-default-exceptions.yml` | Time-boxed deny-by-default exception leases (owner + expiry required) |
| `_meta/docs/` | Non-structural support docs (platform, integration guides, migration notes) |
| `_meta/docs/composite-services.md` | Canonical definition of harness-only composite service composition |

## Interface Types

- `shell`: POSIX script entrypoint (optional; can be generated from contract)
- `mcp`: networked/MCP adapter
- `library`: runtime/library implementation pointer

## Dependency Boundary

Services are portable as declarative contract content (schemas, rules, fixtures, conventions) without project-local runtime binaries.
Host-provided prerequisites remain required: an agent runtime/model and a minimal tool adapter (`read`, `glob`, `grep`, `bash`).

## Deny-by-Default Guardrails

- Active services must use scoped permissions in `allowed-tools`.
- Bare `Bash` / `Shell` and bare `Write` are rejected for active services.
- `policy.fail_closed: false` is allowed only with an active exception lease.
- Broad write scopes (`Write(...**)`) are allowed only with an active exception lease.
- Shell entrypoints enforce runtime policy via `_ops/scripts/enforce-deny-by-default.sh`
  which delegates to the shared `octon-policy` engine.
- Validation preflight uses the same engine path to keep runtime and validator
  decisions in parity.

## Validation Shortcuts

```bash
./_ops/scripts/validate-services.sh
./_ops/scripts/validate-services.sh --profile dev-fast
./_ops/scripts/validate-services.sh --profile dev-fast guard
../_ops/scripts/validate-deny-by-default.sh --changed --profile dev-fast
```

## Agent-only Mode

Shell services always enforce agent-only controls through
`_ops/scripts/enforce-deny-by-default.sh` and the v2 policy contract.

- Policy source: `../_ops/policy/agent-only-governance.yml`.
- Required runtime context (defaults applied for local/dev runs):
  - `OCTON_AGENT_ID`
  - `OCTON_AGENT_IDS` (comma-separated distinct agents for quorum checks)
  - `OCTON_RISK_TIER` (`low|medium|high`)
- Tier-specific controls:
  - `medium`: `OCTON_REVIEW_AGENT_ID`, `OCTON_ROLLBACK_PLAN_ID`
  - `high`: `OCTON_REVIEW_AGENT_ID`, `OCTON_ROLLBACK_PLAN_ID`,
    `OCTON_QUORUM_TOKEN`
- Kill-switch controls are scoped and expiring:
  - `global`
  - `service:<id>`
  - `category:<id>`

## Profile Shortcuts

Common workflows can request bounded grants from policy profiles:

```bash
.octon/framework/capabilities/_ops/scripts/policy-profile-resolve.sh refactor
.octon/framework/capabilities/_ops/scripts/policy-profile-resolve.sh tests --emit-grant \
  --subject service:agent \
  --request-id req-1 \
  --agent-id agent-a \
  --plan-step-id step-1
```

## Skill Integration

Skills may whitelist services with:

```yaml
allowed-services: guard cost
```

Service IDs resolve against `services/manifest.yml` for the harness-native catalog.
Executable-runtime IDs resolve against `services/manifest.runtime.yml`.
