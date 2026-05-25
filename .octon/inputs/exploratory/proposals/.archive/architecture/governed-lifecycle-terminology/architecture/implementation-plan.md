# Implementation Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `rationale`: The change updates current product terminology, validator
  expectations, and generated projections together so live docs and validation
  remain aligned.

## Sequence

1. Verify the packet has a passing implementation-grade completeness receipt.
2. Review and accept the packet with implementation authorization.
3. Generate an executable implementation prompt from the packet.
4. Rename the current product feature note and roadmap note to governed
   lifecycle paths if validator and catalog changes can keep navigation intact.
5. Update product feature catalog id, name, summary, roles, and related refs to
   use `Governed Lifecycle Orchestration`.
6. Update product roadmap title and active roadmap item ids to use governed
   lifecycle terminology unless an item is explicitly legacy.
7. Update product validators and validator tests to enforce the new file names,
   feature id, and required boundary phrases.
8. Update current runtime/spec/extension prose where it names the current
   lifecycle capability as `Lifecycle Autopilot`.
9. Regenerate generated effective projections only from authored extension
   inputs when authored extension inputs changed.
10. Regenerate proposal registry projection.
11. Run focused validators and tests.
12. Write implementation-run, implementation-conformance, drift/churn, and
    validation receipts.

## Required Boundary Checks

- No new proposal manifest statuses.
- No route, schema, lifecycle id, or contract primitive named `Governed
  Lifecycle Control Loop`.
- No casual shortening of `Governed Lifecycle Orchestration` to
  `orchestration`.
- Generated projections remain derived-only.
- Proposal-local receipts remain non-authoritative.
- Runner/executor boundary wording remains intact.

## Minimality

The implementation should use targeted semantic edits and file renames for
current product capability surfaces. It should not rewrite archived evidence or
proposal history unless the text is part of active current product guidance.
