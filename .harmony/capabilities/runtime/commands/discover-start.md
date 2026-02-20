---
title: Discover Start
description: Start progressive discovery for a query using the active snapshot.
access: human
argument-hint: "--query <text> [--limit <n>]"
---

# Discover Start `/discover-start`

Run `discover.start` through the filesystem-discovery query plane.

## Implementation

```bash
.harmony/runtime/run tool interfaces/filesystem-discovery discover.start --json \
  '{"query":"<text>","limit":20}'
```
