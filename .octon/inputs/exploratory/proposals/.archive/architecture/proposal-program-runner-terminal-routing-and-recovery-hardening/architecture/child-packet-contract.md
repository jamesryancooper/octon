# Child Packet Contract

Each child packet owns its manifest, implementation plan, validation plan,
evidence plan, rollback posture, promotion targets, implementation receipt,
conformance receipt, drift/churn receipt, closeout receipt, archive metadata,
and terminal outcome.

The parent program may coordinate sequence, dependencies, and aggregate
readiness. It must not satisfy child receipts, edit child validation verdicts,
rewrite child promotion targets, decide child archive metadata, or claim child
terminal outcomes.

Every child must preserve these boundaries:

- runner orchestrates only;
- workflow routes own promotion and archive mutation;
- cleanup mutation stays with cleanup routes/helpers;
- Change closeout remains `closeout-change` / `closeout-worktree` owned;
- publication and registry refresh stay script/tool owned;
- generated state remains non-authority;
- no new proposal statuses;
- local-only raw evidence is never required for hosted closeout/archive;
- scheduler route inventory comes from lifecycle contracts and fresh effective
  projections, not skill or prompt bundle discovery alone.
