# Bundle Contract

This bundle creates or refreshes `support/proposal-review.md` for one proposal
packet. It may update `proposal.yml#status` only to reflect the review verdict:
`accepted`, `rejected`, or unchanged `in-review` for `revision-required`.

The review receipt is proposal-local evidence. It does not implement durable
targets, authorize runtime behavior by itself, or become Octon authority.
