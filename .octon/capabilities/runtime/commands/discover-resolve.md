---
title: Discover Resolve
description: Resolve a discovered node back to file path.
access: agent
argument-hint: "--node-id <node-id>"
---

# Discover Resolve `/discover-resolve`

Run `discover.resolve` through the filesystem-discovery query plane.

```bash
.octon/engine/runtime/run tool interfaces/filesystem-discovery discover.resolve --json \
  '{"node_id":"file:.octon/START.md"}'
```
