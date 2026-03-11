# Automation Authoring Standards

These standards govern canonical orchestration authoring under
`/.harmony/orchestration/runtime/automations/`.

## Scope

Applies to every automation unit, scaffold, validator, and authoring workflow
that creates or mutates automation definitions.

## Standards

1. Keep authority split explicit.
   - `automation.yml` owns identity, workflow target, owner, and lifecycle.
   - `trigger.yml` owns schedule or event selection.
   - `bindings.yml` owns defaults and event-to-parameter mapping.
   - `policy.yml` owns concurrency, idempotency, retry, and incident policy.
2. Keep trigger logic in `trigger.yml`.
   - Do not select events in `bindings.yml`, `policy.yml`, `registry.yml`, or
     prose.
3. Keep binding logic declarative.
   - Allowed binding roots are `event.<field>` and `event.payload.<field>`.
   - Required bindings must not declare defaults.
   - Arbitrary transforms, templating, or code execution do not belong in
     `bindings.yml`.
4. Keep policy complete.
   - Every automation must declare `max_concurrency`, `concurrency_mode`,
     `idempotency_strategy`, `retry_policy`, and `pause_on_error`.
5. Keep workflows free of recurrence.
   - Do not move scheduling or unattended-launch behavior back into workflows.
6. Keep state subordinate.
   - `state/` files may project current status and counters, but they must not
     outrank definition artifacts or linked decision and run evidence.

## Checklist

- [ ] `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml` exist.
- [ ] Trigger selection lives only in `trigger.yml`.
- [ ] Binding rules use canonical event paths only.
- [ ] Policy enforces explicit concurrency and idempotency.
- [ ] `state/` is subordinate to canonical definition artifacts.
