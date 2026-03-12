# Assurance

Assurance gates and completion criteria.

## Assurance Engine (Historical: QGE)

The weighted-assurance policy and enforcement stack in this subsystem is called
the **Assurance Engine** (historical alias: `QGE`).

The Assurance Engine is the harness **authoritative local engine** for assurance governance:

- Policy is sourced from repo-local files (`weights.yml`, override policy files).
- Measurement is sourced from repo-local `scores.yml`.
- Resolution and gating run locally/CI via Rust + shell entrypoints.
- Evidence outputs are generated as local artifacts under `.harmony/output/assurance/`.

This local-first model is canonical. A remote service may be added later for
cross-repo aggregation, but it must not replace local deterministic enforcement.

### Charter-Driven Flow

The Assurance Engine is charter-led and runs as a deterministic chain:

1. `CHARTER.md` defines the priority chain and trade-off rules.
2. `weights/weights.yml` encodes policy weights that must align to the charter.
3. `scores/scores.yml` records measured subsystem scores and evidence.
4. `_ops/scripts/compute-assurance-score.sh` resolves effective weights and results.
5. `_ops/scripts/assurance-gate.sh` enforces policy, charter alignment, and drift checks.
6. Generated artifacts are written under `../output/assurance/`.
7. Umbrella ordering is deterministic: `Assurance > Productivity > Integration`.

## Contents

| File | Purpose | When to Use |
|------|---------|-------------|
| `CHARTER.md` | Canonical Assurance charter and source-of-truth umbrella chain | Before changing weights, gates, or policy decisions |
| `_meta/architecture/README.md` | Assurance subsystem specification docs | When changing assurance policy model |
| `complete.md` | Definition of Done | Before marking any task complete |
| `session-exit.md` | Session exit checklist | Before ending a session |
| `testing-strategy.md` | Testing strategy and assurance approach | When designing or validating tests |
| `security-and-privacy.md` | Security and privacy baseline policy | When handling sensitive data or controls |
| `data-handling-and-retention.md` | Data handling and retention standards | When designing data lifecycle behavior |
| `_ops/scripts/alignment-check.sh` | Profile-based alignment runner across harness aspects | When you want one repeatable alignment command |
| `_ops/scripts/validate-harness-structure.sh` | Structural namespace and discovery contract validation | Before release or architecture-sensitive merges |
| `_ops/scripts/validate-audit-subsystem-health-alignment.sh` | Drift guardrail between `.harmony` architecture and `audit-subsystem-health` | When `.harmony` architecture surfaces change |
| `_ops/scripts/validate-commit-pr-alignment.sh` | Drift guardrail for commit/PR standards policy, template, and workflow alignment | When commit/PR governance artifacts change |
| `weights/weights.md` | Human-readable weighted assurance profiles and governance notes | When reviewing/changing assurance priorities |
| `weights/weights.yml` | Machine-readable policy weights source of truth | When changing assurance policy and precedence overrides |
| `weights/inputs/context.yml` | Default run context for weight resolution | When selecting profile + override context |
| `policy/SUBSYSTEM_OVERRIDE_POLICY.md` | Governance contract for repo-over-subsystem override deviations | When defining or reviewing override controls |
| `policy/subsystem-classes.yml` | Subsystem class strictness for override governance (`control-plane` vs `productivity`) | When tuning override enforcement posture |
| `policy/overrides.yml` | Explicit repo override deviation declarations (ADR/changelog/owner/expiry) | When repo overrides subsystem intent |
| `scores/scores.yml` | Measured subsystem scores, criteria, and evidence pointers | Before computing weighted results/gates |
| `_ops/scripts/compute-assurance-score.sh` | Computes effective weights + weighted scorecards | Local/CI assurance scoring runs |
| `_ops/scripts/assurance-gate.sh` | Enforces weighted gate hard-fail/soft-warn rules | CI/local assurance gate decision |
| `../output/assurance/effective/*.md` | Resolved effective-weight matrix by context | After resolver runs |
| `../output/assurance/results/*.md` | Weighted results + backlog drivers by context | After resolver runs |
| `../output/assurance/policy/deviations/*.md` | Repo-over-subsystem override deviation report by context | After resolver runs |

## Contract

- Read `complete.md` before marking any task as completed.
- Read `session-exit.md` before ending a session or context reset.
- These files define the assurance bar. Do not skip them.
