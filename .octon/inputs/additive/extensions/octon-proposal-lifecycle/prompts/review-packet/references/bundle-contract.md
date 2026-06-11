# Bundle Contract

This bundle creates or refreshes `support/proposal-review.md` for one proposal
packet. It may update `proposal.yml#status` only to reflect the review verdict:
`accepted`, `rejected`, or unchanged `in-review` for `revision-required`. For an
already implemented packet with an accepted verdict, it must preserve
`implemented` and refresh only the review receipt/digest.

The review receipt is proposal-local evidence. It does not implement durable
targets, authorize runtime behavior by itself, or become Octon authority.
