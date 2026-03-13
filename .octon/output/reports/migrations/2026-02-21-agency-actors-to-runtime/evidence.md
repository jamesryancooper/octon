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
test ! -e .octon/agency/actors && echo "PASS: .octon/agency/actors removed"
```

Result:

- Passed (`PASS: .octon/agency/actors removed`)

### Active legacy reference sweep

Command:

```bash
rg -n "\.octon/agency/actors|agency/actors/|\bactors/README\.md\b|\(actors, governance, practices\)|# Agency Actors|title: Agency Actors" . \
  --glob '!.git/**' \
  --glob '!.archive/**' \
  --glob '!.octon/output/**' \
  --glob '!.octon/engine/_ops/state/**' \
  --glob '!.octon/cognition/runtime/migrations/**' \
  --glob '!.octon/cognition/runtime/decisions/**' \
  --glob '!.octon/cognition/runtime/context/decisions.md'
```

Result:

- Passed (no active matches; command exits non-zero when no matches)

## Runtime / Behavioral Verification

### Agency subsystem validation

Command:

```bash
bash .octon/agency/_ops/scripts/validate/validate-agency.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms runtime-only resolution and deprecation enforcement for:
  - `agency/actors`
  - root legacy agency actor/governance paths
  - deprecated agency exports in `octon.yml`

## CI / Guardrail Verification

### Harness structure validation

Command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`Validation summary: errors=0 warnings=0`)
- Confirms deprecated agency path checks include:
  - `/.octon/agency/actors`
  - `/.octon/agency/agents`
  - `/.octon/agency/assistants`
  - `/.octon/agency/teams`

## Migration Artifacts

- Plan:
  - `/.octon/cognition/runtime/migrations/2026-02-21-agency-actors-to-runtime/plan.md`
- ADR:
  - `/.octon/cognition/runtime/decisions/028-agency-runtime-surface-clean-break-rename.md`
- Banlist updates:
  - `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
