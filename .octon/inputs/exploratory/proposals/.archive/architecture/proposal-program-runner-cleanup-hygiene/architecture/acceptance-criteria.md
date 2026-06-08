# Acceptance Criteria

- Cleanup-safe current-run residue is handled only through existing repo-hygiene cleanup routing or canonical cleanup helpers after dry-run classification, cleanup summary, validating authorization receipt, and active implementation work preservation proof.
- Foreign, ambiguous, manual-review, or user-authored residue is retained and routed to blocked evidence rather than deleted automatically.
- Cleanup predicates are evaluated from explicit route-evaluation context: `blocker_present`, `cleanup_candidates_present`, and `hygiene_preflight_required`.
- Unknown predicates, unsupported predicate shapes, stale cleanup fingerprints, or missing cleanup context fail closed with evidence.

## Negative Criteria

- Do not delete foreign, ambiguous, manual-review, or user-authored residue automatically.
- Do not let cleanup routes be status-triggered rather than event/blocker-triggered and phase-scoped.
- Do not block child implementation on no-op or blocked-retained cleanup receipts where `implementation_blocking: false`.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
