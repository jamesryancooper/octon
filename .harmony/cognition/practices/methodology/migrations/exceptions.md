---
title: Clean-Break Migration Exceptions
description: Exception contract for rare cases where clean-break migration is infeasible due to external constraints.
---

# Exceptions to Clean-Break

## Default

Exceptions are not allowed unless explicitly approved by repository maintainers.

## What Qualifies

Exceptions are considered only when a clean-break is infeasible due to hard external constraints, such as a third-party contract that cannot be changed immediately.

## Exception Requirements (MUST)

Any approved exception must:

1. Be explicitly labeled `COMPATIBILITY EXCEPTION` in the migration plan.
2. Define a removal deadline (date or version) for compatibility behavior.
3. Include a deletion plan that explains how and when the shim or flag is removed.
4. Include CI checks that fail after the deadline if the exception remains.

## Strong Preference

If an exception cannot include a hard deadline, it should be rejected.

