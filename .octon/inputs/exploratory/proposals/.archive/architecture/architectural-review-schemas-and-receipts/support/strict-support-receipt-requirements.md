# Strict Support Receipt Requirements

## Required Fields

- `schema_version`
- `receipt_id`
- `mode_slug`
- `subject_ref`
- `subject_digest`
- `verdict`
- `evidence_refs`
- `validator_refs`
- `unresolved_findings_count`
- `unresolved_blockers_count`
- `blockers`
- `non_authority_classification`
- `mode_specific_coverage`
- `route_decision_ref`
- `review_report_ref`
- `finding_refs`
- `disposition_refs`

## Allowed Verdicts

- `pass`
- `fail`
- `blocked`
- `not_applicable`
- `deferred`

## Pass Conditions

A `pass` requires non-empty evidence refs, non-empty validator refs, current
subject digest, zero unresolved blockers, mode-specific coverage, and explicit
non-authority classification.

## Rejection Conditions

Reject a `pass` if evidence is missing, validators are omitted, packet digests
are stale, blocker counts are nonzero, placeholder language appears, or the
receipt uses narrative text instead of schema fields.
