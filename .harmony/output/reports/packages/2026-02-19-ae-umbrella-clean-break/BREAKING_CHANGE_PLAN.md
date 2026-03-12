# Breaking Change Plan: AE Umbrella Chain Migration

## Objective

Perform an atomic, clean-break migration of Assurance Engine (AE) priority semantics from:

`Trust > Speed of development > Ease of use > Portability > Interoperability`

to:

`Assurance > Productivity > Integration`

without compatibility layers, dual mode, or translation paths.

## Breaking Scope

The following are mandatory migration surfaces:

| Surface | Breaking Change |
|---|---|
| Charter policy contract | Replace old chain and trade-off language with umbrella chain semantics. |
| Weights policy contract | Replace legacy `attribute_outcome_map` with `attribute_umbrella_map` and update chain metadata. |
| Runtime scoring engine | Replace old outcome naming/ordering assumptions in resolver, tie-break, and outputs. |
| Runtime gate engine | Make backlog, regression summarization, and high-priority criteria umbrella-aware. |
| Generated outputs | Replace old chain references in scorecard/results/gate summaries. |
| CI workflow | Ensure AE gate checks and artifacts assert umbrella-chain behavior. |
| Docs and release comms | Publish explicit breaking migration notes and downstream instructions. |
| Repo-wide naming | Rename QGE references to AE; do not retain old naming in active surfaces. |

## Clean-Switch Execution Plan

1. Create migration branch and freeze unrelated assurance edits.
2. Update charter contract in `.harmony/assurance/CHARTER.md` to the umbrella chain.
3. Update doctrine and assurance entry docs:
   - `.harmony/assurance/DOCTRINE.md`
   - `.harmony/assurance/README.md`
   - `.harmony/README.md` (Assurance Engine section)
4. Update policy contract in `.harmony/assurance/standards/weights/weights.yml`:
   - `charter.priority_chain` -> `assurance`, `productivity`, `integration`
   - replace old trade-off rules
   - replace legacy `attribute_outcome_map` with `attribute_umbrella_map`
   - bump `meta.version` and append governed changelog entry
5. Update runtime resolver and gate in `.harmony/runtime/crates/assurance_tools/src/main.rs`:
   - replace old outcome terms in data model and output fields
   - compute umbrella rollups from attribute-level data
   - apply umbrella-order tie-breaks in backlog sorting
   - drive high-priority checks using umbrella-rank-aware rules
6. Update workflow and scripts:
   - `.github/workflows/assurance-weight-gates.yml`
   - `.harmony/assurance/_ops/scripts/alignment-check.sh`
   - keep command entrypoints stable unless renaming is explicitly required
7. Regenerate AE artifacts under `.harmony/output/assurance/` so no generated output contains old chain semantics.
8. Execute repo-wide rename sweep for QGE -> AE across active docs/code/commands.
9. Add/refresh tests and golden fixtures for umbrella behavior.
10. Run full assurance checks and merge as one atomic PR.

## Deterministic Migration Guardrails

- No compatibility branches (`legacy_chain`, `translate_old_chain`, similar).
- No runtime fallback behavior for old chain IDs.
- No docs that present both chains as active.
- Attribute-level scoring remains canonical input for every computation.

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Missed old-chain references | Mixed semantics in docs/reports | Enforce grep sweep in CI and pre-merge checklist. |
| Tie-break regression | Incorrect backlog ordering | Add fixture test with known equal-priority ties. |
| Gate severity drift | Unexpected stricter/looser enforcement | Preserve existing hard/warn thresholds and only change ordering drivers. |
| Rollup ambiguity | Non-deterministic umbrella summaries | Use explicit formula and fixed precision rounding. |
| Downstream breakage | Consumers of `.harmony/` fail on update | Publish migration notes and explicit old->new field map. |

## Rollback Strategy (Git Revert, No Runtime Compatibility)

1. If migration PR is merged and must be undone, revert the full migration commit range in one revert PR.
2. Revert order:
   - runtime/CI changes
   - policy/charter docs
   - generated artifacts/tests
3. Re-run baseline assurance workflow after revert to confirm prior state.
4. Do not add fallback logic in AE; rollback is strictly source-control based.

## Done Checklist

- [ ] Charter chain is only `Assurance > Productivity > Integration`.
- [ ] `weights.yml` has complete umbrella mapping for all canonical attributes.
- [ ] Runtime resolver outputs umbrella IDs/ranks and umbrella rollups.
- [ ] Gate logic uses umbrella ranking for backlog/regression/high-priority decisions.
- [ ] No old-chain terms remain in active AE code or policy docs.
- [ ] QGE references are retired from active docs/code/commands.
- [ ] AE golden fixtures updated and passing.
- [ ] CI workflow passes with umbrella-aware scorecard/gate outputs.
- [ ] Breaking change docs, release note, and downstream migration note are published.
