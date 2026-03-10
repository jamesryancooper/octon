# Artifact Contract

This document defines the bounded output contract for
`/audit-design-package-workflow`.

## Bundle Root

Each run writes a bounded bundle at:

```text
.harmony/output/reports/audits/YYYY-MM-DD-<slug>/
```

The bundle root must contain:

- `bundle.yml` — machine-readable run metadata
- `plan.md` — resolved execution plan with selected mode and stage set
- `validation.md` — done-gate checklist and final outcome
- `reports/` — one markdown report per selected stage
- `package-delta.md` — aggregate changed-file summary across file-writing stages

## Top-Level Summary

Each run also writes:

```text
.harmony/output/reports/YYYY-MM-DD-audit-design-package-workflow.md
```

The summary must include:

- target package path
- selected mode
- final readiness verdict
- highest-severity unresolved blockers
- changed package files
- links or references to the bounded bundle contents

## Stage Report Paths

The `reports/` directory uses these file names:

- `01-design-package-audit.md`
- `02-design-package-remediation.md` (`short` mode only)
- `03-design-red-team.md` (`rigorous` mode only)
- `04-design-hardening.md` (`rigorous` mode only)
- `05-design-integration.md` (`rigorous` mode only)
- `06-implementation-simulation.md`
- `07-specification-closure.md`
- `08-minimal-implementation-architecture-blueprint.md`
- `09-first-implementation-plan.md`

## Report Content Requirements

Every report must include:

- target package path
- stage identifier and prompt source path
- input artifact references
- the actual findings or decisions from that stage
- explicit next handoff target

File-writing stage reports must also include:

- `CHANGE MANIFEST`
- created, updated, and removed file lists
- either a direct-edit receipt or exact-file-body / patch output receipt

The specification-closure report may be a no-op receipt only when stage `06`
identifies zero remaining implementation blockers.

## bundle.yml Fields

`bundle.yml` must record at least:

- `workflow_id`
- `package_path`
- `mode`
- `slug`
- `selected_stages`
- `report_paths`
- `changed_files`
- `final_verdict`

## validation.md Checks

`validation.md` must evaluate:

- stage coverage matches the selected mode
- required report files exist
- required file-writing stages include a change manifest or zero-change receipt
- top-level summary exists
- final verdict is explicit
