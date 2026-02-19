---
title: Deny by Default
description: Agents and systems have no permissions until explicitly granted. Security through explicit allowlists, not blocklists.
pillar: Trust
status: Active
---

# Deny by Default

> Agents and systems have no permissions until explicitly granted. Start with zero access; add only what is needed.

## Purpose

Deny by default means Harmony grants **no operational permissions** unless they are
explicitly allowlisted. Any missing, unknown, ambiguous, or unevaluable permission
decision **must fail closed**.

This principle applies to:

- tool access
- filesystem writes
- network access
- service capability grants
- exception handling and temporary elevation

Deny-by-default is the foundation that makes **autonomous operation safe**: agents
can run without constant supervision because their authority is explicit, scoped,
and auditable.

## What Changed with Reversible Autonomy

Harmony previously used *manual review gates* as a primary governance mechanism for
material side effects. Under **Reversible Autonomy with Human-on-the-Loop
Oversight**, deny-by-default remains the baseline, and **ACP policy evaluation is
the runtime dependency for promotion decisions**.

Instead:

- **Deny-by-default** governs *capabilities* (what an actor can attempt).
- **Autonomous Control Points (ACPs)** govern *change promotion* (what can become
  durable) using **reversibility, evidence, budgets, and quorum**.

Humans are approached only when:

- the agent quorum cannot reach a resolution,
- an action crosses a configured risk threshold, or
- after completion (digest/receipt), for optional review or rollback.

See: `autonomous-control-points.md`.

## Enforced Model in Harmony

Harmony enforces deny-by-default through a shared, deterministic control plane:

### 1) Policy Contract Layer

- The canonical policy contract is versioned and stored in-repo.
- Defaults are deny; explicit allowlists define what is permitted.
- Exception leases and kill-switches are tracked as state and validated in CI.

### 2) Decision Engine Layer (Single Source of Truth)

A shared decision engine evaluates policy for:

- validators (CI and local)
- runtime wrappers
- agent execution wrappers

The engine produces **machine-readable allow/deny payloads** with stable reason codes.
All failures (parse, schema, evaluation, IO) are **deny**.

### 3) Enforcement Parity (Validation + Runtime)

Deny-by-default must be enforced:

- **before execution** (preflight)
- **at execution time** (runtime gate)
- **in CI** (cannot merge unsafe artifacts)

Any lane that is not enforceable at runtime is treated as untrusted and must be
downgraded (e.g., stage-only).

## Permission Vocabulary

Harmony uses allowlisted tokens such as:

- `Read`, `Glob`, `Grep`, `Edit`
- `Write(<scoped-path>)` with explicit path scope only
- `Bash(<scoped-command>)` with explicit command scope only
- `WebFetch`, `WebSearch`, `Task`, and approved packs

Rules:

- Bare `Bash` and bare `Write` are prohibited for active skills and services.
- Broad write scopes (for example, workspace-root recursive globs) require a
  time-boxed exception lease.
- Unknown tools are denied.

## Fail-Closed Requirements

Any of the following must return deny and stop execution:

- missing policy data
- unknown tool token or malformed scope
- path/command scope mismatch
- capability required but not granted
- expired or missing exception metadata
- evaluation, schema, or enforcement errors

No permissive fallback is allowed.

## Exception Protocol (Time-Boxed Elevation)

Temporary elevation is allowed only when all fields are present:

- `id`
- `scope` (`skill` or `service` or `agent`)
- `target`
- `rule`
- `owner`
- `reason`
- `created`
- `expires`

Exception leases must be stored in a tracked policy file, validated in CI, and
rejected when expired. Permanent broad permissions are not allowed.

**Reversible Autonomy extension:** exceptions may also be used to temporarily raise
budgets or widen scopes **only when the action remains reversible**. Exceptions
must never be used to bypass irreversibility blocks.

## Autonomy Profiles (Least-Privilege by Default)

To keep long agent runs low-friction, Harmony groups common allowlists into
**profiles**. Profiles are:

- explicit, versioned, reviewable
- scoped to actor type (agent vs service vs skill)
- bounded by budgets and ACP ceilings

Examples:

- `observe` (read-only)
- `iterate` (reversible local changes, tests, branch commits)
- `operate` (stateful changes with canary + rollback proof + quorum)
- `emergency` (break-glass; time-boxed; highest audit burden)

Profiles reduce day-to-day friction without weakening deny-by-default.

## Boundary with ACPs

Deny-by-default answers: **“May this actor attempt this capability?”**

ACP answers: **“May this staged change be promoted to durable state?”**

Promotion criteria are defined in ACP, not in this document.
See: [Autonomous Control Points](./autonomous-control-points.md).

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
This principle governs capability attempts; ACP governs promotion.

## Development Speed Guidance

Deny-by-default should not block normal low-risk iteration. Harmony uses:

- low-risk profiles with pre-scoped safe defaults
- precise denial diagnostics that point to exact remediation
- short-lived exception leases instead of permanent broad access
- stage-only fallbacks that still produce useful artifacts (diffs, plans, receipts)

This keeps individual edits fast while retaining repository-level safety.

## Anti-Patterns

- blocklist-first policy
- unscoped `Bash` or `Write`
- broad workspace write grants without expiry
- fail-open error handling
- policy docs that diverge from enforceable behavior
- using manual review as a substitute for reversibility, evidence, and budgets

## Related Documentation

- [Trust Pillar](../pillars/trust.md)
- [Autonomous Control Points](./autonomous-control-points.md)
- [Skills Specification](../../capabilities/_meta/architecture/specification.md)
- [Runtime Policy](../_meta/architecture/runtime-policy.md)
- [ADR 019](../decisions/019-deny-by-default-uniform-enforcement-and-agent-only-operation.md)
