# I/O Contract

Inputs are the exact worktree/ref baseline, optional scoped include/exclude
paths, ownership hints, validation floor, rollback posture, and evidence refs.
An omitted target means `preserved`.

Output is `closeout-worktree-report-v1` with:

- exact initial/final inventory refs and digests;
- candidate partitions and preservation dispositions;
- `read_only_classification: true`;
- `direct_material_actions_performed: false`;
- `repo_hygiene_cleanup_actions_performed: false`;
- `cleaned_claim: false`;
- `containment_reason: RP00_CONTAINMENT_PUBLICATION_DISABLED` when applicable;
- `worktree_terminal_state: nonterminal` or preservation-only disposition; and
- RP-06/RP-08 as a later owner when publication/cleanup was requested.

The report cannot authorize or claim staging, commit, push, landing, sync,
cleanup, deletion, archive, publication, branch mutation, provider mutation,
or target lifecycle completion. Historical receipt fields remain
compatibility-only.
