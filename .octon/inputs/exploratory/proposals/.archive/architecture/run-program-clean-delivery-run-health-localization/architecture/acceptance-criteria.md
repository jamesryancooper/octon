# Acceptance Criteria

- Ordinary validators do not modify tracked `.octon/generated/.../runs/**`
  health files.
- Speculative projections are local-private, disposable, or regenerable unless
  promoted.
- Promotion receipts name path, digest, source refs, freshness, owning route,
  allowed consumers, and non-authority classification.
- Negative controls reject closure or delivery claims that rely on unpromoted
  generated run-health projections.
