---
title: Run Balanced Review
---

Apply the Balanced Architecture Review Method: charter, system job, current
reality map, steelman, Chesterton's Fence, constraints, complexity, bottlenecks,
clean-sheet comparison, target architecture, authority boundaries, evidence
plan, validation plan, and rollback posture.

Apply the external-tool integrity gate. Treat each external tool as immutable;
identify the supported interface and Octon-owned adaptation or enforcement
surface. Any option that requires an external-tool fork, patch, modification,
private derivative, reengineering effort, undocumented internal, or upstream
change for Octon acceptance is a blocking finding and must be redesigned inside
Octon or reported as blocked.

Emit the selected method id and applied lens profile as run evidence: write an
`architectural-review-routing-decision-v2` artifact (`routing-decision.yml`)
carrying `method` (bound to the `naming.yml` methods.catalog) and
`lenses_applied` (bound to `lens-bank.yml` lens ids) into the existing
run-evidence root
`.octon/state/evidence/runs/workflows/{run_id}/architectural-review/pre-integration-architecture-review/`.
Fail closed on `unknown_method` or `missing_method_record` per routing v2. The
support receipt stays `architectural-review-support-receipt-v1` and method-free.
