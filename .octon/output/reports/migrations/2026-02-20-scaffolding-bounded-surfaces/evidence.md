---
title: Scaffolding Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to scaffolding runtime/governance/practices bounded surfaces.
---

# Scaffolding Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-scaffolding-bounded-surfaces`
- Plan: `/.octon/cognition/methodology/migrations/2026-02-20-scaffolding-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "\.octon/scaffolding/(templates/|prompts/|examples/|patterns/|_ops/scripts/)|scaffolding/(templates/|prompts/|examples/|patterns/|_ops/scripts/)" AGENTS.md .octon .github --glob '!.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh' --glob '!.octon/cognition/methodology/migrations/**' --glob '!.octon/output/**' --glob '!.octon/ideation/**' --glob '!.octon/runtime/_ops/state/**' --glob '!.octon/cognition/decisions/**' --glob '!.octon/cognition/context/decisions.md' --glob '!.octon/continuity/log.md'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .octon/scaffolding/templates .octon/scaffolding/prompts .octon/scaffolding/examples .octon/scaffolding/patterns .octon/scaffolding/_ops/scripts; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .octon/scaffolding/templates`
- `REMOVED .octon/scaffolding/prompts`
- `REMOVED .octon/scaffolding/examples`
- `REMOVED .octon/scaffolding/patterns`
- `REMOVED .octon/scaffolding/_ops/scripts`

## Runtime/Contract Verification

Commands:

```bash
bash .octon/scaffolding/runtime/_ops/scripts/init-project.sh --dry-run
cd .octon && bash init.sh
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

Result:

- `init-project.sh --dry-run` exit code `0` (bootstrap templates resolved from `scaffolding/runtime/templates/`).
- `init.sh` (run from `.octon/`) exit code `0` and includes new scaffolding surfaces in key-subdirectory checks.
- `validate-harness-structure.sh` exit code `0` (`Validation summary: errors=0 warnings=0`) including deprecated scaffolding path removal checks.
- `alignment-check.sh --profile harness` exit code `0` (`Alignment check summary: errors=0`).

## CI-Gate Verification

Updated gate surfaces:

- `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `/.octon/init.sh`
- `/.github/workflows/agency-validate.yml`
- `/.github/workflows/flags-stale-report.yml`

These updates enforce canonical scaffolding runtime/governance/practices surfaces and remove legacy path assumptions from trigger and drift checks.
