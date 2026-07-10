# Cutover Checklist

This is additive native methodology authoring with no live-state migration: a new
method doc is created and two additive navigation edits are made. Balanced remains
the default method, and the Greenfield method was already routable after phase-1,
so no routing behavior changes. "Cutover" here is the single atomic landing of the
new doc plus the two wiring edits.

## Pre-Cutover

- [ ] Implementation authorized (accepted status, accepted proposal-review
      receipt authorizing the executable prompt, strict Pre-Integration
      Architecture Review receipt present).
- [ ] Upstream `architecture-review-method-taxonomy-and-routing` (phase-1) has
      passed its `verification` gate; `naming.yml` names and `review-routing.yml`
      routes the greenfield method. Transitively,
      `architecture-lens-bank-foundation` (phase-0) has verified; the greenfield
      lens profile is stable.
- [ ] Write scope confirmed limited to
      `.octon/framework/cognition/practices/methodology/architectural-review/`.
- [ ] `architecture/method-doc-authoring-spec.md` re-checked against the live
      `naming.yml` slug, `review-routing.yml` `method_selection`, and
      `lens-bank.yml` greenfield profile (slug + 14 required + 3 optional lens ids
      still match).

## Cutover (atomic)

- [ ] `greenfield-reference-architecture-review-method.md` authored with the
      question, use cases, non-goals, required inputs, lens profile, five required
      output sections, initial-build sequencing, minimum viable architecture,
      what-not-to-build-yet, clean-sheet complementarity, escalation rules, and
      the fail-closed output boundary.
- [ ] `naming.yml` greenfield catalog entry gains
      `doc: "greenfield-reference-architecture-review-method.md"`; nothing else
      changed.
- [ ] README References section links the new doc; canonical-names table
      untouched.

## Post-Cutover Validation

- [ ] Doc-consistency check passes: doc slug = `naming.yml` slug = `lens-bank.yml`
      slug; cited lens ids match the greenfield profile exactly.
- [ ] All five required output sections and the three build-discipline
      subsections present; fail-closed output boundary present.
- [ ] Naming and routing validators pass with the additive `doc:` reference.
- [ ] Phase-0 lens-reference validator still passes; the profile is unchanged.
- [ ] `git diff` shows the `naming.yml` change is only the additive `doc:` field,
      the README change is only a References link, and Balanced/companion doctrine
      is unchanged.
- [ ] Remaining `validate-architectural-review-*.sh` suite still passes.
- [ ] Evidence retained under the child promotion evidence root.

## Closure

- [ ] All acceptance criteria AC-1..AC-9 satisfied; verification receipt
      retained; child moved to `closed`.
