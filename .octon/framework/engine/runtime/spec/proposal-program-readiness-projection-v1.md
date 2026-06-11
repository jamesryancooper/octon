# Proposal Program Readiness Projection v1

## Purpose

The proposal-program readiness projection is a read-only diagnostic view over a
proposal-program parent packet, its child registry, child-owned packet receipts,
retained-run evidence indexes, route evidence, and publication freshness
evidence. It exists to expose stale receipts, dependency gaps, route gaps,
archive readiness gaps, generated/publication drift, and blocker posture before
child dispatch and before parent closeout.

The projection is not authority. It cannot authorize child dispatch, satisfy a
child gate, satisfy parent closeout, authorize archival, authorize generated
publication, replace retained evidence, or make `inputs/**` or `generated/**`
authoritative.

## Inputs

The projection may read these current source classes:

- parent program `proposal.yml`
- parent `resources/child-packet-index.yml`
- child proposal manifests and subtype manifests
- child `support/proposal-review.md` receipts and reviewed-packet digests
- child `support/implementation-grade-completeness-review.md` receipts
- child implementation, conformance, drift/churn, closeout, and archive receipts
- runner checkpoints and workflow evidence under retained run evidence roots
- retained-run evidence indexes whose source digests still match their raw refs
- generated/publication freshness receipts, only as derived freshness evidence
- blocker ledgers, recovery summaries, and dependency declarations

## Outputs

A projection result must identify:

- `parent_readiness`: parent manifest, registry, review, implementation, and
  closeout posture.
- `child_readiness`: each child status, review freshness, implementation
  readiness, implementation receipts, closeout/archive receipts, blocker state,
  and dependency state.
- `dependency_readiness`: predecessor and successor constraints from the child
  registry.
- `route_readiness`: diagnostic readiness for review, implementation, closeout,
  archive, correction, and no-dispatch terminal routes.
- `archive_readiness`: terminal child archive metadata and closeout receipt
  availability when parent closeout or archive claims depend on them.
- `generated_publication_freshness`: freshness posture for generated or
  publication outputs used by closeout diagnostics.
- `evidence_index_availability`: retained-run evidence index availability and
  freshness when terminal claims depend on retained run evidence.
- `blocker_posture`: unresolved blockers, stale source refs, drift, and
  recovery classes.
- `source_digest_freshness`: digest-bound source freshness for child reviews,
  evidence indexes, and generated/publication evidence.
- `authority_boundary`: an explicit statement that the projection is
  diagnostic, derived, read-only, and non-authoritative.

## Fail-Closed Conditions

The projection validator must fail closed when any required diagnostic source is
missing, stale, or authority-widening:

- parent or child manifests are missing or invalid
- child registry paths are unsafe, unresolved, or ambiguous
- accepted child review digests are stale
- implementation-readiness receipts are missing, failing, unresolved, or require
  clarification
- implementation, conformance, drift/churn, closeout, or archive evidence is
  missing or stale when terminal or archive claims depend on it
- generated/publication freshness evidence is missing or stale when closeout
  diagnostics depend on it
- retained-run evidence indexes are missing, invalid, digest-stale, or claim
  execution authority
- predecessor constraints or child dependencies are unresolved
- blocker ledgers contain unresolved blockers for required children
- the projection claims it authorizes dispatch, child gates, closeout, archive,
  correction, implementation, or generated-state authority

## Runtime Boundary

Lifecycle runners may use this projection as a pre-dispatch and pre-closeout
diagnostic. Existing child-owned validators, proposal review gates,
implementation-readiness validators, implementation conformance validators,
post-implementation drift validators, closeout receipts, archive metadata,
promotion receipts, and publication validators remain the authority surfaces for
their respective transitions.

Parent program summaries may cite projection results as evidence of what was
checked, but a parent projection never replaces child receipts, child promotion
targets, child validation verdicts, child archive metadata, retained-run
evidence, or generated/publication freshness receipts.
