# Migration Plan

## Completion Status

- Status: **Completed**
- Active enforcement phase: `phase2`
- Effective policy files:
  - `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/subsystem-classes.yml`
  - `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/overrides.yml`
- Verification evidence:
  - resolver emits policy deviations report under `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/policy/deviations/*.md`
  - gate passes under strict warning mode with baseline inputs

## Phase 0 (Grace)

- Enforce precedence as-is; do not block merges for missing deviation records.
- Emit warnings for undeclared overrides and missing expiry metadata.
- Require no backfill before adoption.
- Completion: done

## Phase 1 (Control-plane Enforcement)

- Hard-fail control-plane override deviations without declaration + ADR + changelog linkage.
- Hard-fail expired control-plane temporary overrides.
- Keep productivity undeclared overrides as warnings.
- Hard-fail productivity large changes without ADR.
- Completion: done

## Phase 2 (Steady-state)

- Keep Phase 1 rules.
- Require every new/changed repo override in `weights.yml` to be represented in deviation records.
- Use strict warnings in CI where teams want warning-free policy posture.
- Completion: done

## Backfill Steps

1. Run resolver to generate deviations report for active contexts.
2. For each listed repo override deviation, add an entry in `overrides.yml`.
3. Link each entry to ADR and changelog version.
4. Mark temporary overrides with `expires_at` and owner.
5. Re-run gate; resolve hard findings before enabling next phase.

## Default Behavior Without Deviation Records

- During Phase 0: allow and warn.
- After Phase 0: class-based enforcement applies.
