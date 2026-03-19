---
title: Snapshot Build
description: Build deterministic snapshot artifacts via filesystem-snapshot.
access: agent
argument-hint: "[--root <path>] [--state-dir <path>] [--set-current true|false]"
---

# Snapshot Build `/snapshot-build`

Build deterministic snapshot artifacts via the filesystem-snapshot writer plane.

## Usage

```text
/snapshot-build
/snapshot-build --root .
/snapshot-build --root .octon --set-current true
```

## Implementation

```bash
.octon/framework/engine/runtime/run tool interfaces/filesystem-snapshot snapshot.build --json \
  '{"root":".","state_dir":".octon/generated/effective/capabilities/filesystem-snapshots","set_current":true}'
```
