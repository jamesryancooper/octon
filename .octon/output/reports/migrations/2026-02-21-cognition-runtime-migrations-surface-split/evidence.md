# Cognition Runtime Migrations Surface Split Evidence (2026-02-21)

## Scope

Clean-break migration that separates migration policy doctrine from runtime migration records and centralizes migration evidence output paths.

Legacy removed:

- Dated migration records under:
  - `/.octon/cognition/practices/methodology/migrations/<YYYY-MM-DD>-<slug>/`
- Root-level migration evidence reports under:
  - `/.octon/output/reports/<YYYY-MM-DD>-<slug>/evidence.md` (migration evidence class)

Canonical replacement:

- Runtime migration records under:
  - `/.octon/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/`
- Runtime migration discovery index:
  - `/.octon/cognition/runtime/migrations/index.yml`
- Migration evidence reports under:
  - `/.octon/output/reports/migrations/<YYYY-MM-DD>-<slug>/evidence.md`

## Static Verification

### Legacy dated-record placement sweep

Command:

```bash
find .octon/cognition/practices/methodology/migrations \
  -mindepth 1 -maxdepth 1 -type d -name '20*-*'
```

Result:

- Passed (`no matches`)

### Legacy root migration-evidence placement sweep

Command:

```bash
find .octon/output/reports \
  -mindepth 1 -maxdepth 1 -type f | \
  grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*(migration|clean-break).*evidence\.md$' || true
```

Result:

- Passed (`no matches`)

### Legacy path token sweep (active surfaces)

Command:

```bash
rg -n "cognition/practices/methodology/migrations/20|output/reports/[0-9]{4}-[0-9]{2}-[0-9]{2}.*evidence\.md" .octon \
  --glob '!.octon/output/**' \
  --glob '!.octon/cognition/practices/methodology/migrations/legacy-banlist.md' || true
```

Result:

- Passed (`no matches`)

## Runtime / Contract Verification

### Harness structure validation

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Observed expected version alignment signal:
  - `audit-subsystem-health version bump detected (1.0.6 -> 1.0.8)`

### Audit-subsystem-health alignment validation

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)

### Workflow contract validation

Command:

```bash
bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)

### Skills contract validation (strict)

Command:

```bash
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

Result:

- Passed (`All checks passed!`)

### Alignment profile validation (skills,workflows,harness)

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness
```

Result:

- Passed (`Alignment check summary: errors=0`)

## Guardrail Verification

Guardrails updated to block legacy reintroduction:

- `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - rejects dated migration folders under practices migration policy path
  - rejects migration evidence reports at output reports root
- `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
  - includes legacy dated-record prefix bans for practices migration path

## Migration Artifacts

- Runtime plan:
  - `/.octon/cognition/runtime/migrations/2026-02-21-cognition-runtime-migrations-surface-split/plan.md`
- ADR:
  - `/.octon/cognition/runtime/decisions/031-cognition-runtime-migrations-surface-split.md`
- Runtime migration index:
  - `/.octon/cognition/runtime/migrations/index.yml`
- Decision context addendum:
  - `/.octon/cognition/runtime/context/decisions.md`
- Evidence report:
  - `/.octon/output/reports/migrations/2026-02-21-cognition-runtime-migrations-surface-split/evidence.md`
