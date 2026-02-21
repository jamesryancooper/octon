# Quality-Gate Domain Split Migration Evidence (2026-02-21)

## Scope

Clean-break migration of overloaded runtime `quality-gate` domains into focused runtime domains:

- Skills:
  - `/.harmony/capabilities/runtime/skills/audit/`
  - `/.harmony/capabilities/runtime/skills/remediation/`
  - `/.harmony/capabilities/runtime/skills/refactor/`
- Workflows:
  - `/.harmony/orchestration/runtime/workflows/audit/`
  - `/.harmony/orchestration/runtime/workflows/refactor/`

Removed legacy directories:

- `/.harmony/capabilities/runtime/skills/quality-gate/`
- `/.harmony/orchestration/runtime/workflows/quality-gate/`

## Static Verification

### Legacy group/path token sweep (active surfaces)

Command:

```bash
rg -n "group: quality-gate|path: quality-gate/" .harmony \
  --glob '!.harmony/output/**' \
  --glob '!.harmony/ideation/**' \
  --glob '!.harmony/cognition/practices/methodology/migrations/**' \
  --glob '!.harmony/cognition/runtime/decisions/**' \
  --glob '!.harmony/cognition/runtime/context/decisions.md'
```

Result:

- Passed (`no matches`)

### Legacy directory reference sweep (active non-guardrail surfaces)

Command:

```bash
rg -n "capabilities/runtime/skills/quality-gate/|orchestration/runtime/workflows/quality-gate/" .harmony \
  --glob '!.harmony/output/**' \
  --glob '!.harmony/ideation/**' \
  --glob '!.harmony/cognition/practices/methodology/migrations/**' \
  --glob '!.harmony/cognition/runtime/decisions/**' \
  --glob '!.harmony/cognition/runtime/context/decisions.md' \
  --glob '!.harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh' \
  --glob '!.harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh' \
  --glob '!.harmony/cognition/practices/methodology/migrations/legacy-banlist.md'
```

Result:

- Passed (`no matches`)

### Legacy directory removal

Command:

```bash
test ! -e .harmony/capabilities/runtime/skills/quality-gate && echo "PASS: .harmony/capabilities/runtime/skills/quality-gate removed"
test ! -e .harmony/orchestration/runtime/workflows/quality-gate && echo "PASS: .harmony/orchestration/runtime/workflows/quality-gate removed"
```

Result:

- Passed
  - `PASS: .harmony/capabilities/runtime/skills/quality-gate removed`
  - `PASS: .harmony/orchestration/runtime/workflows/quality-gate removed`

## Runtime / Contract Verification

### Skills contract validation (strict)

Command:

```bash
bash .harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

Result:

- Passed (`All checks passed!`)
- Confirms deprecated skills path enforcement includes `quality-gate`.

### Workflow contract validation

Command:

```bash
bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms deprecated workflows path enforcement includes:
  - `.harmony/orchestration/runtime/workflows/quality-gate`

### Audit subsystem health alignment validation

Command:

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms logic-change version bump for `audit-subsystem-health`:
  - `1.0.5 -> 1.0.6`

### Alignment profile validation (skills, workflows, harness)

Command:

```bash
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness
```

Result:

- Passed (`Alignment check summary: errors=0`)

## CI / Guardrail Verification

Guardrails updated to block legacy reintroduction:

- Legacy ban entries added for quality-gate directory and taxonomy tokens:
  - `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`
- Deprecated path check enforced in skills validator:
  - `/.harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh`
- Deprecated path check enforced in workflow validator:
  - `/.harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`

## Migration Artifacts

- Plan:
  - `/.harmony/cognition/practices/methodology/migrations/2026-02-21-quality-gate-domain-split/plan.md`
- ADR:
  - `/.harmony/cognition/runtime/decisions/029-quality-gate-domain-split-clean-break-migration.md`
- Decision context addendum:
  - `/.harmony/cognition/runtime/context/decisions.md`
- Banlist updates:
  - `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`
