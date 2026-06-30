# Review Program

- Accepted verdict MUST set parent `proposal.yml#status` to `accepted`.
- Accepted verdict MUST NOT leave parent status as `in-review`.
- Revision-required verdict MUST set parent status to `in-review`.
- Rejected verdict MUST set parent `proposal.yml#status` to `rejected`.
- Compute `reviewed_packet_digest` after the final parent status update.
- Run the strict implementation-authorization gate for accepted parent reviews.

Resolve exactly one parent proposal program path. Read the parent
`proposal.yml`, `resources/child-packet-index.yml`,
`resources/child-packet-index.md`, `architecture/packet-sequence.md`,
`architecture/child-packet-contract.md`, `architecture/program-closeout-plan.md`,
validation plan material, and relevant parent support artifacts. Treat child
packets as child-owned sources of their own lifecycle truth.

Review is parent coordination only. Evaluate whether the parent program
correctly coordinates child registry/index consistency, sequence and dependency
rules, child contract boundaries, validation plan, closeout plan, parent
support artifacts, and child authority preservation. Do not change child
manifests, child receipts, child promotion targets, child validation verdicts,
child archive metadata, runtime truth, or generated effective authority.

Run parent structural validation and the baseline parent review gate. Use the
validator output and parent program content to decide exactly one review
verdict: `accepted`, `revision-required`, or `rejected`. Use
`revision-required` when the parent coordination can become acceptable through
parent-local changes; use `rejected` when the parent program should not
continue in this lifecycle path.

When the verdict is `accepted`, update only the parent `proposal.yml#status` to
`accepted`. When the verdict is `rejected`, update only the parent
`proposal.yml#status` to `rejected`. When the verdict is `revision-required`,
set or keep only the parent `proposal.yml#status` as `in-review`. Do not
introduce any other proposal status.

After any parent manifest status update, compute the reviewed parent packet
digest with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <program_packet_path> --print-digest
```

Write or refresh the parent-local `support/proposal-review.md` with these
required fields:

- `review_id`
- `reviewed_at`
- `reviewer`
- `verdict: accepted|revision-required|rejected`
- `implementation_prompt_authorized: yes|no`
- `reviewed_packet_digest`
- `open_blocking_findings_count`

The receipt must also contain these sections:

- `Approved Promotion Targets`
- `Exclusions`
- `Blocking Findings`
- `Nonblocking Findings`
- `Final Route Recommendation`

For accepted reviews, set `implementation_prompt_authorized: yes` only when
the parent program has no open blocking findings, parent promotion targets are
coherent with the manifest, child authority preservation is explicit, and
strict parent review authorization can pass. For `revision-required` or
`rejected`, set it to `no`.

If the verdict is accepted, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <program_packet_path> --require-implementation-authorization
```

Report the verdict, receipt path, reviewed parent packet digest, blockers,
validators run, parent coordination refresh state, child authority boundaries,
and next route. Parent `support/proposal-review.md` never satisfies child
receipts, child validation verdicts, child promotion targets, or child archive
metadata.
