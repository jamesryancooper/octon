# Acceptance Criteria

- Program verification delegates `generate-program-verification-prompt`, `run-program-verification-and-correction-loop`, contract-declared packet verification routes, or contract-declared validators only.
- Packet verification covers standard validation, implementation conformance, post-implementation drift/churn, and packet-kind validators through existing route ownership.
- Correction runs only for failed, stale, or missing findings and supplies route-declared inputs such as `finding_id`.
- Implemented-state parent review validation uses contract-declared implemented-state gates and baseline review validation, not the accepted-only implementation authorization gate.

## Negative Criteria

- Do not schedule standalone packet verification, correction, or closeout prompt bundles unless the authored packet lifecycle contract declares them as routes and generated projections are refreshed.
- Do not create bespoke verification semantics inside the runner.
- Do not synthesize unbound correction work without retained finding ids.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
