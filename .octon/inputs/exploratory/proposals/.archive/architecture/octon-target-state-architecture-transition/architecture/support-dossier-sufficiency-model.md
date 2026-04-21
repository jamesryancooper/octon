# Support-Dossier Sufficiency Model

## Current posture

`support-targets.yml` uses a bounded-admitted-finite support model. The live support universe admits repo-local governed execution for `repo-shell` and `ci-control-plane` surfaces while keeping frontier, GitHub, Studio, browser, and API-related surfaces stage-only or non-live unless admitted.

The repo-shell consequential support admission is explicit and references required proof planes, lab scenarios, authority artifacts, evidence refs, and a support dossier. The dossier is qualified but has `minimum_retained_runs: 1` and `current_retained_runs: 1`, which is acceptable for bootstrap but not target-state closure-grade support.

## Target sufficiency threshold

A closure-grade live tuple requires:

- at least three retained representative runs across one naturalistic run, one recertification run, and one negative-control run;
- one hidden-check or adversarial scenario;
- one recovery or replay scenario;
- one generated-as-authority denial;
- one host-projection-as-authority denial;
- proof-plane coverage across structural, functional, behavioral, governance, maintainability, and recovery planes;
- current review_due_at and recertification receipt;
- generated SupportCard projection derived from retained evidence.

## Target files

- update `.octon/instance/governance/contracts/support-target-review.yml`;
- update tuple support dossiers under `.octon/instance/governance/support-dossiers/**`;
- add proof bundles under `.octon/state/evidence/validation/support-targets/**`;
- generate support proof maps under `.octon/generated/cognition/projections/materialized/support-proof-map.md`.

## Deny rule

A support tuple whose dossier lacks current proof bundle or required negative controls must not be cited as a live support claim. It may remain declared but must route as stage-only or deny according to governing policy.
