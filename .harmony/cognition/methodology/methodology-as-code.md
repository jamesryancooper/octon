---
title: Methodology-as-Code
description: Policy for encoding Harmony methodology constraints into machine-readable schemas for sustainable AI agent consumption.
---

# Methodology-as-Code

Status: Active (schema v1.2.0, methodology v0.2.0)

## Overview

Harmony uses a **Methodology-as-Code** approach: methodology constraints (pillars, lifecycle stages, HITL requirements, policy rules) are encoded directly into JSON schemas and runtime validation. This enables AI agents to consume methodology as machine-readable contracts while humans read documentation.

**Guiding principle:** Schemas are the source of truth. Documentation is derived from or validated against schemas.

## Why Methodology-as-Code?

| Need | How Methodology-as-Code Addresses It |
|------|--------------------------------------|
| AI agents need machine-readable contracts | Schemas provide typed, validatable interfaces |
| Enforcement must be deterministic | Runtime validation rejects non-conforming inputs |
| Methodology evolution must be safe | Versioned schemas with deprecation windows |
| Humans and AI need different views | Schemas for machines, docs for humans |

## Core Principles

### 1. Schemas Are Authoritative

- **JSON schemas** (`packages/kits/kit-base/schema/*.json`) define the canonical structure
- **Zod schemas** (`packages/kits/kit-base/src/validation.ts`) provide runtime TypeScript validation
- **Documentation** is derived from schemas and must stay aligned
- When in conflict, schemas win

### 2. Layered Methodology Coupling

Not all methodology elements require the same coupling strength:

| Layer | Stability | Coupling | Examples |
|-------|-----------|----------|----------|
| **Structural** | Very stable | Strong | Pillars, lifecycle stages, risk levels |
| **Operational** | May evolve | Moderate | Policy rules, thresholds, ruleset versions |
| **Implementation** | Flexible | Loose | Artifact paths, service names, span names |

**Structural methodology** is defined in `methodology-core.v1.json` and rarely changes. Breaking changes require a major version bump.

**Operational methodology** (policy rules, enforcement modes) can evolve more frequently via minor version bumps.

### 3. Semantic Versioning

Both schemas and methodology follow semver:

| Version Component | When to Bump | Example |
|-------------------|--------------|---------|
| **MAJOR** | Breaking changes to structural methodology | Remove a pillar, change lifecycle stage names |
| **MINOR** | New features, additive changes | Add optional field, new policy rule |
| **PATCH** | Bug fixes, documentation | Fix typo in description, clarify constraint |

**Schema version:** `1.2.0` (current)
**Methodology version:** `0.2.0` (current)

### 4. Backward Compatibility

- **N-1 support:** Orchestrators support the current and previous minor version
- **Deprecation windows:** Fields deprecated in version N can be removed in version N+2
- **Migration notes:** Every deprecation includes migration instructions

## Version Fields

All kit metadata and run records include explicit version tracking:

```json
{
  "schemaVersion": "1.2.0",
  "methodologyVersion": "0.2.0",
  "name": "flowkit",
  "version": "0.1.0"
}
```

| Field | Purpose |
|-------|---------|
| `schemaVersion` | Kit metadata schema version this document conforms to |
| `methodologyVersion` | Harmony methodology version this kit aligns with |
| `version` | Kit's own semantic version |

## Enforcement Modes

Methodology-as-Code supports graceful transitions via enforcement modes:

| Mode | Behavior | Use Case |
|------|----------|----------|
| `block` | Fail on validation errors (default) | Production, CI |
| `warn` | Log warnings but proceed | Development, transitions |
| `off` | Skip validation entirely | Testing, emergencies |

### Setting Enforcement Mode

**Per-kit metadata:**
```json
{
  "policy": {
    "enforcement": "block"
  }
}
```

**Runtime override:**
```typescript
validateWithEnforcement(schema, data, {
  enforcementMode: "warn"
});
```

**Environment variable:**
```bash
HARMONY_ENFORCEMENT_MODE=warn
```

### Transition Procedure

When evolving methodology:

1. **Week 1-2:** Deploy with `enforcement: "warn"` — log violations, don't block
2. **Week 3+:** Switch to `enforcement: "block"` — strict enforcement
3. Update documentation and notify consumers

## Deprecation Policy

### Declaring Deprecations

Add deprecations to kit metadata:

```json
{
  "compatibility": {
    "deprecations": [
      {
        "field": "legacy.oldField",
        "since": "1.1.0",
        "removeAt": "2.0.0",
        "migrationNote": "Use newField instead"
      }
    ]
  }
}
```

### Deprecation Timeline

| Event | Version | Description |
|-------|---------|-------------|
| Deprecation announced | N | Field marked deprecated with `since` |
| Warning period | N to N+1 | Validation warns on deprecated field usage |
| Removal | N+2 | Field removed from schema |

### Example Timeline

1. **v1.1.0:** Deprecate `policy.rules` in favor of `policy.rulesetRef`
2. **v1.2.0:** Warn on `policy.rules` usage, recommend migration
3. **v2.0.0:** Remove `policy.rules` from schema

## Compatibility Matrix

### Schema Compatibility

| Kit Schema Version | Supported Orchestrator Versions |
|-------------------|--------------------------------|
| 1.2.0 | 1.1.0, 1.2.0 |
| 1.1.0 | 1.0.0, 1.1.0, 1.2.0 |
| 1.0.0 | 1.0.0, 1.1.0 |

### Methodology Compatibility

| Methodology Version | Kit Schema Versions |
|--------------------|---------------------|
| 0.2.0 | 1.1.0+, 1.2.0 |
| 0.1.0 | 1.0.0, 1.1.0 |

## Breaking Change Procedure

For breaking changes (MAJOR version bump):

1. **Announce:** Document the breaking change and rationale
2. **Deprecate:** Mark affected fields as deprecated with migration notes
3. **Warn period:** At least one minor version with `enforcement: "warn"`
4. **Remove:** Implement breaking change in new major version
5. **Migrate:** Provide migration script or detailed instructions

### Example: Adding Required Field

**Wrong:** Add required field immediately (breaks existing kits)

**Right:**
1. v1.1.0: Add optional field with default
2. v1.2.0: Deprecate absence of field, warn if missing
3. v2.0.0: Make field required

## CI Validation

The `validate-methodology-alignment.ts` script enforces methodology compliance in CI:

```bash
pnpm --filter @harmony/kit-base validate:methodology
```

### Checks Performed

1. **Schema validation:** All kit metadata validates against current schema
2. **Version consistency:** All kits use compatible schema/methodology versions
3. **Deprecation warnings:** Flag usage of deprecated fields
4. **Structural compliance:** Pillars and lifecycle stages match methodology-core

### CI Integration

```yaml
# .github/workflows/ci.yml
- name: Validate methodology alignment
  run: pnpm --filter @harmony/kit-base validate:methodology
```

## Schema Files

| File | Purpose |
|------|---------|
| `kit-metadata.v1.json` | Kit metadata schema (v1.2) |
| `run-record.v1.json` | Run record schema (v1.1) |
| `methodology-core.v1.json` | Structural methodology definitions |
| `methodology-core.data.json` | Methodology data instance |

## Runtime Validation

Kits use Zod schemas for runtime validation:

```typescript
import {
  validateWithEnforcement,
  KitMetadataSchema,
  CURRENT_SCHEMA_VERSION,
  CURRENT_METHODOLOGY_VERSION,
} from "@harmony/kit-base";

// Validate kit metadata
const result = validateWithEnforcement(KitMetadataSchema, metadata, {
  enforcementMode: "block",
  checkDeprecations: true,
  schemaName: "KitMetadata",
});

if (!result.success) {
  console.error("Validation errors:", result.errors);
}

if (result.warnings?.length) {
  console.warn("Deprecation warnings:", result.warnings);
}
```

## Source of Truth Hierarchy

1. **JSON Schemas** (`packages/kits/kit-base/schema/`)
   - Canonical definitions
   - Used by external tools and AI agents

2. **Zod Schemas** (`packages/kits/kit-base/src/validation.ts`)
   - Runtime TypeScript validation
   - Derived from JSON schemas

3. **Methodology Documentation** (`.harmony/cognition/methodology/`)
   - Human-readable explanations
   - Must align with schemas

4. **Kit Metadata** (`packages/kits/*/metadata/kit.metadata.json`)
   - Per-kit configuration
   - Validated against schemas

## Migration Guide

### Updating from Schema v1.1 to v1.2

1. Add version fields to kit metadata:
   ```json
   {
     "schemaVersion": "1.2.0",
     "methodologyVersion": "0.2.0"
   }
   ```

2. Add enforcement mode to policy (if using policy):
   ```json
   {
     "policy": {
       "enforcement": "block"
     }
   }
   ```

3. Review deprecation warnings and migrate if needed

### Updating from Methodology v0.1 to v0.2

1. Ensure all five pillars are recognized
2. Add `evolvable_modularity` to pillar lists where applicable
3. Update lifecycle stage references if any custom stages were used

## Related Documents

- [Harmony Principles](../principles/principles.md) — The five pillars
- [Methodology Overview](./README.md) — Full methodology description
- [Kit Base README](../../../packages/kits/kit-base/README.md) — Validation utilities
- [Kits README](../../../packages/kits/README.md) — Kit architecture overview

## Changelog

### Schema v1.2.0 (Current)
- Added `schemaVersion` and `methodologyVersion` fields
- Added enforcement modes to policy configuration
- Added deprecation tracking to compatibility section
- Created methodology-core.v1.json for structural methodology

### Schema v1.1.0
- Made `determinism`, `safety`, and `idempotency` required
- Added `evolvable_modularity` to pillars enum

### Schema v1.0.0
- Initial schema release

