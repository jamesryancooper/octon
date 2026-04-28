# Safety Gate Matrix

| Gate | Applies to | Required output |
|---|---|---|
| Human approval | adoption writes, charter changes, support widening, risk acceptance, destructive actions | Decision Request and canonical low-level control artifact. |
| Runtime authorization | material effects, repo mutation, service invocation, shell, outbound HTTP, generated-effective publication | GrantBundle plus AuthorizedEffect token readiness. |
| Evidence retention | all compiler stages and all runs | Retained evidence under `state/evidence/**`. |
| Reversibility | repo-consequential changes | rollback plan or explicit risk acceptance. |
| Support reconciliation | all live claims and run candidates | support posture and reason codes. |
| Capability admission | capability packs and connector operations | allowed/stage/blocked/denied posture. |
| Context packing | consequential or boundary-sensitive run candidate | context-pack request and later receipt. |
| Fail-closed | missing authority/evidence/support/capability/context/rollback | blocked/staged/denied outcome. |
