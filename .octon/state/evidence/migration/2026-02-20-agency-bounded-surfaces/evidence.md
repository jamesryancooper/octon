---
title: Agency Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to agency actors/governance/practices bounded surfaces.
---

# Agency Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-agency-bounded-surfaces`
- Plan: `/.octon/framework/cognition/methodology/migrations/2026-02-20-agency-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "agency/agents|agency/assistants|agency/teams|agency/CONSTITUTION\.md|agency/DELEGATION\.md|agency/MEMORY\.md|\.octon/framework/agency/agents|\.octon/framework/agency/assistants|\.octon/framework/agency/teams|\.octon/framework/agency/CONSTITUTION\.md|\.octon/framework/agency/DELEGATION\.md|\.octon/framework/agency/MEMORY\.md" AGENTS.md .octon .github --glob '!.octon/framework/agency/_ops/scripts/validate/validate-agency.sh' --glob '!.octon/framework/cognition/methodology/migrations/**' --glob '!.octon/generated/**' --glob '!.octon/inputs/exploratory/ideation/**' --glob '!.archive/**' --glob '!.octon/runtime/_ops/state/**' --glob '!.octon/framework/cognition/decisions/**' --glob '!.octon/framework/cognition/context/decisions.md' --glob '!.octon/state/continuity/repo/log.md'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .octon/framework/agency/agents .octon/framework/agency/assistants .octon/framework/agency/teams .octon/framework/agency/CONSTITUTION.md .octon/framework/agency/DELEGATION.md .octon/framework/agency/MEMORY.md; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .octon/framework/agency/agents`
- `REMOVED .octon/framework/agency/assistants`
- `REMOVED .octon/framework/agency/teams`
- `REMOVED .octon/framework/agency/CONSTITUTION.md`
- `REMOVED .octon/framework/agency/DELEGATION.md`
- `REMOVED .octon/framework/agency/MEMORY.md`

## Runtime/Contract Verification

Command:

```bash
bash .octon/framework/agency/_ops/scripts/validate/validate-agency.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

## CI-Gate Verification

Updated gate surfaces:

- `/.octon/framework/agency/_ops/scripts/validate/validate-agency.sh`
- `/.octon/framework/assurance/_ops/scripts/validate-harness-structure.sh`

Command:

```bash
bash .octon/framework/assurance/_ops/scripts/validate-harness-structure.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

Related remediation completed:

- `/.octon/framework/cognition/principles/_meta/` was normalized to namespaced layout (`docs/`) with index at `/.octon/framework/cognition/principles/_meta/docs/README.md`.
