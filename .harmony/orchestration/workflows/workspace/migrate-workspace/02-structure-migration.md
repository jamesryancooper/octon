# Step 2: Structure Migration

Apply structural changes to align with current conventions.

## Actions

1. Create missing required directories:
   - `progress/` (if missing)
   - `checklists/` (if missing)
   - `projects/` (if needed)

2. Create `.scratchpad/` with subdirectories if needed:
   - `.scratchpad/inbox/` — temporary staging
   - `.scratchpad/archive/` — deprecated content
   - `.scratchpad/brainstorm/` — ideas under exploration
   - `.scratchpad/ideas/` — quick captures
   - `.scratchpad/drafts/` — work in progress

3. Move files to new locations:

| Source | Destination |
|--------|-------------|
| `agents/*.md` | `prompts/*.md` (flatten) |
| Explanatory content | `.scratchpad/` |
| Deprecated content | `.scratchpad/archive/` |
| Research projects in `.scratchpad/projects/` | `projects/` |

4. Do NOT pre-create empty `.scratchpad/` subdirectories; create only when needed

## Verification

- Required files exist: `START.md`, `scope.md`, `conventions.md`
- Required dirs exist: `progress/`, `checklists/`
- No agent-facing files reference `.scratchpad/` content
- Projects directory exists at workspace level if research projects are present
