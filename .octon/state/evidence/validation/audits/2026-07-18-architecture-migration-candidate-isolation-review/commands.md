# Commands

- `rg --files`, `wc -l`, and full packet inspection over RP-02.
- `validate-proposal-review-gate.sh --package rp02 --print-digest`.
- Controlled `validate-proposal-standard.sh --package rp02` passes.
- `validate-proposal-implementation-readiness.sh --package rp02`.
- `validate-architecture-proposal.sh --package rp02`.
- `validate-proposal-program-structure.sh --package parent`.
- Ordered `yq` extraction plus `diff` for child and parent target equality.
- Targeted inspection of lifecycle launchers, RP-01 census, parent ownership,
  collision records, reconciliation decisions, and ED-001 source lineage.
- `git diff --check` before the receipt-atomic review commit.
