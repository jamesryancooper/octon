# Program Run Kickoff Prompt

prompt_id: autonomous-lifecycle-blocker-recovery-run-kickoff-prompt-20260604T150106Z
created_at: 2026-06-04T15:01:06Z
program_packet_path: .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
orchestration_prompt_ref: support/program-implementation-orchestration-prompt.md
kickoff_mode: lifecycle-first-then-closeout-worktree

Use this prompt to run the accepted Autonomous Lifecycle Blocker Recovery
proposal-program lifecycle, then close out the resulting dirty worktree through
the wrapper sequence. The current dirty worktree is not a lifecycle preflight
blocker. Do not run hygiene or closeout before the lifecycle unless a live
validation gate proves that pre-lifecycle residue is blocking execution.

## Operator Prompt

Act as the single accountable Octon orchestrator for the
`autonomous-lifecycle-blocker-recovery` proposal program.

First read:

1. `.octon/instance/ingress/AGENTS.md`
2. `.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery/support/program-implementation-orchestration-prompt.md`
3. `.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery/proposal.yml`
4. `.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery/resources/child-packet-index.yml`
5. `.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery/support/proposal-review.md`

Then revalidate readiness from live files:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
```

If any command reports an error or warning, diagnose whether it is a routine,
in-scope, local correction that can be repaired without widening authority, such
as refreshing a proposal-local review receipt made stale only by this kickoff
prompt, refreshing stale child receipts through child-owned routes, rerunning a
freshness gate, or routing cleanup through repo-hygiene-cleanup when a validator
explicitly requires cleanup. Apply the smallest valid fix, rerun the failed
gate, and continue only after all three gates report `errors=0 warnings=0`.

Stop only for hard blockers:

- destructive action without cleanup authority or explicit approval;
- ambiguous ownership;
- missing child-owned authority or missing child receipts;
- parent summaries being the only proof of child state;
- unsupported scope expansion;
- external permission, provider, or human-review requirements;
- validation failures that cannot be safely repaired within declared scope.

When the gates pass, start the proposal-program lifecycle with a planning
handoff:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery
```

Inspect the returned run id, selected route, child batch, blockers, approval
requirements, evidence paths, and checkpoint path. Do not treat `planned`,
`program-route-handoff`, `route-ready`, or parent summaries as completed child
implementation.

If the handoff reports a runnable proof-gated route and no blocker, execute one
bounded route step:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery --execute-routes --invocation-authority unattended --executor codex --max-steps 1 --max-child-concurrency 1
```

After each bounded execution step, inspect the summary, checkpoint, and event
log. If the run reports `max-steps-exhausted` with no blocker and the checkpoint
or summary says execution can resume, continue with:

```sh
.octon/framework/engine/runtime/run lifecycle resume --run-id <program-run-id>
```

Repeat bounded resume/inspection only while the lifecycle runner proves that
execution can resume without approval or unsafe state. Handle routine blockers
autonomously by applying the smallest in-scope repair, rerunning the failed
validation, and resuming from the retained run. Stop for hard blockers only.

When the lifecycle runner reaches a terminal completed state proven by
child-owned receipts and retained evidence, run `closeout-worktree` for the
current dirty Octon worktree. Treat the completed lifecycle run as context and
use the runner summary, checkpoint, event log, child receipts, validation
evidence, cleanup evidence, and closeout evidence as inputs.

The closeout sequence must:

- bind repo policy and closeout contracts;
- inventory branch, local `main`, `origin/main`, `HEAD`, staged, unstaged,
  untracked, ignored, generated, evidence, input-surface, and branch residue;
- run the read-only residue classifier;
- classify lifecycle-owned input/archive moves, generated effective artifacts,
  proposal registry updates, and publication evidence as publishable only when
  policy permits;
- classify local run-state residue separately;
- route local run-state cleanup only through `repo-hygiene-cleanup` with fresh
  receipt-backed cleanup authority;
- re-inventory after each delegated closeout or cleanup;
- delegate exactly one coherent publishable candidate at a time through
  `closeout-change`;
- commit and push only after the direct-main/cleaned route validates and proves
  `main == origin/main == landed_ref`.

Do not blindly `git add -A`. Do not delete residue directly from
`closeout-worktree`. Do not publish local-private run residue unless the
classifier and policy classify it as publishable evidence. Do not treat parent
lifecycle summaries as child receipts.

Final report must include:

- program run id;
- selected route or child batch history;
- executed route count;
- child packets touched;
- lifecycle evidence, checkpoint, and event log paths;
- closeout candidates and dispositions;
- cleanup authorization refs;
- commit SHA and push result, if committed and pushed;
- validation results;
- retained residue;
- remaining blockers or approval pauses;
- next resume command, if nonterminal;
- whether child-owned authority was preserved.
