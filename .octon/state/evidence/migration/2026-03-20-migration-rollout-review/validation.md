# Validation

## Grep And Lineage Gates

- legacy `.proposals/**` references outside retained receipts and bundled
  resources: PASS (no live matches)
- numbered active architecture proposal directories: PASS (only
  `migration-rollout` is active under `inputs/exploratory/proposals/architecture/`)
- `repo_snapshot_minimal` references: PASS (no matches)
- repo-root adapter parity (`AGENTS.md`, `CLAUDE.md`, `.octon/AGENTS.md`):
  PASS
- proposal-registry and migration-index cross-reference audit: PASS
- archived ratified packet proposal presence check (1 through 14): PASS

## Validator And Test Gates

- `test-validate-root-manifest-profiles.sh`: PASS
- `test-validate-companion-manifests.sh`: PASS
- `test-validate-overlay-points.sh`: PASS
- `test-validate-repo-instance-boundary.sh`: PASS
- `test-validate-bootstrap-ingress.sh`: PASS
- `test-validate-raw-input-dependency-ban.sh`: PASS
- `test-validate-locality-registry.sh`: PASS
- `test-validate-locality-publication-state.sh`: PASS
- `test-validate-extension-publication-state.sh`: PASS after aligning the
  native-collision case to quarantine-first behavior
- `test-validate-capability-publication-state.sh`: PASS
- `test-validate-runtime-effective-state.sh`: PASS
- `test-export-harness.sh`: PASS

- `validate-root-manifest-profiles.sh`: PASS (`errors=0`)
- `validate-companion-manifests.sh`: PASS (`errors=0`)
- `validate-overlay-points.sh`: PASS (`errors=0`)
- `validate-repo-instance-boundary.sh`: PASS (`errors=0`)
- `validate-locality-registry.sh`: PASS (`errors=0`)
- `validate-continuity-memory.sh`: PASS (`errors=0 warnings=6`)
- `validate-raw-input-dependency-ban.sh`: PASS (`errors=0`)
- `validate-locality-publication-state.sh`: PASS (`errors=0`)
- `validate-extension-publication-state.sh`: PASS (`errors=0`)
- `validate-capability-publication-state.sh`: PASS after capability-routing
  republication (`errors=0`)
- `validate-runtime-effective-state.sh`: PASS after capability-routing
  republication (`errors=0`)
- `validate-export-profile-contract.sh`: PASS (`errors=0`)
- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/migration-rollout`: PASS (`errors=0 warnings=0`)
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/migration-rollout`: PASS (`errors=0`)
- `alignment-check.sh --profile harness`: PASS after an escalated rerun to
  refresh `.codex/**` host projections in this environment
- follow-up `test-validate-export-profile-contract.sh`: PASS after adding the
  runtime-effective coherence regression case
- follow-up `validate-export-profile-contract.sh`: PASS after republishing and
  validating capability routing inside the export-validation path
- follow-up `validate-capability-publication-state.sh`: PASS (`errors=0`)
- follow-up `validate-runtime-effective-state.sh`: PASS (`errors=0`)

## Self-Challenge Follow-Up

- The comprehensive self-challenge initially found a stale export-validation
  dependency: extension publication refreshes were not cascading into
  capability-routing publication.
- That gap is now closed by republishing and validating capability routing in
  both the export validator and the repo-snapshot validation path.

## Contract Assertions Verified

- `framework/**` and `instance/**` remain the only authored authority
  surfaces.
- `state/**` remains the operational-truth and retained-evidence class.
- `generated/**` remains rebuildable and non-authoritative.
- Packet 14 extension, locality, capability, and runtime-effective publication
  gates are all coherent in the live repository.
- `repo_snapshot` remains behaviorally complete and does not permit a v1
  minimal profile.
- The active Packet 15 proposal package now validates cleanly under the
  proposal standard.
- Packet 14 and Packet 15 discovery-index records now resolve from the
  canonical ADR and migration indices.

## Non-Blocking Warnings

- `validate-continuity-memory.sh` reported six warnings for empty retained run
  directories under `state/evidence/runs/**`; no contract error was raised.
- `alignment-check.sh --profile harness` reported two allowlisted historical
  framing warnings in ADRs 009 and 017; no active framing drift remained.
