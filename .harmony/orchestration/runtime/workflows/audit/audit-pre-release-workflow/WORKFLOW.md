---
name: audit-pre-release-workflow
description: >
  Chain bounded migration, subsystem-health, cross-subsystem, and freshness
  audits into a pre-release gate with deterministic evidence, stable finding
  identity, and explicit done-gate evaluation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters and determine bounded stage plan.
  - id: migration-audit
    file: 02-migration-audit.md
    description: Run audit-orchestration-workflow in bounded mode if manifest provided.
  - id: health-audit
    file: 03-health-audit.md
    description: Run audit-subsystem-health against target subsystem.
  - id: cross-subsystem-audit
    file: 04-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 05-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: merge
    file: 06-merge.md
    description: Merge findings into one stable release-readiness set.
  - id: report
    file: 07-report.md
    description: Generate pre-release recommendation and bounded evidence bundle.
  - id: verify
    file: 08-verify.md
    description: Validate workflow, context-governance evidence, and done-gate outcomes.
# --- Harmony extensions ---
access: human
version: "2.2.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Pre-Release Audit: Overview

Run a bounded release-readiness audit that consumes stage outputs with explicit coverage and finding identity contracts.

## Verification Gate

Pre-release audit is complete only when:

- [ ] All planned stages executed or explicitly skipped
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-audit-pre-release-workflow.md`
- [ ] Pre-release bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are recorded
- [ ] Instruction-layer manifest evidence exists for material policy runs
- [ ] Context-acquisition telemetry fields are present in receipts/digests
- [ ] Context governance validators pass (`validate-developer-context-policy.sh`, `validate-context-overhead-budget.sh`)
- [ ] Recommendation and done-gate rationale are explicit

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 2.2.0 | 2026-02-25 | Added context-governance verification criteria for instruction-layer manifests and context-acquisition telemetry gates |
| 2.1.0 | 2026-02-22 | Forwarded deterministic controls (`post_remediation`, `convergence_k`, `seed_list`) through all nested audit stages |
| 2.0.0 | 2026-02-22 | Added bounded-audit bundle and explicit done-gate/convergence metadata |
| 1.2.0 | 2026-02-21 | Migration stage switched to audit-orchestration-workflow |
| 1.0.0 | 2026-02-10 | Initial version |
