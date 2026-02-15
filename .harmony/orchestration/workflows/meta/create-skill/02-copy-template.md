---
title: Copy Template
description: Copy skill template to new skill directory with spec-compliant structure.
---

# Step 2: Copy Template

> **Deprecated workflow step:** Use the `create-skill` skill for current paths and file naming.

## Input

- Validated `skill-name` from Step 1

## Actions

```text
1. Create directory: .harmony/capabilities/skills/<group>/<skill-name>/

2. Copy core file:
   - .harmony/capabilities/skills/_scaffold/template/SKILL.md -> .harmony/capabilities/skills/<group>/<skill-name>/SKILL.md

3. Create and copy reference files:
   - .harmony/capabilities/skills/_scaffold/template/references/phases.md -> .harmony/capabilities/skills/<group>/<skill-name>/references/phases.md
   - .harmony/capabilities/skills/_scaffold/template/references/io-contract.md -> .harmony/capabilities/skills/<group>/<skill-name>/references/io-contract.md
   - .harmony/capabilities/skills/_scaffold/template/references/safety.md -> .harmony/capabilities/skills/<group>/<skill-name>/references/safety.md
   - .harmony/capabilities/skills/_scaffold/template/references/examples.md -> .harmony/capabilities/skills/<group>/<skill-name>/references/examples.md
   - .harmony/capabilities/skills/_scaffold/template/references/validation.md -> .harmony/capabilities/skills/<group>/<skill-name>/references/validation.md

4. Create empty directories:
   - .harmony/capabilities/skills/<group>/<skill-name>/scripts/
   - .harmony/capabilities/skills/<group>/<skill-name>/assets/

5. Create symlinks in harness folders:
   - .claude/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
   - .cursor/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
   - .codex/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
```

## Directory Structure

Creates agentskills.io spec-compliant structure:

```text
.harmony/capabilities/skills/<group>/<skill-name>/
├── SKILL.md              # Core skill definition
├── references/           # Progressive disclosure content
│   ├── phases.md         # Detailed phase behavior
│   ├── io-contract.md    # Inputs/outputs/dependencies + CLI usage
│   ├── safety.md         # Safety policies
│   ├── examples.md       # Full examples
│   └── validation.md     # Acceptance criteria
├── scripts/              # Executable code (empty)
└── assets/               # Static resources (empty)
```

## Verification

- Directory `.harmony/capabilities/skills/<group>/<skill-name>/` exists
- File `.harmony/capabilities/skills/<group>/<skill-name>/SKILL.md` exists
- All reference files exist in `.harmony/capabilities/skills/<group>/<skill-name>/references/`
- Empty directories created (`scripts/`, `assets/`)
- Symlinks exist in harness directories

## Idempotency

**Check:** Is template already copied?
- [ ] Directory `.harmony/capabilities/skills/<group>/<skill-name>/` exists
- [ ] File `.harmony/capabilities/skills/<group>/<skill-name>/SKILL.md` exists
- [ ] All reference files exist
- [ ] Symlinks exist in harness directories

**If Already Complete:**
- Verify directory structure is complete
- Skip to next step if all files present

**Marker:** `checkpoints/create-skill/<skill-name>/02-copy.complete`

## Output

- New skill directory with template files
- Spec-compliant structure with progressive disclosure
- Proceed to Step 3
