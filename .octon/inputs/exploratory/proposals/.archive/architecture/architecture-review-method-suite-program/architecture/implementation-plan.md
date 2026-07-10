# Implementation Plan (Program Level)

Program "implementation" is child lifecycle orchestration; the parent itself
implements nothing. What is proposal-only versus implementation-authorized:

- **Proposal-only now:** everything in this parent packet — the taxonomy,
  lens bank design, disposition matrix, sequencing, and charters are
  direction, not authorization.
- **Requires later authorization:** every durable change named in the
  disposition matrix happens only inside an accepted child packet through
  the governed lifecycle (create → review → accept → implement → verify →
  close), child by child.

## Orchestration Steps

1. **Program review and acceptance** through the proposal lifecycle (parent
   packet review → acceptance of the suite design and coordination
   structure).
2. **Phase-0 creation:** `architecture-lens-bank-foundation` via the
   governed create-packet route, citing the intake unit as lineage and
   `architecture/lens-bank-design.md` as the design source, re-grounded
   against the live repository.
3. **Phase-1 creation** after the lens bank verifies:
   `architecture-review-method-taxonomy-and-routing` (naming v2, routing
   v2, README, validators).
4. **Phase-2 creation** (parallel) after taxonomy/routing verifies:
   `greenfield-reference-architecture-review-method`,
   `companion-architecture-review-methods`,
   `architectural-review-schema-extensions`.
5. **Phase-3 creation** after all phase-2 children verify:
   `architectural-review-suite-integration` (workflow method recording,
   feature/mechanism notes, lifecycle advisory text, projection refresh,
   closing validator sweep).
6. **Conditional facades:** create `architecture-review-command-facades`
   only on demonstrated operator demand; otherwise route to a no-action
   record at closeout.
7. **Program closeout** per `program-closeout-plan.md` with aggregate
   evidence retained under the declared program evidence root, then archive.

## Per-Child Validation Expectations (bound in the child contract)

| Child | Validation floor |
| --- | --- |
| lens-bank-foundation | Lens-reference validator green with ≥1 negative control (undefined lens id; method missing profile); doc/YAML consistency between `architecture-lens-bank.md` and `lens-bank.yml`. |
| taxonomy-and-routing | Naming and routing validators green against v2 schemas with negative controls (unknown method, duplicate slug, missing default method); no slug or alias regressions; pre-integration gate behavior unchanged (existing fail-closed conditions still fire). |
| greenfield-method | Doc-consistency check against `naming.yml` and `lens-bank.yml`; five required output sections present; reference-architecture-only boundary stated. |
| companion-methods | Same doc-consistency check per method doc; boundary statements against readiness/surface-audit doctrine present; shared contract shape complete for all four docs. |
| schema-extensions | Schema validation of v2 report/routing-decision fixtures, positive and negative (missing method field, unknown lens id); support receipt v1 fixtures still pass unchanged. |
| suite-integration | Full architectural-review validator suite green (naming, routing, receipts, workflows, lifecycle gates, extension split, skills-commands) plus product-feature-catalog validator; projection refresh performed only by canonical publishers with evidence of the refresh run. |
| command-facades (conditional) | Skills-commands validator green; facades invoke existing routes only; negative control proving a facade cannot mint review authority or bypass routing. |

Rollback posture: the parent is coordination-only — "rollback" of the parent
is archival with rationale; child rollbacks are child-owned and declared per
child before implementation (registry `rollback_posture: manual`). Schema
and naming changes must declare v1 coexistence/rollback posture inside their
owning children.

No executor implementation prompts are created at this stage; prompt
generation for children happens through the lifecycle's generate-prompt
routes after child acceptance.
