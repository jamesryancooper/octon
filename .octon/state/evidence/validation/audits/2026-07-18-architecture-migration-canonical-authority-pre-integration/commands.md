# Commands

- `rg --files`, `find`, and `wc -l` over the complete RP-01 packet.
- `validate-proposal-review-gate.sh --print-digest` at the frozen packet.
- Three controlled `validate-proposal-standard.sh --skip-registry-check`
  passes.
- `validate-proposal-implementation-readiness.sh` and
  `validate-architecture-proposal.sh` at draft state.
- `validate-proposal-program-structure.sh` for the parent registry and
  collision graph.
- Ordered `yq` extraction plus `diff` for proposal targets and registry scopes.
- Targeted `rg`, `sed`, and `nl -ba` inspection of authority, lifecycle, kernel
  launch, ownership, acceptance, and evidence-ordering surfaces.
