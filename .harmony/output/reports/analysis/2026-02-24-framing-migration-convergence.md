# Framing Migration Convergence Report

Date: 2026-02-24
Owner: harmony-platform
Scope: Root and `.harmony/**` framing migration convergence for agent-first purpose, managed complexity, and system-governed model.

## Convergence Outcome

Status: **Converged**

The migration is converged for active runtime/governance/practices surfaces with regression guardrails in place.

## Closed Owner Decisions

1. `complexity_calibration` is the canonical complexity attribute id.
2. Active surfaces are aligned to six-pillar naming.
3. Historical output reports were rewritten to current Assurance framing.
4. Historical ADR handling is annotation-first: superseding links were added without rewriting historical rationale bodies.
5. Full-repo regression check was executed.
6. `solo/tiny team` messaging remains in non-SSOT surfaces while SSOT emphasizes cross-project agent standardization.

## Step Gate Results

- Step 10 (historical output reports rewrite): PASS
  - Deprecated terms removed from rewritten historical reports.
  - Assurance Engine and `Assurance > Productivity > Integration` references present.
- Step 11 (historical ADR superseding annotations): PASS
  - Added superseding annotations to ADRs retaining legacy framing tokens:
    - `/.harmony/cognition/runtime/decisions/009-manifest-discovery-and-validation.md`
    - `/.harmony/cognition/runtime/decisions/017-assurance-clean-break-migration.md`
- Step 12 (regression guardrails): PASS
  - Added `/.harmony/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`.
  - Wired framing validator into `alignment-check.sh` (harness profile).
  - Updated completion/exit checklists with framing validation requirements.
- Step 13 (final convergence): PASS
  - `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh` -> PASS
  - `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness` -> PASS (`errors=0`)
  - `bash .harmony/assurance/runtime/_ops/scripts/compute-assurance-score.sh --weights .harmony/assurance/governance/weights/weights.yml --scores .harmony/assurance/governance/scores/scores.yml` -> PASS

## Regression Evidence

Full-repo sweep command:

```bash
rg -n --hidden --glob '!.git' '<legacy-framing-pattern-set>' .
```

Result: **2 matches**, both intentional historical ADR references with superseding annotations:

1. `/.harmony/cognition/runtime/decisions/009-manifest-discovery-and-validation.md`
2. `/.harmony/cognition/runtime/decisions/017-assurance-clean-break-migration.md`

No active-surface deprecated framing matches remain.

## Residual Risks

1. Historical ADR token retention may be misread as active guidance by casual readers.
   - Mitigation: superseding annotations added and framing validator allowlists require those annotations.
2. Generated/runtime artifacts can drift after governance edits.
   - Mitigation: `validate-harness-structure.sh` already enforces generated artifact sync; convergence run included sync.

## Definition of Done Check

- [x] Canonical framing is applied to active contracts, governance, runtime docs, workflows, templates, and assurance policy surfaces.
- [x] `Complexity Calibration` terminology and `complexity_calibration` id are canonicalized.
- [x] System-governed model language is active and consistent.
- [x] Historical output reports are rewritten to current naming.
- [x] Historical ADRs with legacy framing include superseding links.
- [x] Framing regression validator exists and is wired into harness alignment checks.
- [x] Final convergence validations pass.

