# Architecture Health Contract

## Purpose

Define the target-state single health gate that determines whether Octon's
architecture is structurally coherent, runtime-enforced, proof-backed, and
promotion-safe after this proposal lands.

## New target command

```bash
octon doctor --architecture
```

or, until wired into the Rust CLI:

```bash
.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh
```

## Health contract domains

| Domain | Required validation |
| --- | --- |
| Class-root placement | No authored authority under `state/**`, `generated/**`, or `inputs/**`; no generated outputs under `framework/**` or `instance/**`. |
| Registry integrity | Contract registry, root manifest, overlay registry, instance manifest, ingress manifest, decisions index, and retirement register exist and agree. |
| Root manifest | `octon.yml` class roots, profiles, runtime inputs, generated commit defaults, receipt roots, and executor profile refs are valid. |
| Overlay legality | Instance overlays appear only at declared and enabled overlay points. |
| Runtime authorization | Every material side-effect class has coverage entry, request builder, grant/receipt refs, negative controls, and tests. |
| Run lifecycle | Every transition has required control roots, rollback posture, receipts, evidence, disclosure, and operator-visible state. |
| Support claims | Every live tuple has partitioned admission, dossier, proof bundle, negative-control evidence, support card, and disclosure coverage. |
| Pack admission | Live runtime pack admissions align with framework pack contracts, support targets, and runtime routing. |
| Extension publication | Raw additive inputs, desired selection, active/quarantine state, generated/effective outputs, receipts, and freshness agree. |
| Generated/effective freshness | Runtime-facing generated outputs have current receipts; stale outputs fail closed. |
| Generated cognition | Operator/read-model projections carry source traceability and freshness metadata and do not route runtime authority. |
| Proof planes | Structural, behavioral, governance, maintainability, recovery, and runtime enforcement proof planes have retained artifacts for live claims. |
| Compatibility retirement | Every compatibility shim has owner, successor, review cadence, and retirement trigger. |
| Operator boot | Ingress manifest is concise; closeout/branch logic is delegated; mandatory read order is valid. |
| Deployment practicality | Runtime build/install/doctor path exists; fixtures cover first-run lifecycle. |

## Required outputs

The health command must emit:

- machine-readable JSON summary;
- markdown operator summary;
- per-domain pass/fail results;
- retained validation evidence under `state/evidence/validation/**` when run in closure mode;
- denial/stage-only reason codes for failed gates.

## Fail-closed behavior

A failed health domain blocks:

- promotion of this packet to `accepted` or `implemented`;
- support claim widening;
- runtime-effective publication;
- live tuple disclosure;
- closing a consequential run that depends on the failed domain.

## Non-authority rule

Generated health summaries are read models. The canonical facts remain in the
registries, control roots, retained evidence, and validator outputs that the
summary cites.
