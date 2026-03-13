# Step 1: Backup Assessment

Read all existing files in the target `.octon` and create a migration plan.

## Actions

1. Validate harness schema compatibility first:
   - Read `.octon/octon.yml`.
   - Resolve `schema_version`.
   - Compare to `versioning.harness.supported_schema_versions`.
   - If unsupported, STOP and emit deterministic migration instructions from `versioning.harness.deterministic_upgrade_instructions`.
2. List all files and directories in the harness
3. Note custom content that MUST be preserved:
   - Custom prompts, workflows, commands
   - Progress history
   - Domain-specific context

4. Identify deprecated patterns:

| Old Pattern | Current Pattern |
|-------------|-----------------|
| `README.md` at root | Keep or move to `docs/` |
| `agents/` directory | Flatten to `prompts/` |
| Verbose agent content | Compress, move rationale to `ideation/scratchpad/` |
| Missing `continuity/` | Create with current state |
| Missing `access` frontmatter | Add to commands/workflows/prompts |

## Output

Migration plan listing:
- Files to preserve (with new locations if moving)
- Files to transform
- Files to archive
- New files to create
- Version-gate status (`supported` or `blocked-with-upgrade-instructions`)
