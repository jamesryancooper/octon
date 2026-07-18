# Commands

- `rg --files`, `wc -l`, YAML parsing, and complete RP-02 packet inspection.
- `validate-proposal-review-gate.sh --package rp02 --print-digest`.
- Three controlled `validate-proposal-standard.sh --package rp02` passes.
- `validate-proposal-implementation-readiness.sh --package rp02`.
- `validate-architecture-proposal.sh --package rp02`.
- `validate-proposal-program-structure.sh --package parent`.
- Ordered `yq` extraction plus `diff` for child and parent target equality.
- Canonical proposal-registry and repo-authority index generator write/check.
- Targeted source inspection of named lifecycle-executor integration symbols,
  RP-01 census, parent ownership/collisions, and ED-001 lineage.
- Receipt-atomic strict review and architecture-receipt validation after
  accepted-state materialization.
- `git diff --check`.
