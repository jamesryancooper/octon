# Implementation Plan

- proposal: `execution-constitution-completion-closeout`

This closeout is a bounded completion cutover, not a redesign. The goal is to
finish the archived unified-execution proposal in one atomic, clean-break,
big-bang landing that removes the remaining mismatch between the repo’s claimed
final model and its live operational reality.

## Profile Selection

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- rationale:
  - the direction is already chosen and partially landed
  - the remaining work crosses constitution, runtime, evidence, disclosure,
    lab, and retirement surfaces
  - the remaining gaps are dangerous precisely because the current repo can
    over-claim completion while placeholder or bypass paths remain live
  - a compatibility window would preserve the ambiguity this proposal is meant
    to remove

## Atomic Cutover Rule

The implementation must land as one coordinated branch with these
non-negotiables:

1. no coexistence window between the old and final models
2. no helper-authored acceptance bundles remain eligible as live completion
   evidence after landing
3. no legacy authority evidence family remains ambiguous about whether it is
   canonical
4. no placeholder governance overlay remains in the same branch that declares
   the final model complete
5. all docs, validators, generated read models, and retained closeout evidence
   are updated in the same branch

## Atomic Work Package

The branch may still be built from multiple local implementation slices, but
they are not independently releasable. The cutover is accepted only when all of
the slices below land together.

### Slice 1: Canonical Authority Only

Scope:

- remove the remaining gap between authority schemas/runtime code and the live
  retained authority model
- ensure acceptance runs emit canonical decision and grant-bundle artifacts
- remove helper-based authority synthesis from the live acceptance model

Durable outputs:

- populated `state/control/execution/approvals/**`
- populated `state/evidence/control/execution/**` for acceptance runs
- runtime and validation updates that make canonical authority artifacts
  mandatory for acceptance evidence
- retirement or explicit historical demotion for `state/evidence/decisions/repo/**`

Exit gate:

- acceptance runs have canonical authority artifacts
- legacy decision records are not the sole authority evidence for acceptance
- helper scripts cannot synthesize acceptance bundles at all

### Slice 2: Universal Run-First Execution

Scope:

- make the run root the only consequential execution model
- add run continuity under `state/continuity/runs/**`
- prove both mission-backed and run-only supported execution

Durable outputs:

- `state/continuity/runs/**`
- at least one mission-backed supported run bundle
- at least one run-only supported run bundle
- validator and read-model updates that consume run continuity as first-class
  state

Exit gate:

- both acceptance run classes exist
- no acceptance run relies on mission continuity as a substitute for run state
- support-tier routing and mission requirements match the retained artifacts

### Slice 3: Proof And Disclosure Closure

Scope:

- retain structural and governance proof as durable evidence instead of only
  script references
- publish a current-release HarnessCard
- move disclosure toward a clear canonical family

Durable outputs:

- retained structural/governance proof artifacts for acceptance evidence
- current-release HarnessCard
- disclosure-family updates clarifying canonical retention roots
- validator updates that reject incomplete proof bundles

Exit gate:

- acceptance proof spans all required planes
- RunCards and the release HarnessCard reference canonical retained artifacts
- the final model exposes one unambiguous canonical disclosure family

### Slice 4: Retention And Replay Activation

Scope:

- activate the constitutional retention family
- add external replay index support for pointered evidence
- formalize storage-class behavior for replay-heavy evidence

Durable outputs:

- `framework/constitution/contracts/retention/**`
- `state/evidence/external-index/**`
- retention validators and closeout documentation

Exit gate:

- retention family is active, not reserved
- replay-heavy evidence is explicitly classified
- acceptance bundles can point to external immutable replay payloads without
  breaking canonical evidence rules

### Slice 5: Lab And Observability Deepening

Scope:

- expand authored lab topology beyond minimal runtime contracts
- expand observability topology beyond the current measurement/intervention
  schema shell

Durable outputs:

- authored `framework/lab/` surfaces for scenario, replay, shadow, fault, and
  adversarial discovery
- authored `framework/observability/` surfaces for measurement,
  intervention, failure taxonomy, and reporting
- retained evidence showing those surfaces are exercised in closeout validation

Exit gate:

- lab is a real authored behavioral-proof domain
- observability is a real authored reporting domain
- behavioral closeout claims can cite those surfaces directly

### Slice 6: Governance And Retirement Completion

Scope:

- populate repo-owned governance contract overlays
- add retirement governance and release-closeout review surfaces
- explicitly retire or demote remaining transitional helpers, placeholders, and
  ambiguous legacy families

Durable outputs:

- populated `instance/governance/contracts/**`
- retirement policy under repo-owned governance contracts
- retained release evidence for drift review, support-target review, adapter
  review, and deletion review

Exit gate:

- build-to-delete is enforced by durable governance, not only by charter text
- current authoritative docs no longer over-claim completion
- the archived predecessor proposal can be completed without qualifications

## Branch-Level Acceptance Gate

The branch is rejected unless all of the following hold simultaneously:

1. canonical authority artifacts are populated for acceptance runs
2. one mission-backed and one run-only supported run exist under the canonical
   authority path
3. structural and governance proof are retained as durable evidence
4. retention governance is active and external replay indexing exists
5. lab and observability are real authored domains, not minimal shells
6. repo-owned governance contract overlays are populated
7. no authoritative doc, validator, or generated view still describes a mixed
   or transitional steady state

## Final Verification

Run the implementation audit again against the archived proposal and require it
to conclude all of the following:

1. overall verdict is `complete` or `mostly complete`
2. architectural accuracy is `architecturally accurate` or
   `mostly accurate with deviations`
3. no `P1` finding remains on authority, run-first execution, acceptance
   evidence, or over-claimed completion
4. final acceptance criteria from the archived proposal score as implemented,
   except for any explicitly documented intentional design evolution now
   captured in authoritative current surfaces
