---
title: Bind Mission
description: Bind the planning pass to durable mission authority before any plan control state is created.
---

# Bind Mission

Planning may start only from durable mission authority, an approved mission
candidate, or an accepted proposal whose promotion requires mission-scoped
execution.

## Checks

1. Resolve `mission_id` to `/.octon/instance/orchestration/missions/**` or an
   approved mission candidate route.
2. Record mission ref, mission digest, owner ref, risk ceiling, allowed action
   classes, support-target tuple refs, scope ids, success criteria, and failure
   conditions.
3. Confirm the request does not start from chat, generated summaries, raw input
   files, or proposal-local analysis as runtime authority.
4. Confirm hierarchical planning is enabled or stage-only under
   `/.octon/instance/governance/policies/hierarchical-planning.yml`.

## Fail Closed

- Stop when mission authority is missing, stale, ambiguous, or unsupported.
- Stop when ownership, support-target refs, or approval requirements are
  unresolved.
- Stop when the requested plan would widen mission scope, risk ceiling, allowed
  action classes, support targets, or capability admission.
