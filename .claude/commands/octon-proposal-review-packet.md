# Packet - Review

Run the `review-packet` bundle for one packet path or proposal id.

Write or refresh `support/proposal-review.md`, using only proposal-local
support state for the review receipt. Set `proposal.yml#status` to `accepted`
only when the review verdict is `accepted` and the packet is not already
`implemented`; preserve `implemented` for already implemented packets while
refreshing the receipt/digest. Set status to `rejected` only when the verdict is
`rejected`, and leave it `in-review` when the verdict is `revision-required`.

Do not promote durable targets or implement runtime changes from this command.
