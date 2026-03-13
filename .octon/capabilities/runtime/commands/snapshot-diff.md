---
title: Snapshot Diff
description: Compare two filesystem-snapshot artifacts.
access: agent
argument-hint: "--base <snapshot-id|path> --head <snapshot-id|path> [--state-dir <path>]"
---

# Snapshot Diff `/snapshot-diff`

Compare two snapshots and emit added/removed/changed paths.

## Usage

```text
/snapshot-diff --base snap-aaaa --head snap-bbbb
```

## Implementation

```bash
.octon/engine/runtime/run tool interfaces/filesystem-snapshot snapshot.diff --json \
  '{"base":"snap-aaaa","head":"snap-bbbb","state_dir":".octon/engine/_ops/state/snapshots"}'
```
