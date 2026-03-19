---
title: Audit Self-Containment
description: Verify all .octon subsystems are harness-native and self-contained with no external dependency leakage.
access: human
---

# Audit Self-Containment

## Context

Read-only audit that verifies every subsystem under `.octon/` is harness-native (uses only harness-internal patterns, contracts, and discovery mechanisms) and self-contained (no leaking references to external packages, runtime binaries, or out-of-harness dependencies).

## Persona

Harness integrity auditor — structural analyst that enforces harness boundary isolation.

## Class Roots Under Audit

| Class Root | Path | Expected Internals |
|---|---|---|
| Framework | `framework/` | `manifest.yml`, `overlay-points/`, portable authored domains, portable `_ops/` helpers only |
| Instance | `instance/` | `manifest.yml`, `ingress/`, `bootstrap/`, `locality/`, `cognition/`, `orchestration/`, `extensions.yml` |
| Inputs | `inputs/` | `additive/extensions/`, `exploratory/proposals/`, `exploratory/plans/`, `exploratory/drafts/`, `exploratory/ideation/` |
| State | `state/` | `continuity/`, `evidence/`, `control/` |
| Generated | `generated/` | `effective/`, `cognition/`, `proposals/` |

Each subsystem MUST satisfy three properties:

1. **Structurally complete** — Has `README.md` for orientation and `_meta/architecture/` for specification
2. **Harness-native** — Uses only harness-internal discovery patterns (`manifest.yml` → `registry.yml` → concrete files), references only `.octon/`-relative paths, follows harness conventions and the underscore-prefixed namespace convention (`_meta/`, `_ops/`, `_scaffold/`)
3. **Self-contained** — No references to external packages, no runtime binary dependencies beyond host-provided prerequisites (agent runtime, model, minimal tool adapter)

## Instructions

For each of the five class roots, perform these verification layers in order.

### Layer 1: Structural Completeness

1. Verify `README.md` exists and provides orientation (contents table, purpose statement)
2. Verify `architecture/` directory exists with at least a `README.md`
3. If the class root uses discovery or companion control metadata, verify required manifests/registries exist at the canonical paths
4. Flag any class root missing required structural files

### Layer 2: Harness-Native Compliance

1. Grep all `.md` and `.yml` files within each subsystem for references to paths outside `.octon/`:
   - Forbidden patterns: `packages/`, `apps/`, `node_modules/`, `platform/`, `src/`, `dist/`, `build/`
   - Allowed exceptions: `docs/` (human-facing docs), `.cursor/` (IDE config per conventions), external URLs
2. Verify all internal cross-references use `.octon/`-relative paths
3. Verify discovery files (`manifest.yml`, `registry.yml`) reference only harness-internal paths
4. Check that `allowed-tools` in any `SKILL.md` reference only harness-recognized tool names
5. Flag any reference that leaks outside the harness boundary

### Layer 3: Self-Containment Audit

1. For framework services: verify no service references external kit implementations (per `_ops/scripts/validate-service-independence.sh` logic)
2. For framework skills: verify each skill's `references/` and `scripts/` resolve within `.octon/framework/capabilities/runtime/skills/`, and verify any config/resource/checkpoint/log paths resolve only to the canonical `instance/**`, `state/**`, or `generated/**` Packet 3 homes
3. For workflows and bootstrap materials: verify step files (`01-*.md`, `02-*.md`) reference only harness-internal paths and tools
4. Verify no class root requires importing or installing external dependencies to function
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
- Do NOT expand scope beyond `.octon/`
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
