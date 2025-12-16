# Audit Workspace

## Context

Assess an existing `.workspace` directory's health and alignment with the root pattern.

## Instructions

1. Read the target `.workspace` structure
2. Compare against root `.workspace` pattern:
   - Required files: `START.md`, `scope.md`, `conventions.md`
   - Required dirs: `progress/`, `checklists/`
   - Optional dirs: `prompts/`, `workflows/`, `commands/`, `context/`, `templates/`, `examples/`

3. Check each file for:
   - Token budget compliance (~300 target, ~500 max per file)
   - Actionability (can agent act immediately?)
   - Currency (is content up to date?)
   - Scope alignment (content matches `scope.md`)

4. Review `progress/log.md` for:
   - Staleness (>30 days since last update)
   - Completeness (proper session format)
   - Continuity (clear thread across sessions)

5. Review `progress/tasks.json` for:
   - Schema compliance
   - Blocked task resolution
   - Task rot (old pending tasks)

## Output

| Section | Content |
|---------|---------|
| **Health Score** | X/10 with breakdown |
| **Structure Issues** | Missing/extra files |
| **Content Issues** | Staleness, bloat, gaps |
| **Recommendations** | Prioritized action items |
