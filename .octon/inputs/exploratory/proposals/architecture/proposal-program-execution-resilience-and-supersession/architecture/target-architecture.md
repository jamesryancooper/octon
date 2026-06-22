# Target Architecture

Proposal-program execution gains three cooperating control layers.

## Ownership Control

- Every proposal-program run records a start-of-run baseline before selecting any mutating route.
- Mutating routes declare route write leases before they touch files, generated outputs, retained evidence, control state, archive paths, or delivery artifacts.
- The lifecycle planner fails closed when the current worktree cannot prove that a path is owned by the active run, covered by a route lease, or intentionally foreign and preserved.
- Isolated worktree use becomes the preferred gate for program execution when the current worktree is polluted or contains foreign/manual residue.
- Autonomous partitioning remains non-mutating until ownership is proven.

## Loop Control

- Blockers are fingerprinted from blocker class, route id, child id when present, relevant path set, evidence refs, digests, and recovery disposition.
- A repeated route is allowed only when the blocker fingerprint or recovery evidence changed.
- Cleanup routes become terminal for the current blocker when cleanup evidence is unchanged or cleanup has already returned the same non-mutating disposition.
- Publication drift and generated freshness repairs have priority over cleanup when drift is the real blocker.
- Token and attempt budgets force a stage-only or blocked route instead of unbounded retry.

## Rescue Delivery

- A polluted run can be frozen as a non-authorizing evidence bundle.
- Deliverable changes are partitioned from foreign/manual residue and local-only runtime residue before any successor route runs.
- Validated child-owned receipts are carried forward by reference and digest; parent evidence never satisfies child gates.
- The rescue path either creates a clean isolated successor run or routes deliverable changes to normal `closeout-change` or `closeout-worktree`.
- Foreign/manual residue is preserved with explicit disposition instead of being deleted, rewritten, archived, or treated as owned.

## Safety Properties

- Proposal inputs remain non-authoritative.
- Generated outputs remain derived-only.
- Parent summaries cannot satisfy child receipts.
- Cleanup detection never authorizes deletion.
- Supersession preserves evidence lineage without authorizing polluted-run mutation.
- Recovery stops before material effects unless the owning route has current authority.
