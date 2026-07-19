# Change Closeout Lifecycle

Change Closeout is the route-neutral evidence and preservation feature for one
Change. During SI-00 it inventories exact state, classifies an active route,
retains rollback posture, and reports the highest evidence-backed
stage-preserving outcome.

The machine authority remains
`.octon/framework/product/contracts/default-work-unit.yml` and
`.octon/framework/product/contracts/change-closeout-state-machine.yml`.

## Current Boundary

- `direct-main` is not active.
- `branch-no-pr` remains classifiable for branch-local work and preservation;
  its local and hosted landing effects are disabled.
- `branch-pr` remains available for stage-preserving PR coordination when an
  independent PR predicate exists. The RP-00 protected-PR provider cutover is
  separately authorized and is not a Change-closeout effect.
- `stage-only-escalate` preserves work and reports the missing gate.
- cleanup authorization, branch/ref deletion, worktree removal, pruning, and
  closeout-driven sync are disabled.

Historical schemas and receipts may parse retired route and success labels for
audit compatibility. They cannot admit a current request, authorize an effect,
or prove SI-00 success.

## Stable Reasons

- publication or landing: `RP00_CONTAINMENT_PUBLICATION_DISABLED`
- cleanup or deletion: `RP00_CONTAINMENT_CLEANUP_DISABLED`

Every independently invocable helper returns the applicable reason before Git,
worktree, ref, remote, or provider mutation. Cleanup dry runs may inventory
only.

## Outcomes

Generic closeout resolves to `preserved`. Branch-local and pushed-branch
handoff can remain continued outcomes when separately authorized. If landing
was already independently established, closeout may observe `landed` with
`cleanup_status: deferred`; it does not perform landing or cleanup. No current
closeout route reports `cleaned`, `synced`, or autonomous publication success.

## Entry Points

- `/closeout-change`: one Change, preservation-first
- `/closeout-worktree`: read-only partitioning wrapper over singular Changes
- `/closeout-pr`: PR-backed stage-preserving subflow after `branch-pr`

Generated outputs, raw inputs, host state, provider state, chat, and tool
availability are not closeout authority.

## Validation

Focused validation lives in the default-work-unit, closeout state-machine,
lifecycle alignment, hosted-no-PR containment, cleanup-authorization, and
worktree-wrapper validators and their direct-invocation tests.
