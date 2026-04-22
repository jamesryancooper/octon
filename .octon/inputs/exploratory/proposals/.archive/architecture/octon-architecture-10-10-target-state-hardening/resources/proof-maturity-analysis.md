# Proof Maturity Analysis

## Current proof posture

Octon has strong proof-plane declarations: evidence obligations, retained evidence
roots, lab, observability, maintainability, validation scripts, support dossiers,
and runtime specs. This is architecturally strong but not automatically
closure-grade.

## Target proof posture

Every live claim must be backed by:

- retained run evidence;
- authorization decision and grant bundle;
- execution receipt;
- evidence classification;
- replay bundle;
- disclosure artifact;
- support tuple proof bundle;
- negative-control evidence;
- validator output;
- freshness/publication receipt when generated/effective output is involved.

## Proof maturity levels

| Level | Meaning | Current Octon posture |
| --- | --- | --- |
| L0 | Assertion only | Not acceptable. |
| L1 | Documented contract | Strong in many areas. |
| L2 | Validator exists | Present for many surfaces. |
| L3 | Negative controls exist | Partial; target requires full set. |
| L4 | Runtime emitted evidence exists | Emerging; must be broadened. |
| L5 | Closure-grade proof bundle exists | Target state. |

## Required target artifacts

- `SupportCard`: support claim, tuple, exclusions, proof refs.
- `HarnessCard`: system-level support/evaluation disclosure.
- `RunCard`: per-run intent, authority, support, tools, evidence, result.
- `DenialBundle`: reason-code-backed block/stage proof.
- `ReplayBundle`: replay pointers and reconstruction data.
- `RecoveryBundle`: rollback/recovery demonstration.
- `ProofCompletenessReport`: links obligations to evidence refs.

## Non-closure condition

A proof claim that cites only a proposal, generated summary, or dossier without
retained evidence is not closure-grade.
