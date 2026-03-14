---
title: Octon
description: Root overview for the Octon governed harness repository.
---

# Octon

Octon is a portable, agent-first engineering harness that turns a repository
into a governed autonomous engineering environment.

It is not primarily product code. Octon is the operating layer around a
codebase: it defines how agents bootstrap, what they can do, how work is
orchestrated, which actions require approval, and what evidence is required
before work is considered complete.

This repository is self-hosting: Octon is used here to evolve the Octon
harness itself with safe, reviewable, and verifiable changes.

## Core Model

- Portable harness: designed to be copied into other repositories.
- System-governed autonomy: contracts, policies, and workflows run by default.
- Deny-by-default control plane: consequential actions are fail-closed unless
  authorized.
- No silent apply: material side effects require explicit promotion and
  evidence.
- Continuity and assurance: logs, decisions, validation, and completion gates
  preserve traceability.

## Repository Layout

Most of the project lives under `.octon/`:

- [`.octon/agency/`](.octon/agency/) for agent personas, delegation, and
  governance contracts.
- [`.octon/capabilities/`](.octon/capabilities/) for commands, skills, tools,
  services, and policy operations.
- [`.octon/orchestration/`](.octon/orchestration/) for workflows, missions,
  watchers, and operating standards.
- [`.octon/cognition/`](.octon/cognition/) for principles, methodology,
  context, and architecture.
- [`.octon/continuity/`](.octon/continuity/) for tasks, logs, entities, and
  decision continuity across sessions.
- [`.octon/assurance/`](.octon/assurance/) for definition-of-done, validation,
  and release or completion gates.
- [`.octon/engine/`](.octon/engine/) for the executable runtime authority.
- [`.octon/output/`](.octon/output/) for generated reports, plans, and
  artifacts.

The human-led ideation area in [`.octon/ideation/`](.octon/ideation/) is
intentionally outside normal autonomous agent work unless explicitly scoped by
a human.

## Executable Runtime

Octon includes a real runtime, not just governance documents.

The runtime lives under [`.octon/engine/runtime/`](.octon/engine/runtime/) and
includes:

- launcher entrypoints in `run` and `run.cmd`
- the shared `octon` CLI
- the `octon-policy` policy engine
- a Studio host for visual workflow and operator surfaces
- Rust workspace crates such as `core`, `wasm_host`, `kernel`, `studio`,
  `assurance_tools`, and `policy_engine`

## Start Here

If you are new to the repo, start with:

- [`.octon/START.md`](.octon/START.md) for boot sequence and orientation.
- [`.octon/README.md`](.octon/README.md) for the shared harness overview.
- [`.octon/OBJECTIVE.md`](.octon/OBJECTIVE.md) for the current workspace goal.
- [`.octon/engine/runtime/README.md`](.octon/engine/runtime/README.md) for
  runtime entrypoints and operator surfaces.

## Quick Start

```bash
.octon/engine/runtime/run --help
.octon/engine/runtime/run studio
```
