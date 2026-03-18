# Quality-Gate Domain Split Migration Evidence (2026-02-21)

## Scope

Clean-break migration of overloaded runtime `quality-gate` domains into focused runtime domains:

- Skills:
  - `/.octon/framework/capabilities/runtime/skills/audit/`
  - `/.octon/framework/capabilities/runtime/skills/remediation/`
  - `/.octon/framework/capabilities/runtime/skills/refactor/`
- Workflows:
  - `/.octon/framework/orchestration/runtime/workflows/audit/`
  - `/.octon/framework/orchestration/runtime/workflows/refactor/`

Removed legacy directories:

- `/.octon/framework/capabilities/runtime/skills/quality-gate/`
- `/.octon/framework/orchestration/runtime/workflows/quality-gate/`

## Static Verification

### Legacy group/path token sweep (active surfaces)

Command:

```bash
rg -n "group: quality-gate|path: quality-gate/" .octon \
  --glob '!.octon/generated/**' \
  --glob '!.octon/inputs/exploratory/ideation/**' \
  --glob '!.octon/instance/cognition/context/shared/migrations/**' \
  --glob '!.octon/instance/cognition/decisions/**' \
  --glob '!.octon/instance/cognition/context/shared/decisions.md'
```

Result:

- Passed (`no matches`)

### Legacy directory reference sweep (active non-guardrail surfaces)

Command:

```bash
rg -n "capabilities/runtime/skills/quality-gate/|orchestration/runtime/workflows/quality-gate/" .octon \
  --glob '!.octon/generated/**' \
  --glob '!.octon/inputs/exploratory/ideation/**' \
  --glob '!.octon/instance/cognition/context/shared/migrations/**' \
  --glob '!.octon/instance/cognition/decisions/**' \
  --glob '!.octon/instance/cognition/context/shared/decisions.md' \
  --glob '!.octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh' \
  --glob '!.octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh' \
  --glob '!.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md'
```

Result:

- Passed (`no matches`)

### Legacy directory removal

Command:

```bash
test ! -e .octon/framework/capabilities/runtime/skills/quality-gate && echo "PASS: .octon/framework/capabilities/runtime/skills/quality-gate removed"
test ! -e .octon/framework/orchestration/runtime/workflows/quality-gate && echo "PASS: .octon/framework/orchestration/runtime/workflows/quality-gate removed"
```

Result:

- Passed
  - `PASS: .octon/framework/capabilities/runtime/skills/quality-gate removed`
  - `PASS: .octon/framework/orchestration/runtime/workflows/quality-gate removed`

## Runtime / Contract Verification

### Skills contract validation (strict)

Command:

```bash
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

Result:

- Passed (`All checks passed!`)
- Confirms deprecated skills path enforcement includes `quality-gate`.

### Workflow contract validation

Command:

```bash
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms deprecated workflows path enforcement includes:
  - `.octon/framework/orchestration/runtime/workflows/quality-gate`

### Audit subsystem health alignment validation

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms logic-change version bump for `audit-subsystem-health`:
  - `1.0.5 -> 1.0.6`

### Alignment profile validation (skills, workflows, harness)

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness
```

Result:

- Passed (`Alignment check summary: errors=0`)

## CI / Guardrail Verification

Guardrails updated to block legacy reintroduction:

- Legacy ban entries added for quality-gate directory and taxonomy tokens:
  - `/.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md`
- Deprecated path check enforced in skills validator:
  - `/.octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh`
- Deprecated path check enforced in workflow validator:
  - `/.octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`

## Migration Artifacts

- Plan:
  - `/.octon/instance/cognition/context/shared/migrations/2026-02-21-quality-gate-domain-split/plan.md`
- ADR:
  - `/.octon/instance/cognition/decisions/029-quality-gate-domain-split-clean-break-migration.md`
- Decision context addendum:
  - `/.octon/instance/cognition/context/shared/decisions.md`
- Banlist updates:
  - `/.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md`
