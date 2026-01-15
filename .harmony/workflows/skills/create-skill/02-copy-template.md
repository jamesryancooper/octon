---
title: Copy Template
description: Copy skill template to new skill directory with spec-compliant structure.
---

# Step 2: Copy Template

## Input

- Validated `skill-name` from Step 1

## Actions

```text
1. Create directory: skills/<skill-name>/

2. Copy core file:
   - skills/_template/SKILL.md -> skills/<skill-name>/SKILL.md

3. Create and copy reference files:
   - skills/_template/references/behaviors.md -> skills/<skill-name>/references/behaviors.md
   - skills/_template/references/triggers.md -> skills/<skill-name>/references/triggers.md
   - skills/_template/references/io-contract.md -> skills/<skill-name>/references/io-contract.md
   - skills/_template/references/safety.md -> skills/<skill-name>/references/safety.md
   - skills/_template/references/examples.md -> skills/<skill-name>/references/examples.md
   - skills/_template/references/validation.md -> skills/<skill-name>/references/validation.md

4. Create empty directories:
   - skills/<skill-name>/scripts/
   - skills/<skill-name>/assets/

5. Create symlinks in harness folders:
   - .claude/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
   - .cursor/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
   - .codex/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
```

## Directory Structure

Creates agentskills.io spec-compliant structure:

```text
skills/<skill-name>/
├── SKILL.md              # Core skill definition
├── references/           # Progressive disclosure content
│   ├── behaviors.md      # Detailed phase behavior
│   ├── triggers.md       # Commands and triggers
│   ├── io-contract.md    # Inputs/outputs/dependencies
│   ├── safety.md         # Safety policies
│   ├── examples.md       # Full examples
│   └── validation.md     # Acceptance criteria
├── scripts/              # Executable code (empty)
└── assets/               # Static resources (empty)
```

## Verification

- Directory `skills/<skill-name>/` exists
- File `skills/<skill-name>/SKILL.md` exists
- All reference files exist in `skills/<skill-name>/references/`
- Empty directories created (`scripts/`, `assets/`)
- Symlinks exist in harness directories

## Idempotency

**Check:** Is template already copied?
- [ ] Directory `skills/<skill-name>/` exists
- [ ] File `skills/<skill-name>/SKILL.md` exists
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
