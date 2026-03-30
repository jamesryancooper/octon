# Instance Governance Contract Overlays

This directory contains the repo-owned governance overlays that institutionalize
build-to-delete review, retirement tracking, and closeout gating for the
unified execution constitution.

## Canonical Overlays

- `retirement-policy.yml`: policy rules for compensating-mechanism retirement,
  review freshness, and fail-closed closeout
- `retirement-registry.yml`: canonical registry of registered, historical, and
  retired transitional surfaces
- `drift-review.yml`: recurring review contract for stale or over-retained
  kernel-adjacent surfaces
- `support-target-review.yml`: recurring review contract for support-tier,
  admission, and pack-boundary posture
- `adapter-review.yml`: recurring review contract for host/model adapter
  conformance and projection boundaries
- `retirement-review.yml`: recurring review contract for retirement registry
  completeness and active retirement decisions
- `ablation-deletion-workflow.yml`: ablation-backed deletion workflow contract
  for demotion, retention, and removal decisions
- `closeout-reviews.yml`: blocking review/workflow set for the final target-state
  claim
- `disclosure-retention.yml`: repo-owned disclosure and replay retention
  posture for release-grade claims

These overlays remain subordinate to `framework/constitution/**`, but they are
the repo-local contract surfaces that make retirement, ablation, and closeout
enforceable instead of merely advisory.
