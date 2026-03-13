# Quality-Gate Domain Split Migration Evidence (2026-02-21)

## Scope

Clean-break migration of overloaded runtime `quality-gate` domains into focused runtime domains:

- Skills:
  - `/.octon/capabilities/runtime/skills/audit/`
  - `/.octon/capabilities/runtime/skills/remediation/`
  - `/.octon/capabilities/runtime/skills/refactor/`
- Workflows:
  - `/.octon/orchestration/runtime/workflows/audit/`
  - `/.octon/orchestration/runtime/workflows/refactor/`

Removed legacy directories:

- `/.octon/capabilities/runtime/skills/quality-gate/`
- `/.octon/orchestration/runtime/workflows/quality-gate/`

## Static Verification

### Legacy group/path token sweep (active surfaces)

Command:

```bash
rg -n "group: quality-gate|path: quality-gate/" .octon \
  --glob '!.octon/output/**' \
  --glob '!.octon/ideation/**' \
  --glob '!.octon/cognition/runtime/migrations/**' \
  --glob '!.octon/cognition/runtime/decisions/**' \
  --glob '!.octon/cognition/runtime/context/decisions.md'
```

Result:

- Passed (`no matches`)

### Legacy directory reference sweep (active non-guardrail surfaces)

Command:

```bash
rg -n "capabilities/runtime/skills/quality-gate/|orchestration/runtime/workflows/quality-gate/" .octon \
  --glob '!.octon/output/**' \
  --glob '!.octon/ideation/**' \
  --glob '!.octon/cognition/runtime/migrations/**' \
  --glob '!.octon/cognition/runtime/decisions/**' \
  --glob '!.octon/cognition/runtime/context/decisions.md' \
  --glob '!.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh' \
  --glob '!.octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh' \
  --glob '!.octon/cognition/practices/methodology/migrations/legacy-banlist.md'
```

Result:

- Passed (`no matches`)

### Legacy directory removal

Command:

```bash
test ! -e .octon/capabilities/runtime/skills/quality-gate && echo "PASS: .octon/capabilities/runtime/skills/quality-gate removed"
test ! -e .octon/orchestration/runtime/workflows/quality-gate && echo "PASS: .octon/orchestration/runtime/workflows/quality-gate removed"
```

Result:

- Passed
  - `PASS: .octon/capabilities/runtime/skills/quality-gate removed`
  - `PASS: .octon/orchestration/runtime/workflows/quality-gate removed`

## Runtime / Contract Verification

### Skills contract validation (strict)

Command:

```bash
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

Result:

- Passed (`All checks passed!`)
- Confirms deprecated skills path enforcement includes `quality-gate`.

### Workflow contract validation

Command:

```bash
bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms deprecated workflows path enforcement includes:
  - `.octon/orchestration/runtime/workflows/quality-gate`

### Audit subsystem health alignment validation

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms logic-change version bump for `audit-subsystem-health`:
  - `1.0.5 -> 1.0.6`

### Alignment profile validation (skills, workflows, harness)

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness
```

Result:

- Passed (`Alignment check summary: errors=0`)

## CI / Guardrail Verification

Guardrails updated to block legacy reintroduction:

- Legacy ban entries added for quality-gate directory and taxonomy tokens:
  - `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
- Deprecated path check enforced in skills validator:
  - `/.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh`
- Deprecated path check enforced in workflow validator:
  - `/.octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`

## Migration Artifacts

- Plan:
  - `/.octon/cognition/runtime/migrations/2026-02-21-quality-gate-domain-split/plan.md`
- ADR:
  - `/.octon/cognition/runtime/decisions/029-quality-gate-domain-split-clean-break-migration.md`
- Decision context addendum:
  - `/.octon/cognition/runtime/context/decisions.md`
- Banlist updates:
  - `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
