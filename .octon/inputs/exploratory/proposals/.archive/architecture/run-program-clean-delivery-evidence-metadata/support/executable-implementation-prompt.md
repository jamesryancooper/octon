# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-evidence-metadata-implementation-prompt-20260629T140500Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
lifecycle_id: proposal-packet
route_id: run-packet-implementation
prompt_generation_run_id: 20260629T140500Z-run-program-clean-delivery-evidence-metadata-implementation
reviewed_packet_digest: sha256:834db4b77e7a71b4de0903408ab0756508de0b68a31ec4e0d537123685ca79a8
release_state: pre-1.0
change_profile: atomic
non_authority_classification: packet-local-operational-support-only
generated_at: 2026-06-29T14:05:00Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, replace retained evidence, or
substitute for Change closeout, archive authorization, cleanup authorization,
generated publication receipts, branch authorization, final sync proof, or
terminal current-state proof. The proposal packet remains temporary and
non-authoritative.

## Prompt Generation Gate Receipt

Prompt generation was allowed only after these gates passed from the current
worktree:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
```

The accepted review receipt records `verdict: accepted`,
`implementation_prompt_authorized: yes`, and
`open_blocking_findings_count: 0`.

Observed packet digest at prompt generation time:

```text
sha256:834db4b77e7a71b4de0903408ab0756508de0b68a31ec4e0d537123685ca79a8
```

The required repository anchors and compact prompt-pack source digests supplied
to the route matched at prompt generation time. If any referenced source,
review digest, packet digest, or implementation authorization drifts before
implementation, stop and rerun the owning review or freshness route.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- rationale: receipt schema, terminal local evidence writer,
  disclosure-tier validator, proposal registry generator, and proposal
  artifact-index generator behavior must land as one coherent evidence and
  metadata hardening change.
- transitional exception: not authorized

## Required Starting Reads

Read these before durable edits:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- every file in this packet listed by `navigation/source-of-truth-map.md`
- all promotion targets listed below

Before durable edits, emit a Profile Selection Receipt, Repository
Reconnaissance Receipt, Minimal Implementation Plan, Impact Map, Evidence Plan,
Dependency Receipt, rollback notes, and cleanup-pass plan. The dependency
receipt should be `none` unless the implementation intentionally changes
dependencies; do not add dependencies without separate justification and
validation.

The current worktree may contain existing local changes and untracked lifecycle
or evidence material from adjacent clean-delivery work. Inspect current diffs
before editing, preserve unrelated changes, and do not reset, restore, or
delete user or prior-run work.

## Preconditions

Run these gates before durable target mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
```

Refuse implementation if any gate fails, if `proposal.yml#status` is not
`accepted`, if the review digest is stale, if open blocking findings appear, or
if the implementation would require promotion targets outside the manifest
without a packet revision or linked accepted proposal.

## Promotion Targets

Durable implementation may touch only these manifest promotion targets and
tests or fixtures directly required to prove them:

- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh`

Do not edit generated effective outputs by hand. If an owning generator must
refresh derived proposal metadata after implementation, run the generator and
retain freshness evidence; generated outputs remain derived-only.

Do not change `proposal.yml#status`. The implementation route records
implementation evidence for later lifecycle routes; it does not close,
archive, deliver, land, sync, branch-clean, cleanup, or claim `cleaned`.

## Explicit Non-Goals

- Do not implement runner dispatch, delivery workflow sequencing, archive
  relocation, branch cleanup, Git mutation, hosted provider mutation, repo
  hygiene deletion, final sync, terminal proof synthesis, or any `cleaned`
  completion claim.
- Do not create a second delivery workflow, closeout route, scheduler,
  proposal-local planner, evidence authority plane, metadata publisher, or
  receipt authority plane.
- Do not treat local/private terminal evidence as landing authorization,
  cleanup authorization, hosted check evidence, Change receipt truth, delivery
  authority, archive evidence, generated-publication evidence, or policy
  authority.
- Do not treat generated proposal registry, proposal artifact indexes,
  spines, handoff capsules, navigation inventories, parent summaries, host
  state, chat, tool state, or model memory as authority.
- Do not add durable target files outside the manifest. If the implementation
  proves a schema, validator, workflow, or contract outside the manifest is
  required, stop and route a packet revision or linked proposal.
- Do not claim implemented closeout, archive-ready, delivered, landed, synced,
  cleaned, or cleaned-proof-ready from this prompt or from implementation text
  alone.

## Repository Starting Points

Use the existing Change closeout and proposal metadata machinery:

- `change-receipt-v1.schema.json` already models selected route, target and
  actual lifecycle outcomes, landing authorization, cleanup authorization,
  hosted landing, terminal current-state proof refs and digests,
  publishable-evidence receipt refs, stateful closeout, stop reasons, and
  route-specific constraints.
- `write-terminal-closeout-local-evidence.sh` already writes ignored local
  terminal evidence under
  `.octon/state/evidence/local/terminal-closeout/<change-id>/`, validates
  terminal proof and local evidence manifests, copies proof and receipt
  snapshots, records digests, and declares retained-evidence-only boundaries.
- `validate-evidence-disclosure-tiers.sh` already validates tier contracts,
  publishable evidence receipts, tracked local evidence boundaries, terminal
  local proof digest refs, and hosted/shared closeout refs for local-only,
  generated, or input evidence misuse.
- `generate-proposal-registry.sh` already discovers proposal manifests,
  validates packet identity, renders the derived registry, and checks or
  writes `.octon/generated/proposals/registry.yml`.
- `generate-proposal-artifact-index.sh` already emits digest-bound proposal
  artifact indexes, program spines, optional child handoff capsules,
  source refs, source digests, output refs, non-authority classifications, and
  failure behavior.
- Existing tests include `test-validate-evidence-disclosure-tiers.sh`,
  `test-branch-no-pr-delivery-receipt-builder.sh`,
  `test-change-closeout-state-machine.sh`,
  `test-change-closeout-lifecycle-alignment.sh`,
  `test-hosted-no-pr-landing.sh`,
  `test-generate-proposal-registry.sh`,
  `test-proposal-artifact-index-spine.sh`, and
  `test-proposal-lifecycle-terminal-freshness.sh`.

Extend these surfaces in place. Do not duplicate their roles.

## Workstream 1: Change Receipt Evidence Class Hardening

Update `.octon/framework/product/contracts/change-receipt-v1.schema.json` with
the smallest schema tightening needed to keep hosted/shared `landed` and
`cleaned` claims separate from local/private terminal proof.

Required behavior:

- Hosted/shared terminal outcomes for `branch-pr` and hosted `branch-no-pr`
  routes must require publishable landing and cleanup authorization refs before
  any `cleaned` claim can validate.
- `landed` outcomes must retain landing authorization refs and hosted landing
  evidence appropriate to the selected route.
- `cleaned` outcomes with completed source-branch cleanup must retain cleanup
  authorization refs and cleanup evidence refs.
- Local/private terminal current-state proof refs may corroborate terminal
  state only when paired with SHA-256 digest evidence and retained-evidence-only
  classification.
- Publishable-evidence receipt refs must remain repo-publishable summaries of
  local evidence and must not publish raw local evidence.
- Blocked, escalated, denied, deferred, and stage-only outcomes must preserve
  explicit stop reasons rather than validating as successful closeout.

If these requirements cannot be expressed in the existing schema without
touching non-manifest contract surfaces, stop and record the required packet
revision instead of widening the implementation.

## Workstream 2: Terminal Local Evidence Writer

Harden
`.octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh`
so local/private terminal snapshots remain retained evidence only.

Required behavior:

- Synthesize mode must require publishable landing and cleanup authorization
  inputs before writing a local final Change receipt for a hosted/shared
  `cleaned` terminal snapshot.
- Snapshot mode must refuse or mark blocked when supplied receipt/proof inputs
  would present local/private refs as hosted/shared landing, cleanup, delivery,
  archive, Change, or generated-publication evidence.
- Copied landing and cleanup authorization inputs must be recorded as source
  refs and digest-backed copied files inside the local terminal evidence
  manifest, without converting the local manifest into authorization evidence.
- The generated local manifest must keep `disclosure_tier: local-private` and
  `non_authority_classification: retained-evidence-only`.
- Error paths must be explicit and non-destructive. A missing publishable
  authorization ref should produce a blocked/refused result, not a synthetic
  hosted/shared success receipt.

## Workstream 3: Disclosure-Tier Validator

Extend
`.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`
with positive and negative controls for hosted/shared receipt misuse.

Required behavior:

- Hosted/shared closeout validation must scan all authorization-grade and
  outcome-grade evidence refs that can influence landing, cleanup, delivery,
  archive, Change receipt, stateful closeout, final verification, publishable
  receipt, and terminal proof claims.
- Fail closed when hosted/shared receipts cite local/private terminal evidence,
  generated outputs, proposal paths, or raw input paths as authorization-grade
  refs.
- Allow local terminal proof refs only as digest-backed retained evidence with
  a sibling `terminal-closeout-local-evidence-v1` manifest declaring
  retained-evidence-only posture.
- Require clear blocked-result routing when publishable landing or cleanup
  authorization refs are missing for a hosted/shared terminal claim.
- Preserve existing static tier-contract checks and publishable-receipt checks.

Add fixtures or test cases for accepted hosted/shared refs, accepted local
terminal retained evidence, rejected local/private landing refs, rejected
local/private cleanup refs, rejected generated refs, rejected proposal-path
refs, rejected missing publishable authorization refs, and blocked-result
routing.

## Workstream 4: Proposal Registry Refresh Receipts

Update
`.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
so proposal registry refresh behavior is digest-backed and route-owned without
making the generated registry authoritative.

Required behavior:

- In `--check` and `--write` modes, record enough metadata in command output or
  retained refresh evidence to name source refs, source digests, output refs,
  output digests, owning route or generator, and generated-output
  non-authority classification.
- Preserve deterministic rendering of `.octon/generated/proposals/registry.yml`.
- Preserve proposal manifest authority over generated registry projection.
- Fail closed on missing source manifests, duplicate proposal keys, path
  mismatches, archive metadata drift, stale generated output, or digest
  mismatch.
- If a persistent receipt field in the generated registry would require a
  schema change outside this packet, stop and route a packet revision rather
  than silently changing the schema.

## Workstream 5: Proposal Artifact Index Refresh Receipts

Update
`.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh`
so proposal artifact index, proposal program spine, child handoff capsule, and
navigation inventory refresh behavior carries digest-backed refresh evidence.

Required behavior:

- Preserve existing source refs, source digests, output refs, digest-bound
  freshness, authority boundary, reader preferences, and failure behavior.
- Ensure check/write output or retained refresh evidence names source refs,
  source digests, output refs, output digests, owning generator, generated
  output non-authority classification, and the next owning route when refresh
  cannot complete.
- Keep generated artifacts derived-only and handle-oriented by default.
- Add validation for stale source digest, missing source, stale output,
  generated-registry substitution, missing child handoff when required, and
  navigation inventory freshness where the generator owns that output.

## Workstream 6: Validation And Fixtures

Use existing tests and validators first. Add focused fixtures only where a
behavior is not currently exercised.

Minimum validation set after implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-evidence-disclosure-tiers.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-branch-no-pr-delivery-receipt-builder.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-proposal-registry.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-artifact-index-spine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-terminal-freshness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
```

Also run generator checks for this packet when generated proposal metadata is
refreshed by the owning route:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata --check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh
```

If a check is blocked by unrelated existing worktree drift, record the blocker,
the unrelated path family, and the smallest safe next route. Do not hide or
delete unrelated work to make validation pass.

## Required Post-Implementation Receipts

After durable implementation, produce
`support/implementation-conformance-review.md`.

The conformance review must include:

- `verdict: pass|fail`
- `unresolved_items_count`
- blockers
- checked evidence
- promotion target coverage for every manifest target
- implementation map coverage
- validator coverage with exact commands and results
- generated output coverage and freshness posture
- rollback coverage
- downstream reference coverage
- exclusions
- final closeout recommendation

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
```

After the conformance gate passes, produce
`support/post-implementation-drift-churn-review.md`.

The drift/churn review must include:

- `verdict: pass|fail`
- `unresolved_items_count`
- blockers
- checked evidence
- active proposal-path backreference scan
- naming drift review
- generated projection freshness
- manifest and schema validity
- repo-local projection boundary review
- target-family boundary review
- churn review
- validators run
- exclusions
- final closeout recommendation

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata
```

Refuse closeout, archive, implemented status, archive-ready claims, delivery
claims, branch cleanup claims, terminal proof claims, and `cleaned` claims
until both post-implementation receipts exist and both validators pass.

## Evidence Plan

Retain compact validation evidence under the owning validation evidence root
for this implementation. Evidence must identify:

- command, cwd, runtime, start time, end time, exit code, and bounded output
  excerpt for each validation command;
- disclosure-tier positive controls and negative controls;
- local/private terminal evidence leakage negative controls;
- publishable landing and cleanup authorization positive controls;
- schema validation outcomes for valid and invalid Change receipt fixtures;
- generator source refs, source digests, output refs, output digests, and
  generated-output non-authority classification;
- generated metadata check or write results;
- implementation conformance receipt and drift/churn receipt refs;
- rollback notes for each changed promotion target.

Local/private terminal evidence under
`.octon/state/evidence/local/terminal-closeout/**` remains local operator
evidence only and must not be cited as hosted/shared authorization evidence.

## Rollback Posture

Rollback is atomic across the five promotion targets:

- revert `change-receipt-v1.schema.json`;
- revert `write-terminal-closeout-local-evidence.sh`;
- revert `validate-evidence-disclosure-tiers.sh`;
- revert `generate-proposal-registry.sh`;
- revert `generate-proposal-artifact-index.sh`;
- rerun the relevant validators;
- rerun generator checks or refresh generated metadata through owning
  generators if the implementation produced derived output changes.

Do not hand-edit generated outputs during rollback. If rollback would collide
with unrelated existing work, stop, partition the worktree, and record the
blocker rather than reverting unrelated changes.

## Terminal Criteria For The Implementation Route

The implementation route is complete only when:

- all five promotion targets satisfy the accepted packet scope;
- required tests and validators pass or have explicit blockers recorded;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata`
  passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata`
  passes;
- generated outputs, if refreshed, were refreshed only by owning generators and
  remain derived-only;
- no active durable target depends on this proposal path;
- no local/private evidence is used as hosted/shared authorization evidence;
- no out-of-scope Git, archive, cleanup, branch, terminal proof, delivery, or
  `cleaned` effect was performed.

Delegation is not authorized by this prompt. If a later operator explicitly
authorizes delegation, split only disjoint write scopes and keep the primary
orchestrator accountable for integration, validation, evidence, and final
refusal criteria.
