# Risk Register

| Risk | Impact | Likelihood | Mitigation |
| --- | --- | --- | --- |
| Reconciler becomes a second authority source | High | Medium | Generated result may narrow/block only; canonical inputs remain authored/evidence sources |
| Validator allows generated matrix to widen support | High | Medium | Negative fixture: generated-widening attempt must fail |
| Runtime keeps ambient permission path | High | Medium | Material APIs require `VerifiedEffect<T>`; negative bypass tests per path |
| Token metadata too narrow | High | Medium | Require route/run/tuple/grant/revocation/expiry/budget fields |
| Token receipt write failure after side effect | High | Low/Medium | Preflight evidence root, transactional receipt policy, fail before effect when receipt impossible |
| Run health hides uncertainty | Medium/High | Medium | Unknown/disagreement maps to review-required or blocked |
| Run health is consumed as authority | High | Medium | Non-authority schema field and validator; no runtime import dependency |
| Support mismatch blocks legitimate work | Medium | Medium | Diagnostics and staged posture; do not silently promote |
| Migration too broad | Medium | Medium | Keep scope limited to reconciliation, token enforcement, run health |
| Workflow changes outside `.octon` needed | Medium | Low/Medium | Integrate through existing `.octon` validators; separate proposal if workflow change required |
| Existing fixtures are illustrative only | Medium | Medium | Require retained post-promotion validation evidence |
