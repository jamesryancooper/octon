# Implementation Plan

## Workstream 1: Contracts

Add `proposal-program-delivery-profile-v1.schema.json` under product contracts.
It must validate the target program path, route preference, target outcome, PR
policy, stash policy, child execution strategy, required validators,
publication checks, mechanism-specific checks, closeout expectations, terminal
proof requirements, and final sync requirements.

Add `proposal-program-delivery-receipt-v1.schema.json` under product contracts.
It must validate aggregate evidence refs without allowing the aggregate receipt
to replace child-owned or target-owned receipts.

## Workstream 2: Workflow

Add `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
with a contract and staged guidance for:

- profile binding;
- parent and child proposal freshness validation;
- proposal-program lifecycle execution or resume;
- child receipt validation;
- generated registry and publication freshness validation;
- governed mechanism integration validation when applicable;
- lifecycle residue and repo hygiene handling;
- Change closeout handoff;
- branch-no-pr landing authorization validation;
- branch cleanup authorization validation;
- terminal proof validation;
- final worktree hygiene validation;
- final delivery receipt emission.

Register the workflow in the workflow manifest and registry.

## Workstream 3: Validators And Tests

Add focused validators for the delivery profile, delivery receipt, and workflow
shape. Tests must include positive fixtures and negative controls for:

- parent summary used in place of child receipts;
- stale child receipts;
- missing implementation conformance;
- missing drift/churn receipt;
- stale generated publication evidence;
- governed mechanism change without mechanism integration receipt;
- branch-no-pr mutation without landing authorization;
- branch deletion without cleanup authorization;
- missing terminal current-state proof;
- dirty worktree with `cleaned` overclaim;
- final local main and origin/main mismatch;
- generated prompt or proposal-local file used as authority.

## Workstream 4: Lifecycle Hooks

Update the proposal lifecycle extension only enough to expose the delivery mode
as a cross-lifecycle runner. Hooks must pass scoped non-authorizing context and
must require lifecycle-interaction return evidence before the delivery workflow
can treat a target-owned step as resolved.

Do not move Git, branch, cleanup, closeout, publication, or archive authority
into `proposal-program`.

## Workstream 5: Entry Points

Add `/proposal-program-delivery` as a thin command and a corresponding skill.
The entrypoint must translate operator arguments into a delivery profile and
invoke the workflow. It must block, not fall back to PR creation, when the
profile declares a no-PR policy and branch-no-pr is impossible.

## Workstream 6: Feature Documentation

Add `governed-proposal-delivery.md` and catalog entries explaining the product
feature, mode, boundaries, hard gates, advisory evidence, and operator command.
The documentation must explicitly say that delivery receipts aggregate evidence
and do not authorize target-owned lifecycle effects.

## Workstream 7: Validation And Publication

Run the proposal, architecture, workflow, schema, validator, generated
publication, product feature catalog, lifecycle contract, closeout alignment,
and terminal proof test set required by the final implementation. Refresh any
generated projections through owning publishers rather than editing generated
outputs as source truth.

## Rollback

Rollback is atomic: remove the workflow, schemas, validators, tests, feature
documentation, command, skill, and lifecycle hook changes. Retain emitted run
or validation evidence under state/evidence as historical evidence.
