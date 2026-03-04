---
title: Agency Bounded Surfaces Migration Evidence
description: Verification evidence for the clean-break migration to agency actors/governance/practices bounded surfaces.
---

# Agency Bounded Surfaces Migration Evidence

## Migration

- ID: `2026-02-20-agency-bounded-surfaces`
- Plan: `/.harmony/cognition/methodology/migrations/2026-02-20-agency-bounded-surfaces/plan.md`

## Static Verification

Command:

```bash
rg -n "agency/agents|agency/assistants|agency/teams|agency/CONSTITUTION\.md|agency/DELEGATION\.md|agency/MEMORY\.md|\.harmony/agency/agents|\.harmony/agency/assistants|\.harmony/agency/teams|\.harmony/agency/CONSTITUTION\.md|\.harmony/agency/DELEGATION\.md|\.harmony/agency/MEMORY\.md" AGENTS.md .harmony .github --glob '!.harmony/agency/_ops/scripts/validate/validate-agency.sh' --glob '!.harmony/cognition/methodology/migrations/**' --glob '!.harmony/output/**' --glob '!.harmony/ideation/**' --glob '!.archive/**' --glob '!.harmony/runtime/_ops/state/**' --glob '!.harmony/cognition/decisions/**' --glob '!.harmony/cognition/context/decisions.md' --glob '!.harmony/continuity/log.md'
```

Result:

- Exit code `1` (no matches), which is expected for this sweep.

Legacy path presence check:

```bash
for p in .harmony/agency/agents .harmony/agency/assistants .harmony/agency/teams .harmony/agency/CONSTITUTION.md .harmony/agency/DELEGATION.md .harmony/agency/MEMORY.md; do if [ -e "$p" ]; then echo "EXISTS $p"; else echo "REMOVED $p"; fi; done
```

Result:

- `REMOVED .harmony/agency/agents`
- `REMOVED .harmony/agency/assistants`
- `REMOVED .harmony/agency/teams`
- `REMOVED .harmony/agency/CONSTITUTION.md`
- `REMOVED .harmony/agency/DELEGATION.md`
- `REMOVED .harmony/agency/MEMORY.md`

## Runtime/Contract Verification

Command:

```bash
bash .harmony/agency/_ops/scripts/validate/validate-agency.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

## CI-Gate Verification

Updated gate surfaces:

- `/.harmony/agency/_ops/scripts/validate/validate-agency.sh`
- `/.harmony/assurance/_ops/scripts/validate-harness-structure.sh`

Command:

```bash
bash .harmony/assurance/_ops/scripts/validate-harness-structure.sh
```

Result:

- Exit code `0`
- Summary: `Validation summary: errors=0 warnings=0`

Related remediation completed:

- `/.harmony/cognition/principles/_meta/` was normalized to namespaced layout (`docs/`) with index at `/.harmony/cognition/principles/_meta/docs/README.md`.
