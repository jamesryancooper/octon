# Durable Hygiene Handoff Fix Steering Prompt

Goal: fix the proposal-program lifecycle so governed `closeout-worktree` handoff evidence cannot make its own worktree hygiene fingerprint stale, then continue the `run-program-to-clean-delivery` lifecycle through governed review, implementation, verification, closeout, archive, delivery, cleanup, and terminal validation until the repository reaches a proven `git_clean_terminal` state.

Main-thread state anchors:

- Target parent program: `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`.
- Target outcome: validated `git_clean_terminal`, not merely an implementation checkpoint or a preserved-residue handoff.
- The parent review/architecture receipt state has already been refreshed and accepted in the main lifecycle path. Do not redo or overwrite accepted parent review evidence unless a validator proves it is stale.
- Preserve child authority throughout: parent program evidence coordinates child work but cannot replace child packet review, implementation, verification, closeout, archive, delivery, or terminal receipts.

Problem to solve:

- The program runner correctly requests `closeout-worktree` evidence when child closeout is blocked by foreign or ambiguous worktree hygiene.
- Writing the governed handoff report and lifecycle return can add new `.octon/state/evidence/**` paths.
- Those new paths may be classified as fresh foreign residue on the next preflight, changing `worktree_hygiene_foreign_fingerprint` and forcing an endless fresh-return loop.

Implementation requirements:

- Treat only validated, same-run `closeout-worktree` handoff reports and returns as same-scope retained evidence for worktree hygiene classification.
- Recognize validated `closeout-worktree-report-v1` handoff reports at the governed evidence locations used by the runner, including YAML and JSON-compatible YAML forms (`.yml`, `.yaml`, `.json`) when schema, digest, and same-scope checks pass.
- Accept a handoff return only when the `lifecycle-interaction-return-v1` consumer is `closeout-worktree`, `outcome.completed` is true, the cited report digest matches the report file, and the report authorization binds to the current program run or current-run classifier/request refs.
- Continue to fail closed for stale returns whose `authorized_foreign_fingerprint` targets a prior classifier path set. A stale prior return is a recovery signal for a fresh governed handoff, not authority to suppress current residue.
- Do not hide arbitrary `.octon/state/evidence/**` residue.
- Preserve fail-closed behavior when a return is incomplete, has the wrong consumer, references a missing report, has a digest mismatch, or points at a different program run.
- Preserve child closeout authority: parent handoff evidence may unblock hygiene preflight but must not replace child receipts, archive authorization, cleanup authorization, or lifecycle outcomes.
- Add regression coverage proving same-run closeout-worktree handoff evidence does not alter the foreign fingerprint while unrelated handoff evidence still blocks.

Verification floor:

- Run the focused classifier test suite.
- Run closeout-worktree/lifecycle interaction validators for any generated handoff evidence used to continue the program.
- After writing handoff evidence, rerun the proposal worktree hygiene classifier for the same run/target and prove the handoff evidence itself is not the source of a new foreign fingerprint.
- Re-run publication freshness before dispatch if lifecycle evidence or generated projections changed.
- Resume or re-run the proposal-program lifecycle with bounded steps and explicit dirty-start lease only when the repository is already dirty and the run evidence records that lease.

Lifecycle continuation:

- If publication freshness preflight blocks dispatch, run the governed publication recovery route, validate freshness again, and continue from the lifecycle planner's next selected route rather than manually skipping ahead.
- If the next selected route is `cleanup-lifecycle-residue`, execute it through its governed evidence contract before retrying child closeout. Treat cleanup classification and disposition evidence as route-owned: do not infer deletion, archive, branch cleanup, or `git_clean_terminal` authority from classifier output alone.
- After `cleanup-lifecycle-residue` completes or records a governed preserved/blocked disposition, retry the proposal-program lifecycle with bounded steps so child closeout can receive a fresh worktree hygiene snapshot and, when needed, a fresh validated `closeout-worktree` handoff return.
- Bind fresh `closeout-worktree` handoff returns to lifecycle-produced classifier snapshots whenever the runtime will consume them. Do not rely on an ad hoc classifier output unless the runtime route explicitly accepts that evidence path.
- Continue all six child packet lifecycles through their own review/readiness, implementation, verification/correction, closeout, and archive handoff routes before parent closeout claims aggregate completion.
- After child and parent closeout/archive readiness are valid, continue through Proposal Program Delivery, Change closeout, governed landing, final sync, branch cleanup, terminal evidence, disclosure-tier validation, delivery evidence indexing, and final `git_clean_terminal` validation.
- If the execution environment prohibits embedded executors, sub-agents, or route-spawned assistants, stop before launching that route, record the route and evidence refs needed to continue, and hand the action back to an allowed main-thread execution context.

Autonomy and blockers:

- Handle low-risk blockers autonomously when the route is governed, non-destructive, and evidence-backed.
- Stop before destructive cleanup, archive, branch deletion, push, merge, or any final `git_clean_terminal` claim unless the required route evidence and approvals exist.
- If the runner still requests a fresh handoff after the classifier fix, generate or update the handoff evidence at stable existing paths when possible, validate it, and retry once before escalating as a remaining lifecycle design blocker.
- Do not claim the blocker is resolved while any required route is merely interrupted, spawned in a prohibited execution context, or represented only by parent summary evidence.

Done gate:

- The work is complete only when all required parent and child lifecycle receipts validate, Proposal Program Delivery and Change closeout receipts validate, archive and cleanup outcomes are route-owned, terminal proof is fresh after the final mutation, and final repository validation proves `git_clean_terminal`.
