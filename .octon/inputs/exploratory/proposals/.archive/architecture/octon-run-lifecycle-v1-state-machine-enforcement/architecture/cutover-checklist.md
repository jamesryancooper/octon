# Cutover Checklist

Reviewed on 2026-04-24 against the current shared worktree. Checked items are
observed as implemented or validated. This checklist remains proposal-local
lineage and does not promote this packet to authority.

## Before implementation

- [x] Confirm Run Journal v1 implementation is present.
- [x] Confirm Authorized Effect Token enforcement is present.
- [x] Confirm Context Pack Builder v1 implementation is present.
- [x] Confirm `run-lifecycle-v1.md` remains the target transition contract.
- [x] Confirm no support-target expansion is in scope.

## During implementation

- [x] Add lifecycle transition and reconstruction schemas.
- [x] Implement lifecycle reconstruction from journal.
- [x] Implement transition validation and fail-closed reason codes.
- [x] Route runtime operations through transition gate.
- [x] Route CLI run commands through transition gate.
- [x] Add closeout validator.
- [x] Harden raw `runtime_bus::append_event` against fake closeout refs,
  unresolved risks, non-stage-only staged routing, and absolute generated/input
  refs.
- [x] Confirm unknown lifecycle states fail closed in runtime tests and
  assurance fixtures.
- [x] Add positive and negative fixtures.
- [x] Add assurance validator and tests.

## Before promotion

- [x] Run lifecycle tests locally.
- [x] Run packet checksum validation.
- [x] Generate retained validation evidence.
- [x] Confirm generated projections are derived-only.
- [x] Confirm support-target declarations are unchanged except proof refs if explicitly required.
- [x] Confirm no runtime code reads from this proposal path.
- [x] Confirm raw append bypass controls are covered by Rust and assurance
  fixtures.
- [x] Confirm active UEC certification tooling verifies existing runtime-owned
  journals and does not synthesize `events.ndjson` or `events.manifest.yml`.
- [x] Confirm active UEC certification tooling verifies auxiliary evidence
  read-only and writes only caller-provided certification outputs.
- [x] Confirm the static run-journal append-boundary guard passes.
- [x] Confirm rerunning the required validation stack after staging leaves
  `git diff --name-only` empty.

## After promotion

- [x] Archive this packet or mark as historical lineage.
- [x] Regenerate generated proposal registry if the repo workflow expects it.
- [ ] Regenerate operator/read-model projections from canonical state.
- [ ] Retain closeout evidence outside proposal tree.
