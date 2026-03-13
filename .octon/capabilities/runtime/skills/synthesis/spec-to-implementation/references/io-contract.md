---
# I/O Contract Documentation
# Authoritative sources:
# - Tool permissions: SKILL.md frontmatter `allowed-tools`
# - Parameters: .octon/capabilities/runtime/skills/registry.yml
# - Output paths: .octon/capabilities/runtime/skills/registry.yml
---

# I/O Contract Reference

Extended input/output documentation for the `spec-to-implementation` skill.

## Parameters

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `spec` | text | Yes | — | Path to spec document or inline specification text |
| `scope` | text | No | `.` | Directory to scan for existing code and contracts |
| `format` | text | No | `markdown` | Output format (`markdown` or `yaml`) |
| `change_profile` | text | No | `auto` | Governance profile (`atomic` or `transitional`) |
| `release_state` | text | No | `auto` | Semantic release state (`pre-1.0` or `stable`) |
| `transitional_exception_note` | text | Conditional | — | Required when `release_state=pre-1.0` and `change_profile=transitional`; includes `rationale`, `risks`, `owner`, `target_removal_date` |

## Output Structure

### Primary Output

Implementation plan written to:

- `.octon/output/plans/YYYY-MM-DD-implementation-plan-{{run_id}}.md`

The plan must include these top-level sections:

1. `Profile Selection Receipt`
2. `Implementation Plan`
3. `Impact Map (code, tests, docs, contracts)`
4. `Compliance Receipt`
5. `Exceptions/Escalations`

### Execution Log

Written to:

- `.octon/capabilities/runtime/skills/_ops/state/logs/spec-to-implementation/{{run_id}}.md`

### Log Index

Written to:

- `.octon/capabilities/runtime/skills/_ops/state/logs/spec-to-implementation/index.yml`

## Governance Keys

Machine-readable keys used in receipts and templates:

- `change_profile`
- `release_state`
- `transitional_exception_note`

## Dependency Permissions

- **Read**: spec and existing code/contracts
- **Glob/Grep**: locate impacted surfaces
- **Write(../../output/plans/*)**: emit plan artifact
- **Write(_ops/state/logs/*)**: emit run logs and index
