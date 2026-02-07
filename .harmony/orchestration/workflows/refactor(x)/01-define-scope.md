# Step 1: Define Refactor Scope

## Purpose

Explicitly capture what is being refactored before any changes. This prevents scope drift and ensures exhaustive search patterns.

## Actions

1. Document the refactor type:
   - **Rename:** `old-name` → `new-name`
   - **Move:** `old/path/` → `new/path/`
   - **Restructure:** Multiple coordinated changes

2. Define the canonical patterns:
   ```
   OLD: [exact old pattern]
   NEW: [exact new pattern]
   ```

3. Generate search variations for the OLD pattern:
   - Base: `old-name`
   - With leading slash: `/old-name`
   - With trailing slash: `old-name/`
   - With both: `/old-name/`
   - In quotes (double): `"old-name"`
   - In quotes (single): `'old-name'`
   - As path segment: `/old-name/`
   - Without special chars: `oldname` (if applicable)

4. List file types to search:
   - Markdown: `*.md`
   - YAML: `*.yml`, `*.yaml`
   - JSON: `*.json`
   - Shell: `*.sh`
   - TypeScript/JavaScript: `*.ts`, `*.tsx`, `*.js`, `*.jsx`
   - Config files: `*.config.*`, `.*rc`
   - Any project-specific types

5. Identify exclusions (if any):
   - `node_modules/`
   - `.git/`
   - Build outputs

6. Note any directories or files that should be physically renamed/moved (not just text references)

## Output

A scope definition block to reference in subsequent steps:

```markdown
## Refactor Scope

**Type:** [Rename|Move|Restructure]
**Old:** `[pattern]`
**New:** `[pattern]`

**Search variations:**
- [ ] `old-name`
- [ ] `/old-name`
- [ ] `old-name/`
- [ ] `/old-name/`
- [ ] `"old-name"`
- [ ] `'old-name'`

**File types:** md, yml, yaml, json, sh, ts, js

**Physical changes:**
- [ ] Rename directory `X` to `Y`
- [ ] Move file `A` to `B`

**Exclusions:** node_modules, .git, dist
```

## Idempotency

**Check:** Is scope already defined for this refactor?
- [ ] Scope definition block exists in working document
- [ ] OLD and NEW patterns are specified
- [ ] Search variations are listed

**If Already Complete:**
- Load existing scope definition
- Ask user if modifications needed
- Skip to next step if no changes

**Marker:** `checkpoints/refactor/<refactor-id>/01-scope.complete`

## Proceed When

- All variations are listed
- File types are comprehensive for this codebase
- Physical vs. text changes are distinguished
