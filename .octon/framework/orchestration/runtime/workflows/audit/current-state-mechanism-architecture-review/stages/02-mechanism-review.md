---
title: Review Mechanism Architecture
---

Map authority refs, workflow refs, product refs, runtime refs, mutable control
refs, retained evidence refs, generated refs, raw input refs, validators, owner
boundaries, and non-authority boundaries.

Emit the selected method id and applied lens profile as run evidence: write an
`architectural-review-report-v2` artifact (`report.yml`) carrying `method`
(bound to the `naming.yml` methods.catalog) and `lenses_applied` (bound to
`lens-bank.yml` lens ids) into the existing run-evidence root
`.octon/state/evidence/runs/workflows/{run_id}/architectural-review/current-state-mechanism-architecture-review/`.
Fail closed on `unknown_method` or `missing_method_record` per routing v2. The
support receipt stays `architectural-review-support-receipt-v1` and method-free.
