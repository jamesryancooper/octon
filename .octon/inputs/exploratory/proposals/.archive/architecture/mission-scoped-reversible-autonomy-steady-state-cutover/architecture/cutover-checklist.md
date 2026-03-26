# Cutover Checklist

## Pre-Merge

- [ ] Confirm the repo baseline is `0.6.0`
- [ ] Create one integration branch for the full cutover
- [ ] Freeze any unrelated mission-autonomy refactors
- [ ] Promote a decision record and migration plan stub under canonical roots

## Release And Ratification

- [ ] Bump `version.txt` to `0.6.1`
- [ ] Bump `.octon/octon.yml` `release_version` to `0.6.1`
- [ ] Update `.octon/README.md`
- [ ] Update architecture specification
- [ ] Update runtime-vs-ops contract
- [ ] Update contract registry
- [ ] Record this packet as superseding the prior completion-cutover packet

## Mission Scaffolding And Readers

- [ ] Keep the authored mission scaffold limited to mission-authority files
- [ ] Extend the seed path to create the full control-file family immediately
      after mission creation
- [ ] Add `authorize-updates.yml` and `action-slices/` to the seeded control
      family
- [ ] Update create-mission flow to auto-seed control state, route outputs, and
      generated views
- [ ] Update all readers to use `owner_ref`
- [ ] Migrate in-tree missions to the final scaffold/control family

## Contracts

- [ ] Tighten existing v1 contracts
- [ ] Add `authorize-update-v1.schema.json`
- [ ] Add `mission-view-v1.schema.json`
- [ ] Register every runtime-required contract
- [ ] Normalize breaker-state vocabulary

## Runtime And Scheduler

- [ ] Enforce non-empty intent and slice presence for material autonomous work
- [ ] Enforce non-generic route recovery for material autonomous work
- [ ] Wire `effective_scenario_resolution_ref`
- [ ] Wire schedule controls into scheduler behavior
- [ ] Wire directives into runtime behavior
- [ ] Wire authorize-updates into runtime behavior
- [ ] Wire burn and breaker state into route and evaluator behavior
- [ ] Wire late-feedback finalize blocking
- [ ] Ensure observe-family operate behavior forks a bounded operate sub-mission

## Generated Effective Route

- [ ] Normalize route taxonomy
- [ ] Distinguish `mission_class` and `effective_scenario_family`
- [ ] Emit route reason codes
- [ ] Emit route freshness TTL
- [ ] Ensure route generation is triggered by all relevant control mutations

## Read Models And Evidence

- [ ] Materialize `Now / Next / Recent / Recover` for all active missions
- [ ] Materialize operator digests for all routed recipients
- [ ] Materialize `mission-view.yml` for all active missions
- [ ] Emit control receipts for every required mutation class
- [ ] Keep run evidence and control evidence separate

## Validation And CI

- [ ] Add / update version-parity validator
- [ ] Add / update all required validators
- [ ] Add / update scenario suite
- [ ] Wire validators and scenario suite into blocking CI
- [ ] Prove branch-protection-required checks are correct

## Release Proof

- [ ] Generate release evidence bundle
- [ ] Verify all acceptance criteria are satisfied
- [ ] Archive prior completion-cutover packet
- [ ] Merge the integration branch
- [ ] Tag or otherwise record `0.6.1`

## Post-Merge

- [ ] Re-run validators on `main`
- [ ] Confirm no active mission lacks summaries, digests, projections, or
      route linkage
- [ ] Confirm no doc or bootstrap path still describes the old incomplete
      state
- [ ] Archive this packet after promotion evidence is durable
