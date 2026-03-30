# Unified Execution Constitution Closure Certification Cutover Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `transitional_exception_note`: not applicable
- `selection_rationale`: this packet is a one-branch closure-certification
  cutover with one bounded claim, one surviving authority path, and no
  transitional support posture after merge

## Goal

Implement the unified-execution closure-certification packet as one
repo-local, clean-break migration so the live release claim is bounded to the
supported envelope and blocked by canonical authority, bundle, disclosure,
shim, and retirement proofs.

## Bounded Claim

- certified tuple: `MT-B / WT-2 / LT-REF / LOC-EN`
- certified adapters: `repo-shell` + `repo-local-governed`
- reduced or excluded surfaces:
  - `github-control-plane`
  - `ci-control-plane`
  - `WT-3`
  - `LT-EXT`
  - `LOC-MX`
  - `MT-C`
  - `WT-4`

## Branch Readiness Inventory

- live support-target declarations already publish the bounded tuple and the
  reduced/experimental/unsupported matrix
- retained WT-2 run evidence already exists under the canonical run and
  disclosure roots and can serve as the positive supported-envelope fixture
- build-to-delete review evidence and retirement registry already exist and can
  be tightened rather than recreated in parallel
- GitHub auto-merge already materializes canonical approval artifacts, but
  autonomy-policy classification still needs to move into canonical `.octon/**`
  logic

## Implementation Plan

1. Freeze the claim in a canonical closure manifest and make HarnessCard
   wording a pure projection of that manifest.
2. Reuse the retained supported WT-2 run as the positive certification fixture,
   add explicit reduced/deny/fail-closed fixtures, and publish retained
   certification summaries.
3. Move PR autonomy lane classification into canonical
   `.octon/framework/assurance/governance/**` logic and reduce GitHub workflows
   to downstream bindings over that logic.
4. Add the canonical closure validator and release workflow, then publish the
   migration and certification evidence bundle in the same branch.

## Impact Map

- `code`: canonical governance scripts for PR-autonomy classification and
  closure validation
- `contracts`: closure manifest, contract registry, retirement registry, host
  adapter declarations
- `validators`: closure validator, execution-governance assertions, workflow
  binding checks, shim audit
- `evidence`: migration bundle, release HarnessCard, publication summaries,
  certification fixtures, build-to-delete receipt mapping
- `docs`: HarnessCard source, publication summaries, disclosure/support limits

## Compliance Receipt

- one bounded release claim only
- one live constitutional authority path only
- no GitHub or CI surface mints final authority inside the certified envelope
- no consequential supported run may satisfy the claim without the full run
  bundle and resolving disclosure proof refs
- retained shims remain legal only as adapter-only, subordinate, or
  retirement-conditioned surfaces

## Exceptions / Escalations

- no human escalation required at planning time
- unrelated user worktree changes were preserved in place and not reverted
