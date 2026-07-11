# Implementation Plan (Architecture-Level)

This is an architecture-level plan: phases, preconditions, and gates. It
contains no patches and authorizes nothing. Actual implementation requires
governed acceptance of this packet plus implementation planning through the
proper route.

## Preconditions

1. Human governance records the option decision (A or B) and accepts the
   per-override disposition table (`architecture/acceptance-criteria.md`).
2. This packet reaches `accepted` status through the proposal lifecycle
   (review → acceptance), citing the retained review evidence.
3. **Targeted Prompt 4 pre-implementation gate (not yet run):** after
   acceptance and before any implementation planning or executor
   implementation, run a targeted Architecture Readiness Audit
   (`.octon/inputs/additive/.incoming/octon-architecture-review-prompt-library/payload/prompts/04-architecture-readiness-audit.md`,
   targeted mode with the accepted runtime environment-override governance
   architecture supplied — Option B with the self-governance hierarchy).
   Required coverage: authority clarity, per-override disposition
   completeness, validator depth, rollback posture, receipt/evidence plan,
   negative-control design, and preserved operational flexibility. Required
   output: retained evidence under
   `.octon/state/evidence/validation/architecture/reviews/architecture-readiness-audit/<review-id>/`,
   with the exact prompt artifact copied into the bundle and the model
   actually used recorded. Implementation planning must not proceed until
   that evidence exists and is cited by this packet. The gate does not
   reopen the option decision unless the audit finds a material
   architecture-readiness defect.

### Prompt 4 Gate Result Handling (when the gate runs)

The gate run is not a checkbox: its retained evidence must be dispositioned
before implementation planning may proceed.

- **Pass:** implementation planning may proceed through the governed
  implementation-planning route, citing the gate evidence.
- **Readiness defects found:** implementation planning remains blocked; this
  packet must be revised or corrected through its governed route before
  planning proceeds.
- **Gaps in authority boundaries, rollback posture, validator depth,
  receipts/evidence, negative-control design, or operational flexibility:**
  treat as blocking unless human governance explicitly routes a specific gap
  as a non-blocking deferral with owner and trigger. Deferral is prohibited
  for any gap that would weaken authority, fail-closed behavior, evidence
  integrity, or the self-governance guarantees (acceptance criterion 4d).
- **Material change to the accepted architecture:** stop implementation
  planning; revise or supersede this packet through the governed lifecycle
  route; rerun the targeted Prompt 4 gate after the revision.
- **Constitutional conflict surfaced:** stop implementation planning; route
  to the Constitutional Challenge path (per the review library's routing
  amendment) rather than continuing.

The recorded disposition must name: the retained evidence path; prompt
number/title (Prompt 4, Architecture Readiness Audit); the accepted
architecture target; the actual model used; the verdict; blocking findings,
if any; the packet changes made in response; and one explicit decision:
proceed, revise, defer, escalate, or rerun. The gate evidence remains
evidence, not authority; non-blocking findings must be explicitly routed,
never silently dropped.

## Phases (assuming recommended Option B)

1. **Contract authoring (framework docs):** author the runtime
   environment-input contract in `framework/engine/runtime/spec/`; update
   `policy-interface-v1.md` (remaining env inputs + `stage_only_behavior`);
   reserve the candidate FCR id via the charter amendment policy.
2. **Explicit-input replacement (runtime):** publication-path bypass becomes
   an explicit receipted input; execution role/intent become request/config
   fields; policy-mode wrapper export becomes explicit invocation input; test
   seams move to injected configuration. Atomic change set.
3. **Negative control (assurance):** add the env-override invariance
   validator; wire into the assurance plane; retain first passing receipts.
4. **Closure:** re-run the review's authority-boundary check for the
   ambient-environment row; record closure against F-01/F-02 in the packet
   traceability map; proceed to packet verification and closeout via the
   proposal lifecycle.

## Gates

- Phase 2 may not start before Phase 1's contract is accepted (prevents code
  defining the contract by accident).
- Closeout requires the acceptance-criteria rows all green plus retained
  receipts and the negative control passing.

## Rollback Posture

Atomic revert of the landed change set; publication capability verified
post-revert (`support/rollback-plan.md`).
