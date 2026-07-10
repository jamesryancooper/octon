# Current-State Gap Map

Live-repository grounding for this packet, captured against the working tree on
2026-07-10. Where the parent program design docs disagree with the live repo, the
repository wins (child-packet contract obligation 3); each divergence is recorded
here as a resolved reconciliation, not a stale-source blocker.

## What Already Exists (Delivered By Earlier Program Children)

- `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
  is `architectural-review-naming-v2`. Its `methods.catalog` already declares all
  six methods with the canonical companion slugs `tradeoff-review-method`,
  `failure-mode-review-method`, `evolution-fitness-review-method`, and
  `boundary-authority-review-method`, each with a `role: companion` and a
  `lens_profile_ref` into `lens-bank.yml`. **The four companion catalog entries
  carry no `doc:` field yet** — Balanced and Greenfield do.
- `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
  is `architectural-review-lens-bank-v1` with 18 tiered lenses and a complete
  `method_profiles.<slug>` entry (non-empty `required` set) for each of the four
  companion slugs. The lens-reference validator
  (`validate-architectural-review-lens-references.sh`) already passes.
- `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
  is `architectural-review-routing-v2` with a `method_selection` block:
  `allowed_methods_by_route`, an `escalation_map` keyed on
  `balanced-architecture-review-method`, and
  `constitutional_conflict_routes_to: constitutional-challenge`. Fail-closed
  conditions include `unknown_method` and `missing_method_record`.
- `README.md` canonical-names table and Methods-And-Selection prose already name
  all six methods; the References section links only Balanced and Greenfield.
- `balanced-architecture-review-method.md` and
  `greenfield-reference-architecture-review-method.md` exist. Greenfield is the
  authored-shape template the four new docs mirror.

## The Gap This Packet Closes

The four companion methods are declared in the naming catalog and profiled in the
lens bank, but **their human-readable method docs do not exist**. A method that is
named and lens-profiled but undocumented is half-integrated: an operator selecting
`failure-mode-review-method` has no doctrine describing its question, output
contract, non-goals, escalation, or non-authority boundary. This packet authors
those four docs and makes them discoverable from `naming.yml` and the README.

## Files That Must Change

| Path | Current state | Required change | Owner role |
| --- | --- | --- | --- |
| `.octon/framework/.../architectural-review/tradeoff-review-method.md` | absent | author method doc | cognition-owner |
| `.octon/framework/.../architectural-review/failure-mode-review-method.md` | absent | author method doc | cognition-owner |
| `.octon/framework/.../architectural-review/evolution-fitness-review-method.md` | absent | author method doc | cognition-owner |
| `.octon/framework/.../architectural-review/boundary-authority-review-method.md` | absent | author method doc (Octon-only v1) | cognition-owner |
| `.octon/framework/.../architectural-review/naming.yml` | 4 companion catalog entries lack `doc:` | add additive `doc:` pointer to each | cognition-owner |
| `.octon/framework/.../architectural-review/README.md` | References list Balanced + Greenfield | add 4 doc links to References | cognition-owner |

(See `architecture/file-change-map.md` for the exact per-file change map.)

## Source ⇄ Repository Reconciliations (Repository Wins)

1. **Companion method slugs.** The parent's `method-taxonomy.md` §§3–6 uses
   descriptive slugs (`architecture-tradeoff-review`,
   `failure-mode-architecture-review`, `evolution-fitness-architecture-review`,
   `boundary-authority-architecture-review`). The delivered
   `naming.yml`/`lens-bank.yml` canonicalize these as `tradeoff-review-method`,
   `failure-mode-review-method`, `evolution-fitness-review-method`, and
   `boundary-authority-review-method`. **The docs use the naming.yml slugs**; the
   naming validator binds every catalog slug to a `lens-bank.yml` `suite_methods`
   profile, so the doc filenames follow the naming slugs (`<slug>.md`).
2. **Surface-audit doctrine path.** `method-taxonomy.md` cites
   `audits/surface-architecture.md`. The live doctrine is at
   `.octon/framework/cognition/practices/methodology/audits/surface-architecture.md`
   (a `methodology/audits/` sibling, not under `architectural-review/`). The
   Boundary/Authority doc's boundary statement cites the live path.
3. **Readiness failure-mode section name.** `method-taxonomy.md` calls it the
   readiness audit's "failure-mode assessment". The live section in
   `architecture-readiness/framework.md` is "## Mandatory Failure-Mode Analysis".
   The Failure-Mode doc cites the live heading.

None of these divergences require a program registry or design revision: they are
naming/path canonicalizations already settled by the phase-0/phase-1 children and
the live audit doctrine. No stale claim is being implemented.

## Explicitly Out Of Scope (Owned Elsewhere)

- Naming/routing schema changes beyond the additive `doc:` pointer — owned by
  `architecture-review-method-taxonomy-and-routing` (already delivered).
- Report/routing-decision schema `method`/`lenses_applied` fields — owned by
  `architectural-review-schema-extensions`.
- Method-id recording in review workflow evidence, feature/mechanism notes,
  advisory lifecycle text, and generated-projection refresh — owned by
  `architectural-review-suite-integration` (phase-3, depends on this child).
- Command/skill facades for direct method invocation — conditional child
  `architecture-review-command-facades`.
- Any change to Balanced or Greenfield doctrine, readiness doctrine, or
  surface-audit doctrine.
