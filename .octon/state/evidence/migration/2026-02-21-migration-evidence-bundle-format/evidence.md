# Migration Evidence Bundle Format Evidence (2026-02-21)

## Scope

Clean-break migration that replaces flat migration evidence files with required
multi-file evidence bundles.

Legacy removed:

- `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>-evidence.md`

Canonical replacement:

- `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/`
- required files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

## Static Verification

### Flat evidence file sweep (`output/reports/migrations/`)

Command:

```bash
find .octon/state/evidence/migration -mindepth 1 -maxdepth 1 -type f | \
  grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*evidence\.md$' || true
```

Result:

- Passed (`no matches`)

### Root reports migration-evidence sweep (`output/reports/`)

Command:

```bash
find .octon/generated/reports -mindepth 1 -maxdepth 1 -type f | \
  grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*(migration|clean-break).*evidence\.md$' || true
```

Result:

- Passed (`no matches`)

### Bundle file completeness sweep

Command:

```bash
for d in .octon/state/evidence/migration/20*-*; do
  test -d "$d" || continue
  for f in bundle.yml evidence.md commands.md validation.md inventory.md; do
    test -f "$d/$f" || echo "missing $d/$f"
  done
done
```

Result:

- Passed (`no missing files`)

## Runtime / Contract Verification

### Harness structure validation

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)

### Audit-subsystem-health alignment validation

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)

### Workflow contract validation

Command:

```bash
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)

### Skills contract validation (strict)

Command:

```bash
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

Result:

- Passed (`All checks passed!`)

### Alignment profile validation (skills,workflows,harness)

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness
```

Result:

- Passed (`Alignment check summary: errors=0`)

## Guardrail Verification

Guardrails enforce the bundle contract in:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - rejects flat migration evidence files in `output/reports/migrations/`
  - requires `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and
    `inventory.md` for each date-prefixed migration bundle directory
  - validates `bundle.yml` metadata pointers and id/kind

## Migration Artifacts

- Runtime plan:
  - `/.octon/instance/cognition/context/shared/migrations/2026-02-21-migration-evidence-bundle-format/plan.md`
- ADR:
  - `/.octon/instance/cognition/decisions/032-migration-evidence-bundle-format.md`
- Runtime migration index:
  - `/.octon/instance/cognition/context/shared/migrations/index.yml`
- Decision context addendum:
  - `/.octon/instance/cognition/context/shared/decisions.md`
- Evidence bundle:
  - `/.octon/state/evidence/migration/2026-02-21-migration-evidence-bundle-format/`
