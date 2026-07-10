# Acceptance Criteria

Accepting and implementing this child requires all of the following. Each maps to
a gap in `architecture/current-state-gap-map.md` and a check in
`architecture/validation-plan.md`.

- **AC-1 — Methods list authored.** `naming.yml` is at
  `architectural-review-naming-v2` and declares a `methods` block with
  `default: balanced-architecture-review-method` and a catalog containing all six
  canonical method slugs. (G1)
- **AC-2 — Canonical slugs fixed and reconciled.** The six method slugs equal the
  `-method`-suffixed slugs, and `architecture/slug-reconciliation-decision.md`
  records the decision and the program design-revision note superseding the
  parent prose slugs. (G2)
- **AC-3 — Lens-bank dependency bound.** Every `methods.catalog[].slug` appears
  in the phase-0 `lens-bank.yml` `suite_methods`, and the naming validator fails
  closed (NC-A) when a declared method has no lens-bank profile. (G3)
- **AC-4 — Method-selection routing authored.** `review-routing.yml` is at
  `architectural-review-routing-v2` with a `method_selection` block
  (`default_method` = Balanced, per-route `allowed_methods_by_route`,
  `escalation_map`) and `fail_closed_conditions` extended with `unknown_method`
  and `missing_method_record`. (G4, G5)
- **AC-5 — Fail-closed with negative controls.** The naming and routing
  validators pass on the shipped models and fail (non-zero exit) on all three
  negative-control fixtures: method without a lens profile (NC-A), unknown method
  in routing (NC-B), and a routing decision missing the method record (NC-C).
  (G3, G4, G5)
- **AC-6 — Docs extended without doctrine change.** The mechanism README
  canonical-names table gains the six method rows plus a selection note and
  reference links, and `balanced-architecture-review-method.md` gains navigation
  cross-references only; Balanced Required Sequence, Octon Fit Gates, and Output
  Contract text are unchanged. (G6, G7)
- **AC-7 — Additive-only, no regression, no authority granted.** No slug is
  renamed and no alias retired; existing `canonical_modes`, routes,
  `default_route`, evidence roots, and the pre-integration gate are unchanged; no
  new mechanism, gate, routed workflow mode, evidence root, or command facade is
  created; and method selection grants no review output any authority. (G8)
- **AC-8 — Evidence retained.** Naming + routing validator runs (positive + three
  negative controls), the lens-bank binding proof, the no-regression proof, and
  the Balanced-doctrine-unchanged `git diff` proof are retained under the child's
  promotion evidence root.

## Closure Condition

This child reaches `closed` only when AC-1 through AC-8 hold, all validators pass
(with the three negative controls demonstrably failing closed), and the
verification receipt is retained. Allowed alternative terminal states are
`superseded` or `rejected` with recorded rationale (child-packet-contract
obligation 8). No unresolved acceptance criterion may remain at closeout.
