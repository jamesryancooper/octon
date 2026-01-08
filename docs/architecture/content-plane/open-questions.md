# Open Questions

These should be validated with real repo usage before committing further complexity:

1. **Markdown format choice**: plain Markdown + directives vs Markdoc tags vs limited MDX.
2. **Locale storage convention**: suffix vs subfolders (choose once; enforce).
3. **Embeddings strategy**: keep private in CI artifacts vs ship a local index.
4. **Lease visibility across PRs**: do you need a GitHub API overlap check, or is orchestration sufficient?
5. **Asset pipeline depth**: repo-stored vs object storage pointers; image transforms now vs later (Lee's CMS cost breakdown shows why hosted CDNs can get expensive).
6. **How much IR block standardization is worth it**: start with a small block set (hero/prose/cta/pricing) and grow only when reuse demands.
7. **Runtime layer trigger criteria**: What specific metrics or events should trigger the escalation from build-only to runtime layers? (See [runtime-content-layer.md](./runtime-content-layer.md and [boundary-conditions.md](./boundary-conditions.md) for framework.)
8. **Runtime sync-back cadence**: For runtime write scenarios, what's the optimal sync-back frequency to git? Per-change, scheduled, or threshold-based?
9. **Runtime schema evolution**: How should schema migrations be coordinated between canonical (git) and runtime (server DB) layers?
10. **Runtime content governance**: Should runtime content have the same risk-tier enforcement as canonical, or relaxed rules for live updates?
