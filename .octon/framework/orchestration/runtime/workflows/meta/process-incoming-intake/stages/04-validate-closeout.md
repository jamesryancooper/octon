# Validate Routing Closeout

Run the validation floor for the selected governed route and record the routing
stop point, target handoff, or fail-closed denial.

## Shared Validation

Run or justify fail-closed blockers:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-incoming-intake-routing.sh`
- route decision schema validation
- handoff schema validation when handoff context exists
- target-owned intake admission contract validation when handoff is requested
- lifecycle interaction request/return validation when target lifecycle
  interaction receipts are referenced

## Handoff Routes

Required closeout:

- evidence states handoff context is advisory and non-authorizing
- proposal packet or program admission contract validates
- target preflight result is retained when invoked
- target return refs are retained when produced
- intake does not claim implementation, Change closeout, worktree closeout,
  repo hygiene cleanup, or proposal archive completion without target-owned
  return evidence

## Blocked / Rejected / Deferred

Required closeout:

- evidence states no install, activation, publication, projection, or runtime
  exposure occurred
- denial evidence records the blocker and next condition
- retained copy is under input `.archive/<intake-id>/` only when needed and safe
- evidence-only retention is used when source material is unsafe to retain
- `.incoming/<intake-id>/` is absent only after final blocked disposition

## Shared Acceptance Criteria

- final status is one of `single-work-unit-handoff`,
  `coordinated-program-handoff`, or `blocked-rejected-deferred`; archive
  metadata may explain blocked, rejected, deferred, superseded, or historical
  handling without creating additional route outcomes
- `.incoming/<intake-id>/` is absent after final disposition; classification-only
  and advisory-handoff stops may leave raw intake in place when no final
  disposition was applied
- evidence records validation outcomes, route decision, handoff context,
  target-owned preflight or return refs, intake-envelope findings, payload
  inventory, and unresolved blockers
- no runtime, policy, generated, retained evidence, state/control, publication,
  extension-pack, skill, or host-projection surface depends on `.incoming/**` or
  `.archive/**`
