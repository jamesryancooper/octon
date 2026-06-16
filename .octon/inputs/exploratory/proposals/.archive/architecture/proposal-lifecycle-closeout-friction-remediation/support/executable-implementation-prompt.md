# Executable Implementation And Packet Delivery Orchestration Prompt

implementation_prompt_id: proposal-lifecycle-closeout-friction-remediation-implementation-prompt-20260616T122829Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
authorized_by: support/proposal-review.md
pre_integration_architecture_review: support/pre-integration-architecture-review.yml
reviewed_packet_digest: sha256:ea4739171c0801f4f4294cc2f8ed91356d10b225ccad3489e3fc9b8390e1dd8e
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-16T12:28:29Z
delivery_prompt_mode: standalone-packet-implementation-and-terminal-closeout-orchestration
release_state: pre-1.0
change_profile: atomic

This prompt is an operational implementation and delivery aid for the accepted
proposal packet. It does not approve execution, authorize cleanup, authorize
branch landing, widen scope, replace proposal manifests, replace retained
evidence, or make proposal-local files durable authority.

Durable authority may land only in approved promotion targets outside the
proposal path. Proposal-local files, support receipts, generated proposal
registry entries, generated projections, local terminal evidence, host state,
dashboards, provider metadata, chat history, model memory, and tool
availability are implementation input or derived context only. They are not
runtime, policy, control, retained-evidence, cleanup, publication, branch, or
closeout authority.

## Prompt Generation Gate Receipt

This prompt is generated for an accepted architecture packet with a fresh
reviewed packet digest:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
```

The reviewed packet digest recorded by the proposal review and architecture
receipt is `sha256:ea4739171c0801f4f4294cc2f8ed91356d10b225ccad3489e3fc9b8390e1dd8e`.

## Objective

Implement the accepted proposal as one atomic Octon-internal lifecycle
hardening change. Reduce avoidable proposal lifecycle closeout friction by
adding governed publication-freshness preflight, review digest refresh
sequencing, archive residue classification, branch-no-pr empty-check rationale,
branch cleanup authorization clarity, repo hygiene cleanup boundaries, helper
escalation guidance, validators, tests, and packet delivery evidence.

The target end state is clearer and more deterministic lifecycle delivery:

- proposal review, strict pre-integration architecture review, and
  implementation-grade completeness remain separate gates;
- executable implementation prompt generation has a validator-backed path to
  refresh proposal review digest before implementation authorization;
- terminal closeout has a pre-terminal publication freshness bundle for
  capability, extension, runtime route, host projection, proposal registry,
  proposal artifact, and runtime-effective handle checks;
- archive workflow residue is classified as eligible local run residue,
  retained manual-review residue, active control state, or durable evidence;
- `branch-no-pr` authorization records retained rationale when an empty hosted
  check set is explicitly allowed;
- branch landing and cleanup helpers provide actionable sandbox/network/ref
  write escalation guidance without suggesting authority bypass;
- terminal current-state proof remains final post-mutation evidence only.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one coherent lifecycle friction remediation across
  workflows, validators, helpers, contracts, closeout skills, repo hygiene
  guidance, and tests
- transitional exception: not authorized

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and mandatory constitutional/kernel files;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `resources/postmortem-findings.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- `support/pre-integration-architecture-review.yml`;
- live terminal closeout, archive, and create-architecture proposal workflows;
- live publication freshness, proposal lifecycle freshness, terminal closeout
  workflow, archive workflow, change closeout lifecycle, and repo hygiene
  validators;
- live branch-no-pr and branch cleanup git helpers;
- live `cleanup-local-run-artifacts.sh` and
  `classify-change-closeout-residue.sh`;
- live `default-work-unit` and `change-closeout-state-machine` contracts;
- live `closeout-change`, `closeout-worktree`, and `repo-hygiene-cleanup`
  remediation skills;
- focused shell tests under `.octon/framework/assurance/runtime/_ops/tests/`.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the proposal review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, the
pre-integration architecture review verdict is `pass`, and the reviewed packet
digest is fresh.

## Approved Promotion Targets

Durable edits may touch only these approved target families unless a packet
revision explicitly widens scope:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-cleanup.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
- `.octon/framework/assurance/runtime/_ops/tests/`

Packet-local receipts are required after durable implementation:

- `.octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation/support/post-implementation-drift-churn-review.md`

Retained validation evidence should live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/proposal-lifecycle-closeout-friction-remediation/<timestamp>/`
- `.octon/state/evidence/runs/lifecycle/proposal-lifecycle-closeout-friction-remediation/<run-id>/`

## Out Of Scope

Do not implement or edit the `proposal-packet-delivery` aggregate workflow,
command, skill, profile schema, receipt schema, wrapper validators, or
wrapper-specific fixtures. Those are owned by `proposal-packet-delivery-wrapper`.

Do not edit:

- `.octon/generated/**`, except through owning publication scripts after a
  source change requires projection refresh;
- `.octon/state/control/**`;
- `.octon/state/evidence/**`, except retained validation and run evidence
  created by this implementation route;
- `.octon/inputs/**` outside this proposal packet's support receipts;
- `.github/**`, provider settings, branch protection settings, root adapters,
  or host projections except through owning publication scripts.

Do not create a new default work unit, convert `branch-no-pr` into PR-backed
routing, weaken review/pre-integration/conformance/drift/archive/branch cleanup
gates, hand-edit generated projections, delete active control state, delete
durable evidence, or treat generated output, terminal evidence, helper output,
host state, chat, dashboards, model memory, or tool availability as authority.

Do not change `proposal.yml#status` to `implemented` during durable code edits.
The later proposal closeout route owns implemented-status and archive mutation
after implementation conformance and drift/churn receipts pass.

If implementation requires an out-of-scope file, authority-class widening,
wrapper-owned target, generated hand edit, destructive cleanup of current
residue, branch deletion, PR creation, host setting mutation, or target-family
widening, stop and report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory proposal standard, architecture, review, and readiness
   gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/proposal-lifecycle-closeout-friction-remediation/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for terminal closeout freshness, review digest
   refresh, archive residue classification, branch-no-pr empty-check rationale,
   branch cleanup authorization, repo-hygiene cleanup boundaries, sandbox
   guidance, and wrapper-owned delivery surfaces.

### 1. Publication Freshness Preflight

Update terminal closeout workflow guidance and validators so packet terminal
closeout runs a pre-terminal freshness bundle before final archive-ready
evaluation.

The implementation must cover:

- capability projections;
- extension projections;
- runtime route projections;
- host projections;
- proposal registry projections;
- proposal artifact outputs;
- runtime-effective handles.

Generated outputs must remain derived-only and refreshed through owning
publication or registry scripts. Negative controls must prove stale generated
projections fail closed and cannot be repaired by hand edits.

### 2. Review Digest Refresh Sequencing

Clarify the create, review, and implementation-prompt sequence so generating
or refreshing `support/executable-implementation-prompt.md` cannot leave a
stale accepted review digest.

The implementation must:

- keep implementation-grade completeness distinct from proposal acceptance;
- require accepted proposal review before implementation prompt generation;
- require the review digest to be refreshed after digest-covered packet
  changes;
- keep proposal-local prompt generation as operational aid, not durable
  authority;
- add validator or workflow coverage for the sequence.

### 3. Archive Residue Classification

Improve archive workflow and repo hygiene classification so validation-only
archive subruns and publication side effects route consistently.

The implementation must:

- classify eligible untracked, unreferenced local run residue for possible
  governed cleanup;
- retain active control state and durable evidence unless a separate governed
  route explicitly classifies them for manual review;
- ensure detection alone never authorizes deletion;
- preserve cleanup authorization receipt or explicit operator confirmation
  requirements;
- add negative controls proving protected residue fails closed.

### 4. Branch-No-PR Empty Check Rationale

Require or validate retained rationale when `branch-no-pr` authorization uses
an explicitly allowed empty hosted check set.

The implementation must:

- preserve exact source SHA, landing authorization, fast-forward proof, and
  final `origin/main == landed_ref` requirements;
- keep `branch-no-pr` PR-free;
- fail validation when an empty hosted check set lacks retained rationale;
- avoid treating absence of hosted checks as equivalent to passing checks.

### 5. Branch Cleanup And Sandbox Guidance

Add operator-facing guidance to branch landing and cleanup helpers so
restricted sandboxes fail with actionable messages when git ref writes,
fetches, pushes, or remote branch checks are required.

The implementation must:

- keep sandbox escalation inside governed helper reruns;
- avoid suggesting bypass of platform, provider, sandbox, or host controls;
- preserve branch cleanup containment, open-PR, rollback, and authorization
  checks before local or remote branch deletion;
- update `closeout-change` and `closeout-worktree` guidance where operators
  encounter these helper routes.

### 6. Contracts, Skills, Validators, And Tests

Update the closeout contracts, remediation skills, validators, and focused
tests so every durable behavioral claim is machine-checkable.

Coverage must include:

- terminal closeout publication-freshness preflight;
- archive workflow residue classification;
- repo hygiene cleanup authorization boundaries;
- branch-no-pr empty-check rationale;
- branch cleanup authorization posture;
- sandbox-sensitive helper guidance;
- proposal review digest freshness after prompt generation;
- wrapper-owned aggregate delivery route exclusion.

### 7. Publication Refresh

If source changes require generated projection updates, refresh them only
through owning scripts. Retain publication receipts and rerun freshness
validators after publication. Do not hand-edit generated projections.

### 8. Implementation Receipts

After durable edits and validation, create or refresh:

- `support/implementation-run.md`;
- `support/implementation-conformance-review.md`;
- `support/post-implementation-drift-churn-review.md`.

Each receipt must record verdict, validation commands, evidence refs,
unresolved counts, blockers, rollback posture, non-authority boundaries, and
explicit refusal criteria. The conformance and drift/churn receipts must pass
their validators before any closeout or archive claim.

## Validation Floor

Run the smallest credible validation set that covers changed surfaces, with at
least these commands when the corresponding validators exist:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation --run-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh
```

Run focused tests under `.octon/framework/assurance/runtime/_ops/tests/` for:

- stale publication freshness fail-closed behavior;
- stale review digest fail-closed behavior;
- undeclared archive residue deletion refusal;
- cleanup detection versus deletion authorization;
- missing empty-check rationale refusal;
- branch cleanup authorization refusal;
- sandbox escalation guidance coverage;
- wrapper-owned delivery surface exclusion.

After implementation receipts are written, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
git diff --check
```

If generated proposal registry or artifact projections are refreshed, also run
the owning registry and artifact index validators before terminal closeout.

## Packet Delivery Orchestration

Carry the packet from implementation through delivery in this order:

1. Implement only the approved durable target changes.
2. Run the target validators and focused negative controls.
3. Refresh generated projections through owning scripts when required by source
   changes, then rerun freshness validators.
4. Write `support/implementation-run.md` with the change profile, touched
   targets, evidence directory, validation commands, rollback posture, and
   unresolved count.
5. Write `support/implementation-conformance-review.md` and run
   `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation`.
6. Write `support/post-implementation-drift-churn-review.md` and run
   `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation`.
7. Run terminal closeout workflow validation, archive workflow validation,
   publication freshness validation, repo hygiene governance validation, branch
   helper negative controls, and `git diff --check`.
8. Route Change closeout through the governed `closeout-worktree` or
   `closeout-change` route selected by the default work unit policy.
9. If using `branch-no-pr`, obtain branch landing authorization before hosted
   mutation and retain exact SHA, empty-check rationale when applicable,
   fast-forward, and final `origin/main == landed_ref` proof.
10. Obtain branch cleanup authorization before local or remote branch deletion.
11. Record terminal current-state proof after the final mutation and after
    cleanup, with refs and worktree state current at that moment.
12. Verify final sync and clean worktree proof.
13. Only then claim implementation delivery, implemented-status readiness, or
    archive readiness.

Do not claim closeout, archive readiness, cleaned branch state, publication
freshness, implementation conformance, drift/churn pass, or final delivery from
intermediate terminal output, stale receipts, helper output alone, generated
projections, host state, dashboards, chat history, or model memory.

## Closeout Refusal Criteria

Refuse closeout or archive if any of the following are true:

- proposal review, pre-integration architecture review, implementation
  readiness, conformance, or drift/churn receipts are missing or failing;
- the reviewed packet digest is stale for a digest-covered packet change;
- publication freshness is stale or generated projections require hand edits;
- terminal current-state proof is absent after the final mutation;
- archive residue is unclassified or deletion is inferred from detection;
- branch-no-pr empty hosted check sets lack retained rationale;
- branch cleanup lacks governed authorization;
- sandbox escalation guidance suggests bypassing platform or host controls;
- wrapper-owned aggregate delivery surfaces are changed under this packet;
- final validation or `git diff --check` fails;
- final worktree is dirty from unclassified or unrelated changes.

## Rollback

Rollback is a repo-local revert of the authored workflow, validator, helper,
contract, skill, and test changes, followed by generated projection refresh
through owning scripts when those projections were updated. Retained
validation, publication, branch, cleanup, and terminal evidence remains
historical evidence only and must not authorize mutation or closeout after
rollback.

## Next Lifecycle Route

The next lifecycle route is `run-packet-implementation`.
