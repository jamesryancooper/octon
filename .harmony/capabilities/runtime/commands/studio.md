---
title: Launch Studio
description: Launch Harmony Studio for workflow graph design, inspection, and safe staged edits.
access: human
argument-hint: "[--root <project-root>]"
---

# Launch Studio `/studio`

Open the Harmony Studio desktop app from a project containing `.harmony/`.

## Usage

```text
/studio
/studio --root @/path/to/project-root
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--root` | No | Project root containing `.harmony/`. Defaults to current working directory. |

## Implementation

From project root:

```bash
.harmony/runtime/run studio
```

or, from inside `.harmony/`:

```bash
./runtime/run studio
```

When `studio` is invoked, the launcher uses source mode to avoid stale prebuilt binary drift.

## Output

- Opens the `harmony_studio` desktop window
- Loads workflows from `.harmony/orchestration/runtime/workflows/`
- Enables graph inspection, staged edit buffer, patch preview export, and apply audit browsing

## References

- **Runtime launcher:** `.harmony/runtime/run`
- **Kernel studio command:** `.harmony/runtime/crates/kernel/src/main.rs`
- **Studio crate:** `.harmony/runtime/crates/studio/`
