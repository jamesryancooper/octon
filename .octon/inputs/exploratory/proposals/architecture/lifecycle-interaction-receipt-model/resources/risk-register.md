# Risk Register

| Risk | Mitigation |
| --- | --- |
| Interaction requests become de facto authority. | Schemas, validators, runner, executor proof, and skill guidance mark requests non-authorizing and reject authority-bearing evidence. |
| The model becomes a hidden lifecycle bus. | No subscription list, no auto-dispatch, no global event routing, no source-owned target execution. |
| Phase names become hidden statuses. | Phase ids remain checkpoint/event context only. Proposal statuses stay unchanged. |
| Source lifecycle reports success without target proof. | Return receipt with evidence refs is required for resolved dependency claims. |
| Target lifecycle scope widens from source context. | Scope digest, include/exclude paths, and target-owned scope checks fail closed. |
| Evidence refs dangle or become stale. | Validator checks existence and digest freshness. |
| Executor adapter reinterprets request policy. | Executor receives refs as context only and still requires route delegation proof and target gates. |
| Generated projections are treated as source authority. | Publication refresh is derived and covered by generated/non-authority documentation. |

## Fail-Closed Behavior

Missing, stale, dangling, ambiguous, unsafe, or out-of-scope interaction
evidence blocks the claim that depends on it. It does not authorize recovery by
workaround. Target lifecycles must stop before action when their own receipts,
scope checks, authority proof, rollback posture, hosted controls, or delegation
proof are incomplete.
