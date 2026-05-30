# Program Revision Receipt

revision_id: canonical-child-packet-registry-20260527T184747Z
revised_at: 2026-05-27T18:47:47Z
reviser: octon-proposal-lifecycle-revise-program
parent_program_path: .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture
source_review_id: governed-cross-surface-mechanisms-documentation-architecture-review-20260527T184500Z
source_review_verdict: revision-required
parent_status_after_revision: in-review
post_revision_digest: sha256:e2e3a55878c7aff1ed4a39766ef4b4c3539bc633f336f664d7b2724b12bb1cb2
child_registry_digest_after_revision: sha256:180f824030f26370a64cfc506e717117c2e5424b9fe7075fa5dafd3b6054a13d
remaining_blocking_count: 0
catalog_refresh_confirmed: yes
registry_refresh_confirmed: yes
checksum_refresh_confirmed: yes
verdict: pass

## Changed Parent Files

- `proposal.yml`
- `README.md`
- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`

## Addressed Findings

- Finding 1: Parent child registry still claims accepted sibling child packets
  are uncreated candidates.

## Revision Summary

The parent registry posture changed from `staged-child-candidates` to
`canonical-child-packets`.

Required child packet entries now record:

- `child_packet_status: accepted`
- `canonical_child_packet_exists: true`
- `program_required_for_implementation: true`

The optional `mechanism-detail-pages-and-operator-map` child also records
`child_packet_status: accepted` and `canonical_child_packet_exists: true`, but
keeps `required: false`, `deferred: true`, and
`program_required_for_implementation: false`.

Parent prose was updated to stop describing child packets as uncreated
candidates. It now records that the child packets exist as sibling
child-owned proposal packets with accepted child-owned reviews, while
preserving child-owned lifecycle truth and optional-child deferral.

## Boundary Preservation

This revision is parent coordination only. It does not edit child manifests,
child receipts, child promotion targets, child validation verdicts, child
archive metadata, runtime truth, generated effective authority, state/control
truth, retained evidence, product contracts, or durable documentation.

Parent revision receipts do not satisfy child receipts.

## Validators Rerun

The following validators must pass after this receipt:

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture --skip-registry-check --skip-promotion-target-checks`
- `validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture`
- `validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture`

## Next Gate

Run `octon-proposal-lifecycle-review-program` again. Acceptance requires a
fresh accepted parent review receipt.
