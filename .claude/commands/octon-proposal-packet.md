# Octon Proposal Packet

Run the proposal packet lifecycle dispatcher.

Use explicit `--bundle <route-id>` when the route is known, or provide a
`--lifecycle-action`, packet path, source kind, verification finding, or
program packet path for deterministic dispatch through
`context/routing.contract.yml`.

Leaf commands:

- `/octon-proposal-packet-create`
- `/octon-proposal-packet-explain`
- `/octon-proposal-packet-generate-implementation-prompt`
- `/octon-proposal-packet-run-implementation`
- `/octon-proposal-packet-generate-verification-prompt`
- `/octon-proposal-packet-generate-correction-prompt`
- `/octon-proposal-packet-run-verification-and-correction-loop`
- `/octon-proposal-packet-generate-closeout-prompt`
- `/octon-proposal-packet-closeout`
- `/octon-proposal-packet-create-program`
- `/octon-proposal-packet-generate-program-implementation-prompt`
- `/octon-proposal-packet-generate-program-verification-prompt`
- `/octon-proposal-packet-generate-program-correction-prompt`
- `/octon-proposal-packet-run-program-verification-and-correction-loop`
- `/octon-proposal-packet-generate-program-closeout-prompt`
- `/octon-proposal-packet-closeout-program`

The dispatcher must preserve proposal authority boundaries and use generated
effective extension/capability outputs after publication.
