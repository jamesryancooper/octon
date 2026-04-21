# Validation Plan

## Existing validators to run

- proposal standard validator;
- architecture proposal subtype validator;
- architecture conformance validator;
- overlay-points validator;
- proposal registry generation validator;
- support-target review validator;
- runtime-effective state validator;
- mission runtime/source-of-truth validators where run/mission surfaces are touched;
- service and skill validators where capability surfaces are touched.

## New validators to add

| Validator | Required proof |
|---|---|
| `validate-fail-closed-obligation-ids.sh` | Unique, stable FCR IDs with no duplicates. |
| `validate-evidence-obligation-ids.sh` | Unique, stable EVI IDs with no duplicates. |
| `validate-material-side-effect-inventory.sh` | Every material side-effect class has owner, root, risk, and required boundary. |
| `validate-authorization-boundary-coverage.sh` | Every material command/service/workflow/publication path maps to a request builder, authorization call, grant/denial path, and tests. |
| `validate-generated-effective-freshness.sh` | Runtime-facing generated/effective outputs have retained publication receipts and freshness artifacts. |
| `validate-proof-bundle-completeness.sh` | Run/support proof bundles contain authority, lifecycle, replay, disclosure, evidence-classification, and negative-control evidence. |
| `validate-active-doc-hygiene.sh` | Active docs contain no proposal-path dependencies, historical wave chronology, or conflicting projection semantics. |
| `validate-compatibility-retirement.sh` | Transitional projections have owner, consumer, canonical replacement, expiry, and retirement evidence. |

## Negative-control tests

- generated artifact presented as authority must deny;
- raw input as direct policy dependency must deny;
- host label/comment/check as authority must deny;
- unmediated repo mutation must deny;
- stale generated/effective runtime input must deny or stage-only per policy;
- live support claim without support proof bundle must deny;
- run closeout without evidence completeness receipt must stage-only;
- compatibility projection without owner/expiry must fail validation.

## Runtime smoke tests

- `octon info` still resolves root, octon dir, run evidence root, execution control root, tmp root, OS/arch, and services;
- `octon run start --contract <sample>` invokes request builder and authorization boundary;
- `octon run inspect --run-id <id>` reads canonical run artifacts;
- `octon workflow run <id>` redirects or fails closed into run-first semantics;
- `octon orchestration summary --surface all` remains read-only.

## Evidence requirements

All validation outputs for this transition must be retained under:

`/.octon/state/evidence/validation/architecture-target-state-transition/**`
