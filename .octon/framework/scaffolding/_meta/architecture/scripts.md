---
title: Harness Scaffolding Scripts
description: Executable scaffolding scripts owned by the scaffolding runtime surface.
---

# Harness Scaffolding Scripts

Scaffolding runtime scripts are executable utilities used to bootstrap and validate harness assets.

## Location

```text
.octon/framework/scaffolding/runtime/_ops/scripts/
├── init-project.sh               # Stable wrapper to the canonical bootstrap script
└── sync-bootstrap-projection.sh  # Refresh projected bootstrap assets in the base harness template
```

## `init-project.sh`

The stable scaffolding bootstrap wrapper. It delegates to the canonical bootstrap implementation under `scaffolding/runtime/bootstrap/`.

### Purpose

- Generate canonical `/.octon/AGENTS.md` and refresh root ingress adapters
- Generate canonical `/.octon/instance/charter/workspace.{md,yml}` plus compatibility shims at `/.octon/instance/bootstrap/OBJECTIVE.md` and `/.octon/instance/cognition/context/shared/intent.contract.yml`
- Optionally generate compatibility boot files (`BOOT.md`, `BOOTSTRAP.md`)
- Generate root `alignment-check` shim
- Optionally initialize agent-platform adapter bootstrap config

### Usage

```bash
.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh
```

Optional flags:

- `--with-boot-files`
- `--with-agent-platform-adapters`
- `--agent-platform-adapters <csv>`
- `--force`
- `--dry-run`

## Script Conventions

1. Scripts live under `scaffolding/runtime/_ops/scripts/`.
2. Scripts use fail-fast shell settings (`set -euo pipefail`).
3. Scripts operate only on canonical runtime/governance/practices surfaces.
4. Scripts fail closed on missing required templates or manifests.

## See Also

- [Templates](./templates.md) - canonical reusable templates
- [README.md](../runtime/README.md) - runtime surface split between bootstrap and templates
- [README.md](./README.md) - scaffolding architecture index
