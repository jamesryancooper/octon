# Cognition Bounded Surfaces Migration Evidence (2026-02-20)

## Scope

Clean-break migration of cognition to canonical bounded surfaces:

- `cognition/runtime/`
- `cognition/governance/`
- `cognition/practices/`
- `cognition/_ops/`
- `cognition/_meta/`

Legacy cognition root surfaces were removed:

- `context/`, `decisions/`, `analyses/`, `knowledge-plane/`
- `principles/`, `pillars/`, `purpose/`, `methodology/`
- `principles/_ops/`, `principles/_meta/docs/`

## Static Verification

### Legacy path removal

Command:

```bash
for p in \
  .octon/framework/cognition/context \
  .octon/framework/cognition/decisions \
  .octon/framework/cognition/analyses \
  .octon/framework/cognition/knowledge-plane \
  .octon/framework/cognition/principles \
  .octon/framework/cognition/pillars \
  .octon/framework/cognition/purpose \
  .octon/framework/cognition/methodology \
  .octon/framework/cognition/principles/_ops \
  .octon/framework/cognition/principles/_meta/docs; do
  [[ -e "$p" ]] && echo "FAIL: $p" && exit 1 || echo "PASS: $p removed"
done
```

Result:

- Passed (all legacy cognition root paths removed)

### Active legacy reference sweep

Command:

```bash
rg -n "\.octon/framework/cognition/(context|decisions|analyses|knowledge-plane|principles|pillars|purpose|methodology)(/|\\b)" . \
  --glob '!.git/**' \
  --glob '!.octon/generated/**' \
  --glob '!.octon/framework/engine/_ops/state/**' \
  --glob '!.octon/state/continuity/repo/log.md' \
  --glob '!.octon/instance/cognition/decisions/**' \
  --glob '!.octon/instance/cognition/context/shared/decisions.md' \
  --glob '!.octon/instance/cognition/context/shared/migrations/**' \
  --glob '!.octon/framework/capabilities/_ops/tests/test-ra-acp-migration-guard.sh' \
  --glob '!.octon/framework/cognition/_ops/principles/scripts/test-principles-governance-lint-fixtures.sh' \
  --glob '!.octon/framework/cognition/_ops/principles/scripts/reference-lint.sh'
```

Result:

- Passed (no active legacy cognition references detected)

## Runtime / Behavioral Verification

### Principles governance lint

Command:

```bash
bash .octon/framework/cognition/_ops/principles/scripts/lint-principles-governance.sh
```

Result:

- Passed (`Principles reference lint passed`, `Principles governance lint passed`)

### Principles governance fixture tests

Command:

```bash
bash .octon/framework/cognition/_ops/principles/scripts/test-principles-governance-lint-fixtures.sh
```

Result:

- Passed (`Principles governance lint fixture tests passed`)

### RA+ACP migration guard

Commands:

```bash
bash .octon/framework/capabilities/_ops/scripts/validate-ra-acp-migration.sh
bash .octon/framework/capabilities/_ops/tests/test-ra-acp-migration-guard.sh
```

Result:

- Passed (`RA+ACP migration regression checks passed`; guard tests `5 passed, 0 failed`)

## CI / Guardrail Verification

### Harness structure validator

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Includes cognition bounded-surface enforcement:
  - requires `cognition/runtime/`, `cognition/governance/`, `cognition/practices/`, `cognition/_ops/`
  - fails if deprecated cognition root paths reappear

## Notes

- Bounded-surface contract now includes cognition migration and updated applicability boundaries:
  - `/.octon/framework/cognition/_meta/architecture/bounded-surfaces-contract.md`
- Migration artifacts:
  - Plan: `/.octon/instance/cognition/context/shared/migrations/2026-02-20-cognition-bounded-surfaces/plan.md`
  - ADR: `/.octon/instance/cognition/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
  - Banlist: `/.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md`
