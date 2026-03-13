---
title: Capabilities Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to capabilities runtime/governance/practices bounded surfaces.
---

# Capabilities Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-capabilities-bounded-surfaces`
- Plan: `/.octon/cognition/methodology/migrations/2026-02-20-capabilities-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "\.octon/capabilities/(commands|skills|tools|services|_ops/policy)|capabilities/(commands|skills|tools|services|_ops/policy)" AGENTS.md .octon .github --glob '!.octon/assurance/_ops/scripts/validate-harness-structure.sh' --glob '!.octon/cognition/methodology/migrations/**' --glob '!.octon/output/**' --glob '!.octon/ideation/**' --glob '!.archive/**' --glob '!.octon/runtime/_ops/state/**' --glob '!.octon/cognition/decisions/**' --glob '!.octon/cognition/context/decisions.md' --glob '!.octon/continuity/log.md' --glob '!.octon/capabilities/runtime/services/_ops/state/**'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .octon/capabilities/commands .octon/capabilities/skills .octon/capabilities/tools .octon/capabilities/services .octon/capabilities/_ops/policy; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .octon/capabilities/commands`
- `REMOVED .octon/capabilities/skills`
- `REMOVED .octon/capabilities/tools`
- `REMOVED .octon/capabilities/services`
- `REMOVED .octon/capabilities/_ops/policy`

## Runtime/Contract Verification

Commands:

```bash
bash .octon/capabilities/runtime/services/_ops/scripts/validate-services.sh --profile strict
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --profile dev-fast synthesize-research
bash .octon/capabilities/_ops/scripts/validate-ra-acp-migration.sh
bash .octon/capabilities/_ops/tests/test-deny-by-default-runtime.sh
bash .octon/capabilities/_ops/scripts/validate-deny-by-default.sh --profile strict
```

Result:

- `validate-services.sh --profile strict` exit code `0` (`Validation passed: 0 errors, 0 warning(s)`).
- `validate-skills.sh --profile dev-fast synthesize-research` exit code `0` (`All checks passed!`).
- `validate-ra-acp-migration.sh` exit code `0` (`RA+ACP migration regression checks passed.`).
- `test-deny-by-default-runtime.sh` exit code `0` (`Runtime deny-by-default tests complete: 44 passed, 0 failed`).
- `validate-deny-by-default.sh --profile strict` exit code `0` (strict service + skills + runtime deny-by-default suite passed, including `Runtime deny-by-default tests complete: 44 passed, 0 failed`).

## CI-Gate Verification

Updated gate surfaces:

- `/.octon/assurance/_ops/scripts/validate-harness-structure.sh`
- `/.octon/capabilities/_ops/scripts/validate-deny-by-default.sh`
- `/.octon/capabilities/_ops/scripts/validate-ra-acp-migration.sh`

Command:

```bash
bash .octon/assurance/_ops/scripts/validate-harness-structure.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

Additional migration consistency fix included:

- `/.octon/capabilities/runtime/services/_ops/state/provider-term-allowlist.tsv` was updated to canonical `/.octon/capabilities/runtime/services/**` paths.
