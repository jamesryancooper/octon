correction_id: operator-free-packet-lifecycle-autonomy-readiness-projection-evidence-index-refs-20260618T182200Z
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
finding_id: readiness-projection-evidence-index-refs
blocking_gate: validate-proposal-program-readiness-projection
verdict: blocked

# Correction Prompt: Program Readiness Projection Evidence Index Refs

## Blocker

The parent-level verification/reconciliation route for
`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
is blocked by the read-only proposal-program readiness projection validator:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
```

The validator reports seven errors:

```text
[ERROR] child blocked-delivery-receipt-semantics terminal readiness requires evidence index refs
[ERROR] child packet-delivery-wrapper-orchestration-autonomy terminal readiness requires evidence index refs
[ERROR] child branch-no-pr-closeout-state-machine-autonomy terminal readiness requires evidence index refs
[ERROR] child generated-freshness-scope-detection terminal readiness requires evidence index refs
[ERROR] child packet-worktree-partitioning-automation terminal readiness requires evidence index refs
[ERROR] child terminal-evidence-sink-autonomy terminal readiness requires evidence index refs
[ERROR] child git-mutation-sandbox-preflight terminal readiness requires evidence index refs
Validation summary: errors=7 warnings=2
```

The child-owned implementation gates are otherwise passing:

- `validate-proposal-implementation-conformance.sh --package <child>` passes
  for all seven required P0/P1 children.
- `validate-proposal-post-implementation-drift.sh --package <child>` passes
  for all seven required P0/P1 children.
- `validate-proposal-lifecycle-terminal-freshness.sh --proposal <child> --run-registry-check`
  passes for all seven required P0/P1 children after refreshing the
  `git-mutation-sandbox-preflight` generated proposal artifact bundle through
  `generate-proposal-artifact-index.sh --proposal <child> --write`.
- `validate-proposal-program-child-readiness.sh --package <parent>` passes.

## Required Correction Route

Use a parent-owned reconciliation correction route for readiness-projection
evidence index references.

- Preserve `proposal.yml#status: accepted` for the parent.
- Do not promote, close out, archive, clean, land, publish, delete, or claim
  `cleaned` for the parent or any child.
- Do not use parent evidence to satisfy child-owned receipts, child validation
  verdicts, promotion evidence, archive metadata, or closeout evidence.
- Identify the canonical retained-run evidence index artifact contract and
  generation route for implemented proposal-program children.
- For each required implemented child, either:
  - attach valid `evidence_index_refs` in the parent child registry to
    retained-run evidence indexes that pass
    `validate-proposal-program-readiness-projection.sh`, or
  - revise the readiness projection contract/validator through a separate
    governed proposal if implemented-but-not-terminal children should not
    require evidence index refs before parent closeout.
- Do not hand-edit generated outputs. Refresh generated proposal registry or
  artifact outputs only through canonical generators if the correction changes
  source digests.
- If child-owned evidence must change, route that change through the relevant
  child-owned correction path. Do not rewrite child receipts from the parent
  route.

## Required Validators

Run, at minimum:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Then rerun the child dependency-gate validators for all required P0/P1
children if any child registry, child packet, generated proposal artifact, or
retained evidence index source changes.

If all gates pass, resume the parent-level verification/reconciliation route
from a fresh preflight. Do not proceed to parent promotion or closeout without a
separate explicit operator instruction.
