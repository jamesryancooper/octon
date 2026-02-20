---
title: Snapshot Build
description: Build deterministic snapshot artifacts via filesystem-snapshot.
access: human
argument-hint: "[--root <path>] [--state-dir <path>] [--set-current true|false]"
---

# Snapshot Build `/snapshot-build`

Build deterministic snapshot artifacts via the filesystem-snapshot writer plane.

## Usage

```text
/snapshot-build
/snapshot-build --root .
/snapshot-build --root .harmony --set-current true
```

## Implementation

```bash
.harmony/runtime/run tool interfaces/filesystem-snapshot snapshot.build --json \
  '{"root":".","state_dir":".harmony/runtime/_ops/state/snapshots","set_current":true}'
```
