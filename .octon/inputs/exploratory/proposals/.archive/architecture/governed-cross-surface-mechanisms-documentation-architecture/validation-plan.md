# Validation Plan

_Status: Parent validation plan_

## Parent Structural Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture
```

## Required Child Validation

Before implementation prompt generation, verify that required sibling
child-owned proposal packets have accepted reviews, passing implementation
readiness receipts, and fresh review-gate digests. This implementation run
intentionally selects `mechanism-detail-pages-and-operator-map`, so that child
is required for implementation and closeout while still remaining child-owned.

Child packets must add or update validators for:

- product feature catalog remaining navigation-only;
- mechanism index not becoming runtime authority;
- `state/control/**` not being labeled retained evidence;
- generated-effective surfaces remaining non-authoritative;
- operator read models remaining navigation/visibility only;
- raw/input surfaces not becoming runtime or policy dependencies;
- lifecycle interaction receipts not authorizing target action;
- parent proposal-program evidence not satisfying child packet receipts;
- proposal lifecycle, Change closeout, worktree closeout, and repo hygiene not
  collapsing into one authority system;
- retired `Lifecycle Autopilot` terminology not reappearing outside explicit
  compatibility or historical notes.

## Aggregate Closeout Validation

The final required child must retain aggregate evidence showing:

- all required children exist as child-owned proposal packets;
- all required mechanisms are represented;
- every mechanism entry names required surface classes;
- ownership and delegation boundaries are present;
- non-authority boundaries are explicit;
- validators cover both positive and negative cases;
- product, architecture, runtime, operator, generated, input, state/control,
  and state/evidence terminology stays layer-correct.
