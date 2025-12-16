# Scaffold Workspace

## Context

Atomic reference for creating a `.workspace` directory structure.

## Manual Steps

```bash
# 1. Create directories
mkdir -p <TARGET>/.workspace/{progress,checklists}

# 2. Copy templates (from root .workspace)
cp .workspace/templates/START.md <TARGET>/.workspace/
cp .workspace/templates/scope.md <TARGET>/.workspace/
cp .workspace/templates/conventions.md <TARGET>/.workspace/
cp .workspace/templates/done.md <TARGET>/.workspace/checklists/
cp .workspace/templates/log.md <TARGET>/.workspace/progress/
cp .workspace/templates/tasks.json <TARGET>/.workspace/progress/

# 3. Customize scope.md with description
# 4. Update dates in log.md
```

## Placeholders

| Placeholder | Replace With |
|-------------|--------------|
| `{{SCOPE_DESCRIPTION}}` | User-provided scope |
| `{{DATE}}` | Current date (YYYY-MM-DD) |
| `{{TARGET_NAME}}` | Directory name |
