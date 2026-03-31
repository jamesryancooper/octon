# Octon Post-Cutover Atomic Constitutional Alignment Remediation

This packet is the implementation-grade architecture proposal for a **one-branch, big-bang, clean-break, atomic alignment pass** after Octon's March 30, 2026 unified execution constitution cutover.

It assumes the live model is already:

- `pre-1.0`
- `atomic`
- `clean-break`
- run-contract-first for consequential execution
- canonical under authored governance plus retained disclosure roots
- support-target-enforced

The purpose of this packet is **not** to re-run the March 30 cutover. Its purpose is to remove residual post-cutover drift, narrow overclaims, and harden validators so the live model and the documented model cannot silently diverge again.

## Delivery format

This repository copy is normalized to the standard architecture-proposal packet
shape and includes canonical YAML manifests:

- `proposal.yml`
- `architecture-proposal.yml`

All other files follow the normal packet layout.

## Packet kind

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.6.9`
- recommended start release: `0.7.0`
- recommended claim release: `0.7.0`
- cutover style:
  - `atomic`
  - `clean-break`
  - `constitutional`
  - `repo-wide`
  - `same-branch`
  - `pre-1.0`
  - `no-transitional-live-model`

## What this packet does

This packet:

1. reconciles the supplied independent evaluation against the **current default-branch HEAD**
2. preserves the disclosure-family remediation that is already landed at current HEAD
3. normalizes constitutional-family receipt semantics around the March 30, 2026 atomic cutover receipt
4. removes the remaining bootstrap authority-surface leak that treats raw `inputs/**` as authored authority
5. narrows live support, portability, and disclosure claims to **retained proof-backed envelopes**
6. normalizes subordinate ownership identifiers away from placeholder values
7. adds validator and workflow hardening so the same drift class fails closed on recurrence
8. records the user-supplied evaluation under `resources/` as packet lineage

## What this packet does not do

This packet does **not**:

- widen support tiers
- create fictitious proof bundles that do not exist
- preserve broad live claims merely because they were previously published
- reintroduce transitional live wording after the March 30 atomic cutover
- mix `/.octon/**` promotion targets with repo-local non-`/.octon/**` targets in one active packet
- treat this proposal as canonical after promotion

## Current-head reconciliation summary

The user-supplied evaluation is valuable, but it is **not a perfect description of current HEAD**.

At current HEAD:

- the disclosure-family live-model drift called out in the evaluation is already corrected in `/.octon/framework/constitution/contracts/disclosure/family.yml`
- the canonical authored HarnessCard source and retained release disclosure roots are already corrected
- the historical-only status of lab-local HarnessCard mirrors is already corrected

The remaining high-value remediation work is now concentrated in:

- constitutional family receipt semantics
- bootstrap authority-surface correction
- support-target claim narrowing or proof completion
- portability/public-claim narrowing inside `/.octon/**`
- subordinate ownership placeholder removal
- regression-hardening validators and workflows

Read `resources/current-head-reconciliation.md` before using the supplied evaluation as live-state truth.

## Recommended reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/current-head-reconciliation.md`
4. `resources/current-state-drift-baseline.md`
5. `architecture/target-architecture.md`
6. `architecture/constitutional-kernel-alignment.md`
7. `architecture/bootstrap-authority-and-ingress-alignment.md`
8. `architecture/disclosure-and-support-target-alignment.md`
9. `architecture/documentation-and-claim-alignment.md`
10. `architecture/file-level-remediation-spec.md`
11. `architecture/implementation-plan.md`
12. `architecture/acceptance-criteria.md`
13. `architecture/validation-plan.md`
14. `architecture/cutover-checklist.md`
15. `navigation/source-of-truth-map.md`
16. `navigation/change-map.md`
17. `resources/path-impact-matrix.md`
18. `resources/proposal-to-implementation-traceability.md`
19. `resources/missing-proof-and-overclaim-ledger.md`
20. `resources/repo-local-follow-on-items.md`
21. `resources/risks-tradeoffs-and-open-questions.md`
22. `resources/user-supplied-independent-evaluation.md`

## Non-negotiable remediation rules

1. The March 30, 2026 live model remains the only supported live constitutional model.
2. No active constitutional family may describe its live profile using a stale phase receipt without explicit lineage semantics.
3. No orientation or bootstrap document may widen authored authority into raw `inputs/**`.
4. No live support claim may remain broader than retained proof.
5. No portability claim may outrun the support-target and disclosure evidence that backs it.
6. No placeholder owner identifier may remain on binding subordinate governance surfaces.
7. Disclosure historical mirrors may remain retained, but they may never become canonical live roots again.
8. This packet chooses **truthful narrowing** over aspirational overclaim whenever proof is missing.

## Archived in-repo path

This packet is now archived at:

```text
/.octon/inputs/exploratory/proposals/.archive/architecture/octon-post-cutover-atomic-constitutional-alignment-remediation/
```

## Proposal status

This packet is non-canonical implementation guidance. Canonical truth must live in durable promoted targets after promotion.
