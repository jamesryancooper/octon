# Execute Handoff Or Denial

Execute only the route selected by the classification receipt.

The source under `.incoming/<intake-id>/` remains raw intake throughout this
stage. Handoff context is advisory only. It does not install, normalize,
activate, publish, archive, close out Changes, clean worktrees, delete repo
hygiene residue, or authorize target lifecycle action.

## Handoff Routes

For `single-work-unit-handoff`, create
`governed-incoming-intake-handoff-v1` advisory context for the
`proposal-packet-intake-admission` target-owned contract.

For `coordinated-program-handoff`, create
`governed-incoming-intake-handoff-v1` advisory context for the
`proposal-program-intake-admission` target-owned contract.

Required behavior:

- validate the route decision receipt before creating handoff context
- bind source intake digest, decision digest, payload inventory digest, and
  scope digest into the handoff
- include forbidden authority transfers for Git mutation, hosted provider
  action, branch cleanup, worktree cleanup, repo hygiene deletion, promotion,
  archive, and scope expansion
- validate the target-owned intake admission contract
- when `execute_handoff` is false, stop with retained handoff evidence and no
  target dispatch
- when `execute_handoff` is true, invoke only the target-owned admission/GLO
  route whose contract validates
- record target-owned preflight result, lifecycle run id, route execution
  result, and target return refs when produced

## Direct Target Route

`target-owned-direct-handoff` is recognized but denied unless a non-proposal
target declares a valid `target-owned-intake-admission-contract-v1` contract.
The current implementation must record `rejected-no-target-owned-contract` and
terminal disposition `blocked-rejected-deferred`.

## Blocked Route

For `blocked-rejected-deferred`, do not create target handoff context or invoke
target routes. Record denial evidence and the stop reason. Retain or archive
raw source only through a separately governed final disposition whose retention
posture is safe and evidenced.

Prohibited for every route:

- direct writes to `.codex/skills`, `.claude/skills`, or `.cursor/skills`
- direct generated/effective edits
- root `.archive/**` or Downloads staging
- raw-intake installation or normalization
- target dispatch without a target-owned intake admission contract
- treating handoff context or lifecycle interaction receipts as target
  authorization
- allowing parent program evidence to satisfy child packet receipts
- claiming target completion without target-owned return evidence
