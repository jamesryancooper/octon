# Repository Reconnaissance

## Required Context Read

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.codex/skills/octon-proposal-lifecycle-create-packet/SKILL.md`
- `.codex/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`
- `.codex/skills/octon-proposal-lifecycle-closeout-program/SKILL.md`
- `.codex/skills/octon-proposal-lifecycle-run-packet-implementation/SKILL.md`
- `.codex/skills/octon-proposal-lifecycle-run-program-verification-and-correction-loop/SKILL.md`
- `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/workflow.yml`
- `.octon/framework/assurance/evaluators/lifecycle-postmortem/README.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/workflow.yml`

## Existing Surfaces

- `octon-proposal-lifecycle-closeout-packet` already requires
  implementation-grade completeness, implementation conformance, drift/churn,
  review preservation, worktree hygiene classification, and
  `support/proposal-closeout.md` before archive readiness.
- `octon-proposal-lifecycle-closeout-program` adds parent-local aggregate
  conformance and drift/churn receipts while preserving child-owned receipts.
- `octon-proposal-lifecycle-run-packet-implementation` requires
  implementation conformance and post-implementation drift/churn validators
  before implemented or archive-ready claims.
- `octon-proposal-lifecycle-run-program-verification-and-correction-loop`
  shows the aggregate pattern: parent receipts can summarize child state only
  when child authority is preserved.
- `lifecycle-postmortem` is optional, read-only, post-run, and evidence-only.
- `post-integration-architecture-review` is evidence-only and explicitly does
  not replace implementation conformance or drift/churn closeout gates.
- `archive-proposal` owns archive relocation and registry regeneration after
  proposal validation and implemented archival gates.
- `default-work-unit`, `change-closeout-state-machine`, and
  `git-worktree-autonomy-contract` own Change routing, hosted exact-SHA checks,
  branch-no-pr landing authorization, branch cleanup authorization, final sync,
  and cleaned closeout evidence.

## Gap

The packet lifecycle has gates and validators but no parent-style packet
terminal workflow that sequences those gates, handles evidence-generation
residue, delegates material side effects, waits for exact-SHA hosted checks
when required, and emits one packet-local aggregate terminal receipt.

## Design Implication

The new surface should be a packet lifecycle terminalizer. It should coordinate
and validate existing owners rather than moving closeout, cleanup, publication,
Git/GitHub, postmortem, architecture review, or archive authority into the
packet receipt.
