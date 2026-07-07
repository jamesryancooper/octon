# Acceptance Criteria

## Parent Program

- The parent program lists every staged child in `related_proposals`.
- `resources/child-packet-index.yml` lists every child as a sibling proposal path, not a nested child path.
- `resources/child-packet-index.md`, `architecture/packet-sequence.md`, `architecture/child-packet-contract.md`, and `architecture/program-closeout-plan.md` mention every child id.
- `support/program-creation.md` records `child_authority_preserved: yes`.
- Parent validation passes with `validate-proposal-program-structure.sh`.

## Child Packet Readiness

- Each child has its own `proposal.yml`, `architecture-proposal.yml`, `README.md`, architecture docs, navigation docs, validation plan, source lineage, and implementation-grade completeness receipt.
- Each child declares durable promotion targets outside the proposal workspace.
- Each child records its validation floor and negative controls.
- No child delegates its own receipts, conformance, drift/churn, closeout, archive, or implementation evidence to the parent.

## Future Implementation Success

- PR 1 proves repeated routes stop when blocker fingerprints are unchanged.
- PR 2 proves owned, leased, and foreign path classification is deterministic before mutation.
- PR 3 proves a polluted parent run can freeze and supersede without losing validated child-owned receipts.
- PR 4 proves `closeout-worktree` can emit non-mutating partition reports that preserve foreign/manual residue and do not authorize cleanup or child closeout.
