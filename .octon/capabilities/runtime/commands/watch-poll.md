---
title: Watch Poll
description: Poll for filesystem changes using the filesystem-watch service.
access: agent
argument-hint: "[--root <path>] [--state-key <key>] [--max-events <n>] [--max-files <n>]"
---

# Watch Poll `/watch-poll`

Run `watch.poll` through the filesystem-watch service.

## Usage

```text
/watch-poll
/watch-poll --root . --state-key filesystem-watch:default --max-events 200
```

## Implementation

```bash
.octon/engine/runtime/run tool interfaces/filesystem-watch watch.poll --json \
  '{"root":".","state_key":"filesystem-watch:default","max_events":200,"max_files":50000}'
```
