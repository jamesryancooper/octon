# Final Closure Certification Design

## 1. Required Evidence Bundle
The completion bundle must contain, at minimum:
- active `release-lineage.yml`
- active release `harness-card.yml`
- closure certificate
- closure gate status
- closure summary
- cross-artifact consistency report
- support-universe coverage report
- proof-plane coverage report
- projection parity report
- support-target canonicality report *(new)*
- authority purity report *(new)*
- disclosure wording report *(new)*
- stage-attempt canonicality report *(new)*
- blocker ledger *(new)*
- known-limits coherence report *(new)*
- recertification status and trigger log
- run cards for all exemplar runs cited by the active claim

## 2. Two-Pass Validation Regime
### Pass 1 — Semantic and structural correctness
- regenerate release bundle and closure projections from canonical authored surfaces,
- run the full validator suite,
- emit blocker ledger,
- require zero blockers,
- require no diff between generated claim-bearing bundle and committed canonical release bundle.

### Pass 2 — Idempotence and parity
- rerun bundle/projection generation from the post-pass-1 repo state,
- rerun parity / freshness / blocker-ledger checks,
- require byte-stable or defined semantic-stable results,
- require zero blockers again.

## 3. Validator Sufficiency Requirement
A complete claim is not publishable unless the sufficiency workflow proves that seeded versions of blocker classes A–E each fail the expected validator. This is the direct answer to blocker E.

## 4. Zero-Blocker Criteria
The generated blocker ledger is zero only when:
- no tuple mismatches exist,
- no authority purity leaks exist,
- no stale claim-envelope wording exists,
- no active non-v2 stage-attempt exists,
- and the validator suite itself has current sufficiency proof.

## 5. Truth-Condition Satisfaction Check
| Truth condition | Required evidence for closure |
|---|---|
| TC-01 constitutional-singularity | registry + shim/projection resolution report |
| TC-02 objective-hierarchy | workspace / mission / run binding report |
| TC-03 admitted-live-support-universe | support-target canonicality report + support-universe coverage |
| TC-04 canonical-authority | authority purity report + family linkage report |
| TC-05 durable-run-semantics | stage-attempt canonicality + run bundle completeness |
| TC-06 classed-evidence | evidence-classification completeness + external index linkage |
| TC-07 complete-proof | proof-plane coverage + evaluator independence |
| TC-08 claim-calibrated-disclosure | wording report + known-limits coherence + RunCards/HarnessCard |
| TC-09 closure-certification | two-pass clean status + blocker ledger zero |
| TC-10 recertification-discipline | valid recertification status + trigger log clear |

## 6. Recertification Trigger Model
Any material change to the following reopens the claim automatically:
- `support-targets.yml`
- `support-target-admissions/**`
- support dossiers that alter evidence of support
- run contract family / stage-attempt family
- authority family structure
- capability pack or adapter admissions
- disclosure wording policy / known-limits policy
- closure validators or closure workflows
- release coverage bundle or exemplar run set

When a trigger fires, the blocker ledger reopens and `claim_status: complete` is no longer valid until recertification passes.

## 7. Final Certification Stop Condition
The release is certifiable as an unqualified complete UEC **only** when:
- pass 1 clean,
- pass 2 clean,
- sufficiency workflow current and green,
- blocker ledger zero,
- HarnessCard truthful,
- release lineage points to the certified bundle,
- recertification status valid.
