---
title: ".octon Super-Root Architecture"
description: Class-first super-root architecture for Octon.
---

# `.octon/` Super-Root Architecture

## Purpose

Octon's top level is organized by artifact class, not by domain. This makes
authored authority, raw inputs, operational truth, and rebuildable outputs
explicit.

## Canonical Topology

```text
.octon/
  README.md
  AGENTS.md
  octon.yml
  framework/
  instance/
  inputs/
  state/
  generated/
```

## Meanings

- `framework/` is portable authored Octon core.
- `instance/` is repo-specific durable authored material.
- `inputs/` is non-authoritative additive and exploratory input.
- `state/` is mutable operational truth and retained evidence.
- `generated/` is rebuildable output only.

## Portability

`octon.yml` defines profile-driven portability. Do not copy the whole `.octon/`
tree as the default bootstrap model.

## Boundaries

- Raw `inputs/**` paths must never become direct runtime or policy
  dependencies.
- Human-led ideation is part of `inputs/exploratory/ideation/**`.
- Legacy mixed roots are not canonical and must not be reintroduced.
