# Create Workspace

## Context

Scaffold a new `.workspace` directory in a target location, customized to the directory's context and content type.

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `TARGET_PATH` | Yes | Directory where `.workspace/` will be created |

## Phase 1: Validate

1. Verify `TARGET_PATH` exists (or create it)
2. Check no existing `.workspace/` (or confirm overwrite)
3. Note the directory name for `{{TARGET_NAME}}`

## Phase 2: Analyze Context

### 2.1 Directory Analysis

```bash
ls -la <TARGET_PATH>
```

### 2.2 Identify Directory Type

| Indicators | Type | Conventions Focus |
|------------|------|-------------------|
| `package.json`, `tsconfig.json`, `src/` | Node/TypeScript | Component naming, imports |
| `pyproject.toml`, `requirements.txt`, `*.py` | Python | Module naming, docstrings |
| `*.md`, `content/`, `docs/` | Documentation | Document structure, frontmatter |
| `*.yaml`, `*.json`, `Dockerfile`, `terraform/` | Config/Infra | Schema validation, comments |
| `*.test.*`, `__tests__/`, `spec/` | Test suite | Test naming, coverage |

### 2.3 Detect Existing Patterns

- **Naming:** Check existing files for kebab-case, PascalCase, snake_case
- **Style:** Look for `.eslintrc`, `.prettierrc`, `.editorconfig`, `pyproject.toml`
- **Tests:** Look for test files, `jest.config`, `pytest.ini`
- **CI:** Look for `.github/workflows/`, `Makefile`, `scripts/`
- **Docs:** Read `README.md` for setup instructions, purpose

### 2.4 Note Key Files

Record for `START.md`:

- Entry points (`index.ts`, `main.py`, `README.md`)
- Config files that matter
- Build/run scripts

## Phase 3: Gather User Context

Ask these questions (skip if obvious from Phase 2):

1. **Scope:** "What is this directory for?"
   → `scope.md` description

2. **In-scope work:** "What types of work happen here?"
   → `scope.md` "In Scope" section

3. **Out-of-scope:** "What belongs elsewhere?"
   → `scope.md` "Out of Scope" section

4. **Quality checks:** "What must be verified before completion?"
   → `done.md` quality criteria

5. **Prerequisites:** "Any setup needed to work here?"
   → `START.md` boot sequence

## Phase 4: Create Structure

```bash
mkdir -p <TARGET>/.workspace/{progress,checklists}
```

## Phase 5: Generate Customized Files

### 5.1 `scope.md`

```markdown
# Scope: {{TARGET_NAME}}

## This Workspace Covers

{{USER_SCOPE_DESCRIPTION}}

## In Scope

{{USER_IN_SCOPE or derive from directory type}}

## Out of Scope

{{USER_OUT_OF_SCOPE or derive from adjacent directories}}

## Decision Authority

**Decide locally:**
- {{Based on directory ownership}}

**Escalate:**
- {{Based on what affects other areas}}

## Adjacent Areas

{{List sibling directories if relevant}}
```

### 5.2 `conventions.md`

Customize based on detected type:

**For Code (Node/TS):**

```markdown
## File Naming
- Components: PascalCase (`MyComponent.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Tests: `*.test.ts` or `*.spec.ts`
```

**For Documentation:**

```markdown
## File Naming
- Lowercase with hyphens: `my-document.md`
- Index files: `README.md` or `index.md`
```

**For Config/Infra:**

```markdown
## File Naming
- Lowercase with hyphens: `my-config.yaml`
- Environment-specific: `config.{env}.yaml`
```

### 5.3 `done.md`

Add detected quality gates:

```markdown
## Quality Criteria

{{If tests detected}}
- [ ] Tests pass (`npm test` / `pytest`)

{{If linter detected}}
- [ ] Linting passes (`npm run lint`)

{{If build detected}}
- [ ] Build succeeds (`npm run build`)

{{If TypeScript}}
- [ ] No type errors (`tsc --noEmit`)

{{User's custom checks}}
- [ ] {{USER_QUALITY_CHECK}}
```

### 5.4 `START.md`

Customize boot sequence:

```markdown
## Boot Sequence

{{If setup required}}
1. **Setup:** {{USER_PREREQUISITES or detected setup}}

2. **Read `scope.md`** → Know boundaries
3. **Read `conventions.md`** → Know style rules
4. **Read `progress/log.md`** → Know what's been done
5. **Read `progress/tasks.json`** → Know current priorities

{{If key entry points found}}
**Key files:**
- {{Entry point 1}}
- {{Entry point 2}}
```

### 5.5 `tasks.json`

Generate initial tasks based on directory state:

**Empty/New Directory:**

```json
{
  "tasks": [
    { "id": "define-structure", "description": "Define directory structure", "status": "pending" },
    { "id": "create-initial", "description": "Create initial content", "status": "pending" }
  ]
}
```

**Existing Code:**

```json
{
  "tasks": [
    { "id": "document-state", "description": "Document current codebase state", "status": "pending" },
    { "id": "identify-debt", "description": "Identify technical debt", "status": "pending" }
  ]
}
```

**Existing Docs:**

```json
{
  "tasks": [
    { "id": "audit-docs", "description": "Audit existing documentation", "status": "pending" },
    { "id": "identify-gaps", "description": "Identify documentation gaps", "status": "pending" }
  ]
}
```

### 5.6 `log.md`

Initialize with creation context:

```markdown
# Progress Log

## {{DATE}}

**Session focus:** Workspace initialization

**Completed:**
- Created `.workspace/` structure
- Analyzed directory: {{DIRECTORY_TYPE}}
- Configured scope: {{BRIEF_SCOPE}}

**Key findings:**
- {{Notable files or patterns found}}

**Next:**
- {{First task from tasks.json}}

**Blockers:**
- None
```

## Phase 6: Verify

1. List created files
2. Show customizations made
3. Run `init.sh` if available
4. Point user to `START.md`

## Output

- New `.workspace/` directory at `TARGET_PATH`
- Summary of customizations
- Next steps recommendation
