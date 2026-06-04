# Program Run Kickoff Prompt

prompt_id: token-efficient-proposal-program-controller-run-kickoff-prompt-20260603T011116Z
created_at: 2026-06-03T01:11:16Z
program_packet_path: .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller
orchestration_prompt_ref: support/program-implementation-orchestration-prompt.md
kickoff_mode: bounded-program-lifecycle-start

Use this prompt to kick off the Token-Efficient Proposal Program Controller
lifecycle run. The program is ready to start only while the parent strict review
gate and program child-readiness gate pass from live repository state.

## Operator Prompt

Act as the single accountable Octon orchestrator for the
`token-efficient-proposal-program-controller` proposal program.

First read:

1. `.octon/instance/ingress/AGENTS.md`
2. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/support/program-implementation-orchestration-prompt.md`
3. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/proposal.yml`
4. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/resources/child-packet-index.yml`
5. `.octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller/support/proposal-review.md`

Then revalidate readiness from live files:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller
```

If either command reports any error or warning, first diagnose whether it is a
routine, in-scope, local correction that can be repaired without widening
authority, such as canonicalizing parent-local child registry syntax or
refreshing a proposal-local review receipt made stale only by that correction.
Apply the smallest valid fix, rerun the failed gate, and continue only after the
strict review gate and child-readiness gate both report `errors=0 warnings=0`.
Stop only for hard blockers: required human approval, irreversible/destructive
action, authority ambiguity, unsupported scope widening, missing ownership,
external effects, or a validation failure that cannot be safely repaired within
the declared program scope.

If both gates return `errors=0 warnings=0`, start with an orchestration-only
program lifecycle handoff:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller
```

Inspect the returned run id, selected route, child batch, blockers, approval
requirements, and evidence/checkpoint paths. Do not treat `planned`,
`program-route-handoff`, or `route-ready` as completed implementation.

If the handoff reports a runnable proof-gated route and no blocker, kick off one
bounded execution step:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller --execute-routes --invocation-authority unattended --executor codex --max-steps 1 --max-child-concurrency 1
```

After that single execution step, stop and report:

- program run id;
- selected parent route or child batch;
- executed route count;
- child packets touched;
- evidence and checkpoint paths;
- validation results;
- approval pauses, blockers, or failures;
- next resume command;
- whether child authority was preserved.

Do not continue into additional execution steps without a new explicit operator
instruction. Do not close out, archive, publish generated state, or claim
implementation completion unless the lifecycle runner and child-owned receipts
prove those states.
