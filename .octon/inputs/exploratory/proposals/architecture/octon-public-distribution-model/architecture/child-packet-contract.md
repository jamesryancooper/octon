# Child Packet Contract

Every child must:

1. Remain a canonical sibling under the architecture proposal root.
2. Preserve its own manifest, promotion scope, targets, review, implementation,
   evidence, validation, rollback, closeout, and archive authority.
3. Refresh current evidence before implementation.
4. Fail closed on unknown paths, ambiguous ownership, stale evidence, or a
   missing manual gate.
5. Name exact positive and negative acceptance evidence.
6. Keep raw sensitive findings and evidence out of proposal resources.
7. Use deterministic automation for mechanical rules and bounded AI review for
   synthesis only.
8. Refuse implementation until human proposal acceptance and dependency gates.
9. Refuse closeout until conformance and drift reviews are fresh.
10. Preserve all deferred controls and activation triggers.
11. Declare promotion targets as the exact deliverable files or leaf
    directories inside this parent's registry write scopes, name every
    registry-scoped deliverable in the packet architecture, and — for
    octon-internal packets only — include the child evidence root
    `.octon/state/evidence/validation/proposals/<child-id>/`. Repo-local
    packets must not add `.octon/**` targets; mixed target families fail
    canonical validation.

The parent cannot set child validation verdicts, own child receipts, authorize
child archive, redefine child promotion targets, or substitute aggregate
evidence for child evidence.

