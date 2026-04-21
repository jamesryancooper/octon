# Migration and Cutover Plan

## Cutover posture

The correct posture is **hybrid bounded cutover**.

A hard cutover would be too risky because runtime enforcement, evidence-store, promotion semantics, and operator views affect the control plane. A slow indefinite staged cutover would preserve liminal architecture and duplicated topology truth. The hybrid approach keeps existing constitutional invariants live, introduces new contracts and validators in staged gates, and performs hard cutovers only for bounded surfaces after proof exists.

## Phase 0 — Freeze invariants

Preserve unchanged:

- five-class super-root model;
- authored authority roots;
- generated/input non-authority;
- state/control/evidence separation;
- support-target boundedness;
- mission/run split;
- adapter non-authority;
- overlay restriction.

No remediation branch may weaken those invariants.

## Phase 1 — Registry-first consolidation

Introduce expanded `contract-registry.yml`. Existing docs remain readable but are marked registry-checked. Generated replacements are introduced alongside current docs.

Cutover gate:

- registry validation passes;
- generated docs match active docs;
- no contradiction detected.

## Phase 2 — Validators as warning gates

Add validators initially in report mode:

- authorization-boundary coverage;
- evidence completeness;
- generated/input non-authority;
- promotion receipts;
- support-target proofing;
- operator read-model traceability.

Cutover gate:

- report mode produces stable output for at least one representative run and one proposal/promotion path.

## Phase 3 — Enforcement for new paths

All newly changed material execution paths, generated/effective publications, support admissions, and promotions must satisfy the new validators.

Cutover gate:

- no new bypasses introduced;
- all new support claims proof-backed;
- all new promotions receipt-backed.

## Phase 4 — Runtime boundary hard cutover

Authorization coverage becomes required for all material paths.

Cutover gate:

- complete material path inventory;
- negative bypass suite passes;
- protected execution fails closed when coverage is missing;
- `authorize_execution` call path coverage evidence retained.

## Phase 5 — Evidence-store hard cutover

Run closeout, support disclosure, generated/effective publication, and architecture closure require retained evidence-store conformance.

Cutover gate:

- evidence completeness validator passes for sample run, denied run, staged run, publication, and support tuple.

## Phase 6 — Documentation simplification

Historical wave/cutover/proposal-lineage content is moved to decision records or migration evidence. Active docs are regenerated or registry-checked and reduced to steady-state language.

Cutover gate:

- active docs no longer repeat canonical topology in conflicting hand-maintained form;
- decision records preserve history.

## Phase 7 — Closure certification

Final closure requires:

- all validators passing;
- closure evidence retained;
- decision records created;
- operator read models generated and traceable;
- support tuple proof cards present;
- proposal archived as lineage only.
