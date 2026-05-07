# Packet Revision Scenario

Given a proposal packet whose latest review verdict is `revision-required`,
`revise-proposal-packet` applies only packet-local changes for review findings,
writes `support/revisions/<revision-id>.md`, refreshes catalog, checksums, and
registry projections as needed, and returns the packet to `in-review`.

The route does not accept the packet, promote durable targets, or implement
runtime changes.
