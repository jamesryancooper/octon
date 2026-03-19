# Missions

`/.octon/instance/orchestration/missions/` is the canonical repo-instance home
for durable mission definitions and mission-scoped orchestration artifacts.

## Purpose

- keep repo-owned missions under the instance authority layer
- separate durable mission definitions from framework workflows and mutable
  continuity state
- provide one canonical registry and scaffolding surface for mission creation

## Layout

```text
.octon/instance/orchestration/missions/
  README.md
  registry.yml
  .archive/
  _scaffold/template/
    mission.yml
    mission.md
    tasks.json
    log.md
  <mission-id>/
    mission.yml
    mission.md
    tasks.json
    log.md
    context/
```

## Boundary Rules

- mission authority lives here under `instance/**`
- mission-local mutable execution evidence belongs under `state/**`
- framework workflows may create or complete missions, but they are not the
  authority surface for mission definitions
