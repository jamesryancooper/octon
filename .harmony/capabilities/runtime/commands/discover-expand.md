---
title: Discover Expand
description: Expand progressive discovery frontier by traversing graph neighbors.
access: human
argument-hint: "--node-ids '<json-array>' [--limit <n>]"
---

# Discover Expand `/discover-expand`

Run `discover.expand` through the filesystem-discovery query plane.

```bash
.harmony/runtime/run tool interfaces/filesystem-discovery discover.expand --json \
  '{"node_ids":["file:.harmony/START.md"],"limit":100}'
```
