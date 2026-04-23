# Artifact Catalog

## Root

- `README.md` — executive framing, scope, reading order, and non-authority notice.
- `proposal.yml` — base proposal manifest and promotion target list.
- `architecture-proposal.yml` — architecture subtype manifest.
- `PACKET_MANIFEST.md` — enumerated packet contents.
- `SHA256SUMS.txt` — checksums for all packet files.

## Navigation

- `navigation/source-of-truth-map.md` — authority, placement, and boundary map.
- `navigation/artifact-catalog.md` — packet inventory.

## Architecture

- `architecture/target-architecture.md` — recommended target state.
- `architecture/current-state-gap-map.md` — current coverage and implementation gaps.
- `architecture/concept-coverage-matrix.md` — concept-by-surface coverage matrix.
- `architecture/file-change-map.md` — durable target file map.
- `architecture/implementation-plan.md` — phased implementation plan.
- `architecture/migration-cutover-plan.md` — cutover sequence and rollback posture.
- `architecture/validation-plan.md` — structural, runtime, evidence, and bypass validation.
- `architecture/acceptance-criteria.md` — acceptance and closure criteria.
- `architecture/cutover-checklist.md` — implementation checklist.
- `architecture/closure-certification-plan.md` — closure evidence and certification plan.
- `architecture/execution-constitution-conformance-card.md` — quick conformance card.

## Resources

- `resources/source-artifact.md` — source registration and evidence set.
- `resources/architectural-evaluation.md` — focused architectural evaluation of current state and leverage.
- `resources/implementation-gap-analysis.md` — exact blockers and proposal closure path.
- `resources/concept-extraction-output.md` — extracted implementation target.
- `resources/concept-verification-output.md` — repository-grounded verification.
- `resources/repository-baseline-audit.md` — repo-state audit relevant to this proposal.
- `resources/coverage-traceability-matrix.md` — source-to-gap-to-target traceability.
- `resources/full-concept-integration-assessment.md` — detailed dossier.
- `resources/evidence-plan.md` — retained evidence plan.
- `resources/decision-record-plan.md` — ADR and decision posture.
- `resources/risk-register.md` — risk register.
- `resources/assumptions-and-blockers.md` — assumptions, preconditions, and blockers.
- `resources/rejection-ledger.md` — rejected broadenings and false starts.

## Support

- `support/promoted-drafts/authorized-effect-token-v2.schema.json` — candidate target schema draft.
- `support/promoted-drafts/authorized-effect-token-consumption-v1.schema.json` — candidate consumption receipt schema draft.
- `support/promoted-drafts/material-side-effect-inventory.example.yml` — candidate inventory shape.
- `support/negative-tests/test-authorized-effect-bypass.sh` — illustrative negative bypass test.
- `support/rust/authorized_effects_api_shape.rs` — illustrative Rust API shape.
