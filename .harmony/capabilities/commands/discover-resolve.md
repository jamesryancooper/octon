---
title: Discover Resolve
description: Resolve a discovered node back to file path.
access: human
argument-hint: "--node-id <node-id>"
---

# Discover Resolve `/discover-resolve`

Run `discover.resolve` through the filesystem-discovery query plane.

```bash
.harmony/runtime/run tool interfaces/filesystem-discovery discover.resolve --json \
  '{"node_id":"file:.harmony/START.md"}'
```
