# Review Proposal Packet

Resolve exactly one proposal packet path. Read `proposal.yml`, the subtype
manifest, source-of-truth map, artifact catalog, target architecture or
equivalent subtype documents, implementation plan, validation plan, acceptance
criteria, risk register, promotion targets, implementation-grade completeness
receipt, and relevant support artifacts. Treat supplemental resources as
proposal-local context only.

Run the structural, subtype, implementation-readiness, and baseline review gate
validators. Use the validator output and packet content to decide exactly one
review verdict: `accepted`, `revision-required`, or `rejected`. Use
`revision-required` when the proposal can become acceptable through
packet-local changes; use `rejected` when the proposal should not continue in
this lifecycle path.

When the verdict is `accepted`, update `proposal.yml#status` to `accepted`.
When the verdict is `rejected`, update `proposal.yml#status` to `rejected`.
When the verdict is `revision-required`, leave or return `proposal.yml#status`
to `in-review`. Do not introduce any other proposal status.

After any manifest status update, compute the reviewed packet digest with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <proposal_path> --print-digest
```

Write or refresh `support/proposal-review.md` with these required fields:

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

For accepted reviews, set `implementation_prompt_authorized: yes` only when all
open blocking findings are resolved, approved targets match the manifest
promotion targets, and strict review authorization can pass. For
`revision-required` or `rejected`, set it to `no`.

Refresh `navigation/artifact-catalog.md`, checksums when the packet maintains
`SHA256SUMS.txt`, and the proposal registry projection when manifest state
changed. If the verdict is accepted, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <proposal_path> --require-implementation-authorization
```

Report the verdict, receipt path, reviewed packet digest, blockers, validators
run, registry/checksum refresh state, and next route. Do not promote durable
targets, execute implementation, or treat support receipts as runtime, policy,
or durable authority.
