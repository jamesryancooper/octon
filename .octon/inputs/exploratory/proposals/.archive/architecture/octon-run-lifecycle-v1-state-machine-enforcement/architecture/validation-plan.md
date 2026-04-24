# Validation Plan

## Current validation status

Reviewed on 2026-04-24. The validation plan has an implemented durable
validator and retained evidence outside this proposal packet:

- validator:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh`
- append-boundary guard:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-append-boundary.sh`
- regression harness:
  `.octon/framework/assurance/runtime/_ops/tests/test-run-lifecycle-v1.sh`
- fixtures:
  `.octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/**`
- retained reports:
  `.octon/state/evidence/validation/assurance/run-lifecycle-v1/validation-report.{md,yml}`

The retained report records `status: pass`. This proposal-local status note is
non-authoritative and promotion-safe; canonical validation evidence remains
under `.octon/state/evidence/**`. The retained lifecycle report writer is
idempotent for unchanged semantic validation output, and the UEC certification
pass verifies existing journals and auxiliary evidence read-only so promotion
validation reruns do not mutate tracked files.

Current coverage includes 19 lifecycle fixtures: valid closeout, pause/resume,
denial closeout, `bound -> staged` stage-only routing, `authorized -> staged`
downgrade routing, rollback closeout, invalid direct running, missing
stage-only authority, non-stage-only staged routing, missing grant,
runtime-state drift, incomplete closeout, fake closeout refs, unresolved
blocking risk, generated/read-model authority misuse including absolute
generated paths, effect-token use outside `running`, and unknown `created` or
`authorizing` lifecycle states. The retained report also records
`journal-append-boundary` coverage from the static guard that rejects active
durable direct writers to canonical control journal files outside runtime_bus.

## Validator objectives

The lifecycle validator must prove:

1. every Run has canonical run roots before consequential transitions;
2. `events.ndjson` and `events.manifest.yml` are the canonical transition record;
3. `runtime-state.yml` is reconstructable from the journal;
4. invalid transitions fail closed;
5. effect-token consumption only occurs in valid states;
6. context-pack binding and freshness participate before authorization/resume;
7. closeout requires evidence completeness and journal snapshot linkage;
8. generated/read models never determine lifecycle authority.
9. active durable assurance/governance scripts do not create or rewrite
   canonical control journals outside the runtime-owned append path.

## Required checks

| Check | Positive expectation | Negative expectation |
|---|---|---|
| Journal reconstruction | Reconstruct terminal state from events. | Missing, reordered, or hash-broken events fail. |
| Runtime-state drift | `runtime-state.yml` matches reconstructed state. | Mismatch blocks consequential transition. |
| Transition legality | Allowed edge advances state. | Forbidden edge fails closed. |
| Authority preconditions | `authorized` requires decision artifact and grant. | Missing grant denies transition. |
| Context preconditions | Context pack receipt/hash valid before authorization. | Missing/stale/mismatched pack blocks. |
| Token preconditions | Material effects require valid token in `running`. | Token consumption outside scope/state rejects. |
| Pause/resume | Pause happens at safe interrupt; resume validates current grant/context. | Resume with expired grant or stale context fails. |
| Rollback | Failed/revoked can roll back only with rollback evidence. | Rollback without evidence fails. |
| Closeout | Closed requires evidence bundle, disclosure, rollback posture, snapshot, review disposition, and risk disposition. | Missing any required artifact or unresolved blocking risk blocks closure. |
| Generated non-authority | Operator view mirrors lifecycle. | Operator view cannot create or repair lifecycle state. |
| Journal append boundary | Runtime bus remains the only active canonical journal append path. | Shell redirection, truncation, or direct file write to control `events.*` outside runtime bus fails validation. |

## Validator artifacts

- `validate-run-lifecycle-v1.sh`
- `validate-run-journal-append-boundary.sh`
- `test-run-lifecycle-v1.sh`
- fixtures under `fixtures/run-lifecycle-v1/`
- retained reports under `.octon/state/evidence/validation/assurance/run-lifecycle-v1/`

## CI posture

The implemented assurance suite now points
`.octon/framework/assurance/functional/suites/run-lifecycle-integrity.yml` at
the lifecycle validator. Promotion/archive review should confirm the suite is
wired into any intended blocking CI entrypoint before live support claims cite
it as a release gate.
