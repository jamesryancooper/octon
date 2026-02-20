# Examples Reference

Worked examples demonstrating the create-skill skill.

## Example 1: Basic Skill Creation

**Goal:** Create a new skill named `analyze-codebase`.

### Invocation

```
/create-skill "analyze-codebase"
```

### Phase 1: Validate

```
Validating skill name: analyze-codebase

- Format: PASSED (matches ^[a-z][a-z0-9]*(-[a-z0-9]+)*$)
- Length: PASSED (16 characters)
- Convention: PASSED (starts with verb "analyze")
- Uniqueness: PASSED (not in manifest.yml)

Validation complete. Proceeding to Phase 2.
```

### Phase 2: Copy Template

```
Creating skill directory structure...

Created: .harmony/capabilities/runtime/skills/analyze-codebase/
Created: .harmony/capabilities/runtime/skills/analyze-codebase/SKILL.md
Created: .harmony/capabilities/runtime/skills/analyze-codebase/references/
Created: .harmony/capabilities/runtime/skills/analyze-codebase/references/behaviors.md
Created: .harmony/capabilities/runtime/skills/analyze-codebase/references/io-contract.md
Created: .harmony/capabilities/runtime/skills/analyze-codebase/references/safety.md
Created: .harmony/capabilities/runtime/skills/analyze-codebase/references/examples.md
Created: .harmony/capabilities/runtime/skills/analyze-codebase/references/validation.md
Created: .harmony/capabilities/runtime/skills/analyze-codebase/scripts/
Created: .harmony/capabilities/runtime/skills/analyze-codebase/assets/

Creating symlinks...
Created: .claude/skills/analyze-codebase -> ../../.harmony/capabilities/runtime/skills/analyze-codebase
Created: .cursor/skills/analyze-codebase -> ../../.harmony/capabilities/runtime/skills/analyze-codebase
Created: .codex/skills/analyze-codebase -> ../../.harmony/capabilities/runtime/skills/analyze-codebase
```

### Phase 3: Initialize

```
Initializing skill files...

- Updated SKILL.md frontmatter (name: analyze-codebase)
- Set metadata.created: 2026-01-20
- Set metadata.updated: 2026-01-20
- Replaced placeholders in 6 files
```

### Phase 4: Update Registry

```
Updating registry files...

- Added entry to manifest.yml (id: analyze-codebase)
- Added entry to registry.yml (key: analyze-codebase)
```

### Phase 5: Update Catalog

```
Updating catalog...

- Added row to .harmony/catalog.md
```

### Phase 6: Report Success

```
## Skill Created: analyze-codebase

**Location:** `.harmony/capabilities/runtime/skills/analyze-codebase/`

### Files Created
- SKILL.md (core definition)
- references/behaviors.md
- references/io-contract.md
- references/safety.md
- references/examples.md
- references/validation.md

### Symlinks Created
- .claude/skills/analyze-codebase
- .cursor/skills/analyze-codebase
- .codex/skills/analyze-codebase

### Registry Updated
- manifest.yml: Entry added
- registry.yml: Entry added

### Next Steps
1. Edit SKILL.md to define description and workflow
2. Complete TODO items in manifest.yml and registry.yml
3. Add examples to references/examples.md
4. Test with `/analyze-codebase [input]`
```

---

## Example 2: Skill with Description

**Goal:** Create skill with pre-filled description.

### Invocation

```
/create-skill "format-json" --description="Format and validate JSON files with pretty printing"
```

### Result

SKILL.md description pre-filled:

```yaml
---
name: format-json
description: >
  Format and validate JSON files with pretty printing.
  Include specific keywords to help agents identify relevant tasks.
...
---
```

---

## Example 3: Naming Convention Warning

**Goal:** Create skill with non-verb-noun name.

### Invocation

```
/create-skill "data-processor"
```

### Phase 1 Output

```
Validating skill name: data-processor

- Format: PASSED
- Length: PASSED (14 characters)
- Convention: WARNING
  > Consider using an action-oriented name starting with a verb.
  > Example: "process-data" instead of "data-processor"
- Uniqueness: PASSED

Proceeding with warning. You may want to rename later.
```

The skill is created despite the warning, as naming convention is recommended but not required.

---

## Example 4: Validation Failure - Already Exists

**Goal:** Attempt to create skill that exists.

### Invocation

```
/create-skill "refine-prompt"
```

### Phase 1 Output

```
Validating skill name: refine-prompt

- Format: PASSED
- Length: PASSED
- Convention: PASSED
- Uniqueness: FAILED
  > Skill "refine-prompt" already exists in manifest.yml

ERROR: Cannot create skill.

Options:
1. Choose a different name
2. Overwrite existing skill (requires confirmation)
3. Cancel

What would you like to do?
```

---

## Example 5: Validation Failure - Invalid Format

**Goal:** Attempt to create skill with invalid name.

### Invocation

```
/create-skill "My-Awesome-Skill"
```

### Phase 1 Output

```
Validating skill name: My-Awesome-Skill

- Format: FAILED
  > Skill name must be lowercase letters, numbers, and hyphens only.
  > Pattern: ^[a-z][a-z0-9]*(-[a-z0-9]+)*$

ERROR: Invalid skill name format.

Suggestions:
- Use lowercase: "my-awesome-skill"
- Start with verb: "create-awesome-thing"

Please provide a valid skill name.
```

---

## Example 6: Resume Interrupted Creation

**Scenario:** Session ended during Phase 3.

### Resume Invocation

```
/create-skill "validate-schema"
```

### Detection

```
Found existing scaffold in progress:
  Skill: validate-schema
  Status: in_progress
  Phase: 3 (Initialize)
  Progress: Placeholder replacement incomplete

Resume from Phase 3? [Y/n]
```

### User Confirms

```
Resuming skill creation from Phase 3...

Phase 3: Initialize
- Completing placeholder replacement...
- Done.

Phase 4: Update Registry
- Adding to manifest.yml...
- Adding to registry.yml...
- Done.

Phase 5: Update Catalog
- Adding row to catalog.md...
- Done.

Phase 6: Report Success
## Skill Created: validate-schema
...
```

---

## Example 7: Atomic Archetype

**Goal:** Create a simple atomic skill without references/.

### Invocation

```
/create-skill "format-json" --archetype=atomic
```

### Result

Minimal structure created:

```
.harmony/capabilities/runtime/skills/format-json/
├── SKILL.md
├── scripts/
└── assets/
```

Note: No `references/` directory for atomic archetype.

---

## Anti-Examples: What NOT to Do

### Skipping Validation

**Wrong:**
```
User: Create skill "My-Awesome-Skill"
Agent: Creating skill directory...
```

**Why it's wrong:** Name validation must happen FIRST. "My-Awesome-Skill" fails format check (uppercase).

### Overwriting Without Confirmation

**Wrong:**
```
Skill "analyze-codebase" exists. Overwriting...
```

**Why it's wrong:** Must ask for explicit confirmation before overwriting.

### Skipping Registry Update

**Wrong:**
```
Created skill directory. Done!
```

**Why it's wrong:** Skill is not discoverable without manifest/registry entries. Always complete all 6 phases.

### Not Creating Symlinks

**Wrong:**
```
Skill created at .harmony/capabilities/runtime/skills/my-skill/
```

**Why it's wrong:** Symlinks in harness folders are required for multi-agent compatibility.

### Not Writing Run Log

**Wrong:**
```
Skill created. Goodbye!
```

**Why it's wrong:** All skill executions must be logged for auditability.
