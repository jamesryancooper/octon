# Cutover Checklist

This checklist operationalizes the closure work and evidence expectations from the [implementation audit](../resources/implementation-audit.md).

## Branch readiness

- [ ] Active and paused in-tree missions inventoried
- [ ] Missing scenario fixtures inventoried
- [ ] No-change zones explicitly preserved
- [ ] Target release locked to `0.6.3`
- [ ] No deferred-remediation assumptions remain in branch scope

## Pre-merge implementation

- [ ] Root manifest, architecture docs, runtime-vs-ops contract, and contract registry aligned
- [ ] Mission scaffold remains authority-only and uses canonical `owner_ref`
- [ ] Mission activation path seeds the full control family before active or paused runtime state
- [ ] Seeding path creates continuity stubs and emits mission-seed receipts
- [ ] Route publisher records route provenance and normalized precedence
- [ ] Evaluator consumes fresh route, current intent, and current slice
- [ ] Material autonomous work cannot fall back to generic `service.execute` behavior
- [ ] Signal and authorize-update handlers cover the full declared grammar
- [ ] Control receipts cover all required mutation classes
- [ ] Burn/breaker reducer recomputes state from retained evidence
- [ ] Summary, digest, and mission-view generators are wired for every active autonomous mission
- [ ] Active and paused missions in-tree are migrated to seed-complete state

## Pre-merge proof

- [ ] Root manifest target release updated to `0.6.3`
- [ ] `version.txt` updated to `0.6.3`
- [ ] Mission lifecycle rule documented as seed-before-active
- [ ] Mission activation tests prove seed-before-active is canonical
- [ ] Route publisher consumes the full authoritative input set
- [ ] Control receipts cover all required mutation classes
- [ ] Burn/breaker reducer is wired and tested
- [ ] Lifecycle, route, evidence, and scenario validators are present
- [ ] CI runs the full closeout suite
- [ ] Scenario fixtures cover all required mission classes and operator conditions
- [ ] Generated outputs and evidence bundles are present for every active autonomous mission

## In-merge atomic checks

- [ ] No active mission is missing seeded control truth
- [ ] No active material autonomous mission lacks slice-linked intent
- [ ] No active mission has an unlinked or stale route
- [ ] No control mutation lacks a retained control receipt
- [ ] No generated mission output lacks source citations
- [ ] No generated summary claims unsupported control or evidence state
- [ ] No runtime path still depends on legacy `owner`
- [ ] No docs describe roots or behaviors that differ from runtime and validation

## Post-merge ratification

- [ ] Completion decision written under canonical cognition decisions
- [ ] Migration evidence written under canonical migration roots
- [ ] Previous steady-state packet archived
- [ ] This packet archived after promotion
- [ ] `0.6.3` tagged as the MSRAOM closeout release
- [ ] MSRAOM treated as complete steady-state architecture going forward
