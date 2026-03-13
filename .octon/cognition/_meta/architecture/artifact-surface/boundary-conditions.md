# Artifact Surface Boundary Conditions & Warning Signs

## Quantitative thresholds

Reconsider or escalate if:

- **Build time > 5 minutes** consistently (indexing too slow; need incremental builds, caching, or alternative storage).
- **Merge conflicts weekly** on content (need stricter leasing, more granular docs, or real-time tooling).
- **> 3 frequent non-technical editors** (add a minimal GUI).
- **Content must update without deployment** (need runtime layer—see [runtime-artifact-layer.md](./runtime-artifact-layer.md)).
- **> 10,000 content items** (indexes/search become heavy; consider specialized systems).
- **Agent collision rate > 5%** of runs (coordination failure; strengthen orchestration + leasing).
- **Personalization/A/B testing required** (need runtime write layer—see [runtime-artifact-layer.md](./runtime-artifact-layer.md)).
- **Real-time subscriptions needed** (need server DB—see [runtime-artifact-layer.md](./runtime-artifact-layer.md)).

## Qualitative indicators

Warning signs you're "building a CMS":

- You're spending meaningful time on scheduling, workflow UI, custom approval states, or bespoke asset tooling beyond minimal scripts (Knut's "six months" warning).
- You're adding a runtime authoring API with auth, roles, or sync.
- You're repeatedly re-implementing query parsing or schema evolution outside the compiler.

## Escalation paths

If thresholds are crossed, escalate in this order:

1. **Improve compiler**: incremental builds, caching, better SQL indexes.
2. **Add Tier 1 runtime read layer**: edge-replicated SQLite (Turso/D1/LiteFS) for global reads and mobile/offline needs. See [runtime-artifact-layer.md](./runtime-artifact-layer.md).
3. **Add Tier 2 central read layer**: server DB read replicas for complex queries and aggregations.
4. **Add Tier 3 runtime write layer**: server DB (Postgres/Supabase) for live overrides, personalization, and content updates without deployment. See [runtime-artifact-layer.md](./runtime-artifact-layer.md).
5. **Add minimal editor UI**: git-backed UI (Keystatic/Decap) if SMEs blocked.
6. **Adopt a CMS** only if:

   - you require real-time collaborative editing as a core feature,
   - complex multi-stage workflows/audit beyond PR-based review,
   - multi-tenant content isolation with per-tenant schemas,
   - or content changes hourly without deploy constraints AND runtime write layer is insufficient.

## Runtime layer decision matrix

Use this matrix to determine when to add runtime layers:

| Need | Stay Build-Only | Add Runtime Read | Add Runtime Write |
|------|-----------------|------------------|-------------------|
| Fast global reads | ❌ | ✅ | — |
| Mobile offline sync | ❌ | ✅ | — |
| Sub-100ms latency | ❌ | ✅ | — |
| Content updates without deploy | ❌ | ❌ | ✅ |
| Personalization | ❌ | ❌ | ✅ |
| A/B testing | ❌ | ❌ | ✅ |
| Real-time subscriptions | ❌ | ❌ | ✅ |
| Concurrent multi-user editing | ❌ | ❌ | ✅ |

See [runtime-artifact-layer.md](./runtime-artifact-layer.md) for complete runtime layer specification.
