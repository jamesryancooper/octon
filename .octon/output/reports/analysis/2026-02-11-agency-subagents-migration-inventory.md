# Agency Subagents Migration Inventory

Date: 2026-02-11

## Scope

Legacy path audited: `.octon/agency/subagents/`

## Artifact Classification

| Legacy Artifact | Classification | Action |
|---|---|---|
| `subagents/README.md` | Obsolete duplicate of agent semantics | Removed from active topology; replaced by `agents/README.md` and `agency/README.md` |
| `subagents/_template/agent.md` | Agent-equivalent template | Migrated to `agents/_template/agent.md` |
| `subagents/registry.yml` | Obsolete synthetic agent registry not backed by concrete definitions | Removed; canonical source is `agents/registry.yml` |

## Migration Decisions

- Keep runtime term "subagent" only as assistant invocation context.
- Consolidate actor artifacts into `agents/`, `assistants/`, `teams/`.
- Enforce deprecation via agency validation script and CI.

## Outcome

`subagents/` has no remaining role in active agency routing or configuration.
