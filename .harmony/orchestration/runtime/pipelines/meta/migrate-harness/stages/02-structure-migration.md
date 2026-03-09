# Step 2: Structure Migration

Apply structural changes to align with current conventions.

## Actions

1. Create missing required directories:
   - `continuity/` (if missing)
   - `assurance/` (if missing)
   - `projects/` (if needed)

2. Create `ideation/scratchpad/` with subdirectories if needed:
   - `ideation/scratchpad/inbox/` — temporary staging
   - `ideation/scratchpad/archive/` — deprecated content
   - `ideation/scratchpad/brainstorm/` — ideas under exploration
   - `ideation/scratchpad/ideas/` — quick captures
   - `ideation/scratchpad/drafts/` — work in progress

3. Move files to new locations:

| Source | Destination |
|--------|-------------|
| `agents/*.md` | `prompts/*.md` (flatten) |
| Explanatory content | `ideation/scratchpad/` |
| Deprecated content | `ideation/scratchpad/archive/` |
| Research projects in `ideation/projects/` | `projects/` |

4. Do NOT pre-create empty `ideation/scratchpad/` subdirectories; create only when needed

## Verification

- Required files exist: `START.md`, `scope.md`, `conventions.md`
- Required dirs exist: `continuity/`, `assurance/`
- No agent-facing files reference `ideation/scratchpad/` content
- Projects directory exists at harness level if research projects are present
