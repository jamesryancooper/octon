# Agency Actors-to-Runtime Migration Evidence (2026-02-21)

## Scope

Clean-break migration of agency runtime surface naming from:

- `agency/actors/` (legacy)

To:

- `agency/runtime/` (canonical)

The migration updates active docs, architecture contracts, templates, and
validators so `runtime/` is the single authoritative path.

## Static Verification

### Legacy path removal

Command:

```bash
test ! -e .harmony/agency/actors && echo "PASS: .harmony/agency/actors removed"
```

Result:

- Passed (`PASS: .harmony/agency/actors removed`)

### Active legacy reference sweep

Command:

```bash
rg -n "\.harmony/agency/actors|agency/actors/|\bactors/README\.md\b|\(actors, governance, practices\)|# Agency Actors|title: Agency Actors" . \
  --glob '!.git/**' \
  --glob '!.archive/**' \
  --glob '!.harmony/output/**' \
  --glob '!.harmony/engine/_ops/state/**' \
  --glob '!.harmony/cognition/runtime/migrations/**' \
  --glob '!.harmony/cognition/runtime/decisions/**' \
  --glob '!.harmony/cognition/runtime/context/decisions.md'
```

Result:

- Passed (no active matches; command exits non-zero when no matches)

## Runtime / Behavioral Verification

### Agency subsystem validation

Command:

```bash
bash .harmony/agency/_ops/scripts/validate/validate-agency.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms runtime-only resolution and deprecation enforcement for:
  - `agency/actors`
  - root legacy agency actor/governance paths
  - deprecated agency exports in `harmony.yml`

## CI / Guardrail Verification

### Harness structure validation

Command:

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms deprecated agency path checks include:
  - `/.harmony/agency/actors`
  - `/.harmony/agency/agents`
  - `/.harmony/agency/assistants`
  - `/.harmony/agency/teams`

## Migration Artifacts

- Plan:
  - `/.harmony/cognition/runtime/migrations/2026-02-21-agency-actors-to-runtime/plan.md`
- ADR:
  - `/.harmony/cognition/runtime/decisions/028-agency-runtime-surface-clean-break-rename.md`
- Banlist updates:
  - `/.harmony/cognition/practices/methodology/migrations/legacy-banlist.md`
