# Lifecycle Autopilot Roadmap

Lifecycle Autopilot's end-to-end proposal packet lifecycle automation loop is
implemented. The roadmap items below capture useful follow-up work that remains
outside the initial landing scope.

## Suggested Follow-Ups

| Roadmap Item | Intent | Status |
| --- | --- | --- |
| `lifecycle-autopilot-live-provider-smoke-tests` | Add optional smoke coverage for real `codex`, `claude`, and `auto` executors. | suggested |
| `lifecycle-autopilot-operator-run-diagnostics` | Provide a concise read-only explanation of lifecycle stop and resume state. | completed for proposal-program runs |
| `lifecycle-autopilot-approval-grant-ux` | Improve human approval artifact creation and review for durable routes. | completed for proposal-program runs |
| `lifecycle-autopilot-second-extension-pilot` | Prove generic lifecycle portability with a non-proposal extension. | suggested |
| `lifecycle-autopilot-program-multi-target-support` | Extend automation to coordinated program or multi-target runs when justified. | completed |
| `lifecycle-autopilot-program-controller-v2` | Add recoverable proposal-program controller behavior, explicit-opt-in program-atomic execution, event replay, recovery handlers, and operator controls. | completed |
| `lifecycle-autopilot-program-controller-v3` | Add replay-verifiable v2 event logs, status read models, complete aggregate closeout receipts, digest-guarded registry mutations, seed/reference scaffolding, barrier recovery, and recovery recipes. | completed |
| `lifecycle-autopilot-state-evidence-hygiene` | Clarify cleanup and retention for local run/evidence outputs. | suggested |

## Boundary

This roadmap note is planning-only. It does not add runtime behavior, policy
authority, support commitments, proposal statuses, generated-effective state, or
durable execution evidence.
