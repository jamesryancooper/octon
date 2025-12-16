# Migrate Workspace

## Context

Upgrade an older `.workspace` to current conventions, preserving existing content.

## Instructions

1. **Backup assessment**
   - Read all existing files
   - Note custom content to preserve
   - Identify deprecated patterns

2. **Structure migration**

   | Old Pattern | New Pattern |
   |-------------|-------------|
   | `README.md` at root | Move to `.humans/README.md` |
   | `agents/` directory | Flatten to `prompts/` |
   | Verbose agent content | Compress, move rationale to `.humans/` |
   | Missing `progress/` | Create with current state |

3. **Content migration**
   - Preserve custom prompts, workflows, commands
   - Update file references to new locations
   - Compress agent-facing content to budget
   - Move explanatory content to `.humans/`

4. **Validation**
   - Run `init.sh` health check
   - Verify boot sequence works
   - Check token budgets

## Output

- Migrated `.workspace/` structure
- List of changes made
- Preserved content locations
- Post-migration verification
