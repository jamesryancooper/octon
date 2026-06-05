# Target Architecture

Lifecycle evidence records:

- direct child-owned receipt references for child terminal claims;
- replayable checkpoint or retained evidence pointers when raw control state is
  cleaned;
- compact recovery event summaries;
- stale receipt refresh cause and resulting child-owned evidence path;
- explicit rejection of parent-summary-only child proof.

Parent evidence may summarize aggregate state, but child-owned receipts remain
the only acceptable proof for child lifecycle outcomes.
