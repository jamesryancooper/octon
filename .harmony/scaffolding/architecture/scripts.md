---
title: Harness Scripts
description: Shell scripts for harness health checks and automation.
---

# Harness Scripts

Scripts are **shell utilities** stored at the primary (repo-root) `.harmony/` level. They provide automation for harness maintenance tasks that are better suited to shell execution than agent procedures.

## Location

```text
.harmony/
└── init.sh    # Health check script
```

---

## `init.sh`

The primary root-harness script. Verifies that root-profile files and directories exist.

### Purpose

- Validate harness structure integrity
- Report missing required components
- Identify available standard directories
- Validate the repo-root harness profile (not minimal descendant profiles)

### Usage

```bash
cd .harmony
./init.sh
```

### Output

```text
=== .harmony Health Check ===
✓ START.md
✓ scope.md
✓ conventions.md
✓ catalog.md
✓ continuity/
✓ quality/
✓ scaffolding/prompts/
✓ orchestration/workflows/
✓ capabilities/commands/
✓ cognition/context/

Standard directories:
✓ scaffolding/templates/
○ scaffolding/examples/ (not created)

=== Ready ===
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All required files/directories present |
| `1` | One or more required items missing |

Descendant harnesses may intentionally omit many root-profile directories. Use `init.sh` as a root harness check, not as a strict descendant harness validator.

---

## When to Use Scripts vs Workflows

| Use Case | Use Script | Use Workflow |
|----------|------------|--------------|
| Simple file/directory checks | ✅ | — |
| Complex multi-step procedures | — | ✅ |
| Needs agent judgment | — | ✅ |
| Pure validation (no changes) | ✅ | — |
| Creates or modifies files | — | ✅ |

Scripts are for **quick validation**. Workflows are for **agent-driven procedures**.

---

## Script Conventions

1. **Location** — Scripts live at `.harmony/` root, not in subdirectories
2. **Naming** — Use descriptive names: `init.sh`, `validate.sh`
3. **Shebang** — Always include `#!/bin/bash`
4. **Exit on error** — Include `set -e` for fail-fast behavior
5. **Output** — Use clear status indicators: `✓`, `✗`, `○`

---

## See Also

- [README.md](./README.md) — Canonical harness structure
- [Checklists](./checklists.md) — Quality gates (agent-facing alternative to validation scripts)
