# Companion Architecture Review Methods

Temporary, non-authoritative architecture proposal packet. Status: **draft**.
Candidate lineage only — this packet proposes and plans a change; it authorizes
nothing and promotes nothing until its own governed review, implementation, and
verification lifecycle completes.

This packet is child `companion-architecture-review-methods` (phase-2,
`method-docs` group) of the parent program
[`architecture-review-method-suite-program`](../architecture-review-method-suite-program/).
The parent coordinates; it does not own. This child is an independent,
manifest-governed proposal packet at its canonical sibling path and carries its
own receipts, promotion targets, and validation verdicts.

## What This Packet Delivers

Author the four **companion** architecture-review method docs of the
Architecture Review Method Suite as first-class methodology surfaces under the
existing Architectural Review Mechanism method layer. The suite's default
(Balanced) and the fifth companion (Greenfield) are already authored by earlier
program children; this child authors the remaining four:

| Display name | Canonical slug (naming.yml v2) | New doc file |
| --- | --- | --- |
| Architecture Tradeoff Review | `tradeoff-review-method` | `tradeoff-review-method.md` |
| Failure-Mode Architecture Review | `failure-mode-review-method` | `failure-mode-review-method.md` |
| Evolution/Fitness Architecture Review | `evolution-fitness-review-method` | `evolution-fitness-review-method.md` |
| Boundary/Authority Architecture Review | `boundary-authority-review-method` | `boundary-authority-review-method.md` |

All four docs live in
`.octon/framework/cognition/practices/methodology/architectural-review/`.

## Design Anchors

1. **Methods are how, not new occasions.** Each companion method is a
   methodology surface — question, scope, output contract, escalation — selected
   within an existing review route. No new routed workflow mode, evidence root,
   lifecycle gate, or command facade is created here.
2. **One shared lens bank.** Every method draws its lenses from
   `lens-bank.yml`; each doc cites lens ids only and must match its
   `method_profiles.<slug>` entry exactly. No private lens catalogs.
3. **Non-authority output.** Every method's output is retained evidence or
   proposal input, stated fail-closed. The pre-integration architecture review
   support receipt remains the only lifecycle-gating review artifact.
4. **No duplication of adjacent doctrine.** Failure-Mode Review cites, and does
   not redefine, the Architecture Readiness Audit's failure-mode assessment;
   Boundary/Authority Review cites, and does not absorb, the Surface
   Architecture Audit's single-unit authority-model classification.
5. **Octon-only Boundary/Authority in v1.** The generic mode is deferred at the
   program level and is not introduced here.

## Reading Order

1. `proposal.yml` — highest packet-local lifecycle authority.
2. `architecture-proposal.yml` — architecture subtype manifest.
3. `navigation/source-of-truth-map.md` — durable authorities, proposal-local
   sources, derived projections, evidence surfaces, and boundary rules.
4. `architecture/target-architecture.md` — intended end state.
5. `architecture/current-state-gap-map.md` — live-repo grounding and the gap
   this packet closes.
6. `architecture/implementation-plan.md` — workstreams.
7. `architecture/file-change-map.md` — exact per-file change map.
8. `architecture/validation-plan.md` — doc/registry consistency check and
   regression validators.
9. `architecture/acceptance-criteria.md` — proof the target landed.
10. `architecture/cutover-checklist.md`, `architecture/rollback-plan.md`,
    `architecture/operator-disclosure.md`.
11. `resources/**` — preserved source lineage and traceability.
12. `navigation/artifact-catalog.md` — packet inventory (discovery only).

## Non-Canonical Rule

This proposal is a temporary implementation aid. It is not canonical runtime,
documentation, policy, or contract authority. Durable outputs land only in the
declared framework promotion targets, and after promotion those targets stand on
their own with no dependency on this proposal path.
