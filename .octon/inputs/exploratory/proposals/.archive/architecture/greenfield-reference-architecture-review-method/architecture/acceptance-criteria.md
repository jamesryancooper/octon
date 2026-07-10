# Acceptance Criteria

Accepting and implementing this child requires all of the following. Each maps to
a gap in `architecture/current-state-gap-map.md` and a check in
`architecture/validation-plan.md`.

- **AC-1 — Method doc authored.** `greenfield-reference-architecture-review-method.md`
  exists in the mechanism directory and states the method question, use cases,
  required inputs, and non-goals per `architecture/method-doc-authoring-spec.md`.
  (G1)
- **AC-2 — Five required output sections present.** The doc contains all five
  required sections: (1) domain/job model, (2) reference architecture, (3)
  quality/security/ops model, (4) authority/evidence model, (5) evolution plan.
  (G2)
- **AC-3 — Build discipline present.** The doc contains initial-build sequencing,
  a minimum viable architecture, and an explicit what-not-to-build-yet list. (G3)
- **AC-4 — Reference-architecture-only boundary stated fail-closed.** The doc
  states, as a fail-closed boundary, that Greenfield output is reference
  architecture — evidence or proposal input, never implementation authority, never
  a lifecycle gate, never a what-to-change verdict — and that the pre-integration
  support receipt remains the only lifecycle-gating review artifact. (G4)
- **AC-5 — Lens profile bound to the bank.** The doc cites its lenses by id from
  `lens-bank.yml` `method_profiles.greenfield-reference-architecture-review-method`
  (14 required + 3 optional), defines no private catalog, and the doc-consistency
  check confirms an exact match. (G5)
- **AC-6 — Distinctness stated.** The doc records its non-goals and its
  clean-sheet complementarity with Balanced (deliverable vs comparison tool; no
  what-to-change verdict) and its escalation rules (Tradeoff / Failure-Mode /
  Balanced or proposal drafting / Constitutional Challenge), citing
  `review-routing.yml` `method_selection`. (G6, G7)
- **AC-7 — Doc wired in, additive only.** The `naming.yml` greenfield catalog
  entry carries `doc: "greenfield-reference-architecture-review-method.md"` and
  the README References section links the doc; both edits are additive, with no
  slug, schema-version, route, or canonical-names-table-row change. (G8)
- **AC-8 — No regression, no new authority.** Balanced doctrine, companion docs,
  the lens bank, routing routes/`method_selection` semantics, and every
  `validate-architectural-review-*.sh` validator are unchanged (validators still
  pass); no new mechanism, gate, routed workflow mode, evidence root, command
  facade, or schema is created; and Greenfield outputs grant no authority. (G9)
- **AC-9 — Evidence retained.** The doc-consistency check run, the structural and
  fail-closed-boundary presence checks, the no-regression validator sweep, and the
  additive-only / doctrine-unchanged `git diff` proofs are retained under the
  child's promotion evidence root.

## Closure Condition

This child reaches `closed` only when AC-1 through AC-9 hold, the doc-consistency
check passes, the full validator suite still passes, and the verification receipt
is retained. Allowed alternative terminal states are `superseded` or `rejected`
with recorded rationale (child-packet-contract obligation 8). No unresolved
acceptance criterion may remain at closeout.
