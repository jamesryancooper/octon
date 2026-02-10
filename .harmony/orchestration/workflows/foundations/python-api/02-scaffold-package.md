---
name: scaffold-package
title: "Scaffold Package"
description: "Run /scaffold-package to create the foundational package structure."
---

# Step 2: Scaffold Package

## Input

- Validated input record (from step 1)

## Purpose

Create the foundational package structure that every other skill depends on:
`pyproject.toml`, `src/<package>/` tree, typed config, structured logging,
health endpoints, and the `ContractModel` base class.

## Actions

1. **Check skip list:**

   If `scaffold-package` is in the skip list:

   - Verify `pyproject.toml` exists and has `[project].name`
   - Verify `src/<package>/` exists with `models/base.py` and `config/settings.py`
   - If verified, skip to step 3
   - If missing critical files, warn and ask user whether to proceed

2. **Invoke the skill:**

   ```text
   /scaffold-package {PROJECT_NAME} "{DESCRIPTION}" {PYTHON_VERSION} {SERVICES...}
   ```

   Example:

   ```text
   /scaffold-package my-app "Event processing API" python3.12 postgres nats redis
   ```

3. **Validate outputs:**

   After the skill completes, confirm these files exist:

   - `pyproject.toml` with `[project].name = "{PROJECT_NAME}"`
   - `src/{PACKAGE_NAME}/__init__.py`
   - `src/{PACKAGE_NAME}/models/base.py` with `ContractModel` class
   - `src/{PACKAGE_NAME}/config/settings.py` with `BaseSettings` subclass
   - `src/{PACKAGE_NAME}/api/app.py` with `create_app()` factory
   - `src/{PACKAGE_NAME}/observability/logging.py`

4. **Record result:**

   Note which files were created vs already existed (for incremental runs).

## Idempotency

**Check:** Package structure already exists.

- [ ] `pyproject.toml` exists with correct project name
- [ ] `src/{PACKAGE_NAME}/models/base.py` exists
- [ ] `src/{PACKAGE_NAME}/config/settings.py` exists
- [ ] `src/{PACKAGE_NAME}/api/app.py` exists

**If Already Complete:**

- Skip to step 3
- The skill itself handles additive generation (only creates missing files)

**Marker:** `checkpoints/python-api-foundation/02-scaffold-package.complete`

## Error Messages

- Skill invocation failed: "SCAFFOLD_FAILED: /scaffold-package exited with errors: {details}"
- Critical file missing after run: "SCAFFOLD_INCOMPLETE: Expected {file} but it was not created"

## Output

- Complete package structure under `src/{PACKAGE_NAME}/`
- `pyproject.toml` with project metadata and dependencies
- List of files created/verified

## Proceed When

- [ ] `pyproject.toml` exists with correct project name
- [ ] `src/{PACKAGE_NAME}/` tree has all standard sub-packages
- [ ] `models/base.py` contains `ContractModel`
- [ ] `config/settings.py` contains typed `Settings` class
