# Current-State Gap Map

## Existing surfaces v2 can build on

| Existing surface | v2 use |
| --- | --- |
| Five-root authority model | Correct placement and boundary enforcement. |
| Bootstrap/ingress | Mission continuation startup and readiness posture. |
| Workspace charter/objective | Engagement/Work Package objective binding. |
| Run lifecycle | All mission execution remains run-first. |
| Execution authorization | All material continuation uses engine-owned authorization. |
| Context Pack Builder | Fresh run-bound context evidence between runs. |
| Support targets | Support posture gate. |
| Capability pack registry | Connector operations map to packs. |
| Evidence store | Mission evidence aggregates run-level evidence. |
| Mission charter | Mission scope/success/failure authority. |
| Mission-control lease | Autonomy Window lease gate. |
| Autonomy budget | Continuation budget gate. |
| Circuit breaker | Continuation stop gate. |
| Action Slice schema | Mission Queue item base. |
| Run-first CLI | v2 layers mission continuation above `octon run start --contract`. |

## Assumed v1 baseline

v2 consumes v1 Engagement, Project Profile, Work Package, Decision Request, Evidence Profile, Preflight Evidence Lane, connector posture, and first run-contract candidate outputs. If they are absent in the live repo, this packet is blocked behind v1 except for fail-closed shims.

## v2 gaps

1. No mission-level continuation runtime.
2. No operator-visible Autonomy Window.
3. No canonical Mission Queue.
4. No Continuation Decision record.
5. No Mission Run Ledger.
6. No mission-level evidence profile and closeout bundle.
7. No mission-aware Decision Request semantics.
8. No limited connector operation/admission hook.
9. No `octon continue` / `octon mission continue` path.
10. No explicit progress gate against infinite-agent behavior.
