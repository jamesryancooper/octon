# Current-State Gap Map

This map distinguishes implemented reality from partial materialization and
target-state intent.

## Summary

Octon already has the major constitutional and runtime pieces required for
controlled autonomy: bounded support declarations, generated route bundles,
runtime authorization contracts, effect-token contracts, run lifecycle state,
evidence-store obligations, assurance scripts, and generated read-model rules.

The remaining gap is cross-surface closure. Support claims, authorization
enforcement, and operator visibility are each present in pieces, but the repo
does not yet have one material gate proving that they agree for every live
claim and material effect.

## Capability status

| Capability | Current status | Evidence in repo | Gap |
| --- | --- | --- | --- |
| Bounded support universe | Implemented and materially real | `.octon/instance/governance/support-targets.yml` declares bounded admitted finite support | Needs reconciliation against route, pack, matrix, cards, disclosure, and proof |
| Runtime-effective route bundle | Implemented generated/effective artifact | `.octon/generated/effective/runtime/route-bundle.yml` | Must be gated against support declarations and proof |
| Capability-pack routes | Implemented generated/effective artifact | `.octon/generated/effective/capabilities/pack-routes.effective.yml` | Current route posture can disagree with route bundle and support matrix |
| Support-target matrix | Implemented generated projection | `.octon/generated/effective/governance/support-target-matrix.yml` | Matrix can lag or omit claims; must not be treated as sole truth |
| Support proof/admission evidence | Partially implemented | `.octon/state/evidence/validation/support-targets/**` | Need freshness/completeness gate per live support claim |
| Execution authorization | Implemented core boundary | `execution-authorization-v1.md`, `authority_engine` | GrantBundle exists; typed effect-token consumption not universally visible |
| Authorized effect tokens | Partially implemented / emerging | `authorized-effect-token-v1.md`, `authorized_effects` crate | Runtime code and token struct need closure-grade fields, verifier, receipts, and negative proof |
| Boundary coverage validators | Partially implemented / emerging | `validate-authorization-boundary-coverage.sh`, token tests | Need hard end-to-end positive/negative proof for every material API path |
| Run lifecycle | Implemented contract and state pattern | `run-lifecycle-v1.md`, `state/control/execution/runs/**` | Needs run-health projection that summarizes health without minting authority |
| Evidence store | Implemented contract | `evidence-store-v1.md` | Need migration-specific evidence bundle and closure certification |
| Operator read models | Implemented principles; run-health not complete | `operator-read-models-v1.md` | Need per-run health schema/generator/validator/fixtures |

## Concrete mismatch motivating Phase 1

The current repo contains a high-value support truth mismatch that this migration
should make impossible to publish unnoticed:

| Surface | GitHub control-plane repo-consequential posture |
| --- | --- |
| Authored support-target declarations | live/admitted |
| Runtime route bundle | stage-only/non-live |
| Capability-pack routes | allow/admitted-live |
| Generated support-target matrix | not listed as supported |

A reconciler should not decide which artifact "wins" by convention. It should
emit a deterministic failure that names the mismatch and blocks live publication
or route activation until canonical authority, proof, generated handles, and
disclosures agree.

## What is not a current gap

This proposal does not claim Octon lacks governance. It already has strong
governance architecture. The gap is that the strongest enforcement and
operator-visibility guarantees are not yet closed end to end across all
material surfaces.
