# Cutover Checklist

This change is an additive, in-place extension of existing surfaces. There is
no intermediate live state and no data migration; cutover is the governed
promotion of each target family behind a green validator sweep.

## Preconditions

- [ ] All three phase-2 dependencies (`greenfield-reference-architecture-review-method`,
      `companion-architecture-review-methods`, `architectural-review-schema-extensions`)
      have passed their own verification gate.
- [ ] Live suite surfaces re-grounded and match this packet's assumptions
      (`naming.yml` v2, `review-routing.yml` v2 `method_selection`,
      `lens-bank.yml`, v2 report/routing-decision schemas). Any mismatch has
      triggered a parent registry/design revision, not an in-place workaround.
- [ ] This packet has an accepted proposal-review receipt and a passing
      pre-integration architecture review receipt.

## Cutover Steps (each family = one revertible promotion commit)

1. [ ] **Workflow method-recording family** — the four review-occasion
       `workflow.yml` / stage edits recording the selected method id in v2 run
       evidence. Support receipt untouched.
2. [ ] **Navigation family** — feature note, mechanism entry, and `index.yml`
       extensions (navigation-only) plus the per-occasion advisory.
3. [ ] **Validator family** — extended `validate-architectural-review-workflows.sh`
       and its positive/negative fixtures.
4. [ ] **Projection refresh** — run each affected projection's canonical
       publisher; retain the refresh-run evidence. No direct `.octon/generated/**`
       edits.

## Post-Cutover Verification

- [ ] Full architectural-review validator suite green (including the extended
      workflows validator and NC-01 missing-method-record control).
- [ ] `validate-proposal-standard.sh` and `validate-architecture-proposal.sh`
      green for this packet.
- [ ] `validate-product-feature-catalog.sh` and
      `validate-feature-catalog-drift-closeout.sh` green.
- [ ] Each canonical publisher `--check` is clean (projections fresh).
- [ ] Two consecutive clean sweeps on the same revision, no new findings.
- [ ] No support receipt carries a `method`/`lenses_applied` field.

## Abort / Hold Conditions

- Any validator in the sweep fails, or a negative control does not fire →
  hold cutover, do not advance remaining families, and route to correction.
- A required change would fall outside the four declared write scopes → hold
  and raise a parent registry revision.
