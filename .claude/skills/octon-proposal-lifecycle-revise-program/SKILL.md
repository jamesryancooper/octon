---
name: octon-proposal-lifecycle-revise-program
description: Run the revise-program bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-12"
  updated: "2026-05-12"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Program - Revise

Apply parent-local coordination revisions for parent review findings and write
`support/revisions/<revision-id>.md`.

Revision is parent coordination only. It may change parent-local coordination
files such as the parent manifest, child registry and index, sequence, child
contract, validation plan, closeout plan, and parent support artifacts. It may
not edit child manifests, child receipts, child promotion targets, child
validation verdicts, child archive metadata, runtime truth, or generated
effective authority.

Keep or return the parent `proposal.yml#status` to `in-review`; acceptance
requires a later `review-program` pass. Parent revision receipts never
satisfy child receipts.

This route is the revision side of the existing `program-review-revision` loop.
Do not introduce or depend on a standalone program review-and-revise wrapper
unless a later accepted packet admits that surface.

Write revision receipts with machine-readable completion fields:
`revision_id`, `source_review_id`, `changed_parent_files`,
`changed_packet_files`, `addressed_finding_ids`, `remaining_blocking_count`,
`post_revision_digest`, `validators_rerun`,
`catalog_checksum_registry_refresh`, and `child_authority_preserved`. Use
`remaining_blocking_count: 0` only when the selected parent-local review
findings are fully addressed; otherwise stop with a blocker instead of writing
a completion-style revision receipt. Do not emit `post_revision_packet_digest`
or `pending` placeholders.
