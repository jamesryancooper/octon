# Migration and Cutover Plan

## Cutover stance

This is an enforcement hardening cutover, not a support-universe expansion. The safest path is staged activation behind validators, then fail-closed enforcement for consequential Runs.

## Current cutover posture

As of 2026-04-24, the enforcement hardening is implemented in durable
runtime/spec/assurance/lab surfaces with retained validation evidence. The
closure pass hardened the canonical `runtime_bus` append boundary against fake
closeout refs, unresolved risks, non-stage-only staged routing, and relative or
absolute generated/input governing refs. Assurance fixtures also cover unknown
`created` and `authorizing` lifecycle states as fail-closed controls. The final
closure pass also removed active UEC certification journal and auxiliary
evidence repair, added a static append-boundary guard so durable scripts cannot
directly write canonical control journals outside runtime_bus, and made
retained lifecycle validation report writing idempotent for unchanged semantic
results. No support-target widening was observed. This packet records closure
posture only; promotion/archive must still be handled by the canonical
workflow, and this proposal path must remain non-authoritative.

## Compatibility posture

- `runtime-event-v1` dot-named events remain compatibility aliases only.
- Canonical lifecycle enforcement must use normalized hyphenated journal events.
- Existing historical runs may be treated as legacy evidence and should not be retroactively promoted as fully lifecycle-conformant unless reconstruction succeeds.
- `runtime-state.yml` files created before cutover may be rebuilt from journal when possible; otherwise mark as legacy/incomplete.

## Cutover sequence

1. Add lifecycle schemas and validator in non-blocking report mode.
2. Run validator against fixtures and any available current run roots.
3. Fix reconstruction or event-normalization gaps.
4. Enable blocking mode for newly created consequential Runs.
5. Keep legacy runs readable but not claim-bearing unless lifecycle reconstruction evidence exists.
6. Add closeout gate enforcement for new runs.
7. Require raw append bypass controls to pass in Rust and assurance fixtures.
8. Require the static append-boundary guard to pass before promotion.
9. Update support-target proof bundles to cite lifecycle reconstruction evidence once available.

## Rollback plan

If lifecycle enforcement blocks valid work due to implementation defect:

1. keep the journal immutable;
2. disable new enforcement only through an explicit governance exception or stage-only fallback;
3. retain the failed validator output under evidence;
4. patch the validator or transition map;
5. replay affected runs in dry-run mode before restoring live enforcement.

Do not roll back by allowing runtime operations to bypass journal, effect-token, or context-pack requirements.

## Rollback posture after implementation

- Rollback is governance-controlled and evidence-preserving.
- The canonical journal remains append-only and must not be rewritten.
- Retained validation failures should land under
  `.octon/state/evidence/validation/assurance/run-lifecycle-v1/**` or the
  affected run evidence root.
- Proposal-local docs may be updated to record rollback rationale, but runtime
  behavior must never depend on this packet.
