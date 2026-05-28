# Program - Review

Run the `review-program` bundle for one parent proposal program path.

Review is parent coordination only. Read the parent `proposal.yml`, child
registry and index, sequence, child contract, validation plan, closeout plan,
and parent support artifacts. Write or refresh the parent-local
`support/proposal-review.md` review receipt using the existing proposal review
fields.

This command may update only the parent `proposal.yml#status` to `accepted`,
`rejected`, or `in-review`. It must not edit child manifests, child receipts,
child promotion targets, child validation verdicts, child archive metadata,
runtime truth, or generated effective authority.
