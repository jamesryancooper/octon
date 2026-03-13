# Plan: `tools/` and `services/` Subsystems for `.octon/capabilities/`

## Context

The `.octon/` harness is tech-stack-agnostic (markdown + YAML), but the current
`packages/kits/` implementation ties domain capabilities to TypeScript. This plan
introduces two new subsystems under `.octon/capabilities/` to make these
capabilities portable:

- **tools/** — Tool packs (named permission bundles) and custom tool definitions
  (atomic operations extending the agent's built-in set)
- **services/** — Domain capabilities with typed contracts (portable replacements
  for kits)

Together with the existing `skills/` and `commands/`, this creates a clean 2x2
taxonomy under `capabilities/`:

```
                Atomic                    Composite
           ┌───────────────────┬────────────────────────┐
Instruction│   Commands        │   Skills               │
-driven    │   (agent follows  │   (agent follows       │
           │    single .md)    │    SKILL.md workflow)   │
           ├───────────────────┼────────────────────────┤
Invocation │   Tools           │   Services             │
-driven    │   (agent calls,   │   (agent invokes       │
           │    gets result)   │    domain capability)   │
           └───────────────────┴────────────────────────┘
```

---

## Phase 1: Service Conventions (kit-base dissolution)

Dissolve kit-base cross-cutting concerns into harness-level convention docs.
These must exist before any service is defined, since all services reference them.

### Create `services/conventions/`

| File | Source | Content |
|------|--------|---------|
| `error-codes.md` | `kit-base/src/errors.ts` | Exit codes 0-8 with semantic meaning, HTTP status mapping |
| `run-records.md` | `kit-base/src/run-record.ts` | Run record JSON format, field spec, lifecycle |
| `observability.md` | `kit-base/src/observability.ts` | OTel span naming (`service.{id}.{action}`), attributes |
| `idempotency.md` | `kit-base/src/idempotency-*.ts` | Key derivation, replay semantics, conflict handling |

Each convention doc follows:
```yaml
---
title: {{Convention Name}}
scope: harness
applies_to: services
migrated_from: packages/kits/kit-base/src/{{source}}
---
```

**Files to create:**
- `.octon/capabilities/services/conventions/error-codes.md`
- `.octon/capabilities/services/conventions/run-records.md`
- `.octon/capabilities/services/conventions/observability.md`
- `.octon/capabilities/services/conventions/idempotency.md`

**Source files to read:**
- `packages/kits/kit-base/src/errors.ts`
- `packages/kits/kit-base/src/run-record.ts`
- `packages/kits/kit-base/src/observability.ts`
- `packages/kits/kit-base/src/idempotency-store.ts`
- `packages/kits/kit-base/schema/run-record.v1.json`

---

## Phase 2: Tools Subsystem

### Directory structure

```
.octon/capabilities/tools/
├── README.md
├── manifest.yml            # Packs + custom tools discovery
├── registry.yml            # Extended metadata for custom tools
├── capabilities.yml        # Built-in tools list, valid interface types, pack rules
├── _scaffold/template/
│   └── TOOL.md
├── _ops/scripts/
│   └── validate-tools.sh
└── _ops/state/
    └── logs/
```

### manifest.yml schema

Two sections: `packs` and `tools`.

**Packs** — named bundles of agent-level tool permissions:
```yaml
packs:
  - id: read-only
    display_name: Read Only
    summary: "Read-only file access tools."
    tools: [Read, Glob, Grep]

  - id: file-ops
    display_name: File Operations
    summary: "Full file read/write access tools."
    tools: [Read, Write, Glob, Grep]

  - id: full-edit
    display_name: Full Edit
    summary: "Complete file editing toolkit."
    tools: [Read, Write, Edit, Glob, Grep]

  - id: web-access
    display_name: Web Access
    summary: "Web fetching and search tools."
    tools: [WebFetch, WebSearch]

  - id: shell-safe
    display_name: Shell Safe
    summary: "Limited shell access for safe operations."
    tools: ["Bash(mkdir)", "Bash(cp)", "Bash(mv)", "Bash(ln)"]

  - id: ci-integration
    display_name: CI Integration
    summary: "GitHub and CI/CD integration tools."
    tools: ["Bash(gh)", "Bash(npm)", "Bash(npx)"]
```

**Custom tools** (empty initially):
```yaml
tools: []
  # Future example:
  # - id: regex-check
  #   display_name: Regex Check
  #   path: custom/regex-check/
  #   summary: "Run regex patterns against content."
  #   status: active
  #   interface_type: shell
  #   tags: [safety, regex]
```

### Pack reference syntax in SKILL.md `allowed-tools`

```yaml
# New pack reference (additive — existing format still works):
allowed-tools: pack:read-only Write(../../output/reports/*) Write(_ops/state/logs/*)

# Multiple packs + inline tools:
allowed-tools: pack:file-ops pack:ci-integration WebFetch Write(_ops/state/logs/*)
```

Resolution: `pack:X` expands to the tools listed in the pack definition, unioned
with any inline tools. Backward-compatible — no existing SKILL.md breaks.

### TOOL.md template frontmatter

```yaml
---
name: {{tool-id}}
description: >
  What this tool does, when to use it, what it returns.
interface_type: shell  # shell | mcp
version: "1.0.0"
metadata:
  author: "{{author}}"
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
requires:
  runtime: [bash]
  commands: []        # External commands needed (e.g., jq, curl)
timeout_ms: 30000
sandbox: process      # none | process
---
```

### capabilities.yml

Defines built-in tools reference, valid interface types, pack composition rules.

### Files to create
- `.octon/capabilities/tools/README.md`
- `.octon/capabilities/tools/manifest.yml`
- `.octon/capabilities/tools/registry.yml`
- `.octon/capabilities/tools/capabilities.yml`
- `.octon/capabilities/tools/_scaffold/template/TOOL.md`
- `.octon/capabilities/tools/_ops/scripts/validate-tools.sh`

---

## Phase 3: Services Subsystem Scaffold

### Directory structure

```
.octon/capabilities/services/
├── README.md
├── manifest.yml
├── registry.yml
├── capabilities.yml
├── conventions/              # From Phase 1
│   ├── error-codes.md
│   ├── run-records.md
│   ├── observability.md
│   └── idempotency.md
├── _scaffold/template/
│   ├── SERVICE.md
│   ├── impl/
│   │   └── .gitkeep
│   ├── schema/
│   │   ├── input.schema.json
│   │   └── output.schema.json
│   └── references/
│       ├── examples.md
│       └── errors.md
├── _ops/scripts/
│   └── validate-services.sh
└── _ops/state/
    ├── logs/
    └── runs/
```

### manifest.yml schema

```yaml
schema_version: "1.0"

services:
  - id: guard
    display_name: Guard
    path: guard/
    summary: "Content protection: injection, hallucination, secrets/PII detection."
    status: active
    interface_type: shell
    tags: [safety, regex, detection]
    category: guard
    stateful: false

  - id: prompt
    display_name: Prompt
    path: prompt/
    summary: "Template rendering, token counting, variant selection."
    status: active
    interface_type: library
    tags: [prompt, template, tokens]
    category: prompt
    stateful: false

  - id: cost
    display_name: Cost
    path: cost/
    summary: "Budget tracking, cost estimation, usage monitoring."
    status: active
    interface_type: shell
    tags: [budget, cost, tracking]
    category: cost
    stateful: true

  - id: flow
    display_name: Flow
    path: flow/
    summary: "HTTP client to LangGraph server for workflow orchestration."
    status: active
    interface_type: mcp
    tags: [workflow, orchestration, langgraph]
    category: flow
    stateful: false
```

### SERVICE.md template frontmatter

```yaml
---
name: {{service-id}}
description: >
  Domain capability with typed I/O contract.
interface_type: shell  # shell | mcp | library
version: "0.1.0"
metadata:
  author: "{{author}}"
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
stateful: false
deterministic: true
dependencies:
  requires: []
  orchestrates: []
  integratesWith: []
observability:
  service_name: "octon.service.{{service-id}}"
  required_spans: ["service.{{service-id}}.{{action}}"]
policy:
  rules: []
  enforcement: block   # block | warn | off
  fail_closed: true
idempotency:
  required: false
  key_from: []
impl:
  entrypoint: "impl/{{service-id}}.sh"
  timeout_ms: 30000
  health_check: null
dry_run: true
allowed-tools: Read Glob Grep
---
```

### registry.yml schema

Per-service extended metadata following the skills pattern: version, commands,
parameters, dependencies, I/O contract paths, observability, policy, idempotency,
implementation pointer. (Full schema documented in Phase 3 deliverables.)

### capabilities.yml

Defines: service category definitions, valid interface types, interface type
requirements, valid dependency types, base conventions references, valid
enforcement modes.

### `allowed-services` field in SKILL.md

New field parallel to `allowed-tools`:

```yaml
# In SKILL.md frontmatter:
allowed-tools: pack:read-only Write(_ops/state/logs/*)
allowed-services: guard cost
```

Space-delimited list of service IDs. No path scoping (services govern their own
I/O via contracts). Validated against `services/manifest.yml`.

### Files to create
- `.octon/capabilities/services/README.md`
- `.octon/capabilities/services/manifest.yml`
- `.octon/capabilities/services/registry.yml`
- `.octon/capabilities/services/capabilities.yml`
- `.octon/capabilities/services/_scaffold/template/SERVICE.md`
- `.octon/capabilities/services/_scaffold/template/impl/.gitkeep`
- `.octon/capabilities/services/_scaffold/template/schema/input.schema.json`
- `.octon/capabilities/services/_scaffold/template/schema/output.schema.json`
- `.octon/capabilities/services/_scaffold/template/references/examples.md`
- `.octon/capabilities/services/_scaffold/template/references/errors.md`
- `.octon/capabilities/services/_ops/scripts/validate-services.sh`

---

## Phase 4: Kit Migration

### Per-kit mapping

| Kit | Service ID | interface_type | Rationale |
|-----|-----------|----------------|-----------|
| GuardKit | `guard` | `shell` | Pure regex. POSIX script wrapping pattern matching. Fully portable. |
| PromptKit | `prompt` | `library` | Needs template engine + tiktoken. Points to `packages/kits/promptkit`. Not portable yet. |
| CostKit | `cost` | `shell` | JSON/YAML file ops. POSIX script with `jq`. Fully portable. |
| FlowKit | `flow` | `mcp` | HTTP client to LangGraph. MCP server wrapping the HTTP calls. |
| kit-base | N/A | dissolved | Cross-cutting concerns → `services/conventions/` (Phase 1). TS runtime stays in `packages/kits/kit-base/`. |

### Per-service migration steps

**guard/ (shell)**
1. Extract regex patterns from `packages/kits/guardkit/src/patterns.ts`
   → `guard/references/patterns.md`
2. Write `guard/impl/guard.sh` (stdin JSON → regex checks → stdout JSON)
3. Copy `guardkit.inputs.v1.json` → `guard/schema/input.schema.json`
4. Copy `guardkit.outputs.v1.json` → `guard/schema/output.schema.json`
5. Map `kit.metadata.json` → SERVICE.md frontmatter

**prompt/ (library)**
1. Create SERVICE.md with `interface_type: library`
2. Copy schemas to `prompt/schema/`
3. Create `impl/LIBRARY.md` documenting `packages/kits/promptkit` as implementation
4. Future: wrap as MCP server for portability

**cost/ (shell)**
1. Write `cost/impl/cost.sh` wrapping JSON file read/write with `jq`
2. Copy schemas to `cost/schema/`
3. Extract pricing tables → `cost/references/pricing.md`

**flow/ (mcp)**
1. Write `flow/impl/flow-client.sh` wrapping `curl` calls to LangGraph
2. Copy schemas to `flow/schema/`
3. Document LangGraph dependency → `flow/references/dependencies.md`

### Source files to read
- `packages/kits/guardkit/src/patterns.ts`
- `packages/kits/guardkit/schema/guardkit.inputs.v1.json`
- `packages/kits/guardkit/schema/guardkit.outputs.v1.json`
- `packages/kits/guardkit/kit.metadata.json`
- `packages/kits/promptkit/schema/promptkit.inputs.v1.json`
- `packages/kits/promptkit/schema/promptkit.outputs.v1.json`
- `packages/kits/promptkit/kit.metadata.json`
- `packages/kits/costkit/schema/costkit.inputs.v1.json`
- `packages/kits/costkit/schema/costkit.outputs.v1.json`
- `packages/kits/costkit/kit.metadata.json`
- `packages/kits/flowkit/schema/flowkit.inputs.v1.json`
- `packages/kits/flowkit/schema/flowkit.outputs.v1.json`
- `packages/kits/flowkit/kit.metadata.json`

### Files to create per service
Each service directory gets: `SERVICE.md`, `impl/`, `schema/input.schema.json`,
`schema/output.schema.json`, `references/examples.md`, `references/errors.md`.

---

## Phase 5: Documentation and Integration

### Update existing files

**`.octon/capabilities/README.md`** — Expand from 3-subsystem to 4-subsystem
table. Add the 2x2 classification diagram. Update interaction model descriptions.

**`.octon/catalog.md`** — Add `## Tools` section (pack table, usage example)
and `## Services` section (service table, usage example). Update the Artifact Type
Decision flowchart to include tools and services paths.

**`.octon/capabilities/skills/_scaffold/template/SKILL.md`** — Add `allowed-services`
field to frontmatter template.

**`.octon/capabilities/skills/_ops/scripts/validate-skills.sh`** — Add validation
for `pack:` prefix resolution in `allowed-tools` and `allowed-services` values
against `services/manifest.yml`.

**`.octon/START.md`** — Update the structure tree to show `tools/` and
`services/` under `capabilities/`.

### New decision flowcharts (in catalog.md)

**"Which subsystem?"**
```
Is this instruction-driven (agent reads and follows)?
├── YES → Atomic? → Command | Composite? → Skill
└── NO (invocation-driven, agent calls it)
    └── Atomic? → Tool | Composite with typed contract? → Service
```

**"What interface_type for a service?"**
```
Can logic run as POSIX shell?
├── YES, pure computation → shell
├── NO, needs runtime library → library (project-specific pointer)
└── NO, communicates over network → mcp
```

### Files to modify
- `.octon/capabilities/README.md`
- `.octon/catalog.md`
- `.octon/capabilities/skills/_scaffold/template/SKILL.md`
- `.octon/capabilities/skills/_ops/scripts/validate-skills.sh`
- `.octon/START.md`

---

## Verification

1. **Structural:** Run `validate-tools.sh` and `validate-services.sh` — zero findings
2. **Consistency:** Run `audit-subsystem-health` against both new subsystems —
   config consistency, schema conformance, semantic quality all pass
3. **Backward compat:** Existing SKILL.md files with inline `allowed-tools` still
   validate without `pack:` prefix
4. **Shell services:** `echo '{"content":"test"}' | guard/impl/guard.sh` returns
   valid JSON matching `output.schema.json`
5. **Cross-reference:** All `allowed-services` values in skills resolve to entries
   in `services/manifest.yml`
6. **Documentation:** capabilities/README.md 2x2 diagram renders correctly;
   catalog.md flowcharts are complete and consistent
