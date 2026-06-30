# Repository Reconnaissance

## Existing Surfaces Read

- `.codex/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.codex/skills/octon-proposal-lifecycle-run-program-verification-and-correction-loop/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/*.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`

## Findings

- The program lifecycle runner already has an orchestrated replan loop,
  checkpoints, route-decision receipts, model-routing receipts, action slices,
  recovery controls, and child authority boundaries.
- The delivery workflow already names the correct owners for child lifecycles,
  generated publication, Change closeout, repo hygiene, branch cleanup, and
  terminal proof.
- Closeout-change already defaults generic closeout to `cleaned` and allows
  routine branch-no-pr progression without repeated operator prompts when
  governed preconditions pass.
- Closeout-worktree already decomposes dirty worktrees into singular Change
  candidates and can preserve proposal-program handoff residue without
  claiming child authority.
- Evidence disclosure validation correctly rejects hosted/shared receipts that
  depend on local/private refs. The future capability must preserve publishable
  landing and cleanup evidence before local terminal proof synthesis.

## Architectural Direction

Add a policy-backed capability profile that composes existing mechanisms:
program lifecycle execution, program delivery workflow, Change closeout,
worktree closeout, repo hygiene cleanup, branch-no-pr helpers, terminal
evidence writer, proposal metadata generators, and strict validators.
