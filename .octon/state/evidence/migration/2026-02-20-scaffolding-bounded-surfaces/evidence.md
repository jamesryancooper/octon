---
title: Scaffolding Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to scaffolding runtime/governance/practices bounded surfaces.
---

# Scaffolding Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-scaffolding-bounded-surfaces`
- Plan: `/.octon/framework/cognition/methodology/migrations/2026-02-20-scaffolding-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "\.octon/framework/scaffolding/(templates/|prompts/|examples/|patterns/|_ops/scripts/)|scaffolding/(templates/|prompts/|examples/|patterns/|_ops/scripts/)" AGENTS.md .octon .github --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh' --glob '!.octon/framework/cognition/methodology/migrations/**' --glob '!.octon/generated/**' --glob '!.octon/inputs/exploratory/ideation/**' --glob '!.octon/runtime/_ops/state/**' --glob '!.octon/framework/cognition/decisions/**' --glob '!.octon/framework/cognition/context/decisions.md' --glob '!.octon/state/continuity/repo/log.md'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .octon/framework/scaffolding/templates .octon/framework/scaffolding/prompts .octon/framework/scaffolding/examples .octon/framework/scaffolding/patterns .octon/framework/scaffolding/_ops/scripts; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .octon/framework/scaffolding/templates`
- `REMOVED .octon/framework/scaffolding/prompts`
- `REMOVED .octon/framework/scaffolding/examples`
- `REMOVED .octon/framework/scaffolding/patterns`
- `REMOVED .octon/framework/scaffolding/_ops/scripts`

## Runtime/Contract Verification

Commands:

```bash
bash .octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh --dry-run
cd .octon && bash init.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

Result:

- `init-project.sh --dry-run` exit code `0` (bootstrap templates resolved from `scaffolding/runtime/templates/`).
- `init.sh` (run from `.octon/`) exit code `0` and includes new scaffolding surfaces in key-subdirectory checks.
- `validate-harness-structure.sh` exit code `0` (`Validation summary: errors=0 warnings=0`) including deprecated scaffolding path removal checks.
- `alignment-check.sh --profile harness` exit code `0` (`Alignment check summary: errors=0`).

## CI-Gate Verification

Updated gate surfaces:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `/.octon/instance/bootstrap/init.sh`
- `/.github/workflows/agency-validate.yml`
- `/.github/workflows/flags-stale-report.yml`

These updates enforce canonical scaffolding runtime/governance/practices surfaces and remove legacy path assumptions from trigger and drift checks.
