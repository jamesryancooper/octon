# Rejection Ledger

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: rejected alternatives and rationale  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Purpose

This ledger records alternatives intentionally rejected by the remediation program so that the target-state does not drift toward attractive but architecture-weak choices.

---

## 2. Rejected alternatives

| ID | Rejected alternative | Reason for rejection | Preserved insight / safer substitute |
|---|---|---|---|
| REJ-001 | Foundational architectural re-write | The prior evaluation found the core foundation sound: class roots, constitutional kernel, fail-closed rules, support targets, mission/run split, generated non-authority, adapter non-authority. A re-foundation would risk discarding strong load-bearing structures. | Moderate restructuring focused on enforcement, proof, consolidation, operator legibility. |
| REJ-002 | Weakening fail-closed posture for adoption speed | Octon’s differentiated value depends on denied/staged behavior when authority, evidence, support, or rollback is missing. | Improve ergonomics and reason-code clarity without weakening default deny. |
| REJ-003 | Treating generated views as authority | Generated views are useful for operator legibility but become dangerous if runtime/policy treats them as truth. | Generated operator views may link to authority/evidence but cannot mint authority. |
| REJ-004 | Broadening support claims before proof | The support-target boundedness is a core strength. Broad claims without conformance evidence create governance theater. | Add support-target proof bundles and stage-only declarations. |
| REJ-005 | Creating a rival control plane | A second control model would collapse Octon’s source-of-truth discipline and create authority ambiguity. | Extend existing `framework/**`, `instance/**`, `state/**`, `generated/**`, `inputs/**` model. |
| REJ-006 | Creating a new topology registry instead of using existing `contract-registry.yml` | The repo already identifies `contract-registry.yml` as machine-readable execution/path/policy invariant registry. A separate registry creates duplication. | Extend `contract-registry.yml` and generate docs from it. |
| REJ-007 | Keeping duplicated topology truth | Repetition is currently useful but drift-prone. | One canonical machine-readable registry plus generated docs and drift validation. |
| REJ-008 | Preserving transitional cutover/wave language in active architecture docs | It makes steady-state operation harder to reason about and increases vocabulary load. | Relocate history to decisions/evidence/migration archives with backlinks. |
| REJ-009 | Letting CI artifacts stand in for retained evidence | CI artifacts are useful transport, but often ephemeral and host-owned. | Retained evidence store contract; CI may upload projections or transport retained bundles. |
| REJ-010 | Turning Octon into a full IDE/OS/cloud platform as part of this remediation | The 10/10 gap is authority/runtime/evidence/validation/operator legibility, not broad ownership of adjacent tooling. | Own authority, authorization, evidence, mission/run control, promotion, support governance; integrate external surfaces through adapters. |
| REJ-011 | Excessive plugin/pack sprawl | Unbounded packs/adapters risk hidden authority and tool sprawl. | Governed pack/admission lifecycle with validation, promotion receipts, and support-target proof. |
| REJ-012 | Hard cutover for all architecture changes | Too risky for runtime and evidence surfaces. | Hybrid bounded cutover: hard for invariants, staged for runtime refactor and operator projections. |
| REJ-013 | Allowing direct `inputs/**` or `generated/**` promotion without receipts | Quiet authority creation violates the architecture. | Promotion/activation contract and receipts. |
| REJ-014 | Making operator views canonical to simplify UX | It would violate generated non-authority and create stale-authority risk. | Operator views remain generated/read-model surfaces with freshness and authority backlinks. |
