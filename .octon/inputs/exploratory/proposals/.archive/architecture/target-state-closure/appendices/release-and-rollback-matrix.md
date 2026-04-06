# Release and Rollback Matrix

## 1. Release states

| State | Meaning | Claim-bearing? | Reversible? |
|---|---|---:|---:|
| candidate-shadow | pre-cutover shadow bundle | No | Yes |
| candidate-pass1 | first certification pass complete | No | Yes |
| candidate-pass2 | second certification pass complete | No | Yes |
| active-certified | active release pointer promoted | Yes | Yes, via pointer rollback |
| invalidated | previously active release invalidated by drift/contradiction | No | N/A |
| superseded | replaced by later active release | No | N/A |

## 2. Promotion conditions

| Transition | Preconditions | Blocking failures |
|---|---|---|
| candidate-shadow → candidate-pass1 | all validators run, all required artifacts generated | any gate failure |
| candidate-pass1 → candidate-pass2 | clean regeneration, identical candidate inputs | any gate failure or bundle divergence |
| candidate-pass2 → active-certified | dual-pass equivalence, closure certificate written, governance signoff | any divergence, missing certificate, failed parity |
| active-certified → superseded | later active release certified | none, but lineage must update |
| active-certified → invalidated | drift/contradiction/invalidator detected | immediate |

## 3. Rollback matrix

| Failure point | Rollback action | Data retained | User-visible effect |
|---|---|---|---|
| pre-cutover shadow validation failure | discard candidate | candidate artifacts | none |
| pass1 failure | discard candidate | candidate artifacts + reports | none |
| pass2 divergence | discard candidate | both candidate bundles + diff report | none |
| post-promotion parity failure | revert active release pointer, regenerate mirrors from previous active bundle | failed bundle retained as historical evidence | live claim reverts immediately |
| drift discovered after promotion | invalidate active release, possibly revert to previous certified release if still valid | invalidation report retained | live claim withdrawn or reverted |

## 4. Release bundle freshness cases

| Change | Requires recertification? | Why |
|---|---:|---|
| charter change | Yes | constitutional meaning changed |
| support-target matrix change | Yes | support claim changed |
| adapter contract change | Yes | runtime/support behavior changed |
| proof-bundle exemplar replacement | Yes | evidence basis changed |
| wording-only mirror edit | Disallowed | mirrors are generated only |
| hidden-check policy change | Yes | benchmark validity changed |

## 5. Final acceptance signal

A release is active and valid only when:
- active pointer references `active-certified`
- no invalidator exists
- stable mirrors are parity-valid
- current release bundle freshness passes
- closure certificate remains in force
