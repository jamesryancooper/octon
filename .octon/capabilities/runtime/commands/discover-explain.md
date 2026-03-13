---
title: Discover Explain
description: Explain candidate relevance and provenance for progressive discovery.
access: agent
argument-hint: "--query <text> --candidate-node-ids '<json-array>'"
---

# Discover Explain `/discover-explain`

Run `discover.explain` through the filesystem-discovery query plane.

```bash
.octon/engine/runtime/run tool interfaces/filesystem-discovery discover.explain --json \
  '{"query":"<text>","candidate_node_ids":["file:.octon/START.md"]}'
```
