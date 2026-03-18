---
title: Capabilities Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to capabilities runtime/governance/practices bounded surfaces.
---

# Capabilities Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-capabilities-bounded-surfaces`
- Plan: `/.octon/framework/cognition/methodology/migrations/2026-02-20-capabilities-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "\.octon/framework/capabilities/(commands|skills|tools|services|_ops/policy)|capabilities/(commands|skills|tools|services|_ops/policy)" AGENTS.md .octon .github --glob '!.octon/framework/assurance/_ops/scripts/validate-harness-structure.sh' --glob '!.octon/framework/cognition/methodology/migrations/**' --glob '!.octon/generated/**' --glob '!.octon/inputs/exploratory/ideation/**' --glob '!.archive/**' --glob '!.octon/runtime/_ops/state/**' --glob '!.octon/framework/cognition/decisions/**' --glob '!.octon/framework/cognition/context/decisions.md' --glob '!.octon/state/continuity/repo/log.md' --glob '!.octon/framework/capabilities/runtime/services/_ops/state/**'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .octon/framework/capabilities/commands .octon/framework/capabilities/skills .octon/framework/capabilities/tools .octon/framework/capabilities/services .octon/framework/capabilities/_ops/policy; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .octon/framework/capabilities/commands`
- `REMOVED .octon/framework/capabilities/skills`
- `REMOVED .octon/framework/capabilities/tools`
- `REMOVED .octon/framework/capabilities/services`
- `REMOVED .octon/framework/capabilities/_ops/policy`

## Runtime/Contract Verification

Commands:

```bash
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-services.sh --profile strict
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --profile dev-fast synthesize-research
bash .octon/framework/capabilities/_ops/scripts/validate-ra-acp-migration.sh
bash .octon/framework/capabilities/_ops/tests/test-deny-by-default-runtime.sh
bash .octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh --profile strict
```

Result:

- `validate-services.sh --profile strict` exit code `0` (`Validation passed: 0 errors, 0 warning(s)`).
- `validate-skills.sh --profile dev-fast synthesize-research` exit code `0` (`All checks passed!`).
- `validate-ra-acp-migration.sh` exit code `0` (`RA+ACP migration regression checks passed.`).
- `test-deny-by-default-runtime.sh` exit code `0` (`Runtime deny-by-default tests complete: 44 passed, 0 failed`).
- `validate-deny-by-default.sh --profile strict` exit code `0` (strict service + skills + runtime deny-by-default suite passed, including `Runtime deny-by-default tests complete: 44 passed, 0 failed`).

## CI-Gate Verification

Updated gate surfaces:

- `/.octon/framework/assurance/_ops/scripts/validate-harness-structure.sh`
- `/.octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh`
- `/.octon/framework/capabilities/_ops/scripts/validate-ra-acp-migration.sh`

Command:

```bash
bash .octon/framework/assurance/_ops/scripts/validate-harness-structure.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

Additional migration consistency fix included:

- `/.octon/framework/capabilities/runtime/services/_ops/state/provider-term-allowlist.tsv` was updated to canonical `/.octon/framework/capabilities/runtime/services/**` paths.
