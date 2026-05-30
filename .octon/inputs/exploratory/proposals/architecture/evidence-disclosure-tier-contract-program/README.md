# Evidence Disclosure Tier Contract Program

_Status: In-review parent architecture proposal program_

This parent program coordinates the child packet sequence needed to preserve
Octon's retained-evidence model while separating evidence by disclosure tier:
private local raw evidence, publishable claim evidence, operator/release
disclosure, and generated read models.

The parent does not implement the target architecture. It coordinates child
packets and preserves the existing authority model: authored authority under
`framework/**` and `instance/**`, operational truth and retained evidence under
`state/**`, generated outputs as derived-only, and `inputs/**` as
non-authoritative proposal lineage.

## Program Boundary

This program may coordinate child sequence, dependency gates, aggregate risk,
aggregate validation, deferrals, supersessions, rollback posture, and aggregate
closeout evidence.

It must not own child lifecycle truth, child manifests, child subtype
manifests, child acceptance criteria, child validation verdicts, child
promotion targets, child receipts, state evidence, Git tracking behavior, or
child archive metadata.

## Required Children

1. `evidence-disclosure-tier-contracts`
2. `local-evidence-store-boundary`
3. `publishable-evidence-receipts`
4. `disclosure-and-read-model-alignment`
5. `evidence-tier-validator-gates`
6. `closeout-repo-hygiene-evidence-flow`
7. `evidence-residue-migration-closeout`

Child packet directories must be canonical siblings under
`.octon/inputs/exploratory/proposals/architecture/`, not nested under this
parent package.

## Current Coordination State

This parent remains `in-review` for the next `review-program` pass.
Implementation authorization is not encoded in this overview or in retained
support prompts; it exists only when a fresh strict parent review gate passes
with an accepted parent review receipt and live child-readiness validation.

Current child-owned lifecycle state is:

- `evidence-disclosure-tier-contracts` is `implemented` with child-owned
  implementation, conformance, and post-implementation drift/churn receipts.
- The six remaining required sibling child packets are `accepted` and retain
  child-owned implementation prompts.
- Live child-readiness validation is a separate child-owned gate and does not
  replace the required fresh accepted parent review.

The local ignore decision remains scoped to `.octon/state/evidence/.gitignore`,
avoiding repo-root target-family mixing while still ignoring
`.octon/state/evidence/local/**`.
