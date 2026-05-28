# Proposal Lifecycle

Run the proposal lifecycle dispatcher for packet and program targets.

Use explicit `--bundle <route-id>` when the route is known, or provide a
`--lifecycle-action`, packet path, source kind, verification finding, or
program packet path for deterministic dispatch through
`context/routing.contract.yml`.

Leaf commands:

- `/octon-proposal-create-packet`
- `/octon-proposal-explain-packet`
- `/octon-proposal-review-packet`
- `/octon-proposal-revise-packet`
- `/octon-proposal-generate-packet-implementation-prompt`
- `/octon-proposal-run-packet-implementation`
- `/octon-proposal-generate-packet-verification-prompt`
- `/octon-proposal-generate-packet-correction-prompt`
- `/octon-proposal-run-packet-verification-and-correction-loop`
- `/octon-proposal-generate-packet-closeout-prompt`
- `/octon-proposal-closeout-packet`
- `/octon-proposal-run-packet-lifecycle`
- `/octon-proposal-create-program`
- `/octon-proposal-explain-program`
- `/octon-proposal-review-program`
- `/octon-proposal-revise-program`
- `/octon-proposal-generate-program-orchestration-prompt`
- `/octon-proposal-generate-program-verification-prompt`
- `/octon-proposal-generate-program-correction-prompt`
- `/octon-proposal-run-program-verification-and-correction-loop`
- `/octon-proposal-generate-program-closeout-prompt`
- `/octon-proposal-closeout-program`
- `/octon-proposal-run-program-lifecycle`

The dispatcher must preserve proposal authority boundaries and use generated
effective extension/capability outputs after publication.
