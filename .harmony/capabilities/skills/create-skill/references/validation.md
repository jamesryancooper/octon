---
acceptance_criteria:
  - "Skill directory created with all required files"
  - "SKILL.md frontmatter name matches directory"
  - "manifest.yml contains entry with correct id"
  - "registry.yml contains entry with correct key"
  - "Symlinks exist and resolve correctly"
  - "Run log captures all phases"
  - "Log indexes updated"
---

# Validation Reference

Acceptance criteria and validation rules for the create-skill skill.

## Acceptance Criteria

A skill creation is valid when:

- [ ] Directory `.harmony/capabilities/skills/{{skill-name}}/` exists
- [ ] `SKILL.md` exists with valid frontmatter
- [ ] Frontmatter `name` field equals skill name
- [ ] All 5 reference files exist in `references/`
- [ ] `scripts/` and `assets/` directories exist
- [ ] `manifest.yml` contains entry with `id: {{skill-name}}`
- [ ] `registry.yml` contains entry with key `{{skill-name}}`
- [ ] `catalog.md` contains row for skill
- [ ] Symlinks exist in `.claude/`, `.cursor/`, `.codex/`
- [ ] Symlinks resolve to correct target
- [ ] Run log exists at `logs/create-skill/{{run-id}}.md`
- [ ] Log indexes updated (both top-level and skill-level)

## Name Validation Rules

### Format (Blocking)

```regex
^[a-z][a-z0-9]*(-[a-z0-9]+)*$
```

| Check | Valid | Invalid |
|-------|-------|---------|
| Lowercase only | `analyze-data` | `Analyze-Data` |
| Start with letter | `a1-test` | `1-test` |
| No leading hyphen | `my-skill` | `-my-skill` |
| No trailing hyphen | `my-skill` | `my-skill-` |
| No consecutive hyphens | `my-skill` | `my--skill` |
| Length 1-64 | `a` through 64 chars | Empty or >64 |

### Naming Convention (Warning)

Skills should start with action verb:
- `analyze-`, `build-`, `create-`, `deploy-`
- `extract-`, `generate-`, `process-`, `refine-`
- `run-`, `validate-`, `transform-`, `convert-`

If not verb-noun, issue warning but continue.

## Post-Creation Verification

After Phase 5, verify:

### Directory Structure

```bash
# All must exist
ls -la .harmony/capabilities/skills/{{skill-name}}/
ls -la .harmony/capabilities/skills/{{skill-name}}/references/
```

Expected:
- `SKILL.md`
- `references/behaviors.md`
- `references/io-contract.md`
- `references/safety.md`
- `references/examples.md`
- `references/validation.md`
- `scripts/` (directory)
- `assets/` (directory)

### File Contents

```bash
# Check frontmatter name
grep "^name: {{skill-name}}" .harmony/capabilities/skills/{{skill-name}}/SKILL.md
```

### Registry Entries

```bash
# Check manifest
grep "id: {{skill-name}}" .harmony/capabilities/skills/manifest.yml

# Check registry
grep "^  {{skill-name}}:" .harmony/capabilities/skills/registry.yml
```

### Symlinks

```bash
# Check symlinks resolve
readlink .claude/skills/{{skill-name}}
readlink .cursor/skills/{{skill-name}}
readlink .codex/skills/{{skill-name}}
```

Expected: `../../.harmony/capabilities/skills/{{skill-name}}`

### Log Files

```bash
# Check run log exists
ls .harmony/capabilities/skills/logs/create-skill/{{run-id}}.md

# Check indexes updated
grep "{{skill-name}}" .harmony/capabilities/skills/logs/create-skill/index.yml
```

## Validation Script

The created skill should pass the validation script:

```bash
.harmony/capabilities/skills/scripts/validate-skills.sh {{skill-name}}
```

Expected output: All checks pass (note: some checks require TODOs to be completed).

## Failure Conditions

| Condition | Phase | Result |
|-----------|-------|--------|
| Name format invalid | 1 | STOP with error message |
| Skill already exists | 1 | STOP, ask for confirmation |
| Template not found | 2 | STOP with error message |
| Cannot create directory | 2 | STOP with error message |
| Cannot write file | 2-5 | STOP at relevant phase |
| Registry malformed | 4 | STOP with error message |
| Catalog not found | 5 | WARN, continue without catalog update |

## Quality Checklist

Before declaring completion:

### Completeness
- [ ] All 6 phases executed
- [ ] All files created
- [ ] All symlinks created
- [ ] Registry entries added
- [ ] Catalog entry added
- [ ] Run log written
- [ ] Indexes updated

### Correctness
- [ ] Name validation passed
- [ ] Placeholders replaced
- [ ] Frontmatter valid YAML
- [ ] Symlinks resolve correctly
- [ ] Registry entries have correct format

### Documentation
- [ ] Checkpoint reflects final state (status: completed)
- [ ] Run log captures all phases with timestamps
- [ ] Next steps clearly communicated to user

## Verification Gate

The skill includes a verification gate at Phase 5:

1. Check all required files exist
2. Verify SKILL.md frontmatter is valid
3. Verify manifest entry exists
4. Verify registry entry exists
5. Verify symlinks resolve

If any check fails:
- Report specific failure
- Do not proceed to Phase 6
- Offer to retry failed operations

## Idempotency Verification

On resume, verify:

1. Checkpoint file exists and is valid YAML
2. Current phase is recorded correctly
3. Completed phases have timestamps
4. No duplicate entries created in registries
