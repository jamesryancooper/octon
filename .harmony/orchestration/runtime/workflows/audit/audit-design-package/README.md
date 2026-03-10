---
name: "audit-design-package"
description: "Run the architecture validation pipeline for a design package in rigorous or short mode, persist stage reports into a bounded bundle, and verify that file-writing stages changed the package or emitted explicit zero-change receipts."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "design-audit"
    file: "stages/02-design-audit.md"
    description: "design-audit"
  - id: "remediation-track"
    file: "stages/03-remediation-track.md"
    description: "remediation-track"
  - id: "implementation-simulation"
    file: "stages/04-implementation-simulation.md"
    description: "implementation-simulation"
  - id: "specification-closure"
    file: "stages/05-specification-closure.md"
    description: "specification-closure"
  - id: "extract-blueprint"
    file: "stages/06-extract-blueprint.md"
    description: "extract-blueprint"
  - id: "first-implementation-plan"
    file: "stages/07-first-implementation-plan.md"
    description: "first-implementation-plan"
  - id: "report"
    file: "stages/08-report.md"
    description: "report"
  - id: "verify"
    file: "stages/09-verify.md"
    description: "verify"
---

# Audit Design Package

_Generated README from canonical workflow `audit-design-package`._

## Usage

```text
/audit-design-package
```

## Purpose

Run the architecture validation pipeline for a design package in rigorous or short mode, persist stage reports into a bounded bundle, and verify that file-writing stages changed the package or emitted explicit zero-change receipts.

## Target

This README summarizes the canonical workflow unit at `.harmony/orchestration/runtime/workflows/audit/audit-design-package`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.harmony/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`.

## Parameters

- `package_path` (folder, required=true): Root design-package directory to validate and harden
- `mode` (text, required=false), default=`rigorous`: Pipeline mode: rigorous or short
- `executor` (text, required=false), default=`auto`: Executor backend: auto, codex, claude, or mock
- `executor_bin` (file, required=false): Optional explicit path to the selected executor binary
- `output_slug` (text, required=false): Optional stable slug for the bounded report bundle
- `model` (text, required=false): Optional model override forwarded to codex or claude
- `prepare_only` (boolean, required=false): Materialize bundle metadata and prompt packets without invoking the executor
- `summary_root` (folder, required=false), default=`.harmony/output/reports`: Root directory for the top-level summary report
- `bundle_root` (folder, required=false), default=`.harmony/output/reports/audits`: Root directory for the bounded stage-report bundle

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `design_package_workflow_summary` -> `../../output/reports/{{date}}-audit-design-package.md`: Top-level workflow summary with selected mode, readiness verdict, changed files, and next steps
- `design_package_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Bounded bundle containing stage reports, metadata, validation state, and aggregate package deltas
- `design_audit_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/01-design-package-audit.md`: Stage report produced by the design package audit prompt
- `design_package_remediation_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/02-design-package-remediation.md`: Short-mode remediation report and package delta receipt
- `design_red_team_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/03-design-red-team.md`: Rigorous-mode adversarial report
- `design_hardening_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/04-design-hardening.md`: Rigorous-mode hardening report and package delta receipt
- `design_integration_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/05-design-integration.md`: Rigorous-mode integration report and package delta receipt
- `implementation_simulation_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/06-implementation-simulation.md`: Buildability simulation report
- `specification_closure_report` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/07-specification-closure.md`: Specification-closure report or explicit no-op receipt
- `implementation_architecture_blueprint` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/08-minimal-implementation-architecture-blueprint.md`: Minimal implementer blueprint extracted from the stabilized package
- `first_implementation_plan` -> `../../output/reports/audits/{{date}}-{{slug}}/reports/09-first-implementation-plan.md`: First production implementation plan derived from the blueprint

## Steps

1. [configure](./stages/01-configure.md)
2. [design-audit](./stages/02-design-audit.md)
3. [remediation-track](./stages/03-remediation-track.md)
4. [implementation-simulation](./stages/04-implementation-simulation.md)
5. [specification-closure](./stages/05-specification-closure.md)
6. [extract-blueprint](./stages/06-extract-blueprint.md)
7. [first-implementation-plan](./stages/07-first-implementation-plan.md)
8. [report](./stages/08-report.md)
9. [verify](./stages/09-verify.md)

## Verification Gate

- [ ] Selected mode is recorded and stage coverage matches it
- [ ] Every selected stage has a persisted report in the bounded bundle
- [ ] Every file-writing stage has a change manifest or zero-change receipt
- [ ] `package-delta.md`, `bundle.yml`, and `validation.md` exist
- [ ] Top-level summary exists at `.harmony/output/reports/YYYY-MM-DD-audit-design-package.md`
- [ ] If the target package contains `design-package.yml`, `validate-design-package-standard.sh --package <target>` passes
- [ ] Final readiness verdict is explicit

## References

- Canonical contract: `.harmony/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`
- Canonical stages: `.harmony/orchestration/runtime/workflows/audit/audit-design-package/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `audit-design-package` |

