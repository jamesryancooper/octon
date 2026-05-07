# Packet Review Scenario

Given an `in-review` proposal packet with implementation-grade completeness
evidence, `review-proposal-packet` writes `support/proposal-review.md` with a
deterministic reviewed packet digest, blocking and nonblocking findings, and a
final route. Accepted reviews set `proposal.yml#status` to `accepted`; rejected
reviews set it to `rejected`; `revision-required` reviews leave the packet
`in-review`.

The route never promotes durable targets or treats review receipts as runtime,
policy, or durable authority.
