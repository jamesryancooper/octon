# Revise Program

Resolve exactly one parent proposal program path. Read the latest parent-local
`support/proposal-review.md`, parent review findings, parent `proposal.yml`,
`resources/child-packet-index.yml`, `resources/child-packet-index.md`,
`architecture/packet-sequence.md`, `architecture/child-packet-contract.md`,
`architecture/program-closeout-plan.md`, validation plan material, and existing
parent revision receipts.

Default to requiring the latest parent review verdict to be
`revision-required`. Proceed from another verdict only when the operator
explicitly identifies a superseding parent review source, and record that basis
in the revision receipt.

Apply the smallest parent-local coordination changes needed to address the
selected parent review findings. Allowed changes are limited to the parent
manifest, parent child registry and index, parent sequence, parent child
contract, parent validation plan, parent closeout plan, and parent support
artifacts. Do not edit child manifests, child receipts, child promotion
targets, child validation verdicts, child archive metadata, runtime truth, or
generated effective authority. If a finding requires child-owned or durable
runtime changes, stop and report a blocker instead of revising the parent
program.

Set or keep only the parent `proposal.yml#status` as `in-review`. Do not set
`accepted` or `rejected` in this route.

After parent edits, compute the post-revision digest with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <program_packet_path> --print-digest
```

Write `support/revisions/<revision-id>.md` with these required fields:

- `revision_id`
- `source_review_id`
- `changed_parent_files`
- `changed_packet_files`
- `addressed_finding_ids`
- `remaining_blocking_count`
- `post_revision_digest`
- `validators_rerun`
- `catalog_checksum_registry_refresh`
- `child_authority_preserved`

Use the exact field name `post_revision_digest`. Do not emit
`post_revision_packet_digest`, `pending`, or placeholder values. When the
selected parent-local findings are fully addressed, set
`remaining_blocking_count: 0`; otherwise stop with a blocker instead of writing
a completion-style revision receipt.

Re-run parent structural validation and the baseline parent review gate. Report
changed parent files, addressed findings, remaining blockers, post-revision
digest, validators rerun, child authority boundary confirmation, and the next
route: `review-program`.

Parent revision receipts never satisfy child receipts, child validation
verdicts, child promotion targets, or child archive metadata.
