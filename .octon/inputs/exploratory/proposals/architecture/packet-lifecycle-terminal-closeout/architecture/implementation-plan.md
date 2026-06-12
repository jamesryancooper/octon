# Implementation Plan

## Workstream 1: Contracts

Add `proposal-packet-terminal-closeout-profile-v1.schema.json` under product
contracts. It must validate:

- packet path and proposal id;
- target outcome, including `archive-ready` and `blocked`;
- route preference and PR policy;
- publication freshness policy;
- hygiene policy;
- expected retained evidence set;
- required validators by target family;
- post-integration architecture review policy;
- packet terminal evaluator policy;
- Git/GitHub hosted check policy;
- blocker and next-route reporting requirements.

Add `proposal-packet-terminal-closeout-receipt-v1.schema.json` under product
contracts. It must validate aggregate evidence refs without allowing the
aggregate receipt to replace packet-owned or target-owned receipts.

## Workstream 2: Workflow

Add `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
with stages for:

- profile binding;
- durable implementation state verification;
- implementation conformance verification;
- post-implementation drift/churn verification;
- publication freshness validation and canonical publisher refresh;
- generated/input non-authority validation;
- run-health and capability/extension publication validation;
- repo-hygiene classification and authorized cleanup handoff;
- worktree hygiene classification;
- evidence-only post-integration architecture review;
- packet terminal evaluator or lifecycle-postmortem hook;
- Git/GitHub route handoff and exact-SHA check validation;
- terminal receipt emission.

Register the workflow in the workflow manifest and registry.

## Workstream 3: Validators And Tests

Add validators for the profile, receipt, and workflow shape. Tests must include
positive fixtures and negative controls for:

- missing implementation conformance receipt;
- stale implementation conformance receipt;
- missing post-implementation drift/churn receipt;
- stale publication freshness receipt;
- direct generated output edit used as freshness repair;
- missing generated/input non-authority validation;
- missing run-health validation;
- missing capability or extension publication validation;
- repo-hygiene deletion without authorization;
- worktree hygiene blocked by foreign residue;
- architecture review output used as closeout authority;
- lifecycle-postmortem output used as archive authority;
- branch-no-pr hosted landing without exact-SHA checks;
- branch-no-pr hosted landing without landing authorization;
- branch cleanup without cleanup authorization;
- terminal receipt overclaiming archive-ready while residue remains;
- terminal receipt attempting archive relocation.

## Workstream 4: Evaluator Hook

Add packet terminal evaluator guidance and template. The evaluator consumes the
terminal run evidence map and emits structured lifecycle improvement findings.
It is required for blocked, nonterminal, cancelled, rollback, or repeated-retry
runs and optional for clean archive-ready runs.

The evaluator output is evidence-only. It cannot authorize terminal verdicts,
archive relocation, publication refresh, cleanup, branch mutation, promotion,
or closeout.

## Workstream 5: Lifecycle Hooks And Entry Points

Update the proposal lifecycle extension to expose packet terminal closeout as a
post-implementation packet lifecycle route.

Add a thin command and skill:

```text
/proposal-packet-terminal-closeout target=<packet-path> outcome=archive-ready
```

The entrypoint normalizes operator arguments into the profile and invokes the
workflow. It does not mint workflow authority by itself.

## Workstream 6: Feature Documentation

Add product feature documentation that explains:

- when packet terminal closeout runs;
- how it differs from closeout-packet, closeout-change, closeout-worktree,
  archive-proposal, and lifecycle-postmortem;
- what evidence it retains;
- how publication freshness repair works;
- how hygiene loops terminate;
- how Git/GitHub exact-SHA checks are triggered or reported as blockers;
- how archive-ready differs from archive relocation.

## Workstream 7: Validation And Publication

Run proposal, architecture, workflow, schema, validator, generated
publication, proposal lifecycle, closeout alignment, Git/GitHub, repo hygiene,
run-health, capability publication, extension publication, postmortem, and
architecture review validation required by the implementation.

Refresh generated projections only through owning publishers.

## Rollback

Rollback is atomic: remove the workflow, schemas, validators, tests, evaluator
guidance, product feature documentation, command, skill, and lifecycle hook
changes. Retain emitted terminal closeout evidence under state/evidence as
historical evidence.
