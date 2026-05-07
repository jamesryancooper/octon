# Revise Proposal Packet

Resolve exactly one proposal packet path. Read the latest
`support/proposal-review.md`, review findings, packet manifests, source-of-truth
map, artifact catalog, target documents, implementation plan, validation plan,
acceptance criteria, risk register, and existing revision receipts.

Default to requiring the latest review verdict to be `revision-required`.
Proceed from another verdict only when the operator explicitly identifies a
superseding review source, and record that basis in the revision receipt.

Apply the smallest packet-local changes needed to address the selected review
findings. Keep changes under the proposal packet. Do not edit durable promotion
targets, runtime surfaces, policy, generated effective extensions, or durable
entry artifacts. If a finding requires durable-surface changes or changes
promotion scope, stop and report a blocker instead of revising the packet.

Set or keep `proposal.yml#status` as `in-review`. Do not set `accepted` or
`rejected` in this route.

After packet edits, compute the post-revision digest with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <proposal_path> --print-digest
```

Write `support/revisions/<revision-id>.md` with these required fields:

- `revision_id`
- `source_review_id`
- `changed_packet_files`
- `addressed_finding_ids`
- `remaining_blocking_count`
- `post_revision_digest`
- `validators_rerun`
- `catalog_checksum_registry_refresh`

Refresh `navigation/artifact-catalog.md`, checksums when the packet maintains
`SHA256SUMS.txt`, and proposal registry projection when manifest or catalog
state changed. Re-run structural, subtype, implementation-readiness, and
baseline review-gate validators.

Report changed packet files, addressed findings, remaining blockers,
post-revision digest, validators rerun, refresh state, and the next route:
`review-proposal-packet`.
