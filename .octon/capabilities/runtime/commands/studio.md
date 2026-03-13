---
title: Launch Studio
description: Launch Octon Studio for workflow graph design, read-only orchestration operations, and safe staged edits.
access: agent
argument-hint: "[--root <project-root>]"
---

# Launch Studio `/studio`

Open the Octon Studio desktop app from a project containing `.octon/`.

## Usage

```text
/studio
/studio --root @/path/to/project-root
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--root` | No | Project root containing `.octon/`. Defaults to current working directory. |

## Implementation

From project root:

```bash
.octon/engine/runtime/run studio
```

or, from inside `.octon/`:

```bash
./engine/runtime/run studio
```

When `studio` is invoked, the launcher uses source mode to avoid stale prebuilt binary drift.

## Output

- Opens the `octon_studio` desktop window
- Loads workflows from `.octon/orchestration/runtime/workflows/`
- Enables graph inspection, staged edit buffer, patch preview export, and apply audit browsing
- Enables a read-only `Operations` workspace for:
  - overview
  - lookup
  - runs
  - incidents
  - queue
  - watchers
  - automations
  - missions
  - playbooks

## References

- **Runtime launcher:** `.octon/engine/runtime/run`
- **Kernel studio command:** `.octon/engine/runtime/crates/kernel/src/main.rs`
- **Studio crate:** `.octon/engine/runtime/crates/studio/`
