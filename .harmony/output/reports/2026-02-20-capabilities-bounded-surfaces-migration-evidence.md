---
title: Capabilities Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to capabilities runtime/governance/practices bounded surfaces.
---

# Capabilities Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-capabilities-bounded-surfaces`
- Plan: `/.harmony/cognition/methodology/migrations/2026-02-20-capabilities-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "\.harmony/capabilities/(commands|skills|tools|services|_ops/policy)|capabilities/(commands|skills|tools|services|_ops/policy)" AGENTS.md .harmony .github --glob '!.harmony/assurance/_ops/scripts/validate-harness-structure.sh' --glob '!.harmony/cognition/methodology/migrations/**' --glob '!.harmony/output/**' --glob '!.harmony/ideation/**' --glob '!.archive/**' --glob '!.harmony/runtime/_ops/state/**' --glob '!.harmony/cognition/decisions/**' --glob '!.harmony/cognition/context/decisions.md' --glob '!.harmony/continuity/log.md' --glob '!.harmony/capabilities/runtime/services/_ops/state/**'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .harmony/capabilities/commands .harmony/capabilities/skills .harmony/capabilities/tools .harmony/capabilities/services .harmony/capabilities/_ops/policy; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .harmony/capabilities/commands`
- `REMOVED .harmony/capabilities/skills`
- `REMOVED .harmony/capabilities/tools`
- `REMOVED .harmony/capabilities/services`
- `REMOVED .harmony/capabilities/_ops/policy`

## Runtime/Contract Verification

Commands:

```bash
bash .harmony/capabilities/runtime/services/_ops/scripts/validate-services.sh --profile strict
bash .harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --profile dev-fast synthesize-research
bash .harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh
bash .harmony/capabilities/_ops/tests/test-deny-by-default-runtime.sh
bash .harmony/capabilities/_ops/scripts/validate-deny-by-default.sh --profile strict
```

Result:

- `validate-services.sh --profile strict` exit code `0` (`Validation passed: 0 errors, 0 warning(s)`).
- `validate-skills.sh --profile dev-fast synthesize-research` exit code `0` (`All checks passed!`).
- `validate-ra-acp-migration.sh` exit code `0` (`RA+ACP migration regression checks passed.`).
- `test-deny-by-default-runtime.sh` exit code `0` (`Runtime deny-by-default tests complete: 44 passed, 0 failed`).
- `validate-deny-by-default.sh --profile strict` exit code `0` (strict service + skills + runtime deny-by-default suite passed, including `Runtime deny-by-default tests complete: 44 passed, 0 failed`).

## CI-Gate Verification

Updated gate surfaces:

- `/.harmony/assurance/_ops/scripts/validate-harness-structure.sh`
- `/.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh`
- `/.harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh`

Command:

```bash
bash .harmony/assurance/_ops/scripts/validate-harness-structure.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

Additional migration consistency fix included:

- `/.harmony/capabilities/runtime/services/_ops/state/provider-term-allowlist.tsv` was updated to canonical `/.harmony/capabilities/runtime/services/**` paths.
