prompt_id: run-program-clean-delivery-autonomy-hardening-end-to-end-lifecycle
generated_at: "2026-07-03T14:30:08Z"
generated_by: codex
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
artifact_class: operational-aid
authority: non-authoritative
child_authority_preserved: yes
intended_outcome: cleaned

# Executable Program Lifecycle Prompt

## Mission

Run the proposal program lifecycle end-to-end for:

```text
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/
```

Execute the lifecycle as self-governed, receipt-backed, and sequential. Start
from live repository state, not from conversation summaries. Continue from
parent program review through child-owned execution, child closeout, child
archive when authorized, parent closeout, Proposal Program Delivery, hosted
landing, final sync, branch cleanup, retained-state disposition, and terminal
verification.

This prompt is operational guidance only. It does not itself authorize
implementation, archive, landing, cleanup deletion, branch deletion, remote
mutation, or a `cleaned` claim. Every effect must be authorized by the owning
route and retained receipt at execution time.

## Mandatory Authority Boundary

Preserve child-owned authority throughout the run.

- Do not let parent summaries satisfy child manifests, child receipts, child
  validation verdicts, child promotion targets, child archive metadata, child
  closeout receipts, or child lifecycle outcomes.
- Run each required child through its own governed packet lifecycle route.
- Parent receipts may summarize child outcomes only by current path and digest.
- Proposal-local support files, generated prompts, generated read models,
  dashboards, host UI state, chat history, model memory, and tool state are not
  authority.
- Classifier output detects residue but never authorizes deletion by itself.

## Mandatory Inputs

Read these parent files before planning:

```text
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/proposal.yml
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture-proposal.yml
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/README.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/resources/child-packet-index.yml
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/resources/child-packet-index.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/resources/source-lineage.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture/packet-sequence.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture/child-packet-contract.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture/program-closeout-plan.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture/implementation-plan.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture/target-architecture.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture/acceptance-criteria.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/validation-plan.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/navigation/source-of-truth-map.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/audit-finding-coverage-review.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/program-creation.md
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/implementation-grade-completeness-review.md
```

For each child, read its child-owned:

```text
proposal.yml
architecture-proposal.yml
README.md
architecture/target-architecture.md
architecture/implementation-plan.md
architecture/acceptance-criteria.md
validation-plan.md
navigation/source-of-truth-map.md
resources/source-lineage.md
support/implementation-grade-completeness-review.md
```

When generated later, child-owned `support/proposal-review.md`,
`support/implementation-run.md`, `support/implementation-conformance-review.md`,
`support/post-implementation-drift-churn-review.md`, `support/validation.md`,
`support/proposal-closeout.md`, `support/proposal-terminal-closeout.yml`, and
archive metadata remain child authority.

## Preflight Inventory

Before any mutation, collect current non-mutating evidence:

```sh
git branch --show-current
git status --short --branch --untracked-files=all
git worktree list
git rev-parse HEAD
git rev-parse main
git rev-parse origin/main
git branch --list 'chore/run-program-clean-delivery-autonomy-hardening*'
git ls-remote --heads origin 'chore/run-program-clean-delivery-autonomy-hardening*'
```

Record whether the source worktree is clean, dirty, stale, detached, or on a
retained branch. If source posture is dirty or stale, do not reconstruct,
stage, commit, push, land, sync, cleanup, or delete branches until a route-owned
clean worktree selection and include-path classification receipt exists.

## Lifecycle Command Surface

Prefer the shared lifecycle runner:

```sh
octon lifecycle run \
  --lifecycle proposal-program \
  --target .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening \
  --execute-routes \
  --invocation-authority unattended \
  --set target_outcome=cleaned \
  --max-child-concurrency 1 \
  --max-steps 200
```

If `octon` is unavailable, use the repo-local launcher:

```sh
.octon/framework/engine/runtime/run lifecycle run \
  --lifecycle proposal-program \
  --target .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening \
  --execute-routes \
  --invocation-authority unattended \
  --set target_outcome=cleaned \
  --max-child-concurrency 1 \
  --max-steps 200
```

If the runner emits a route handoff instead of dispatching, execute the selected
route through its owning lifecycle skill or command, retain the route receipt,
then resume the same program lifecycle from the runner checkpoint. Do not treat
`planned`, `program-route-handoff`, or `route-ready` as child implementation,
child closeout, archive, delivery, or `cleaned`.

## Sequential Child Order

Run required children in registry order. Do not parallelize child execution.

1. `run-program-clean-delivery-compact-blocker-remediation`
   - Owns PM-001.
   - Implement compact blocker-remediation mode, repeated-fingerprint budgets,
     file-count budgets, byte budgets, bounded logs, and full-output threshold
     fail-closed behavior.
2. `run-program-clean-delivery-autonomous-hygiene-continuation`
   - Owns PM-002.
   - Implement target-owned preserve/exclude continuation for
     `artifact-ownership-unclear`, `worktree-hygiene-blocked`, stale hygiene
     fingerprints, dirty worktree ambiguity, and equivalent recoverable closeout
     blockers.
3. `run-program-clean-delivery-stale-branch-retirement`
   - Owns PM-003 and part of PM-007.
   - Implement `source-dirty-anchor`, `route-owned-delivery-branch`,
     correction, cleanup, retained-protected, and retired-stale role labels plus
     no-unique-commit branch retirement.
4. `run-program-clean-delivery-run-health-localization`
   - Owns PM-004.
   - Keep run-health projections diagnostic unless route-promoted by path and
     digest.
5. `run-program-clean-delivery-no-dispatch-deduplication`
   - Owns PM-005.
   - Deduplicate no-dispatch and max-step outputs by unchanged input digest and
     blocker fingerprint.
6. `run-program-clean-delivery-retained-state-reporting`
   - Owns PM-007.
   - Add final retained-state report fields and overclaim validators.
7. `run-program-clean-delivery-authorized-hosted-landing`
   - Owns PM-006.
   - Consume current hosted no-PR landing authorization non-interactively only
     after receipt, provider, rollback, final sync, and execution-environment
     approval-lane checks all pass.

## Per-Child Lifecycle Loop

For each required child, run this loop until the child reaches a terminal
child-owned outcome or a hard stop occurs:

1. Validate child standard, architecture, and implementation-readiness gates.
2. Run child proposal review if missing or stale.
3. If accepted and implementation-authorized, generate the child executable
   implementation prompt through the child route.
4. Implement only the child-owned promotion targets.
5. Run child validators and negative controls from the child validation plan.
6. Emit child `support/implementation-run.md`.
7. Emit and pass child `support/implementation-conformance-review.md`.
8. Emit and pass child `support/post-implementation-drift-churn-review.md`.
9. Run child closeout through child-owned `closeout-packet`.
10. Run child terminal closeout and archive handoff when authorized.
11. Archive the child only when the child closeout receipt authorizes archive.
12. Replan parent from live child receipts, not parent summaries.

Do not advance to the next child while the current required child is in review,
blocked, implemented-but-unclosed, closeout-blocked, archive-unauthorized, or
missing child-owned evidence.

## Program Controller Loop

Run this plan-execute-replan loop until terminal outcome:

1. Plan from live repository state, parent manifests, child registry, child
   receipts, and current run evidence.
2. Dispatch exactly one selected parent route or one selected child route batch.
3. Retain route-decision evidence, selected route ownership, retry fingerprint,
   blocked alternatives, and resume checkpoint.
4. Rerun the blocked or completed gate after each route.
5. Continue sequentially when the gate passes.
6. Switch to compact remediation mode when repeated fingerprints, file counts,
   or byte budgets trigger.
7. Stop only on hard stop conditions listed below.

## Autonomous Recovery Loop

Prefer autonomous governed continuation over passive reporting.

For recoverable blockers such as `artifact-ownership-unclear`,
`worktree-hygiene-blocked`, stale hygiene fingerprints, dirty worktree
ambiguity, stale local branches, artifact-budget breaches, generated diagnostic
churn, no-dispatch repetition, or equivalent closeout ambiguity:

1. Classify the blocker and current fingerprint.
2. Select the narrowest target-owned route.
3. Classify residue into owned, in-scope, retained evidence, publishable
   route-owned receipts, local-private evidence, generated diagnostics,
   duplicate artifacts, disposable residue, foreign residue, ambiguous residue,
   and manual-review residue.
4. Preserve or exclude foreign/ambiguous residue with evidence.
5. Delete only disposable residue that the selected route explicitly
   authorizes by exact path or path class.
6. For cleanup-safe count `0`, prefer non-mutating preserve/exclude evidence.
7. Emit fresh return evidence.
8. Rerun the blocked gate.
9. Continue when the rerun gate passes.

Do not silently delete, reset, archive, stage, commit, push, clean branches, or
mutate refs unless the selected route independently authorizes that action.

## Artifact Budget Rules

Keep artifacts bounded.

- Use repeated fingerprints, file count, and total bytes as budget signals.
- Repeated full workflow directory emission fails closed after a configurable
  threshold and transitions to compact blocker-remediation when safe.
- If the same blocker, validator, or generated-output fingerprint repeats
  without changed inputs, stop producing full duplicate artifacts and emit
  compact delta receipts.
- Deduplicate no-dispatch and max-step outputs by updating one bounded attempt
  ledger with attempt count and timestamp.
- Redirect diagnostics to local-private storage where allowed.
- Promote only final route-owned evidence.
- Treat raw run-health projections as diagnostic read models unless an owning
  route promotes a specific path and digest.

## Hard Stops

Stop and emit a blocked report with the next owning route when any of these
conditions exists:

- unclassifiable foreign residue;
- foreign or ambiguous residue that cannot be safely preserved or excluded;
- destructive cleanup without route authority;
- protected refs or protected branch naming/status;
- external credentials required but unavailable;
- stale, missing, denied, or policy-incomplete authorization;
- provider-policy conflict or host-control denial;
- force-push or remote mutation outside the current receipt;
- missing required child-owned evidence;
- stale accepted review, stale receipt digest, or stale promotion target proof;
- generated read model treated as authority;
- parent summary used as a substitute for child authority;
- conflicting operator instructions.

## Parent Closeout

After all required children are terminal and archived when authorized:

1. Rerun parent standard, architecture, program-structure, and readiness gates.
2. Verify child terminal outcomes directly from child-owned receipts and archive
   metadata.
3. Run parent closeout through `closeout-program`.
4. Do not claim archive authorization unless parent closeout produces a passing
   receipt with `archive_authorized: yes`.
5. Archive the parent only through the parent archive route and only after
   fresh archive authorization.

Parent closeout must cite children by current path and digest. Parent summaries
do not satisfy child authority.

## Proposal Program Delivery

After parent closeout passes and archive handling is complete or explicitly
authorized for later handoff, run Proposal Program Delivery for outcome
`cleaned`.

Use the canonical delivery order:

```text
child implementation -> child validation -> child closeout -> child archive -> parent closeout -> parent archive when authorized -> proposal-program delivery -> Change closeout -> hosted landing -> final sync -> branch cleanup -> retained-state disposition -> terminal proof
```

Before child continuation, parent delivery, Git mutation, landing, sync,
cleanup, branch deletion, or terminal `cleaned` claim, consume a retained
delivery-readiness preflight receipt covering Git write access, worktree
cleanliness, source staleness, review freshness, child receipt compatibility,
tooling, route legality, generated freshness, execution-environment approval
lane, and rollback posture.

Validate aggregate delivery receipt and evidence index:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --index <index>
```

## Landing And Sync

Use current route-owned delivery and hosted no-PR landing receipts.

Consume valid hosted no-PR landing authorization non-interactively only when all
of these validate immediately before mutation:

- source ref;
- target ref;
- exact source SHA;
- required checks or approved empty-check-set rationale;
- no-PR-required status;
- host-control preservation;
- rollback handle;
- final sync plan;
- provider ruleset state;
- execution-environment approval lane, such as pre-approved command prefixes or
  equivalent sandbox/tool authority.

Do not force-push. Do not mutate remote refs beyond the receipt. Do not treat
tool availability, host UI state, or chat approval as route authority.

## Branch Cleanup

After landing and sync:

1. Inventory local and remote refs matching the program branch pattern.
2. Classify branches by role: `source-dirty-anchor`,
   `route-owned-delivery-branch`, correction, cleanup, retained-protected, or
   retired-stale.
3. Prove no unique commits before deleting a stale local branch.
4. If a stale branch is checked out in a dirty worktree, run local-worktree
   retirement first: classify residue, preserve or promote required evidence,
   delete only route-authorized disposable residue, switch to the surviving
   branch, then delete the stale branch.
5. Do not delete remote refs unless a current route-owned receipt explicitly
   authorizes remote cleanup.

## Retained-State Disposition

Classify all remaining residue into:

- required retained evidence;
- publishable route-owned receipts;
- local-private evidence;
- generated diagnostics/read models;
- duplicate repeated artifacts;
- disposable route-authorized residue;
- foreign residue;
- ambiguous residue;
- manual-review residue.

Use owner-specific retained-state localization or repo-hygiene cleanup only when
the selected route authorizes it. Delete only route-authorized disposable
residue. Preserve or exclude foreign, ambiguous, protected, retained, and
manual-review residue with evidence.

## Final Terminal Verification

After the final mutation, verify and report:

```sh
git branch --show-current
git status --short --branch --untracked-files=all
git worktree list
git rev-parse HEAD
git rev-parse main
git rev-parse origin/main
git branch --list 'chore/run-program-clean-delivery-autonomy-hardening*'
git ls-remote --heads origin 'chore/run-program-clean-delivery-autonomy-hardening*'
```

Final reporting must name:

- delivered branch;
- route-owned delivery branch;
- source-dirty-anchor branches;
- retained branches;
- retained worktrees;
- retained evidence;
- deleted residue;
- generated/local-private residue;
- foreign/ambiguous/manual-review residue;
- archive result;
- delivery receipt path and validation result;
- evidence index path and validation result;
- hosted landing receipt path and validation result;
- branch cleanup receipt path and validation result;
- retained-state disposition receipt path and validation result;
- final `main` and `origin/main` refs;
- final worktree status.

Do not overclaim cleanliness. If intentional retained state remains, report it
as retained and classified rather than saying the worktree is clean. Claim
`git_clean_terminal` or `cleaned` only when backed by current route-owned
terminal evidence after the last mutation.

## Expected Outcome

The preferred terminal outcome is:

- all required children terminal and archived when authorized;
- parent closeout passed;
- parent archived when freshly authorized;
- delivery landed on `main`;
- local and remote mutation stayed within current receipts;
- branch cleanup completed where authorized;
- retained state explicitly dispositioned;
- final `main` / `origin/main` alignment verified;
- final worktree status reported without overclaiming cleanliness.

Fallback outcome:

- if the lifecycle cannot safely complete, emit a blocked report with the exact
  hard stop, current evidence, preserved residue classification, highest
  evidence-backed lifecycle outcome, and next owning route.
