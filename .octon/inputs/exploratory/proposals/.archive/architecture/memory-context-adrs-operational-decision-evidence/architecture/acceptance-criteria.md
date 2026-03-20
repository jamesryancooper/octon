# Acceptance Criteria

The memory-routing and decision-surface architecture proposal is ready for
promotion when all of the following are true:

1. The architecture explicitly states that memory is a routing and
   classification model rather than a directory.
2. The architecture explicitly rejects a generic `memory/` class root.
3. The architecture explicitly identifies
   `framework/agency/governance/MEMORY.md` as the canonical memory-policy
   surface.
4. The architecture explicitly identifies
   `instance/cognition/context/shared/**` as the canonical home for shared
   durable context.
5. The architecture explicitly identifies
   `instance/cognition/context/scopes/<scope-id>/**` as the canonical home for
   scope durable context.
6. The architecture explicitly identifies
   `instance/cognition/decisions/**` as the canonical home for ADR authority.
7. The architecture explicitly identifies
   `instance/cognition/decisions/index.yml` as the machine discovery surface
   for ADRs.
8. The architecture explicitly states that ADRs remain durable authored
   authority.
9. The architecture explicitly states that ADRs are not moved into `state/**`.
10. The architecture explicitly identifies `state/continuity/repo/**` as the
    canonical home for repo continuity.
11. The architecture explicitly identifies
    `state/continuity/scopes/<scope-id>/**` as the canonical home for scope
    continuity.
12. The architecture explicitly states that scope continuity is legal only for
    declared, valid, non-quarantined scopes.
13. The architecture explicitly states that repo continuity is the primary
    home for cross-scope or repo-wide work.
14. The architecture explicitly states that scope continuity is the primary
    home for clearly single-scope work.
15. The architecture explicitly defines the one-primary-home rule for
    detailed active state.
16. The architecture explicitly states that repo continuity may summarize or
    link scope-local work but may not duplicate the same detailed ledger.
17. The architecture explicitly identifies `state/evidence/runs/**` as the
    canonical home for run evidence.
18. The architecture explicitly identifies `state/evidence/decisions/**` as
    the canonical home for operational decision evidence.
19. The architecture explicitly identifies `state/evidence/validation/**` as
    the canonical home for validation evidence.
20. The architecture explicitly identifies `state/evidence/migration/**` as
    the canonical home for migration receipts.
21. The architecture explicitly states that `state/evidence/**` is retained
    evidence rather than active task state.
22. The architecture explicitly states that operational decision evidence is
    retained evidence rather than ADR authority.
23. The architecture explicitly states that operational decision evidence is
    not active task state.
24. The architecture explicitly states that operational decision evidence does
    not become architecture authority by importance alone.
25. The architecture explicitly defines the promotion rule from operational
    decision evidence to ADR authority.
26. The promotion rule explicitly requires a durable architecture or contract
    change.
27. The promotion rule explicitly requires multi-scope or repo-wide normative
    impact.
28. The promotion rule explicitly requires the decision to remain binding
    after the operational episode ends.
29. The architecture explicitly identifies
    `generated/cognition/summaries/**` as the canonical home for generated
    decision summaries.
30. The architecture explicitly identifies `generated/cognition/graph/**` as
    the canonical home for generated graph outputs.
31. The architecture explicitly identifies
    `generated/cognition/projections/**` as the canonical home for generated
    projections.
32. The architecture explicitly states that generated cognition outputs are
    non-authoritative.
33. The architecture explicitly states that generated cognition outputs may
    summarize durable context, ADRs, continuity, and evidence without
    replacing them.
34. The architecture explicitly states that generated decision summaries do
    not belong under `instance/**`.
35. The architecture explicitly treats
    `instance/cognition/context/shared/decisions.md` as duplicate-summary drift
    while it remains a generated ADR summary.
36. The architecture explicitly states that the canonical ADR summary home is
    `generated/cognition/summaries/decisions.md`.
37. The architecture explicitly states that
    `instance/cognition/context/shared/memory-map.md` is a routing guide rather
    than an active state ledger.
38. The architecture explicitly states that
    `instance/cognition/context/shared/continuity.md` is an optional signal
    document rather than continuity authority.
39. The architecture explicitly states that `state/continuity/**` may be
    compacted or reset only through governed workflows.
40. The architecture explicitly states that `state/evidence/**` follows
    retention and archival policy rather than casual regeneration.
41. The architecture explicitly states that `generated/**` may be deleted and
    rebuilt.
42. The architecture explicitly states that
    `instance/cognition/context/**` must not be reset as runtime state.
43. The architecture explicitly states that
    `instance/cognition/decisions/**` must not be reset as runtime state.
44. The architecture explicitly states that memory flush or compaction
    receipts required by policy remain under `state/evidence/validation/**`.
45. The architecture explicitly states that no memory-like artifact may create
    an undeclared second source-of-truth.
46. The architecture explicitly states that no generic `memory/` root may be
    introduced.
47. The architecture explicitly states that generated cognition outputs may
    not be consumed as authoritative inputs.
48. The architecture explicitly states that ADRs may not be authored into
    `state/**`.
49. The architecture explicitly states that operational decision evidence may
    not be treated as an ADR surrogate.
50. The architecture explicitly states that generated ADR summaries may not
    persist inside `instance/**` after cutover.
51. The architecture explicitly states that scope continuity publication fails
    closed when the scope binding is invalid or quarantined.
52. The architecture explicitly states that continuity reset workflows must
    not delete durable context, ADRs, or retained evidence.
53. The architecture explicitly states that docs, indexes, and templates must
    stop pointing at duplicate or legacy summary destinations.
54. The architecture explicitly states that repo continuity migration lands
    before scope continuity in any future migration or repo adoption flow.
55. The architecture explicitly states that scope continuity does not land
    before locality registry and validation are live.
56. The architecture explicitly notes that the current repo already satisfies
    the locality and validation prerequisites for its live scope continuity.
57. The architecture explicitly keeps `instance/cognition/context/**` and
    `instance/cognition/decisions/**` repo-specific by default.
58. The architecture explicitly keeps `state/**` excluded from
    `bootstrap_core`.
59. The architecture explicitly keeps `state/**` excluded from
    `repo_snapshot`.
60. The architecture explicitly keeps `generated/**` rebuildable and
    non-portable as the primary portability unit.
61. The architecture explicitly identifies Packet 10 as the upstream contract
    for generated cognition summaries, graphs, and projections.
62. The architecture explicitly identifies Packet 12 as a downstream consumer
    that must not invent alternate cognition output families.
63. The architecture explicitly identifies Packet 14 as the downstream packet
    that must enforce duplicate-ledger and fail-closed rules.
64. The architecture explicitly identifies Packet 15 as the downstream packet
    that must remove any remaining packet-era memory drift.
65. Validators explicitly check for wrong-class memory placement.
66. Validators explicitly check for duplicate authoritative ledgers.
67. Validators explicitly check that generated cognition outputs are never
    promoted to authority by documentation drift.
68. Validators explicitly check that scope continuity exists only for valid
    scopes.
69. Validators explicitly check that reset and compaction flows do not remove
    durable authority or retained evidence.
70. Teams can explain clearly what is durable context, what is ADR authority,
    what is active continuity, what is retained evidence, and what is only a
    generated view.
