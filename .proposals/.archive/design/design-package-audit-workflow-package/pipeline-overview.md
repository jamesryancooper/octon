# Pipeline Overview

This package supports two documented execution modes inside
`/audit-design-package`.

## Rigorous Mode

Use when:

- the package is large or safety-critical
- you want adversarial review separated from remediation
- you want a stronger confidence pass before implementation starts

Sequence:

1. Design Package Audit
2. Design Red-Team
3. Design Hardening
4. Design Integration
5. Implementation Simulation
6. Specification Closure
7. Minimal Implementation Architecture Extraction
8. First Implementation Plan

## Short Mode

Use when:

- you want faster iteration
- you prefer a single remediation pass after the audit
- you are comfortable merging hardening and integration into one stage

Sequence:

1. Design Package Audit
2. Design Package Remediation
3. Implementation Simulation
4. Specification Closure
5. Minimal Implementation Architecture Extraction
6. First Implementation Plan

## Stage-Type Distinction

- Audit, Red-Team, and Implementation Simulation are evaluative.
- Remediation, Hardening, Integration, and Specification Closure must write the
  package or emit an explicit zero-change receipt.
- Architecture Extraction and First Implementation Plan convert the stabilized
  package into implementer-ready outputs.

## Octon Output Rule

Every workflow run should leave behind:

- one workflow bundle under
  `.octon/output/reports/workflows/YYYY-MM-DD-audit-design-package-<slug>/`
- one top-level summary report under `.octon/output/reports/`
- one report file per selected stage
- one prompt packet and one stage log per selected stage
- aggregate validation metadata proving which mode ran and which files changed
- the minimum workflow bundle contract required by
  `/.octon/output/reports/workflows/README.md`

See `artifact-contract.md` for the bundle layout.

## Recommended Operating Rule

Whenever you run a follow-up prompt that is supposed to improve the design
package, include the prior report inline and insist on one of these outcomes:

- the package files are edited directly, or
- full file bodies or exact patches are returned

Never accept recommendation-only output from a file-writing follow-up.
