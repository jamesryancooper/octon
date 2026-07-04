# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-retained-state-reporting-implementation-prompt-20260703T225723Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
lifecycle_id: proposal-packet
route_id: run-packet-implementation
prompt_generation_run_id: lifecycle-proposal-program-1783112176123-f118c03e-run-program-clean-delivery-retained-state-reporting
reviewed_packet_digest: sha256:0eecb0f611b6521c750d23e84e4a0c1b80af0ff03a50b607933d388675d07aa3
prompt_bundle_sha256: sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6
release_state: pre-1.0
change_profile: atomic
non_authority_classification: packet-local-operational-support-only
generated_at: 2026-07-03T22:57:23Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, replace retained evidence, authorize
cleanup, authorize archive movement, authorize branch deletion, authorize
remote mutation, publish generated output, or claim terminal hygiene. Proposal
inputs, generated prompts, generated outputs, parent summaries, dashboards,
host state, chat, model memory, and tool availability remain non-authoritative.

## Prompt Generation Gate Receipt

Prompt generation was allowed after these current gates passed from the
repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --require-implementation-authorization --print-digest
```

The review gate emitted:

```text
sha256:0eecb0f611b6521c750d23e84e4a0c1b80af0ff03a50b607933d388675d07aa3
```

The accepted proposal review records `verdict: accepted`,
`implementation_prompt_authorized: yes`, and
`open_blocking_findings_count: 0`. The implementation-grade completeness
review records `verdict: pass`, `unresolved_questions_count: 0`, and
`clarification_required: no`.

If any packet source, review digest, prompt bundle digest, review receipt, or
pre-integration architecture receipt drifts before implementation, stop and
rerun the owning review or freshness route.

## Required Starting Reads

Before editing, read:

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
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- every file listed in this packet's `navigation/artifact-catalog.md`
- every promotion target listed below that the implementation may edit

Before durable edits, emit a Profile Selection Receipt, Repository
Reconnaissance Receipt, Minimal Implementation Plan, Impact Map, Evidence Plan,
Dependency Receipt, cleanup pass plan, and rollback notes. Use `release_state:
pre-1.0` and `change_profile: atomic`. The dependency receipt should be
`none` unless the implementation intentionally changes dependencies; do not add
dependencies without a separate receipt and validation.

Inspect current diffs before editing. Preserve unrelated local changes and do
not reset, restore, stash, clean, delete residue, switch branches, delete
branches, push, fetch, or mutate hosted refs unless a current route-owned
receipt authorizes the exact action.

## Preconditions

Run these gates before durable target mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --require-implementation-authorization --print-digest
```

Refuse implementation if any gate fails, if `proposal.yml#status` is not
`accepted`, if the accepted review digest is stale, if open blocking findings
appear, if the implementation-grade completeness review no longer passes, or
if satisfying acceptance criteria would require durable targets outside the
manifest without a packet revision or linked accepted proposal.

## Approved Promotion Targets

Durable implementation may touch only these manifest promotion targets and
their necessary in-family files:

- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits, create or refresh only these packet-local implementation
receipts unless another accepted route authorizes more:

- `support/implementation-run.md`
- `support/validation.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Retained validation evidence should live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-retained-state-reporting/`

Do not edit generated/effective outputs by hand. If generated output freshness
is affected, run the owning publisher and retain publication/freshness evidence;
generated outputs remain derived-only.

Do not change `proposal.yml#status`; leave it as `accepted`. A later lifecycle
route owns any implemented-status rewrite, closeout, archive handoff, branch
cleanup, final sync, terminal proof, or `cleaned` claim.

## Explicit Non-Goals

- Do not perform cleanup, archive movement, branch deletion, branch switching,
  remote mutation, hosted landing, or generated publication from this prompt.
- Do not create a parallel cleanup authority, archive authority, branch
  registry, delivery authority, evidence-retention authority, or generated
  freshness authority.
- Do not infer cleanup from parent summaries, child implementation status,
  generated read models, prior postmortems, dashboards, host state, chat,
  model memory, or tool availability.
- Do not claim `source branches deleted`, `cleaned`, `git_clean_terminal`,
  archive authorization, branch deletion, or generated freshness unless the
  final report cites current route-owned evidence for the exact claim.
- Do not collapse similarly named branches. The delivered branch, route-owned
  delivery branch, dirty-anchor branch, retained local branches, and deleted
  branches must stay separately named and dispositioned.

## Repository Starting Points

Reuse and extend existing surfaces before adding new fields, helpers,
validators, or tests:

- `proposal-program-delivery/SKILL.md` already coordinates child lifecycle
  implementation, publication freshness, closeout, archive handoff, Change
  closeout, final sync, cleanup proof, aggregate delivery receipts, and compact
  delivery evidence indexes without taking over child authority.
- `closeout-change/SKILL.md` already owns route-neutral Change closeout,
  branch/PR route selection, branch cleanup authorization, final sync,
  terminal current-state proof, outcome downgrade, and Change receipts.
- `closeout-worktree/SKILL.md` already owns dirty-worktree decomposition,
  wrapper reports, residue classification, repo-hygiene routing, and retained
  residue disposition without authorizing deletion from detection alone.
- `proposal-program-delivery-receipt-v1.schema.json` already requires
  delivery readiness, child receipt coverage, implementation conformance,
  post-implementation drift/churn, generated publication, lifecycle residue
  cleanup, Change closeout, branch authorization, final sync, terminal
  current-state proof, worktree hygiene, delivery evidence index, blockers, and
  non-authority classification.
- `change-receipt-v1.schema.json` already models target lifecycle outcome,
  actual lifecycle outcome, cleanup status, cleanup authorization, cleanup
  evidence, source branch integration, source branch cleanup, stateful
  closeout, terminal current-state proof, and branch cleanup refs.
- `validate-proposal-program-delivery-receipt.sh` already validates aggregate
  delivery receipts, cleaned outcome requirements, branch authorization,
  terminal current-state proof, worktree hygiene, delivery evidence index, and
  non-authority boundaries.
- `validate-change-closeout-lifecycle-alignment.sh` already validates Change
  receipt schema, branch cleanup authorization schema, terminal current-state
  proof, closeout skill docs, policy alignment, and tests.

If an existing field or test already satisfies an acceptance criterion, keep it
and record the coverage in `support/implementation-run.md` and
`support/validation.md` instead of duplicating logic.

## Target End State

Final lifecycle reports and receipts separate retained state from deleted state
and from delivered state. They must be exact enough that an operator can tell
what was delivered, what remains locally, what evidence was retained, what
residue was deleted, what requires manual review, and which claims are backed
by current route-owned evidence.

The durable implementation must make these rows machine-checkable wherever a
final cleanup, delivery, Change closeout, or worktree closeout report can claim
terminal status:

- delivered branch
- route-owned delivery branch
- source-dirty-anchor branches
- retained local branches
- retained worktrees
- retained required evidence
- local-private evidence
- generated diagnostics
- deleted residue
- excluded residue
- manual-review residue
- remote mutation status
- archive authorization
- final current-state proof

Every final cleanup section must include at least these audit-required rows:

- delivered branch
- retained branches
- retained worktrees
- retained evidence

Each row must cite current route-owned evidence or explicitly state `none`.
Broad statements such as "source branches deleted" or "cleanup complete" are
invalid unless every matching retained branch, retained worktree, retained
evidence class, and deleted residue class is named, checked, and dispositioned.

## Ordered Workstreams

1. Inventory final-report and receipt surfaces.

   Run targeted reconnaissance:

   ```sh
   rg -n "final report|final_report|retained|delivery branch|delivered branch|source branch|source_branch_cleanup|cleanup_status|cleaned|git_clean_terminal|terminal_current_state_proof|worktree_hygiene|archive authorization|manual-review|manual_review|generated diagnostics|local-private" .octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery .octon/framework/capabilities/runtime/skills/remediation/closeout-change .octon/framework/capabilities/runtime/skills/remediation/closeout-worktree .octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json .octon/framework/product/contracts/change-receipt-v1.schema.json .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh .octon/framework/assurance/runtime/_ops/tests
   ```

   Record which acceptance criteria are already covered and which gaps remain.
   Reuse existing `source_branch_cleanup`, `terminal_current_state_proof`,
   `worktree_hygiene`, cleanup authorization, stateful closeout, delivery
   evidence index, and residue-routing fields where they already carry the
   needed facts.

2. Add retained-state report fields to receipt schemas.

   Extend `proposal-program-delivery-receipt-v1.schema.json` and
   `change-receipt-v1.schema.json` with the smallest additive schema shape that
   can represent the target rows. Prefer one explicit retained-state report
   object or a clearly named existing final-report object over scattered prose
   fields.

   The schema must require each row to record:

   - row kind or stable field name;
   - subject name, path, ref, or `none`;
   - disposition such as delivered, retained, deleted, excluded,
     manual-review, not-authorized, not-applicable, or blocked;
   - evidence refs for current route-owned proof, or an explicit `none`;
   - blocker or retention reason when disposition is retained, manual-review,
     blocked, excluded, or not-authorized.

   Do not make report text cleanup authority. The report discloses state; it
   does not authorize cleanup, branch deletion, archive movement, generated
   publication, final sync, or terminal hygiene.

3. Update final report instructions in the runtime skills.

   Update `proposal-program-delivery`, `closeout-change`, and
   `closeout-worktree` documentation so final reports must populate the
   retained-state rows from current evidence.

   Required behavior:

   - separate delivered branch from route-owned delivery branch and dirty-anchor
     branches;
   - name every retained local branch that could otherwise be covered by a
     broad "source branch" cleanup statement;
   - name retained worktrees and retained evidence that prevent terminal clean
     claims;
   - classify local-private evidence, generated diagnostics, excluded residue,
     and manual-review residue without implying deletion authority;
   - keep remote mutation status explicit, normally `not-authorized` unless a
     separate current receipt authorizes the exact remote ref operation;
   - keep archive authorization explicit and evidence-backed; absence of an
     archive receipt must report no archive authorization;
   - require final current-state proof for `cleaned` or `git_clean_terminal`
     claims and downgrade or block when proof is missing.

4. Harden delivery and Change validators.

   Extend `validate-proposal-program-delivery-receipt.sh` so aggregate delivery
   receipts fail when final report rows are missing, unclassified, or
   unsupported by current evidence.

   Extend `validate-change-closeout-lifecycle-alignment.sh` so the Change
   receipt schema, closeout skill docs, and representative fixtures require
   retained-state reporting for final cleanup and cleaned/landed closeout
   claims.

   Validators must reject:

   - broad source-branch cleanup language without exact retained/deleted branch
     rows;
   - `cleaned`, `git_clean_terminal`, archive authorization, branch deletion,
     final sync, or generated freshness claims without current route-owned
     evidence;
   - a matching retained local branch that is omitted or not dispositioned;
   - retained worktrees, retained evidence, generated diagnostics, local-private
     evidence, excluded residue, or manual-review residue hidden under a clean
     terminal claim;
   - report rows that rely on proposal-local prose, generated outputs, parent
     summaries, host state, chat, model memory, dashboards, or tool availability
     as authority.

5. Add fixture coverage.

   Add positive and negative controls under
   `.octon/framework/assurance/runtime/_ops/tests/`.

   Required positive controls:

   - valid delivery receipt or final report fixture with delivered branch,
     route-owned delivery branch, retained branches, retained worktrees,
     retained evidence, generated diagnostics, deleted residue, manual-review
     residue, remote mutation status, archive authorization, and final
     current-state proof rows;
   - valid Change closeout receipt fixture where cleanup is completed only
     because branch cleanup authorization, terminal current-state proof,
     worktree hygiene, and retained-state rows all pass;
   - valid blocked or deferred fixture where retained branches or retained
     worktrees are explicitly named and cause downgrade without overclaiming.

   Required negative controls:

   - broad "source branches deleted" claim while a matching retained local
     branch exists but is unnamed or undispositioned;
   - missing retained evidence row in a final cleanup section;
   - missing current evidence for `cleaned`, `git_clean_terminal`, archive
     authorization, branch deletion, or generated freshness;
   - retained local-private evidence, generated diagnostics, excluded residue,
     or manual-review residue hidden under a clean terminal claim;
   - proposal-local support files, generated outputs, parent summaries, host
     state, chat, model memory, dashboards, or tool availability used as
     cleanup or terminal proof.

6. Record implementation receipts and retained validation evidence.

   Create retained validation evidence under the evidence root named above with
   command, cwd, start time, end time, exit code, bounded output excerpts, and
   full-log digest when available.

   Create or update:

   - `support/implementation-run.md`
   - `support/validation.md`
   - `support/implementation-conformance-review.md`
   - `support/post-implementation-drift-churn-review.md`

   `support/implementation-run.md` must summarize durable edits, list touched
   promotion targets, state any acceptance criteria already satisfied before
   edit, cite validators run, confirm no unapproved target was edited, record
   dependency changes as `none` unless intentionally changed, and confirm no
   cleanup, archive movement, branch deletion, branch switching, remote
   mutation, or generated publication was performed by the implementation
   route.

   `support/validation.md` must list each validation command, result, evidence
   ref, and relevant positive or negative controls.

   `support/implementation-conformance-review.md` must include these sections:
   Blockers, Checked Evidence, Promotion Target Coverage, Implementation Map
   Coverage, Validator Coverage, Generated Output Coverage, Governed Mechanism
   Integration Coverage, Rollback Coverage, Downstream Reference Coverage,
   Exclusions, and Final Closeout Recommendation. It must conclude with
   `verdict: pass` and `unresolved_items_count: 0` before implementation can
   be considered complete.

   `support/post-implementation-drift-churn-review.md` must include these
   sections: Blockers, Checked Evidence, Backreference Scan, Naming Drift,
   Generated Projection Freshness, Governed Mechanism Integration Coverage,
   Manifest And Schema Validity, Repo-Local Projection Boundaries, Target
   Family Boundaries, Churn Review, Validators Run, Exclusions, and Final
   Closeout Recommendation. It must conclude with `verdict: pass` and
   `unresolved_items_count: 0` before closeout or archive can be considered.

## Validation Plan

Run at least these commands from the repository root after implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh
```

If a listed command is stale, run the closest current validator that proves the
same claim and record the exact substitution and rationale in
`support/validation.md`.

After creating the post-implementation support reviews, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-retained-state-reporting
```

Refuse closeout, archive-ready, delivered, landed, synced, cleaned, branch
deleted, generated fresh, or terminal hygiene claims until both implementation
conformance and post-implementation drift/churn validators pass with current
receipts.

## Rollback

Rollback removes or supersedes the retained-state reporting fields, skill
instructions, validator checks, and fixtures through this child packet's
governed rollback route. Retained validation evidence and packet-local support
receipts are evidence artifacts; supersede or clean them only through an
explicit governed cleanup or rollback route with current path-and-digest
evidence.

## Closeout Refusal Criteria

Refuse implementation completion and any later closeout/archive claim until all
of the following are true:

- durable edits stayed inside the approved promotion targets;
- final reports include the required retained-state rows or an existing
  equivalent machine-checkable structure with the same semantics;
- every row cites current route-owned evidence or explicitly says `none`;
- broad cleanup language fails when retained branches, retained worktrees, or
  retained evidence are omitted or undispositioned;
- `cleaned`, `git_clean_terminal`, archive authorization, branch deletion, and
  generated freshness claims require current route-owned verification;
- `support/implementation-conformance-review.md` exists and records pass;
- `support/post-implementation-drift-churn-review.md` exists and records pass;
- `validate-proposal-implementation-conformance.sh --package <packet>` passes;
- `validate-proposal-post-implementation-drift.sh --package <packet>` passes.
