# Playbook — Native Repeatable Runbook Expansion

Playbook expands reusable runbook references into deterministic, structured
playbook execution payloads for Plan and Agent consumers.

## Responsibilities

- Validate `playbookPath` and normalize input params.
- Emit deterministic expansion steps for downstream planning.
- Operate in dry-run mode without side effects.

## Input and Output Contracts

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`
- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`

## Example

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/playbook/impl/playbook.sh
{"playbookPath":"playbooks/release.yml","params":{"version":"1.2.3"}}
JSON
```
