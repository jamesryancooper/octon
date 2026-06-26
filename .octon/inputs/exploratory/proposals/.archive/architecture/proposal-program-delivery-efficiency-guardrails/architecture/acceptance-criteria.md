# Acceptance Criteria

## Execution Order

- Delivery profiles with canonical order pass validation without override evidence.
- Delivery profiles with non-canonical requested order fail validation when no override receipt is present.
- Delivery profiles with non-canonical requested order pass only when the override receipt is valid, retained, target-bound, run-bound, and acknowledges efficiency risk.
- Stage 01 stops before lifecycle continuation when alternative order lacks override evidence.

## Readiness Preflight

- The delivery wrapper emits one consolidated readiness receipt before expensive continuation.
- The receipt covers Git metadata write access, source worktree posture, parent review freshness, child receipt compatibility, Bash/Python/YAML tooling, selected route legality, and generated publication freshness posture.
- Any failed preflight item blocks delivery before child reruns, parent closeout, Git mutation, push, landing, sync, cleanup, or branch deletion.

## Clean Worktree Default

- A stale source branch selects a clean route-owned worktree path before commit planning.
- A dirty source branch with unclassified residue selects a clean route-owned worktree path before commit planning.
- Reconstruction requires retained include-path classification evidence.
- Broad stage-all remains rejected unless classification names every included path and proves it is publishable.

## Shared Receipt Semantics

- Child readiness and readiness projection both accept the same legacy archived child validation receipt success forms.
- Both validators reject fail, failed, error, blocked, malformed, missing, or mixed-status validation receipts.
- Strict `verdict: pass` remains enforced for non-validation receipt classes.

## Postmortem Closeout

- Runs that exceed repeated-blocker, recovery, duration, token, or blocker-count thresholds require formal postmortem closeout.
- Missing `evaluation.yml`, `report.md`, `readiness-summary.md`, or stale digest-bound references fail validation.
- A cleaned delivery after recovery cannot claim learned-from completion without validated postmortem evidence.

## Negative Controls

- Prompt text alone cannot authorize alternative order.
- Parent summaries cannot replace child-owned receipts.
- Generated projections cannot authorize publication or route decisions.
- Dirty primary worktree residue cannot be swept into delivery without classifier evidence.
- Missing or stale postmortem artifacts cannot be silently ignored.
