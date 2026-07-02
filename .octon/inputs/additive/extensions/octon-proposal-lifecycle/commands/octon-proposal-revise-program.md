# Program - Revise

Run the `revise-program` bundle for one parent proposal program path.

Revision is parent coordination only. Apply only parent-local coordination
changes needed to address review findings and write
`support/revisions/<revision-id>.md`.

This command may edit parent-local coordination files such as the parent
manifest, child registry and index, sequence, child contract, validation plan,
closeout plan, and parent support artifacts. It must not edit child manifests,
child receipts, child promotion targets, child validation verdicts, child
archive metadata, runtime truth, or generated effective authority.

Program revision returns through `review-program` inside the existing
`program-review-revision` loop. It does not create or require a standalone
program review-and-revise wrapper.
