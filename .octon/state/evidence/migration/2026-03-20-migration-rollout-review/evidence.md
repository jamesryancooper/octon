# Migration And Rollout Completion Review Evidence (2026-03-20)

## Scope

Repo-wide completion review implementing Packet 15 `migration-rollout`:

- correlate the ratified packet proposals 1 through 14, migration plans, ADRs,
  retained cutover bundles, and live canonical class-root surfaces
- execute the Packet 15 grep sweep for legacy path regressions, proposal-path
  drift, and shim misuse
- execute a cross-reference audit for proposal discovery and migration-record
  discovery
- execute live validators and regression coverage across manifest, locality,
  continuity, raw-input, publication, runtime-effective, export, proposal, and
  harness-alignment surfaces
- refresh stale capability routing publication when the review detects drift
  against the current extension publication
- backfill missing Packet 14 and Packet 15 discovery-index records so the
  retained evidence chain is complete

## Verdict

- `verdict`: PASS
- `severity_gate`: no open `CRITICAL` or `HIGH` findings remain after the
  comprehensive follow-up remediation
- `topology`: PASS
- `state sequencing`: PASS
- `input isolation`: PASS
- `snapshot/export integrity`: PASS
- `publication coherence`: PASS
- `legacy retirement`: PASS
- `rollback traceability`: PASS

## Findings Resolved During Review

### Capability Publication Staleness Found And Resolved Before Self-Challenge

The first live run of
`validate-capability-publication-state.sh`
failed because the current capability publication still referenced stale
extension catalog and extension generation-lock hashes.

Observed stale linkage before remediation:

- current extension catalog hash:
  `02f4cac694cd9095543abfa414f68b290f08d58064a5d71f7e78b4680089171f`
- capability-recorded extension catalog hash:
  `4ecc8c9c316e143a4d4529c1e1e81775f13e229ed069ed4f63338aab202a1bba`
- current extension generation-lock hash:
  `c0623224b67e79655f06d5d9075d25a8461fe90271ed2526faf8450de6e6de71`
- capability-recorded extension generation-lock hash:
  `8627b368db79ded9caa860213c4db5b57e7b78e0cc95dfc9452ff899559c0c99`

Resolution:

- rerun `publish-capability-routing.sh`
- final capability generation:
  `capabilities-e45cda38ebdc`
- final capability publication receipt:
  `/.octon/state/evidence/validation/publication/capabilities/2026-03-21T01-16-23Z-capabilities-e45cda38ebdc.yml`

That repair did make the live runtime-effective chain coherent, but only until
the later self-challenge reran the export-profile validator and exposed a
dependency gap in the export-validation path.

### Export-Profile Validation Side Effect

The comprehensive follow-up check proved that
`validate-export-profile-contract.sh`
and the `export-harness.sh` repo-snapshot validation path refreshed extension
publication without also republishing capability routing.

Resolution:

- update
  `/.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh`
  to:
  - require the capability publication validator
  - require the capability routing publisher
  - republish capability routing after extension publication refresh
  - validate capability publication immediately after that refresh
- update
  `/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`
  so `load_current_repo_snapshot_state()` republishes and validates capability
  routing after it republishes extension state
- add a regression case in
  `/.octon/framework/assurance/runtime/_ops/tests/test-validate-export-profile-contract.sh`
  that requires the export-profile validator to preserve runtime-effective
  coherence
- restore the executable bit on:
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
  - `/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`

Verification after remediation:

- `test-validate-export-profile-contract.sh`: PASS
- `validate-export-profile-contract.sh`: PASS
- `validate-capability-publication-state.sh`: PASS
- `validate-runtime-effective-state.sh`: PASS

### Packet 15 Proposal Validation Drift

The active Packet 15 proposal initially failed
`validate-proposal-standard.sh`
because its promotion target pointed at the full
`state/evidence/migration/` tree, which already contains historical retained
proposal-path references in older evidence bundles.

Resolution:

- narrow the promotion target to
  `/.octon/state/evidence/migration/README.md`
- rerun `validate-proposal-standard.sh --package ...`
- rerun `validate-architecture-proposal.sh --package ...`

### Packet 14 And Packet 15 Discovery-Index Gaps

The review found that the existing Packet 14 validation cutover and its ADR
file existed on disk but were missing from the canonical migration and ADR
discovery indices.

Resolution:

- add `2026-03-20-validation-fail-closed-quarantine-staleness-cutover` to
  `/.octon/instance/cognition/context/shared/migrations/index.yml`
- add
  `058-validation-fail-closed-quarantine-staleness-atomic-cutover.md`
  to `/.octon/instance/cognition/decisions/index.yml`
- add the new Packet 15 completion-review record and ADR to those same
  indices

### Extension Collision Assurance Drift

The review found one stale expectation in
`test-validate-extension-publication-state.sh`:
the test expected a native-command collision to make the final validator fail,
but the live publication pipeline already quarantines the colliding pack before
validating the published set.

Resolution:

- update the regression case to assert
  `native-capability-collision:command:native-command`
  is recorded in quarantine
- keep the final validator expectation green on the reduced coherent published
  set

## Non-Blocking Warnings

- `validate-continuity-memory.sh` reported empty run directories in
  `state/evidence/runs/**`; validation still completed with `errors=0`
- `alignment-check.sh --profile harness` reported two allowlisted historical
  framing tokens in:
  - `/.octon/instance/cognition/decisions/009-manifest-discovery-and-validation.md`
  - `/.octon/instance/cognition/decisions/017-assurance-clean-break-migration.md`

These warnings were treated as non-blocking because they do not change live
authority, runtime behavior, or policy precedence.

## Receipts And Evidence

- Governing proposal:
  `/.octon/inputs/exploratory/proposals/architecture/migration-rollout/`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-20-migration-rollout-review/plan.md`
- Closeout ADR:
  `/.octon/instance/cognition/decisions/059-migration-and-rollout-completion-review.md`
- Packet 15 bundle validation record: `validation.md`
- Packet 15 command log: `commands.md`
- Packet 15 inventory: `inventory.md`
