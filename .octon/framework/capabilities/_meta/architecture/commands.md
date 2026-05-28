---
title: Harness Commands
description: Harness-scoped atomic operations defined in .octon/framework/capabilities/runtime/commands/.
---

# Harness Commands

Harness commands are **harness-scoped atomic operations** defined in `.octon/framework/capabilities/runtime/commands/`. They are deterministic, self-contained procedures that operate on artifacts in the harness's parent directory.

## Commands vs Prompts

See `.octon/instance/bootstrap/catalog.md#command-vs-prompt-decision` for the decision logic.

---

## Invocation

Harness commands can be invoked in multiple ways:

| Method | Trigger | Example |
|--------|---------|---------|
| **Direct** | Agent references the command file | Agent reads `.octon/framework/capabilities/runtime/commands/validate-frontmatter.md` |
| **Wrapped (Cursor)** | User types `/command` in Cursor | Via `.cursor/commands/` wrapper |
| **Wrapped (Claude Code)** | User types `/command` in Claude Code | Via `.claude/commands/` wrapper |
| **Wrapped (Any Harness)** | Harness-specific entry point | Via `.<harness>/commands/` wrapper |

When wrapped by a harness entry point, the command gains that harness's integration features.

> **Universal Harness-Agnostic Pattern:** Harness commands are the source of truth. Harness entry points (`.cursor/commands/`, `.claude/commands/`, etc.) are thin wrappers. See [workflows.md](../../../orchestration/_meta/architecture/workflows.md) for the full pattern.

---

## Host Display Labels

Command IDs and filenames stay namespaced for deterministic routing, but host
dropdown labels should be concise and scannable. Do not repeat the full product
or extension namespace in every leaf command title. Put ownership and routing
context in the command ID, summary, manifest metadata, or root dispatcher
command instead.

Preferred leaf labels use the smallest useful grouping prefix:

- `Packet - Review`
- `Program - Generate Implementation Orchestration Prompt`
- `Pack Scaffolder - Create Prompt Bundle`

Avoid redundant labels such as `Octon Proposal Lifecycle: Review Packet` when
all commands in the family already share a namespaced command ID.

Display labels are operator read models only. They do not authorize execution,
replace route IDs, or change command, skill, prompt, lifecycle, or receipt
authority.

---

## Extension Command IDs

Extension command IDs are host projection identities, not runtime route
authority. Leaf commands use a namespaced projection token:
`<operator-family>-<route-or-command-purpose>`.

The operator family is usually the pack ID. Packs may declare a shorter stable
operator family when that family is unambiguous and documented, such as
`octon-proposal-*` for `octon-proposal-lifecycle`. Root dispatcher or
single-purpose commands may equal the pack ID or operator family.

Do not require extension command IDs to match route IDs, skill IDs, prompt set
IDs, or display labels exactly. The routing contract records those bindings.

---

## Native and Instance Command IDs

Native framework commands are authored command contracts. Their command IDs stay
concise, direct, and action-oriented; do not add long namespace prefixes merely
to mirror extension naming. Instance commands follow the same pattern with
repo-native or domain-purpose IDs such as `repo-hygiene`.

Native and instance command IDs are still distinct from display labels and from
generated effective IDs. Host projections copy the command surface from
published capability routing; they do not authorize or rename the command.

Commands that wrap another execution surface, such as a workflow, service,
prompt, lifecycle runner, or external execution contract, must keep the wrapper
command ID focused on the operator action and declare the target or execution
contract separately in command metadata or command body. Do not force wrapper
command IDs to equal selected route IDs, target IDs, prompt set IDs, or service
operation names.

---

## Frontmatter Requirements

Harness command files require YAML frontmatter with the following fields:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Document title |
| `description` | Yes | Brief summary (max 160 characters) |
| `access` | Yes | `agent` for runtime capability commands in this repository; `human` remains a supported schema value for wrapper-oriented entry points |

---

## Example: Validate Frontmatter

A harness command for validating YAML frontmatter in markdown files.

> **Note:** This example is illustrative. See the actual implementation in `.octon/framework/capabilities/runtime/commands/validate-frontmatter.md` for the full specification.

**Location:** `.octon/framework/capabilities/runtime/commands/validate-frontmatter.md`

```markdown
---
title: Validate Frontmatter
description: Validate YAML frontmatter in markdown files
access: agent
---

# Validate Frontmatter

Validate YAML frontmatter in all markdown files in the parent directory.

## Action

1. Find all `*.md` files in the parent directory (recursive)
2. For each file, check that frontmatter exists and contains required fields
3. Report any files with missing or invalid frontmatter

## Output

List of files with validation status:
- ✅ Valid
- ❌ Missing frontmatter
- ⚠️ Missing required field: `<field>`
```

### Direct Invocation

An agent working in the harness can reference the command directly:

> "Validate frontmatter using `.octon/framework/capabilities/runtime/commands/validate-frontmatter.md`"

### Wrapped Invocation

To enable `/validate-frontmatter` in any harness, create a thin wrapper:

**Location:** `.<harness>/commands/validate-frontmatter.md` (e.g., `.cursor/commands/`, `.claude/commands/`)

```markdown
# Validate Frontmatter `/validate-frontmatter`

Validate YAML frontmatter in markdown files.

See `.octon/framework/capabilities/runtime/commands/validate-frontmatter.md` for full implementation.

## Usage

\`\`\`text
/validate-frontmatter @path/to/directory
\`\`\`

## Implementation

Execute `.octon/framework/capabilities/runtime/commands/validate-frontmatter.md` in the target directory's harness.
```

> **Note:** The same wrapper pattern works for any harness. Create equivalent files in `.cursor/commands/`, `.claude/commands/`, `.codex/commands/`, etc.

---

## Command Examples

| Command | Purpose | Why It's a Command (Not a Prompt) |
|---------|---------|-----------------------------------|
| `init.md` | Initialize project bootstrap files | Deterministic generation from templates + manifest values |
| `validate-frontmatter.md` | Check YAML frontmatter | Deterministic validation rules |
| `recover.md` | Recovery procedures | Fixed steps for known error types |
| `format-for-publication.md` | Apply formatting | Consistent rules, no judgment |
| `lint-conventions.md` | Check style compliance | Objective criteria |

---

## See Also

- [Prompts](../../../scaffolding/_meta/architecture/prompts.md) — Context-dependent task templates
- [Workflows](../../../orchestration/_meta/architecture/workflows.md) — Multi-step procedures
- [Taxonomy](../../../cognition/_meta/architecture/taxonomy.md) — Full classification of artifact types
- [README.md](./README.md) — Canonical harness structure reference
