---
title: Octon Constitutional Engineering Harness Umbrella Specification
description: Canonical cross-subsystem structural contract for the Octon Constitutional Engineering Harness super-root.
status: Active
---

# Octon Constitutional Engineering Harness Umbrella Specification

## Purpose

Define the steady-state structural contract for `/.octon/` as Octon's single
authoritative super-root.

The machine-readable source of truth for topology, authority families,
publication metadata, and doc targets is:

- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`

This specification is the human-readable companion to that registry. It stays
subordinate to the constitutional kernel and must not restate competing
constitutional authority.

## Constitutional Authority

Repo-local supreme control authority lives under
`/.octon/framework/constitution/**`, including:

- `CHARTER.md` and `charter.yml`
- `precedence/{normative.yml,epistemic.yml}`
- `obligations/{fail-closed.yml,evidence.yml}`
- `ownership/roles.yml`
- `contracts/registry.yml` and the constitutional contract families

Structural interpretation flows through the contract registry rather than
through repeated hand-maintained path matrices.

## How To Use The Structural Registry

Use these sections of
`/.octon/framework/cognition/_meta/architecture/contract-registry.yml`:

- `class_roots`: canonical class-root bindings and placement rules
- `delegated_registries`: machine-readable surfaces that own more specific
  subdomains
- `path_families`: canonical steady-state path families, authority classes,
  consumers, and validators
- `publication_metadata`: runtime-facing and operator-facing publication rules
- `doc_targets`: steady-state roles for active authoritative docs
- `compatibility_retirement`: explicit retirement governance for retained
  compatibility surfaces
- `runtime_authorization_coverage`: runtime boundary, side-effect inventory,
  coverage, and phase-result contract surfaces
- `execution`, `mission_autonomy`, and `documentation`: compatibility
  projections retained only as transitional readers, never as a parallel
  authority model

## Canonical Operational Roots

- constitutional kernel anchor: `/.octon/framework/constitution/CHARTER.md`
- constitutional runtime contracts:
  `/.octon/framework/constitution/contracts/runtime/**`
- canonical execution control root:
  `/.octon/state/control/execution/**`
- canonical execution scratch root:
  `/.octon/generated/.tmp/execution/**`
- repo-owned network egress policy:
  `/.octon/instance/governance/policies/network-egress.yml`
- repo-owned execution budget policy:
  `/.octon/instance/governance/policies/execution-budgets.yml`
- repo-owned support-target declarations:
  `/.octon/instance/governance/support-targets.yml`
- canonical approval request root:
  `/.octon/state/control/execution/approvals/requests`
- canonical exception lease root:
  `/.octon/state/control/execution/exceptions/leases/`
- canonical revocation root:
  `/.octon/state/control/execution/revocations/`
- authored lab framework root: `/.octon/framework/lab/`
- authored observability framework root: `/.octon/framework/observability/`
- maintainability proof plane:
  `/.octon/framework/assurance/maintainability/`
- retained lab evidence root: `/.octon/state/evidence/lab/`

## Structural Invariants

1. `/.octon/` is the only super-root for this repository.
2. The only class roots are `framework/`, `instance/`, `state/`,
   `generated/`, and `inputs/`.
3. Durable authored authority may live only under `framework/**` and
   `instance/**`.
4. `state/**` is operational truth only and is split into
   `state/control/**`, `state/evidence/**`, and `state/continuity/**`.
5. `generated/**` is rebuildable and never mints authority.
6. `inputs/**` is non-authoritative; human-led ideation remains confined to
   `inputs/exploratory/ideation/**` unless a human explicitly scopes access.
7. `/.octon/octon.yml` owns super-root bindings, profiles,
   runtime-resolution anchors, and generated commit defaults. Dense
   runtime-resolution detail lives in delegated runtime-resolution surfaces.
8. `/.octon/instance/ingress/manifest.yml` owns mandatory ingress reads,
   optional orientation overlays, and the canonical branch/PR closeout
   workflow pointer.
9. Overlay legality exists only where
   `/.octon/framework/overlay-points/registry.yml` declares a point and
   `/.octon/instance/manifest.yml` enables it.
10. Mission authority remains the continuity container under
    `instance/orchestration/missions/**`; consequential run control lives under
    `state/control/execution/runs/**`.
11. Retained evidence, disclosure, and validation receipts live only under
    `state/evidence/**`.
12. Runtime-facing effective outputs under `generated/effective/**` require
    publication receipts and freshness artifacts before runtime may trust them.
13. Proposal packets remain under `inputs/exploratory/proposals/**` and stay
    lineage-only; generated proposal discovery stays non-authoritative.

## Delegated Registries

The structural registry delegates detail ownership to the following
machine-readable surfaces:

| Surface | Owns |
| --- | --- |
| `/.octon/octon.yml` | Class-root bindings, portability profiles, runtime resolution inputs, generated commit defaults |
| `/.octon/framework/constitution/contracts/registry.yml` | Constitutional families and integration surfaces |
| `/.octon/framework/overlay-points/registry.yml` | Legal overlay points and merge modes |
| `/.octon/instance/manifest.yml` | Repo-side overlay enablement |
| `/.octon/instance/ingress/manifest.yml` | Mandatory ingress read order, optional orientation, and closeout workflow pointer |
| `/.octon/instance/cognition/decisions/index.yml` | Append-only ADR discovery |

When any delegated registry changes, this specification stays descriptive and
the machine-readable registry remains canonical.

## Path Families

Steady-state topology and authority are organized through these canonical
family groups:

| Family | Canonical root or surface | Role |
| --- | --- | --- |
| `constitutional_kernel` | `framework/constitution/**` | Supreme repo-local authority |
| `structural_architecture` | `framework/cognition/_meta/architecture/**` | Structural registry plus narrative companion |
| `compatibility_retirement` | `instance/governance/retirement-register.yml` + retirement contracts | Retained compatibility inventory, review cadence, and retirement posture |
| `runtime_authorization_coverage` | `framework/engine/runtime/spec/{execution-authorization-v1.md,authorization-boundary-coverage.yml,material-side-effect-inventory.yml}` | Authorization-boundary and material-side-effect coverage contract |
| `runtime_resolution` | `framework/engine/runtime/spec/runtime-resolution-v1.md` + `instance/governance/runtime-resolution.yml` | Delegated runtime-resolution selector and route-bundle contract |
| `runtime_architecture_health` | `framework/engine/runtime/spec/architecture-health-contract-v1.md` + health/freshness validators | Aggregate runtime health, lifecycle, and publication-freshness gate |
| `overlay_resolution` | `framework/overlay-points/registry.yml` + `instance/manifest.yml` | Declared overlay legality |
| `instance_ingress_and_bootstrap` | `instance/{ingress,bootstrap}/**` | Ingress and optional orientation |
| `branch_pr_closeout_workflow` | `framework/orchestration/runtime/workflows/meta/closeout/**` + Git/worktree autonomy contract | Branch and PR closeout policy plus workflow ownership |
| `workspace_charter_pair` | `instance/charter/{workspace.md,workspace.yml}` | Repo-wide objective authority |
| `instance_governance` | `instance/governance/**` | Support targets, exclusions, policy, ownership, governance disclosure |
| `instance_locality` | `instance/locality/**` | Scope and locality authority |
| `instance_decisions` | `instance/cognition/decisions/**` | Durable ADRs and discovery index |
| `instance_missions` | `instance/orchestration/missions/**` | Mission continuity authority |
| `state_control_execution` | `state/control/**` | Mutable execution, publication, and quarantine truth |
| `state_evidence` | `state/evidence/**` | Retained evidence, disclosure, and validation receipts |
| `state_continuity` | `state/continuity/**` | Handoff and resumption state |
| `generated_effective` | `generated/effective/**` | Runtime-facing effective outputs |
| `runtime_effective_route_bundle` | `generated/effective/runtime/{route-bundle.yml,route-bundle.lock.yml}` | Single fresh, receipt-backed runtime route bundle |
| `runtime_pack_routes` | `generated/effective/capabilities/{pack-routes.effective.yml,pack-routes.lock.yml}` | Generated runtime-facing pack route view |
| `generated_cognition` | `generated/cognition/**` | Non-authoritative operator and mission read models |
| `generated_proposals` | `generated/proposals/registry.yml` | Non-authoritative proposal discovery |
| `inputs_additive` | `inputs/additive/extensions/**` | Raw additive packs before trust activation and publication |
| `inputs_exploratory` | `inputs/exploratory/**` | Ideation and proposal lineage only |

Full canonical paths, allowed consumers, forbidden consumers, validators, and
doc bindings are maintained in the registry rather than in this document.

## Publication Model

The structural registry recognizes three steady-state publication classes:

1. `runtime_effective`
   - output root: `/.octon/generated/effective/`
   - trust condition: retained publication receipt plus current freshness
     artifacts
   - source rule: no direct raw-input publication into runtime-facing outputs
   - runtime handle rule: runtime-facing reads must resolve through
     freshness-checked handles rather than raw string paths
2. `cognition_read_models`
   - output root: `/.octon/generated/cognition/`
   - role: operator and mission projections only
   - traceability rule: every field must trace back to authored authority,
     control truth, retained evidence, or continuity state
3. `proposal_discovery`
   - output path: `/.octon/generated/proposals/registry.yml`
   - role: deterministic proposal discovery only
   - authority rule: proposal lifecycle still resolves from proposal manifests,
     never from the generated registry

Generated publication metadata remains machine-readable in the registry and
must stay aligned with `octon.yml#policies.generated_commit_defaults`.

The target-state navigation maps are generated from registry-backed truth and
remain non-authoritative:

- `generated/cognition/projections/materialized/architecture-map.md`
- `generated/cognition/projections/materialized/runtime-route-map.md`
- `generated/cognition/projections/materialized/support-pack-route-map.md`
- `generated/cognition/projections/materialized/authorization-coverage-map.md`
- `generated/cognition/projections/materialized/compatibility-retirement-map.md`

## Active Doc Roles

The registry assigns these steady-state roles to the active authoritative docs:

| Doc | Role |
| --- | --- |
| `/.octon/README.md` | Concise super-root orientation and class-root summary |
| `/.octon/framework/cognition/_meta/architecture/specification.md` | Human-readable steady-state structural contract narrative |
| `/.octon/instance/bootstrap/START.md` | Boot sequence and first-run operator orientation |
| `/.octon/instance/ingress/AGENTS.md` | Canonical internal ingress surface for mandatory reads and execution posture |

These docs are registry-backed. They must not carry:

- full hand-maintained canonical path matrices
- historical wave or cutover chronology
- proposal-lineage closeout detail
- inline branch/PR closeout policy that duplicates the dedicated closeout workflow family

Historical migrations and proposal lineage belong in ADRs and retained evidence
rather than in active operating docs.

## Fail-Closed Structural Rules

- Wrong-class placement is invalid.
- Undeclared or disabled overlay content is invalid.
- Runtime or policy direct reads from `inputs/**` are invalid.
- Generated outputs are invalid as authority when freshness or publication
  receipts are missing.
- Repo-root ingress adapters are invalid if they diverge from the projected
  ingress surface.
- Host affordances, chat transcripts, and generated views may mirror state but
  never mint authority.

## Contract Markers

### OCTON-SPEC-015

The umbrella specification is the human-readable companion to the structural
contract registry. The registry is the canonical machine-readable topology and
authority surface; this specification explains the steady-state model without
outranking the constitutional kernel.

### OCTON-SPEC-016

The umbrella specification owns the steady-state structural narrative for
runtime, governance, publication, and practices placement. Detailed canonical
paths, publication metadata, and doc bindings resolve from the structural
contract registry and its delegated registries.

## Canonical References

- structural contract registry:
  `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- constitutional contract registry:
  `/.octon/framework/constitution/contracts/registry.yml`
- root manifest: `/.octon/octon.yml`
- overlay registry: `/.octon/framework/overlay-points/registry.yml`
- overlay enablement: `/.octon/instance/manifest.yml#enabled_overlay_points`
- ingress manifest: `/.octon/instance/ingress/manifest.yml`
- decisions index: `/.octon/instance/cognition/decisions/index.yml`
