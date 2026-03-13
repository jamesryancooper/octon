---
title: Discover Expand
description: Expand progressive discovery frontier by traversing graph neighbors.
access: agent
argument-hint: "--node-ids '<json-array>' [--limit <n>]"
---

# Discover Expand `/discover-expand`

Run `discover.expand` through the filesystem-discovery query plane.

```bash
.octon/engine/runtime/run tool interfaces/filesystem-discovery discover.expand --json \
  '{"node_ids":["file:.octon/START.md"],"limit":100}'
```
