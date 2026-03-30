# Unified Execution Constitution Atomic Cutover Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `transitional_exception_note`: not applicable
- `selection_rationale`: the repo already had the target-state runtime and governance families in place, so the remaining work was a same-branch convergence pass rather than a staged coexistence rollout

## Goal

Implement `octon-fully-unified-execution-constitution-v1` as one uninterrupted
branch-local clean-break cutover so the supported live model is:

- run-contract-first for consequential execution
- runtime-consumed for authority
- canonical under authored governance + retained disclosure roots
- support-target-enforced without transitional live wording

## Branch Readiness Inventory

- live consequential control roots:
  `/.octon/state/control/execution/runs/**`
- live continuity roots:
  `/.octon/state/continuity/runs/**`
- live authority roots:
  `/.octon/state/control/execution/{approvals,exceptions,revocations}/**`
- live retained authority evidence:
  `/.octon/state/evidence/control/execution/**`
- canonical disclosure roots promoted in this cutover:
  `/.octon/instance/governance/disclosure/**`
  `/.octon/state/evidence/disclosure/{runs,releases}/**`
- validators and workflows that must flip in-branch:
  authority tooling, run writer, disclosure validators, closeout validator,
  AI gate, PR auto-merge, build-to-delete review packet

## Implementation Plan

1. Runtime bind
   Move the workflow entry to explicit `run-id` handling, keep mission as
   continuity-only context, and align run manifests/contracts with canonical
   disclosure roots.
2. Authority bind
   Publish `quorum-policy-v1`, bind quorum references into approval artifacts,
   and expose a named runtime `authority_engine` crate.
3. Proof and disclosure
   Promote authored HarnessCard source to `instance/governance/disclosure`,
   move canonical retained RunCards/HarnessCards to `state/evidence/disclosure`,
   and keep old mirror paths explicitly historical.
4. Admission and portability
   Rename the live WT-2 support tier from `repo-local-transitional` to
   `repo-local-consequential` and align runtime, workflows, suites, and
   disclosure artifacts to the published matrix.
5. Simplification and retirement
   Register run-local disclosure mirrors and lab-local HarnessCard mirrors as
   historical retained scaffolding, update the build-to-delete review packet,
   and keep only one live disclosure model after merge.

## Impact Map

- `code`: kernel workflow execution, authority routing, authority tooling
- `contracts`: charter manifest, disclosure family, authority family, support
  targets, retirement registry, closeout reviews
- `validators`: assurance/disclosure expansion, closeout validation, harness
  structure, proof-suite defaults
- `evidence`: canonical run/release disclosure packets, build-to-delete review
  packet, migration bundle
- `docs`: disclosure roots, evidence roots, run/readme surfaces, governance
  disclosure orientation

## Compliance Receipt

- no supported live path keeps `change_profile: transitional`
- `adoption_state.wave` and `staged_cutovers` are retained only as historical
  lineage in the constitutional manifest
- host workflows stay projection/request-capture only and no longer define the
  supported support tier as transitional
- canonical live disclosure now resolves from governance + disclosure roots,
  not run-local or lab-local mirror paths

## Exceptions / Escalations

- no human escalation was required
- pre-existing unrelated worktree changes under proposal/archive surfaces were
  preserved in place and not reverted
