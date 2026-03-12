---
title: Domain Architecture Audit - Cognition
description: Independent architecture critique for .harmony/cognition using external robustness criteria.
date: "2026-02-22"
run_id: "2026-02-22-cognition-observed-standard"
target_mode: observed
domain_path: ".harmony/cognition"
criteria:
  - modularity
  - discoverability
  - coupling
  - operability
  - change-safety
  - testability
evidence_depth: standard
severity_threshold: all
---

# Domain Architecture Audit: `.harmony/cognition`

## Run Framing

- Target mode: `observed`
- Target resolution evidence: `.harmony/cognition/` exists with bounded surfaces (`runtime/`, `governance/`, `practices/`, `_ops/`, `_meta/`).
- Baseline profile evidence: `.harmony/cognition/governance/domain-profiles.yml` maps `cognition: bounded-surfaces`.
- Evidence confidence: high for structural findings; medium for adoption/maturity findings.

### Assumptions

1. This run evaluates architecture quality and operational robustness, not doctrinal correctness.
2. Current file system state is representative of normal operation.
3. Runtime script validation outcomes are meaningful proxies for operability.

## Criteria Evaluation Summary

| Criterion | Score (1-5) | Evidence |
|---|---:|---|
| Modularity | 4 | Clear bounded surfaces and scoped indexes (`.harmony/cognition/README.md`, `.harmony/cognition/runtime/index.yml`, `.harmony/cognition/governance/index.yml`, `.harmony/cognition/practices/index.yml`) |
| Discoverability | 3 | Strong index discipline in runtime/governance/practices, but `_ops` is README-only (`.harmony/cognition/index.yml`, `.harmony/cognition/_ops/README.md`) |
| Coupling | 3 | Generated runtime artifacts and evidence maps are tightly coupled to deep relative paths into `output/` (`.harmony/cognition/runtime/evidence/index.yml`, `.harmony/cognition/runtime/migrations/index.yml`) |
| Operability | 4 | Dedicated validators exist and pass (`.harmony/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`, `.harmony/cognition/_ops/knowledge/scripts/validate-knowledge-runtime.sh`) and are run via CI harness validation (`.github/workflows/smoke.yml`) |
| Change Safety | 3 | Good drift checks, but a single large generator script concentrates blast radius (`.harmony/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`) |
| Testability | 3 | Validators exist, but complex generation logic lacks focused fixture tests (`.harmony/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`, `.harmony/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`) |

## Current Surface Map (With File-Path Evidence)

| Surface | Primary Responsibility | Key Evidence |
|---|---|---|
| Root (`.harmony/cognition/`) | Domain discovery and bounded-surface routing | `.harmony/cognition/README.md`, `.harmony/cognition/index.yml` |
| `runtime/` | Authoritative operational artifacts: context, ADRs, migrations, knowledge, evidence, evaluations, projections | `.harmony/cognition/runtime/README.md`, `.harmony/cognition/runtime/index.yml` |
| `governance/` | Normative policy contracts, profiles, principles, controls, exception model | `.harmony/cognition/governance/README.md`, `.harmony/cognition/governance/index.yml`, `.harmony/cognition/governance/domain-profiles.yml` |
| `practices/` | Methodology and recurring operations/runbooks | `.harmony/cognition/practices/README.md`, `.harmony/cognition/practices/index.yml`, `.harmony/cognition/practices/operations/index.yml` |
| `_ops/` | Mutable guardrail scripts for validation and generation | `.harmony/cognition/_ops/README.md`, `.harmony/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh` |
| `_meta/` | Architecture/reference/discovery aids and optional artifact-surface docs | `.harmony/cognition/_meta/architecture/index.yml`, `.harmony/cognition/_meta/docs/index.yml`, `.harmony/cognition/_meta/architecture/artifact-surface/index.yml` |

### Surface Volume Snapshot

- Total files under domain: `278`
- Files by top-level surface:
  - `_meta`: `64`
  - `_ops`: `10`
  - `governance`: `53`
  - `practices`: `40`
  - `runtime`: `109`
- High-density runtime subsurfaces:
  - `runtime/decisions`: `39`
  - `runtime/context`: `19`
  - `runtime/migrations`: `17`

Evidence: `.harmony/cognition/**` file inventory and top-level counts from this run.

## Critical Gaps (Impact + Risk)

No `CRITICAL` severity defects observed in the current state. Highest-severity issues are below.

### Gap 1 - HIGH: Change-Safety Bottleneck in Monolithic Runtime Artifact Generator

- Evidence:
  - `.harmony/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh` is `1125` lines with `34` shell functions.
  - Script is the single generator for multiple derived artifacts referenced as canonical outputs in `.harmony/cognition/practices/operations/generated-artifacts.md`.
- Impact:
  - A single implementation change can affect decisions summaries, projection materializations, evidence indexes, evaluation indexes, and knowledge graph artifacts simultaneously.
- Risk:
  - Reviewability and targeted regression isolation degrade as complexity accumulates in one script boundary.

### Gap 2 - MEDIUM: `_ops` Discoverability Contract Is Human-Readable but Not Machine-Routable

- Evidence:
  - `.harmony/cognition/_ops/` contains scripts across five subsurfaces, but has no `index.yml`.
  - Domain root index only exposes `_ops/README.md` as an entrypoint (`.harmony/cognition/index.yml`).
- Impact:
  - Agents and tooling must parse prose to discover operational script contracts instead of using stable IDs and `when` selectors.
- Risk:
  - Script routing drift and inconsistent invocation patterns as `_ops` grows.

### Gap 3 - MEDIUM: Evaluation Surfaces Are Structurally Present but Operationally Unexercised

- Evidence:
  - `.harmony/cognition/runtime/evaluations/digests/index.yml` has no digest `records`.
  - `.harmony/cognition/runtime/evaluations/actions/open-actions.yml` currently has `actions: []`.
  - Weekly cadence is defined as process contract in `.harmony/cognition/practices/operations/weekly-evaluations.md`.
- Impact:
  - Evaluation architecture cannot yet provide trend evidence or action-closure telemetry in practice.
- Risk:
  - Latent quality regressions or policy drift can go undetected between structural checks.

## Recommended Changes (Priority, Expected Benefit, Tradeoff)

### P1 - Split Runtime Artifact Generation into Composable Units

- Recommendation:
  - Refactor `.harmony/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh` into per-surface generators (decisions, evidence, evaluations, projections, knowledge) plus a thin orchestrator.
  - Add focused fixture tests for parser-heavy branches.
- Expected benefit:
  - Lower blast radius per change, clearer ownership seams, better targeted regression triage.
- Tradeoff:
  - More files and slightly higher orchestration overhead during initial migration.

### P2 - Add Machine Discovery Indexes for `_ops`

- Recommendation:
  - Introduce `.harmony/cognition/_ops/index.yml` and optional child indexes (for `principles`, `runtime`, `knowledge`, `evaluations`, `projections`) with explicit script purpose and invocation timing.
- Expected benefit:
  - Consistent discovery model across all cognition surfaces, easier agent/tool routing, reduced manual lookup.
- Tradeoff:
  - Additional index maintenance burden unless generation/linting is extended.

### P3 - Activate Evaluation Runtime with Minimum Viable Digest Cadence

- Recommendation:
  - Create an initial digest artifact from `template-weekly-digest.md` and populate at least one tracked action to exercise end-to-end generation into `open-actions.yml`.
  - Add a non-blocking freshness warning in validation for stale digest windows.
- Expected benefit:
  - Converts evaluation architecture from static scaffolding into live operability signal.
- Tradeoff:
  - Ongoing maintenance cadence and ownership commitment required.

## Keep As-Is Decisions (And Why)

1. Keep bounded-surface partitioning (`runtime/`, `governance/`, `practices/` + `_ops`, `_meta`).
Reason: it provides clear concern separation and change locality (`.harmony/cognition/README.md`, `.harmony/cognition/index.yml`).

2. Keep generated-artifact drift controls and validators.
Reason: deterministic generation with `--check` and structural validation materially reduces silent drift risk (`.harmony/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`, `.github/workflows/harness-self-containment.yml`).

3. Keep immutable-principles governance guardrails.
Reason: checksum + lint + fixture tests provide strong policy integrity posture (`.harmony/cognition/_ops/principles/scripts/lint-principles-governance.sh`, `.github/workflows/principles-governance-lint.yml`).

4. Keep migration/evidence linkage model across runtime and output surfaces.
Reason: explicit record-to-evidence mapping improves traceability and auditability (`.harmony/cognition/runtime/migrations/index.yml`, `.harmony/cognition/runtime/evidence/index.yml`).

## Open Questions / Unknowns

1. Optional artifact-surface usage level is not measured in this run.
Unknown evidence needed: which docs in `/.harmony/cognition/_meta/architecture/artifact-surface/` are actively consumed vs archival.

2. Runtime generator performance envelope is unknown.
Unknown evidence needed: benchmark timing and diff churn for `sync-runtime-artifacts.sh` under realistic growth scenarios.

3. Evaluation cadence policy is documented but not evidenced by live records.
Unknown evidence needed: expected SLA/freshness target for weekly digests and action closure.

