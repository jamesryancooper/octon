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
  .harmony/cognition/context \
  .harmony/cognition/decisions \
  .harmony/cognition/analyses \
  .harmony/cognition/knowledge-plane \
  .harmony/cognition/principles \
  .harmony/cognition/pillars \
  .harmony/cognition/purpose \
  .harmony/cognition/methodology \
  .harmony/cognition/principles/_ops \
  .harmony/cognition/principles/_meta/docs; do
  [[ -e "$p" ]] && echo "FAIL: $p" && exit 1 || echo "PASS: $p removed"
done
```

Result:

- Passed (all legacy cognition root paths removed)

### Active legacy reference sweep

Command:

```bash
rg -n "\.harmony/cognition/(context|decisions|analyses|knowledge-plane|principles|pillars|purpose|methodology)(/|\\b)" . \
  --glob '!.git/**' \
  --glob '!.harmony/output/**' \
  --glob '!.harmony/engine/_ops/state/**' \
  --glob '!.harmony/continuity/log.md' \
  --glob '!.harmony/cognition/runtime/decisions/**' \
  --glob '!.harmony/cognition/runtime/context/decisions.md' \
  --glob '!.harmony/cognition/practices/methodology/migrations/**' \
  --glob '!.harmony/capabilities/_ops/tests/test-ra-acp-migration-guard.sh' \
  --glob '!.harmony/cognition/_ops/principles/scripts/test-principles-governance-lint-fixtures.sh' \
  --glob '!.harmony/cognition/_ops/principles/scripts/reference-lint.sh'
```

Result:

- Passed (no active legacy cognition references detected)

## Runtime / Behavioral Verification

### Principles governance lint

Command:

```bash
bash .harmony/cognition/_ops/principles/scripts/lint-principles-governance.sh
```

Result:

- Passed (`Principles reference lint passed`, `Principles governance lint passed`)

### Principles governance fixture tests

Command:

```bash
bash .harmony/cognition/_ops/principles/scripts/test-principles-governance-lint-fixtures.sh
```

Result:

- Passed (`Principles governance lint fixture tests passed`)

### RA+ACP migration guard

Commands:

```bash
bash .harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh
bash .harmony/capabilities/_ops/tests/test-ra-acp-migration-guard.sh
```

Result:

- Passed (`RA+ACP migration regression checks passed`; guard tests `5 passed, 0 failed`)

## CI / Guardrail Verification

### Harness structure validator

Command:

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Includes cognition bounded-surface enforcement:
  - requires `cognition/runtime/`, `cognition/governance/`, `cognition/practices/`, `cognition/_ops/`
  - fails if deprecated cognition root paths reappear

## Notes

- Bounded-surface contract now includes cognition migration and updated applicability boundaries:
  - `/.harmony/cognition/_meta/architecture/bounded-surfaces-contract.md`
- Migration artifacts:
  - Plan: `/.harmony/cognition/practices/methodology/migrations/2026-02-20-cognition-bounded-surfaces/plan.md`
  - ADR: `/.harmony/cognition/runtime/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
  - Banlist: `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`
