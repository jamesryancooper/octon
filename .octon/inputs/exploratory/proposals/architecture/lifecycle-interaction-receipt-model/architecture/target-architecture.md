# Target Architecture

## Decision

Adopt a typed Lifecycle Interaction Receipt Model with:

- `lifecycle-interaction-request-v1`
- `lifecycle-interaction-return-v1`
- `handoff` as one interaction profile, not the abstraction itself
- lifecycle-local phase-loop state
- runner-visible non-authorizing context
- target-owned gates and authority
- return evidence before a source lifecycle can claim dependency resolution

Do not introduce a lifecycle bus, shared phase-loop state, global status model,
or source-lifecycle authority over target-lifecycle action.

## First-Principles Domain Model

Lifecycle interaction has five parts:

| Part | Meaning |
| --- | --- |
| Source lifecycle | The lifecycle that discovered a dependency or residue. |
| Requested work | The follow-on lifecycle surface, capability, atomic unit type, and target outcome being requested. |
| Scoped context | Include and exclude paths, source refs, run ids, evidence refs, blockers, and boundary digest. |
| Consumer validation | Independent target lifecycle gates for scope, authority, freshness, rollback, receipts, hosted controls, and delegation proof. |
| Return evidence | Durable proof of completion, blocker, deferral, or remaining residue. |

The interaction receipt is evidence of a request. It is not execution
authority.

## Request Receipt Model

`lifecycle-interaction-request-v1` records:

- stable `interaction_id` and `created_at`
- source lifecycle id, run id, atomic unit type, target ref, and source phase id
- request kind, requested capability, requested lifecycle id, requested route
  surface, requested atomic unit type, and requested target outcome
- scoped include/exclude paths and a recomputable boundary digest
- offered evidence refs with digests and explicit acceptance classes
- forbidden authority-transfer list
- stop conditions and expected return evidence classes

Accepted evidence classes are advisory only:

- `advisory-context`
- `validation-evidence`
- `review-evidence`
- `rollback-context`
- `non-authority-only`

The request schema must reject unknown authority-bearing fields, unknown
acceptance classes, missing required fields, unsafe paths, and missing required
forbidden-transfer entries.

## Return Receipt Model

`lifecycle-interaction-return-v1` records:

- matching `interaction_id`
- consumer lifecycle id and run id
- completed flag, lifecycle outcome, and blocker text
- return evidence refs
- remaining residue

If `outcome.completed` is true, `return_evidence_refs` must be non-empty. A
source lifecycle cannot mark the dependency resolved until it can cite a fresh
valid return receipt and the returned evidence refs validate.

## Interaction Profiles

The model supports profiles without making a bus:

- `handoff`: source records that follow-on work is required and target action
  may proceed only through the target lifecycle's normal gates.
- `blocked-dependency`: source records a blocked dependency and expected return
  evidence before source closeout can claim resolution.
- `residue-routing`: source records residue that may be routed to worktree or
  repo-hygiene handling as context only.

Only `handoff` needs initial implementation behavior. Other profiles are
declared as future-compatible examples and remain non-dispatching unless a
target lifecycle contract explicitly accepts them.

## Lifecycle Contract Metadata

Lifecycle contracts may declare optional interaction metadata:

- `emitted_profiles`: request profiles the lifecycle may emit
- `accepted_profiles`: request profiles the lifecycle may consume as context
- accepted request kinds, capabilities, atomic unit types, target outcomes,
  evidence classes, and forbidden transfers
- return receipt schema and required return evidence classes

The metadata is declarative eligibility, not authority. It allows the runner to
plan and explain target fit while target routes still require normal receipts,
validators, delegation proof, and hosted/provider controls.

## Source Responsibilities

A source lifecycle that emits a request must:

- bind the source run, phase id, target ref, atomic unit type, and requested
  outcome
- keep scope explicit and digest-bound
- offer evidence by ref with digest and advisory acceptance class
- include required forbidden authority-transfer entries
- state stop conditions and expected return evidence
- fail closed when evidence is missing, stale, dangling, ambiguous, or outside
  scope
- refuse to report dependency resolution without a valid return receipt

## Runner Responsibilities

The runner may:

- discover validated interaction request refs from run inputs or checkpoint
  context
- record request refs in event logs and checkpoints
- resolve candidate target lifecycle and route surfaces from declared metadata
- expose the interaction to executor adapters as non-authorizing context
- stop before execution when target gates, receipts, authority, rollback,
  scope, freshness, or delegation proof are missing

The runner must not:

- dispatch solely because a request exists
- self-authorize target action
- widen scope
- treat request evidence as landing, cleanup, archive, promotion, or closeout
  authority
- synthesize source lifecycle success without return evidence

## Executor Adapter Boundaries

Executor adapters receive interaction refs as context only. They must validate
the selected route's delegation proof and required receipts exactly as before.
They must not reinterpret interaction request policy, select alternate routes,
mint authority, skip target gates, or treat a source request as permission to
mutate Git, hosted providers, generated projections, archives, cleanup state, or
proposal status.

## Workflow And Skill Responsibilities

Proposal Packet closeout may emit a `follow_on_work_required` request when
closeout is blocked by Change Closeout, Worktree Closeout, or Repo Hygiene
work. That receipt records context and expected return evidence only.

Change Closeout may consume request context but must still require its own
Change receipt, landing authorization, cleanup authorization, hosted checks,
scope checks, rollback posture, final sync proof, and stateful closeout
evidence before claiming an outcome.

Worktree Closeout and Repo Hygiene may consume request context to classify and
select candidates but must not delete, stage, commit, land, archive, or clean
anything without their own target-owned gates and receipts.

## Authority And Forbidden Transfer Rules

Interaction requests must explicitly forbid transfer of:

- `git-ref-mutation`
- `hosted-provider-authorization`
- `branch-cleanup-authorization`
- `archive-authorization`
- `promotion-authorization`
- `scope-expansion`

The validator must reject a request that omits any required forbidden transfer
or attempts to include authority-bearing evidence classes.

## Impact Summary

Schema impact is limited to two new product contract schemas, optional
lifecycle contract metadata, and route execution request context fields.
Lifecycle contract impact is additive and optional. Runner checkpoint and event
logs gain interaction refs. Proposal lifecycle closeout gains an emission
responsibility when blocked by target-owned work. Closeout and hygiene skills
gain consumption language that confirms non-authority. Existing proposal
statuses remain unchanged.
