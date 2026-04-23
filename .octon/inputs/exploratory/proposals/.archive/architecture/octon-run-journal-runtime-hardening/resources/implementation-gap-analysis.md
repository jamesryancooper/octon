# Implementation Gap Analysis

| Blocking factor | Current manifestation | Required change | How the proposal closes it |
|---|---|---|---|
| Schema split | Constitutional `run-event-v1` and engine `runtime-event-v1` use different shapes/names. | Align event ontology and define migration aliases. | Adds `run-event-v2`, `run-event-ledger-v2`, and engine `run-journal-v1`. |
| Thin event envelope | Existing events do not require sequence/hash/actor/causal refs. | Add typed, causal, hash-linked event envelope. | `run-event-v2` requires integrity and causality fields. |
| Mutable runtime-state drift | Runtime-state is a mutable status surface that may diverge. | Make runtime-state explicitly derived and checkable. | Adds `runtime-state-v2` and reconstruction validator. |
| Incomplete replay | Replay may rely on logs or side artifacts without canonical causal order. | Reconstruct from journal in order with bounded side refs. | Adds replay-store obligations and state-reconstruction v2. |
| Side-effect bypass risk | Material paths could emit receipts without full journal coverage. | Require journal refs for authority, capability, receipt, checkpoint, and rollback events. | Updates authorization-boundary coverage and runtime bus responsibilities. |
| Evidence mismatch | Evidence can be retained separately without proving match to control ledger. | Require journal snapshot and hash match at closeout. | Updates evidence-store and closeout criteria. |
| Generated authority drift | Operator views may become convenient source of truth. | Require source refs/non-authority classification and negative tests. | Updates operator-read-models and validators. |
| Support-target weakness | Support claims may require event ledger generally but not validate completeness. | Add admission test pack for journal/reconstruction. | Updates support-target admission validator. |
| Validator absence | No dedicated Run Journal contract validator. | Add validator and wire into architecture conformance. | Adds `validate-run-journal-contracts.sh`. |
| Replay side-effect abuse | Replay can be dangerous if it repeats live effects. | Make replay dry-run/sandbox by default; require fresh grant for side effects. | Updates replay-store, evidence, and validation. |

## Gap closure principle

Every blocking factor is closed by one of three moves:

1. **contract hardening** — strengthen authored runtime contracts,
2. **runtime enforcement** — route runtime behavior through a single append and
   reconstruction path,
3. **assurance proof** — validate positive and negative cases before promotion.
