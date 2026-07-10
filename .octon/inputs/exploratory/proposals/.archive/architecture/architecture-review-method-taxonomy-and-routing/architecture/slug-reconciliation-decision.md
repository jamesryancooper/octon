# Canonical Companion Method Slug Reconciliation

This is the load-bearing design decision this child owns. The phase-0 lens bank
(`architecture-lens-bank-foundation`) explicitly deferred the **canonical**
companion method slugs to this phase-1 child, seeding `lens-bank.yml` with
provisional slugs. This document fixes the canonical slugs and reconciles them.

## The Divergence

Two source surfaces name the five companion methods differently:

| Method | Parent `method-taxonomy.md` prose slug | Live `lens-bank.yml` `suite_methods` slug (provisional) | Program `child-packet-index.yml` `child_id` |
| --- | --- | --- | --- |
| Greenfield Reference | `greenfield-reference-architecture-review` | `greenfield-reference-architecture-review-method` | `greenfield-reference-architecture-review-method` |
| Tradeoff | `architecture-tradeoff-review` | `tradeoff-review-method` | (companion-methods child) |
| Failure-Mode | `failure-mode-architecture-review` | `failure-mode-review-method` | (companion-methods child) |
| Evolution/Fitness | `evolution-fitness-architecture-review` | `evolution-fitness-review-method` | (companion-methods child) |
| Boundary/Authority | `boundary-authority-architecture-review` | `boundary-authority-review-method` | (companion-methods child) |

Balanced is not in dispute: `balanced-architecture-review-method` is the live
canonical slug in `naming.yml` and is marked `canonical` in `lens-bank.yml`.

## Decision

**Adopt the `-method`-suffixed `suite_methods` slugs from the live
`lens-bank.yml` as the canonical method slugs in `naming.yml` v2.** The six
canonical slugs are:

1. `balanced-architecture-review-method` (default)
2. `greenfield-reference-architecture-review-method`
3. `tradeoff-review-method`
4. `failure-mode-review-method`
5. `evolution-fitness-review-method`
6. `boundary-authority-review-method`

## Rationale

1. **Live repository outranks a stale parent design claim.** Per
   child-packet-contract obligation 3, where a program design doc disagrees with
   the live repository, the repository wins and the child triggers a program
   registry/design revision instead of implementing the stale claim. The phase-0
   lens bank is now live authority; `method-taxonomy.md` prose is not.
2. **Convention consistency.** The `-method` suffix matches Balanced's own
   canonical slug (`balanced-architecture-review-method`), giving a uniform
   method-slug shape distinct from the review *mode* slugs (which end in
   `-review` / `-audit`). This reduces the chance of confusing a method with a
   routed occasion.
3. **Zero churn to the verified dependency.** The phase-0 lens bank's
   `method_profiles` and `suite_methods` already use these slugs. Adopting them
   means the `verification`-gate dependency binds with **no edit to
   `lens-bank.yml`** and the phase-0 lens-reference validator's
   profile-completeness check continues to pass unchanged. The
   `greenfield-...-method` `child_id` in the registry already matches, confirming
   the program's own registry favors the suffixed form.
4. **Downstream stability.** The phase-2 method-doc children reference these
   slugs; fixing them now to equal the lens-bank slugs prevents a later rename
   cascade across method docs, schemas, and workflow evidence.

## Reconciliation Actions In This Packet

- `naming.yml` v2 `methods` list uses the six slugs above; Balanced flagged
  default.
- `review-routing.yml` v2 `method_selection` uses the same six slugs for
  `default_method`, per-route `allowed_methods`, and the escalation map.
- The naming validator asserts every declared method slug appears in
  `lens-bank.yml` `suite_methods` (dependency binding), and the routing/naming
  negative controls prove `unknown_method` and "method without a lens profile"
  fail closed.

## Program Design-Revision Note (non-authoritative, for the parent)

The parent `method-taxonomy.md` prose slugs (`greenfield-reference-architecture-review`,
`architecture-tradeoff-review`, `failure-mode-architecture-review`,
`evolution-fitness-architecture-review`, `boundary-authority-architecture-review`)
are **superseded** by the canonical `-method`-suffixed slugs above. This note is
the child-surfaced trigger for the parent program to align its design docs; it is
recorded here as evidence only and does not itself edit the parent packet. The
parent program owns whether to update `method-taxonomy.md` prose or record the
reconciliation at program closeout. This child does not modify the parent packet.
