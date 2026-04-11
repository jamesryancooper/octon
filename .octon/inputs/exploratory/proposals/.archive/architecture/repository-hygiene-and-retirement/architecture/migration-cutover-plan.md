# Migration and Cutover Plan

## Profile Selection Receipt

| Field | Receipt |
| --- | --- |
| `release_state` | `pre-1.0` |
| `change_profile` | `atomic` |
| repository default | `atomic` unless a hard gate requires `transitional` |
| hard-gate assessment | none found that requires bounded coexistence between old and new hygiene control planes |
| chosen cutover model | clean-break promotion of authoritative `.octon/**` surfaces, followed immediately by dependent workflow integration and baseline audit |
| transitional exception note | none |
| rationale | the repo has no existing competing hygiene architecture; the command lane is empty; retirement governance already exists; therefore a clean-break capability landing is viable and preferable |

## Why `atomic` is correct here

This proposal introduces a new capability family but does not need a long-lived
coexistence model between two rival control planes. The retirement/build-to-delete
spine already exists and will remain authoritative. The missing pieces are the
repo-specific policy, command, validator, and workflow integrations. Those can
be promoted as one coherent architecture without requiring a temporary
transitional registry or a period where two hygiene systems are both active.

## Cutover preconditions

1. this proposal has reached review-ready approval for implementation use;
2. ownership is assigned to Octon governance and `operator://octon-maintainers`;
3. policy, command, and validator file content is authored and reviewed;
4. repo-local workflow integrations are prepared on the same branch or tracked
   as an explicitly linked same-program follow-on change; and
5. no support-target or capability-pack widening is bundled into the cutover.

## Clean-break execution steps

### Step 1 — stage the authoritative `.octon/**` changes

Prepare the new governance policy, command registration/files, contract deltas,
and assurance validators. Do not claim the capability live yet.

### Step 2 — stage the dependent repo-local integrations

Prepare the workflow changes needed to call the new validator and command.
These edits are not proposal promotion targets, but they are part of the
implementation program and must be present before claiming operational live
status.

### Step 3 — run structural validation on the staged branch

Run proposal validation, syntax validation, and architecture-conformance
validation for the new surfaces. Any unresolved ambiguity routes to fix,
stage-only, or escalation.

### Step 4 — merge the coherent cutover batch

Merge the `.octon/**` authoritative surfaces and the dependent workflow
integrations as one implementation milestone. From this point forward, the repo
has one recognized hygiene architecture.

### Step 5 — run the first baseline audit

Immediately after the cutover batch lands, execute the full audit profile. This
is the first operational proof that the architecture is real rather than merely
documented.

### Step 6 — disposition blocking findings

Before closure or implementation-complete status is claimed, every blocking
high-confidence finding must be:

- fixed,
- registered into the retirement plane, or
- explicitly deferred by a nonblocking rationale if policy permits.

### Step 7 — certify capability landing

After baseline audit, same-change registrations, and dual clean validation
passes, the architecture can be considered landed for proposal-closure
purposes.

## Fail-closed conditions

- missing or ambiguous ownership;
- policy/contract conflict with the live retirement spine;
- any attempt to treat generated views or copied proposal resources as
  authoritative;
- missing workflow integration when claiming the capability operationally live;
- any proposed direct delete against protected, claim-adjacent, or ambiguous
  surfaces;
- any implicit support-target or capability-pack widening.

## Rollback posture

Rollback is clean and ordinary because the cutover is atomic:

- revert the `.octon/**` policy/command/contract/validator changes;
- revert the dependent workflow edits;
- discard the baseline audit artifacts if the cutover is abandoned before
  adoption;
- keep any already-emitted evidence as historical proof of the attempted
  cutover, but do not treat it as ongoing control-plane authority.

## Post-cutover checks

1. command manifest includes `repo-hygiene`;
2. required validators exist and parse;
3. architecture-conformance and closure workflows invoke the new checks;
4. scheduled/full audit emits retained evidence under the declared path;
5. no new transitional finding reaches closure without registry coverage.

## No-partial-compliance rule

Because the selected profile is `atomic`, Octon may not claim this capability
as live while only part of the authoritative architecture is present. Either
all of the required `.octon/**` surfaces plus dependent workflow integrations
exist, or the capability remains not yet landed.
