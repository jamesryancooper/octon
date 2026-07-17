# Validation

Require evidence that:

- omitted outcomes resolve to `preserved`;
- direct-main, hosted branch-no-PR, landed, synced, cleaned, cleanup, and other
  effectful/default requests fail with
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`;
- every candidate and path is classified and preserved;
- initial and final refs/worktrees/status remain equal;
- no downstream effect route was invoked;
- no staging, commit, push, landing, sync, cleanup, deletion, archive,
  publication, branch mutation, provider mutation, or false success occurred;
- report flags remain read-only/non-mutating and `cleaned_claim: false`; and
- RP-06/RP-08 are recommendations only.

Any mismatch fails closed and keeps `worktree_terminal_state: nonterminal`.
