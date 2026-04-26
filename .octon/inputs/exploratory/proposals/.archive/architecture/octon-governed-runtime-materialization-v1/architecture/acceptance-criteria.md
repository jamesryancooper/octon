# Acceptance Criteria

The migration is closure-ready only when all criteria below are satisfied.

1. There is one reconciled support-envelope truth path.
2. Support claims cannot be live unless declared, admitted, proof-backed, fresh,
   route-resolved, capability-pack-consistent, and disclosure-consistent.
3. Generated artifacts cannot widen authority or support.
4. Every material side-effect path requires and verifies a typed authorized
   effect.
5. Revoked, expired, stale, unsupported, wrong-scope, wrong-route, wrong-run, or
   missing-effect attempts fail for deterministic reasons.
6. Effect consumption is recorded as retained evidence and linked from the run
   journal.
7. Operators have a generated per-run health view sourced only from canonical
   state/control/evidence/continuity inputs plus generated reconciliation
   handles.
8. Run health distinguishes healthy, blocked, stale, unsupported, revoked,
   evidence-incomplete, review-required, awaiting-approval, rollback-required,
   and closure-ready states.
9. Existing proposal/input/archive artifacts remain non-authoritative.
10. Validators and negative fixtures prove material enforcement, not just
    documentation alignment.
11. The packet identifies exactly what remains out of scope after the migration.
12. No second control plane is introduced.
13. No broad future-facing support claim is promoted as current support.
14. All generated outputs include source refs, source digests, generated time,
    freshness policy, and explicit non-authority classification.
15. Closure certification is retained under state/evidence and does not depend
    on proposal-path artifacts.
