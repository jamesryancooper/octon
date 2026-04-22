# Repository Baseline Audit

## Audited source classes

This audit is grounded in the live repository surfaces listed below. It does not
execute the runtime, and therefore distinguishes structural/runtime intent from
implemented runtime proof.

## Primary structural sources

| Path | Observed role |
| --- | --- |
| `/.octon/README.md` | Concise super-root orientation; class-root model; canonical registries; bootstrap entrypoints. |
| `/.octon/octon.yml` | Root manifest, portability profiles, runtime input bindings, generated commit defaults, execution governance, receipt roots. |
| `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Machine-readable structural authority for class roots, delegated registries, path families, publication metadata, doc targets. |
| `/.octon/framework/cognition/_meta/architecture/specification.md` | Human-readable companion to the structural registry. |
| `/.octon/framework/constitution/CHARTER.md` | Supreme repo-local constitutional charter. |
| `/.octon/framework/constitution/obligations/fail-closed.yml` | Fail-closed reason-code rules. |
| `/.octon/framework/constitution/obligations/evidence.yml` | Evidence obligations. |
| `/.octon/framework/constitution/precedence/normative.yml` | Normative precedence order. |

## Runtime sources

| Path | Observed role |
| --- | --- |
| `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Mandatory material side-effect authorization boundary. |
| `/.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | Inventory of material classes. |
| `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | Coverage map for known material paths. |
| `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Fail-closed run lifecycle state machine. |
| `/.octon/framework/engine/runtime/crates/kernel/src/main.rs` | Runtime CLI with run-first commands and compatibility workflow wrapper. |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs` | Authority engine implementation exports. |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | Authorization implementation path. |

## Governance and support sources

| Path | Observed role |
| --- | --- |
| `/.octon/instance/governance/support-targets.yml` | Bounded-admitted support universe and non-live surfaces. |
| `/.octon/instance/governance/support-target-admissions/**` | Tuple-level admissions. |
| `/.octon/instance/governance/support-dossiers/**` | Support dossier sufficiency artifacts. |
| `/.octon/instance/governance/capability-packs/**` | Repo-owned capability-pack governance. |
| `/.octon/instance/capabilities/runtime/packs/**` | Repo-local runtime pack admissions/projections. |
| `/.octon/instance/extensions.yml` | Desired extension selection. |
| `/.octon/state/control/extensions/**` | Active/quarantine extension state. |

## Bootstrap and proposal sources

| Path | Observed role |
| --- | --- |
| `/.octon/AGENTS.md` | Projected root ingress adapter. |
| `/.octon/instance/ingress/AGENTS.md` | Canonical internal ingress posture. |
| `/.octon/instance/ingress/manifest.yml` | Mandatory reads, optional orientation, adapter parity, closeout gate. |
| `/.octon/instance/bootstrap/START.md` | Boot sequence and operator orientation. |
| `/.octon/inputs/exploratory/proposals/README.md` | Proposal workspace topology and required files. |
| `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | Base proposal manifest contract. |
| `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Architecture subtype requirements. |

## Baseline conclusion

The live repo has the correct architectural foundation. The transition to 10/10
quality should focus on enforcement, proof, partitioning, simplification, and
retirement rather than adding new categories.
