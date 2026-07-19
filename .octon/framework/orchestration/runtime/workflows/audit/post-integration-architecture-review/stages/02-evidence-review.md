---
title: Review Implemented Architecture Evidence
---

Compare implemented structure to the accepted proposal and current architecture
doctrine. Preserve implementation conformance and drift/churn as hard closeout
gates.

Verify external-tool integrity: external tools remain unmodified, all required
behavior lives in Octon-owned code, only supported interfaces are used, and no
implemented or deferred acceptance condition depends on an upstream change or
private derivative.

Emit the selected method id and applied lens profile as run evidence: write an
`architectural-review-report-v2` artifact (`report.yml`) carrying `method`
(bound to the `naming.yml` methods.catalog) and `lenses_applied` (bound to
`lens-bank.yml` lens ids) into the existing run-evidence root
`.octon/state/evidence/runs/workflows/{run_id}/architectural-review/post-integration-architecture-review/`.
Fail closed on `unknown_method` or `missing_method_record` per routing v2. The
support receipt stays `architectural-review-support-receipt-v1` and method-free.
