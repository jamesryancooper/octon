# Run Program to Clean Delivery

Run proposal program delivery through the canonical workflow-backed wrapper:

```text
/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>
```

This operator-facing command is an alias for:

```text
/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>
```

It delegates to `proposal-program-delivery` and
`.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.

## Required Inputs

- `target`: repo-relative path to the accepted proposal program.
- `outcome`: delivery target outcome. Use `cleaned` for clean delivery.
- `profile`: required `proposal-program-delivery-profile-v1` profile path.
- `run-id`: required delivery run identifier for retained evidence paths.

Missing `profile` or `run-id` fails closed before mutation unless satisfied by
fresh, target-bound workflow evidence allowed by the canonical
`proposal-program-delivery` contract.

## Authority Boundary

This alias does not create an independent lifecycle contract, workflow id,
skill authority, closeout rule, archive rule, cleanup rule, Git mutation rule,
branch cleanup rule, generated publication rule, receipt schema, profile
schema, terminal proof rule, or target-owned evidence substitute.

Proposal-local support files, generated prompts, generated outputs, dashboards,
host/tool/chat state, model memory, parent summaries, aggregate delivery
receipts, and delivery evidence indexes do not satisfy delivery admission
inputs or child-owned receipt requirements.
