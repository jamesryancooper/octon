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
  .octon/cognition/context \
  .octon/cognition/decisions \
  .octon/cognition/analyses \
  .octon/cognition/knowledge-plane \
  .octon/cognition/principles \
  .octon/cognition/pillars \
  .octon/cognition/purpose \
  .octon/cognition/methodology \
  .octon/cognition/principles/_ops \
  .octon/cognition/principles/_meta/docs; do
  [[ -e "$p" ]] && echo "FAIL: $p" && exit 1 || echo "PASS: $p removed"
done
```

Result:

- Passed (all legacy cognition root paths removed)

### Active legacy reference sweep

Command:

```bash
rg -n "\.octon/cognition/(context|decisions|analyses|knowledge-plane|principles|pillars|purpose|methodology)(/|\\b)" . \
  --glob '!.git/**' \
  --glob '!.octon/output/**' \
  --glob '!.octon/engine/_ops/state/**' \
  --glob '!.octon/continuity/log.md' \
  --glob '!.octon/cognition/runtime/decisions/**' \
  --glob '!.octon/cognition/runtime/context/decisions.md' \
  --glob '!.octon/cognition/runtime/migrations/**' \
  --glob '!.octon/capabilities/_ops/tests/test-ra-acp-migration-guard.sh' \
  --glob '!.octon/cognition/_ops/principles/scripts/test-principles-governance-lint-fixtures.sh' \
  --glob '!.octon/cognition/_ops/principles/scripts/reference-lint.sh'
```

Result:

- Passed (no active legacy cognition references detected)

## Runtime / Behavioral Verification

### Principles governance lint

Command:

```bash
bash .octon/cognition/_ops/principles/scripts/lint-principles-governance.sh
```

Result:

- Passed (`Principles reference lint passed`, `Principles governance lint passed`)

### Principles governance fixture tests

Command:

```bash
bash .octon/cognition/_ops/principles/scripts/test-principles-governance-lint-fixtures.sh
```

Result:

- Passed (`Principles governance lint fixture tests passed`)

### RA+ACP migration guard

Commands:

```bash
bash .octon/capabilities/_ops/scripts/validate-ra-acp-migration.sh
bash .octon/capabilities/_ops/tests/test-ra-acp-migration-guard.sh
```

Result:

- Passed (`RA+ACP migration regression checks passed`; guard tests `5 passed, 0 failed`)

## CI / Guardrail Verification

### Harness structure validator

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Includes cognition bounded-surface enforcement:
  - requires `cognition/runtime/`, `cognition/governance/`, `cognition/practices/`, `cognition/_ops/`
  - fails if deprecated cognition root paths reappear

## Notes

- Bounded-surface contract now includes cognition migration and updated applicability boundaries:
  - `/.octon/cognition/_meta/architecture/bounded-surfaces-contract.md`
- Migration artifacts:
  - Plan: `/.octon/cognition/runtime/migrations/2026-02-20-cognition-bounded-surfaces/plan.md`
  - ADR: `/.octon/cognition/runtime/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
  - Banlist: `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
