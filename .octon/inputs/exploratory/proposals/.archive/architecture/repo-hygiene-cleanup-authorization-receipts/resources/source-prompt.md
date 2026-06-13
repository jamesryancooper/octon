# Source Prompt

This resource records the prompt used to draft the proposal. It is lineage only
and is not policy, runtime authority, or cleanup authorization.

## Prompt

Audit and propose a governed, agent-executable process for post-closeout repo
hygiene that does not rely on ad hoc explicit operator confirmation for every
cleanup action.

Goal: determine how Octon can let agents handle post-closeout lifecycle and
worktree residue accurately, effectively, and safely through retained,
machine-checkable governance evidence rather than late manual confirmation.

The process must preserve fail-closed safety. It should replace repeated ad hoc
operator approval only when Octon governance can prove that cleanup is
authorized, bounded, non-authoritative, unreferenced, and safe.

Context: after a truthful `cleaned` Change closeout, the selected material
Change may be fully landed, local `main` synchronized, and source branch
cleaned, while non-material residue remains:

- local run/control/evidence artifacts
- generated run-health projections
- closeout evidence
- publication/control run artifacts
- ignored local files

Questions to answer:

- Which residue classes can be governed for autonomous cleanup?
- Which residue classes must always remain retained, foreign, or manual-review?
- What evidence would let an agent delete or prune residue without ad hoc
  confirmation?
- Can repo hygiene emit cleanup authorization receipts similar to branch
  landing or cleanup authorization?
- How should authorization prove path safety, non-authority, allowed pattern
  membership, protected-class exclusion, and rollback or discard posture?
- How should generated run-health pruning be governed separately from generic
  local-run cleanup?
- How should `Closeout Worktree` invoke or route this process without becoming
  the cleanup authority?
- How should singular `Closeout Change` avoid overclaiming global hygiene
  cleanup?
- What receipts, validators, tests, and report fields are needed?
- What runtime or platform approvals may still be required after governance
  authorization?

Constraints:

- Do not reintroduce `Closeout Changes`.
- Preserve singular `Change` as the default work unit.
- `Closeout Worktree` remains a wrapper.
- `Closeout Change` may only clean inside the selected Change route boundary.
- Detection alone must never authorize deletion.
- Generated outputs, control artifacts, host projections, ignored files, chat
  state, provider metadata, and tool availability are not authority.
- Durable evidence must be retained, promoted, or explicitly classified before
  deletion.
- Cleanup must fail closed if authorization is missing, stale, malformed,
  denied, or mismatched.

Requested output: produce a findings-first architectural recommendation and, if
feasible, define the authorization receipt schema, cleanup authority boundary,
eligible and forbidden classes, proof checks, helper behavior, rollback or
discard evidence, closeout integration, validators, tests, and acceptance
criteria.
