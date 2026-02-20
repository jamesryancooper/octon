---
title: Audit Self-Containment
description: Verify all .harmony subsystems are harness-native and self-contained with no external dependency leakage.
access: human
---

# Audit Self-Containment

## Context

Read-only audit that verifies every subsystem under `.harmony/` is harness-native (uses only harness-internal patterns, contracts, and discovery mechanisms) and self-contained (no leaking references to external packages, runtime binaries, or out-of-harness dependencies).

## Persona

Harness integrity auditor — structural analyst that enforces harness boundary isolation.

## Subsystems Under Audit

| Subsystem | Path | Expected Internals |
|---|---|---|
| Agency | `agency/` | `manifest.yml`, `_meta/architecture/`, `agents/`, `assistants/`, `teams/` |
| Capabilities | `capabilities/` | `_meta/architecture/`, `skills/`, `commands/`, `tools/`, `services/` |
| Cognition | `cognition/` | `_meta/architecture/`, `principles/`, `methodology/`, `context/`, `decisions/`, `analyses/` |
| Orchestration | `orchestration/` | `_meta/architecture/`, `workflows/`, `missions/` |
| Scaffolding | `scaffolding/` | `_meta/architecture/`, `patterns/`, `templates/`, `prompts/`, `examples/` |
| Quality | `quality/` | `_meta/architecture/`, checklists |
| Continuity | `continuity/` | `_meta/architecture/`, `log.md`, `tasks.json`, `entities.json`, `next.md` |
| Ideation | `ideation/` | `_meta/architecture/`, `scratchpad/`, `projects/` |
| Output | `output/` | Reports, drafts, artifacts |

Each subsystem MUST satisfy three properties:

1. **Structurally complete** — Has `README.md` for orientation and `_meta/architecture/` for specification
2. **Harness-native** — Uses only harness-internal discovery patterns (`manifest.yml` → `registry.yml` → concrete files), references only `.harmony/`-relative paths, follows harness conventions and the underscore-prefixed namespace convention (`_meta/`, `_ops/`, `_scaffold/`)
3. **Self-contained** — No references to external packages, no runtime binary dependencies beyond host-provided prerequisites (agent runtime, model, minimal tool adapter)

## Instructions

For each of the nine subsystems, perform these verification layers in order.

### Layer 1: Structural Completeness

1. Verify `README.md` exists and provides orientation (contents table, purpose statement)
2. Verify `architecture/` directory exists with at least a `README.md`
3. If the subsystem uses discovery (capabilities, agency, orchestration), verify `manifest.yml` exists at the subsystem or sub-domain level
4. Flag any subsystem missing required structural files

### Layer 2: Harness-Native Compliance

1. Grep all `.md` and `.yml` files within each subsystem for references to paths outside `.harmony/`:
   - Forbidden patterns: `packages/`, `apps/`, `node_modules/`, `platform/`, `src/`, `dist/`, `build/`
   - Allowed exceptions: `docs/` (human-facing docs), `.cursor/` (IDE config per conventions), external URLs
2. Verify all internal cross-references use `.harmony/`-relative paths
3. Verify discovery files (`manifest.yml`, `registry.yml`) reference only harness-internal paths
4. Check that `allowed-tools` in any `SKILL.md` reference only harness-recognized tool names
5. Flag any reference that leaks outside the harness boundary

### Layer 3: Self-Containment Audit

1. For services: verify no service references external kit implementations (per `_ops/scripts/validate-service-independence.sh` logic)
2. For skills: verify each skill's `references/`, `scripts/`, and `_ops/state/` directories resolve within `.harmony/capabilities/runtime/skills/`
3. For workflows: verify step files (`01-*.md`, `02-*.md`) reference only harness-internal paths and tools
4. Verify no subsystem requires importing or installing external dependencies to function
5. Confirm dependency boundaries: only host-provided prerequisites (agent runtime, model, `read`/`glob`/`grep`/`bash` tools) are assumed

### Layer 4: Self-Challenge

After completing Layers 1-3, challenge your own findings:

- Did I check every subsystem, or did I skip one?
- Did I conflate "references an external concept" (allowed) with "depends on an external artifact" (forbidden)?
- Are my false positives actually violations, or are they documentation-only references with no runtime coupling?

## Negative Constraints

- Do NOT modify any files — read-only audit
- Do NOT treat documentation references to external architecture as violations — only flag references that create runtime or structural dependencies
- Do NOT flag external URLs as violations
- Do NOT expand scope beyond `.harmony/`
- Do NOT conflate "mentions" with "depends on"

## Output

```markdown
# Harness Self-Containment Audit

## Coverage Proof
- Subsystems audited: [list all 9]
- Files scanned: [count]
- Layers completed: [1-4]

## Findings by Severity

### Critical (blocks harness portability)
- [subsystem]: [finding]

### Warning (potential coupling risk)
- [subsystem]: [finding]

### Info (noted but non-blocking)
- [subsystem]: [finding]

## Clean Subsystems
- [list subsystems with zero findings]

## Recommended Fix Batches
1. [batch description — grouped by type, not by subsystem]
```
