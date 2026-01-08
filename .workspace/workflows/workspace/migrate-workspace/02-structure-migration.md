# Step 2: Structure Migration

Apply structural changes to align with current conventions.

## Actions

1. Create missing required directories:
   - `progress/` (if missing)
   - `checklists/` (if missing)

2. Create `.humans/` if it doesn't exist

3. Move files to new locations:

| Source | Destination |
|--------|-------------|
| Root `README.md` | `.humans/README.md` |
| `agents/*.md` | `prompts/*.md` (flatten) |
| Explanatory content | `.humans/rationale/` |

4. Create `.inbox/` and `.archive/` only if needed (don't pre-create empty)

## Verification

- Required files exist: `START.md`, `scope.md`, `conventions.md`
- Required dirs exist: `progress/`, `checklists/`
- No agent content in `.humans/` references from agent files

