---
title: Runtime Policy
description: Contract enforcement, flags, rollback, and safe rollout practices to achieve speed with safety in production.
---

# Runtime Policy: Contract Enforcement, Rollback, and Feature Flags

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [runtime architecture](./runtime-architecture.md), [observability requirements](./observability-requirements.md), [knowledge plane](./knowledge-plane.md), [governance model](./governance-model.md), [tooling integration](./tooling-integration.md), [python runtime workspace](./python-runtime-workspace.md), [contracts registry](./contracts-registry.md)

**Purpose:** Define how services behave under abnormal runtime conditions, how we isolate and mitigate failures, and how we roll out and roll back changes safely. This policy enables speed with safety through strong contracts, reversible changes, and progressive delivery.

- **Audience:** service and platform developers, SRE/on‑call, release managers
- **Scope:** application services, integrations, deployment tooling, and runtime config

## Policy Goals

- **Fail‑closed:** default to safe behavior when uncertain or degraded.
- **Isolate and degrade:** contain faults to the smallest possible blast radius.
- **Be observable:** violations emit clear logs, traces, and metrics.
- **Prefer small, reversible changes:** frequent deploys make rollbacks trivial.

## Responsibilities

- **Developers:** implement runtime contracts, validation, fallbacks, and flag checks in services and flows.
- **Platform (including the platform runtime service):**
  - Provide circuit breakers, timeouts, auto‑rollback hooks, and flag runtime.
  - Enforce per‑caller and per‑environment limits (for example, timeouts, concurrency, and resource caps) within the platform runtime service.
  - Apply policy profiles (interactive, batch, Kaizen, CI‑only, etc.) based on caller metadata (`callerKind`, `callerId`, `projectId`, `environment`, and optional `riskTier`).
- **On‑call:** operate runbooks to flip flags, initiate rollback, and communicate status.

---

## Contract Enforcement at Runtime

Design by contract continues in production. Critical assumptions are enforced at runtime; violations are detected early, logged with context, and contained.

**Assertions and invariants:**

- Validate post‑conditions and invariants in critical paths (e.g., non‑negative totals).
- Non‑prod: prefer crash-fast to surface issues. Prod: handle gracefully, record violation, and return an explicit error.
- Every assertion failure must log an error with a trace ID and invariant name.

**Input validation at boundaries:**

- Validate all untrusted inputs (HTTP, file uploads, queues). Reject with appropriate status (e.g., 400) rather than proceeding with uncertain data.

**Security checks:**

- Require authentication and authorization context for every protected action.
- Missing or invalid auth context: abort the operation, log a security event, and do not attempt a best‑effort fallback.

**Resource contracts:**

- Enforce timeouts on external calls and expensive operations.
- Enforce concurrency limits where applicable to prevent resource starvation.

**Graceful degradation and isolation:**

- Use circuit breakers and bulkheads to isolate repeatedly failing dependencies.
- Degrade a single request or feature rather than the whole service.
- If a feature path guarded by a flag repeatedly violates an invariant or trips a circuit breaker, automatically disable that flag (fail‑closed) and alert on-call; record the action in the Knowledge Plane.

**Monitoring contracts (SLOs):**

- Treat key SLOs as runtime contracts. Example: order placement target 2s; if >5s, emit WARN and metric for breach and investigate. Do not abort successful user flows purely for latency unless required by business rules.

**Observability requirements:**

- Assertion or policy violations must emit: invariant name, request/trace ID, principal, affected feature flag(s), and safe summary context.
  Tie emitted trace IDs to PRs/builds for fast provenance and rollback decisions.

Example (pseudocode):

```ts
function placeOrder(input: OrderInput) {
  require(isValid(input), "invalid-order-input");

  const result = withTimeout(2000, () => gateway.charge(input.payment));

  assert(result.totalCents >= 0, "non-negative-total");

  if (!authz.can("place:order", ctx.user)) {
    audit.logSecurity("authz-denied", { user: ctx.userId, traceId: ctx.traceId });
    return err(403, "forbidden");
  }

  return ok(result);
}
```

---

## Rollback Strategy

If a deployment degrades reliability, we must return to a known‑good state quickly and safely.

**One‑click revert:**

- CI/CD supports re‑deploying the previous artifact or swapping traffic (blue/green).
- Keep releases small and frequent to minimize rollback scope.
- Prefer manual promote to production with a rehearsed instant rollback path when using preview deployments; practice promote/rollback regularly.

**Data migration strategy (expand/contract):**

- Favor additive, backward‑compatible changes first. Deploy code that reads/writes both schemas behind flags. Remove old paths only after safe cutover.
- Destructive changes require backups, explicit approvals, and a tested rollback plan.

**Automatic rollback triggers:**

- Configure signals that trigger rollback without human intervention in critical envs:
  - Error rate ≥ 5× baseline over 5m window
  - p95 latency ≥ 2× baseline over 5m window
- Rollback announcement is emitted to on‑call and team channels automatically.

**Rollback drills:**

- Practice deploy → verify → rollback in staging to validate tooling and build muscle memory.

**Configuration preservation:**

- Version infra and app config. Changes applied with releases must be reversible.

**Communication:**

- On rollback: notify on‑call, create incident record, and schedule post‑incident review.

Example configuration (conceptual):

```yaml
autoRollback:
  enabled: true
  triggers:
    - type: error_rate
      window: 5m
      condition: current >= 5x baseline
    - type: p95_latency
      window: 5m
      condition: current >= 2x baseline
  action: rollback_to_previous
  notify: ["#on-call", "#releases"]
```

---

## Feature Flag Strategy

Feature flags are the primary mechanism to decouple deploy from release, reduce blast radius, and provide instant mitigation.

**Principles (TS apps and Python runtimes):**

- Default off and fail‑closed. If flag resolution fails, prefer the safe path.
- Keep flags near decision points with clear, audited names.
- Clean up flags after stabilization to avoid long‑lived tech debt.
- Provider‑agnostic: any flag system that supports dynamic evaluation, audited changes, and deterministic defaults is acceptable. The normative contract is `flagClient.get(name, default)`; providers must not weaken fail‑closed behavior.
  - Integration note: Evaluate flags at the server boundary and propagate decisions inward. An Edge-backed provider is acceptable for low-latency evaluation while heavy/long-running work remains on Node runtimes or in Python flows. Flag decisions that affect Python agents or the **platform runtime service** (for example, the LangGraph-based flow runtime under `platform/runtimes/flow-runtime/**`) SHOULD be made in the TS control plane and passed into flows via runtime contracts and payloads.

**Types:**

- Release toggles: hide new functionality until ready for users.
- Kill switches: disable modules or integrations quickly (e.g., recommendations service).
- Ops/perf toggles: e.g., disable analytics under extreme load.
- Experiment flags: gradual exposure and A/B testing.

**Rollout stages:**

  1) Off in production after deploy; 2) internal/test users; 3) small percentage; 4) full rollout; 5) remove old path and delete flag.

**Runtime management:**

- Prefer dynamic flag backends (admin UI or hot‑reload config) over env‑only toggles.
- All flags changes are audited and observable.

**Contract interplay:**

- If an invariant breaches within a flag‑guarded path, auto‑disable that flag as a containment measure and alert on‑call (regardless of whether the path is exercised by a TS app or a Python flow).
- Contract test failures for externally published APIs (OpenAPI/JSON Schema in the `contracts/` registry) block rollout until resolved or explicitly waived via governance. TS and Python consumers must both remain compatible with the contracts defined in `contracts/openapi` and `contracts/schemas`.

## Runtime Policy for Platform Flows

Python flows executed by the **platform runtime service** (currently implemented as a LangGraph-based flow runtime under `platform/runtimes/flow-runtime/**`) follow the same runtime principles as TS apps, with additional guarantees:

- **Contracts‑first:** Any HTTP or external API surface exposed by the runtime (for example, `/flows/run`, `/flows/start`, `/flows/{runId}`) is defined as OpenAPI/JSON Schema in `contracts/openapi` and `contracts/schemas`, with TS and Python consumers using generated clients from `contracts/ts` and `contracts/py` (for example, `runtime-flows` clients). Callers do not import runtime internals directly.
- **Caller‑aware policies:** Every flow invocation includes caller metadata (`callerKind`, `callerId`, `projectId`, `environment`, optional `riskTier`). The runtime selects and enforces policy profiles (for example, interactive vs Kaizen vs CI) based on this metadata, applying timeouts, step/token limits, and concurrency caps per caller and environment.
- **Flags and isolation:** New or risky flows are guarded by feature flags; repeated invariant violations or circuit breaker trips on a flagged flow SHOULD automatically disable the flag via the control plane and alert on‑call.
- **Observability:** Flows emit OpenTelemetry traces/logs/metrics with W3C trace context, including standardized attributes such as `flow_id`, `flow_version`, `run_id`, `caller_kind`, `caller_id`, `project_id`, `environment`, and `risk_tier`, plus linkage back to PRs/builds via the Knowledge Plane correlation API (see `observability-requirements.md` and `runtime-architecture.md`).
- **Rollback:** If a new flow variant or configuration degrades reliability or correctness, roll back by:
  - Disabling the flag(s) controlling that flow.
  - Reverting the flow definition or code in the runtime implementation (for example, `platform/runtimes/flow-runtime/**`) via standard deploy/rollback procedures.
  - Adjusting policy profiles (for example, tightening limits for specific callers/environments) when warranted.

Examples (pseudocode):

```ts
if (flags.isEnabled("recommendations")) {
  showNewRecommendations();
} else {
  showBaseline();
}
```

Flag hygiene policy: review and retire stale flags regularly (e.g., older than 90 days) once the new path is the default.

References:

- [Harness: Are feature flags part of your rollback plan?](https://www.harness.io/blog/are-feature-flags-a-part-of-your-rollback-plan)
- [LaunchDarkly: What are feature flags?](https://launchdarkly.com/blog/what-are-feature-flags/)
- [Unleash: Feature flag best practices](https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices)

---

## Safe Deployment Practices

**Canary releases:**
Route a small slice of traffic to the new version and watch key metrics; expand if healthy, otherwise roll back or flag off.

**Blue/Green:**
Deploy to Blue while Green serves traffic; smoke test Blue; switch traffic; fall back if problems emerge.

**Dark launch:**
Ship code paths behind flags so deployment risk is decoupled from release risk.

**Circuit breakers:**
Trip on repeated dependency failures to prevent cascading outages; auto‑recover after cooldown.

---

Related docs: [observability requirements](./observability-requirements.md), [governance model](./governance-model.md), [knowledge plane](./knowledge-plane.md)

**Time‑based releases:**
Avoid peak load and low‑staff windows. Prefer morning releases with team available to monitor.

Observability gating
The Thin Control Plane ties deployment events, feature flags, and observability baselines together so that automated gates can halt, roll back, or disable flags deterministically when thresholds are breached.

- CI gates provide baseline quality; runtime gates (canary health, error/latency SLOs) determine progression or rollback.

---

## Operational Runbooks

**Toggle a feature:**

1) Identify flag and current scope (env, segment, %).
2) Flip to safe state (off) and verify reduced errors/latency.
3) Announce change and link trace/metric snapshots.

**Initiate rollback:**

1) Trigger pipeline rollback to previous artifact.
2) Verify smoke tests and golden paths.
3) Confirm metrics stabilize; create/post incident summary.

**Respond to contract breach:**

1) Inspect logs/traces for invariant name and context.
2) If feature‑scoped, disable related flag.
3) If dependency‑scoped, trip/adjust breaker and increase timeouts only if justified.
4) Open issue for root cause and add/adjust tests.

---

## Defaults and Thresholds

- **SLO example:** order placement p95 target 2s; WARN on >5s.
- **Auto‑rollback criteria:** error rate ≥ 5× baseline or p95 latency ≥ 2× baseline for 5m.
- **Circuit breaker example:** open after N consecutive failures; half‑open after cooldown.
- **Timeouts:** set per dependency based on p99 + margin; prefer explicit over infinite.

Teams may override with documented rationale; defaults apply otherwise.

---

## Summary

- Contracts detect and contain faults quickly and transparently.
- Rollbacks return systems to stability fast with minimal user impact.
- Feature flags decouple deploy from release and act as instant kill switches.

Together, these practices enable rapid delivery with strong safety guarantees and clear operational playbooks.
