# Target Architecture

## Decision

Add `proposal-program-delivery` as the first concrete mode of a native
Governed Proposal Delivery process.

The mode delivers a proposal program to a target outcome, usually `cleaned`,
by coordinating target-owned lifecycles and validating their receipts. It is a
cross-lifecycle delivery runner, not another orchestration prompt and not an
expansion of `proposal-program` into Git or cleanup authority.

## Ownership Boundary

The delivery workflow owns:

- selecting the next target-owned lifecycle from current repo state;
- passing scoped non-authorizing context to that lifecycle;
- validating the lifecycle's returned receipt;
- replanning after every material state change;
- aggregating cited evidence into the final delivery receipt.

The delivery workflow does not own:

- parent or child proposal lifecycle transitions;
- child implementation, review, conformance, drift, closeout, or archive
  receipts;
- generated publication;
- governed mechanism integration verification;
- Change route selection or Change receipt truth;
- branch-no-pr landing authorization;
- branch cleanup authorization;
- repo-hygiene deletion authorization;
- terminal current-state proof authority;
- final acceptance of a cleaned claim.

Those remain owned by their existing workflows, validators, schemas, and
receipt contracts.

## Delivery Profile

Add `proposal-program-delivery-profile-v1` as a schema-backed profile consumed
by the delivery workflow.

The profile must declare:

- target program path;
- target outcome, usually `cleaned`;
- route preference, such as `branch-no-pr`;
- PR policy, including a strict "do not create PR; block if branch-no-pr is
  impossible" option;
- stash policy, with `forbidden` as the conservative default;
- child execution mode and dependency strategy;
- required proposal validators;
- required implementation validators;
- required generated publication checks;
- mechanism-specific validators;
- required closeout validators;
- residue and hygiene expectations;
- terminal proof requirements;
- final sync requirements.

The profile validator must fail when a required surface is omitted without an
explicit out-of-scope or not-applicable rationale. Profile validation proves
delivery intent and guardrails; it does not authorize any target lifecycle.

## Delivery Receipt

Add `proposal-program-delivery-receipt-v1` as the aggregate evidence contract.
The delivery workflow writes one final receipt and may also write checkpointed
attempt receipts under the retained run evidence root.

The final receipt must cite, not replace:

- parent proposal lifecycle result;
- every child packet result;
- child-owned review receipts;
- child-owned implementation receipts;
- child-owned conformance receipts;
- child-owned drift/churn receipts;
- child-owned closeout receipts;
- child-owned archive receipts;
- generated registry and publication evidence;
- governed mechanism integration evidence when applicable;
- lifecycle residue cleanup evidence;
- Change receipt;
- branch landing authorization;
- branch cleanup authorization;
- terminal current-state proof;
- correction-branch aggregate receipt when needed;
- final `main == origin/main == landed_ref` proof;
- final worktree hygiene result.

The delivery receipt must carry explicit non-authority classification for raw
inputs, proposal-local files, generated prompts, generated outputs, host state,
dashboards, chat, model memory, and tool availability.

## Execution Sequence

The workflow sequence is state-driven, not fixed prose. The initial mode should
cover this normal path:

1. Bind the profile, target program, route preference, outcome, and non-authority
   rules.
2. Validate parent proposal-program freshness and child registry integrity.
3. Run or resume the proposal-program lifecycle through child execution using
   the existing proposal lifecycle owner.
4. Validate every child-owned proposal review, implementation, conformance,
   drift/churn, closeout, and archive receipt.
5. Refresh or validate generated proposal registry and generated publication
   evidence through the owning publishers.
6. Run governed mechanism integration verification when any child changes a
   governed mechanism.
7. Resolve lifecycle residue cleanup through the proposal lifecycle and
   repo-hygiene cleanup owner.
8. Hand off the coherent Change candidate to closeout-worktree or
   closeout-change.
9. For `branch-no-pr`, validate governed landing authorization before hosted
   mutation.
10. Validate branch cleanup authorization before deleting local or remote source
    refs.
11. Fetch, sync local `main`, and prove local `main`, `origin/main`, and
    `landed_ref` equality.
12. Emit terminal current-state proof after the final mutation.
13. Validate final worktree hygiene before claiming `cleaned`.

At every step, missing, stale, ambiguous, or overclaiming receipt evidence
blocks delivery or downgrades the outcome.

## Hard Gates

The delivery workflow must hard-gate:

- parent and child proposal lifecycle receipts are fresh and passing;
- no parent summary substitutes for child receipts;
- implementation conformance passes;
- post-implementation drift/churn passes;
- generated projections and proposal registries are fresh;
- governed mechanism integration verification passes for governed mechanism
  changes;
- lifecycle residue cleanup is resolved or explicitly blocked;
- branch-no-pr authorization validates before hosted mutation;
- branch cleanup authorization validates before branch deletion;
- terminal current-state proof exists after the final mutation;
- worktree is clean before claiming `cleaned`;
- local `main` is synced to `origin/main`.

## Advisory Evidence

The delivery workflow may cite these as evidence-only until a later policy
promotes them:

- lifecycle postmortem;
- current-state mechanism architecture review findings;
- design quality recommendations;
- operator ergonomics recommendations;
- future rollout suggestions.

## Operator Entry Point

Add a thin command and skill:

```text
/proposal-program-delivery target=<program-path> route=branch-no-pr outcome=cleaned
```

The command should normalize arguments into the delivery profile and then
dispatch the workflow. The command and skill are entrypoints only; they do not
mint delivery, proposal, closeout, Git, publication, or cleanup authority.
