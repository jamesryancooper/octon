# Commands

- `rg --files` and `wc -l` over the complete RP-00 packet.
- `validate-proposal-review-gate.sh --print-digest` at the frozen packet.
- Three controlled `validate-proposal-standard.sh --skip-registry-check` passes.
- `validate-proposal-implementation-readiness.sh` at the draft state.
- `validate-proposal-program-structure.sh` for the parent registry and graph.
- Ordered `yq` extraction plus `diff` for proposal targets and registry scopes.
- Targeted `rg` and `git diff` inspection of current routes, Git helpers,
  provider workflows, inventories, validation surfaces, and candidate history.
