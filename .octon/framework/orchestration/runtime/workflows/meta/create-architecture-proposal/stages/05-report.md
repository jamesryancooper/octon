---
title: Report Scaffold Outcome
description: Summarize the created proposal and next authoring steps.
---

# Step 5: Report Scaffold Outcome

## Purpose

Emit a compact result that points the operator at the new proposal and the next
authoring workflow.

## Actions

1. Report:
   - proposal path
   - proposal kind
   - implementation targets
2. Write the workflow bundle summary and metadata:
   - `bundle.yml`
   - `summary.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
3. Write the top-level summary report under `/.octon/state/evidence/validation/`.
4. Point the operator at:
   - `architecture-proposal.yml`
   - `navigation/source-of-truth-map.md`
   - `/audit-architecture-proposal`
5. Record that the proposal is ready for content authoring, not automatically
   implementation-ready.
6. Include the packet-finalizing fields:
   - `implementation_grade_complete: yes/no`
   - completeness receipt path
   - validators run
   - unresolved question count
   - known exclusions
   - next canonical route
   - external-tool integrity result
7. If an accepted review and executable implementation prompt are generated or
   refreshed after digest-covered packet files change, rerun
   `validate-proposal-review-gate.sh --require-implementation-authorization`
   and `validate-proposal-implementation-readiness.sh` before reporting
   implementation authorization.
8. If digest-covered packet files changed after the accepted review digest was
   recorded, rerun the proposal review or refresh the review receipt before the
   implementation route can proceed. Keep implementation-grade completeness
   separate from review acceptance.

## Proceed When

- [ ] Report includes proposal path and implementation targets
- [ ] Workflow bundle contract files exist
- [ ] Top-level summary exists
- [ ] Next authoring path is explicit
- [ ] Report does not claim final or implementation-ready status unless the completeness gate passes
- [ ] Post-prompt digest refresh or review-gate rerun requirement is explicit
- [ ] Report does not recommend changing or reengineering an external tool
