---
title: Analyze Context
description: Detect directory type and existing patterns.
---

# Step 3: Analyze Directory Context

## List contents

```bash
ls -la <target>
```

## Identify directory type

| Indicators | Type | Conventions Focus |
|------------|------|-------------------|
| `package.json`, `tsconfig.json`, `src/` | Node/TypeScript | Component naming, imports, tests |
| `pyproject.toml`, `requirements.txt`, `*.py` | Python | Module naming, docstrings |
| `*.md`, `content/`, `docs/` | Documentation | Document structure, frontmatter |
| `*.yaml`, `Dockerfile`, `terraform/` | Config/Infra | Schema validation, comments |
| `*.test.*`, `__tests__/`, `spec/` | Test Suite | Test naming, coverage, fixtures |
| Mixed indicators | Hybrid | Combine relevant conventions |

## Detect existing patterns

- **Naming:** Check files for kebab-case, PascalCase, snake_case
- **Style:** Look for `.eslintrc`, `.prettierrc`, `.editorconfig`, `pyproject.toml`
- **Tests:** Look for test files, `jest.config`, `vitest.config`, `pytest.ini`
- **CI:** Look for `.github/workflows/`, `Makefile`, `scripts/`
- **Docs:** Read `README.md` for setup instructions, purpose

## Note key files for START.md

- Entry points (`index.ts`, `main.py`, `README.md`)
- Config files that matter
- Build/run scripts

## Idempotency

**Check:** Is context analysis already complete?
- [ ] Checkpoint file exists: `checkpoints/create-harness/<target>/03-context.complete`
- [ ] Directory type cached
- [ ] Detected patterns cached

**If Already Complete:**
- Load cached analysis
- Skip to next step

**Marker:** `checkpoints/create-harness/<target>/03-context.complete`
