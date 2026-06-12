# Target Architecture

## Decision

Add `proposal-packet-terminal-closeout` as the canonical packet lifecycle
terminalization workflow for implemented proposal packets.

The workflow owns terminal readiness sequencing and the packet-local aggregate
receipt. It does not own the material side effects that it coordinates.

## Workflow State Machine Sketch

The workflow is resumable and state-driven. Each state records its input refs,
validator commands, output evidence refs, and re-entry condition.

1. `bind-profile`
   - Bind the packet path, target outcome, route preference, PR policy,
     publication policy, hygiene policy, and non-authority boundaries.
   - Stop if the packet is not an implemented proposal packet or if the profile
     asks for forbidden authority.
2. `verify-durable-implementation-state`
   - Confirm promotion targets exist or have explicit not-applicable rationale.
   - Run the state-machine, closeout-worktree, lifecycle-alignment,
     default-work-unit, Git/GitHub, hosted-no-PR, generated/input
     non-authority, run-health, capability publication, and extension
     publication validators needed for the packet's scope.
3. `verify-implementation-conformance`
   - Require current `support/implementation-conformance-review.md`.
   - Run the implementation conformance validator.
4. `verify-post-implementation-drift`
   - Require current `support/post-implementation-drift-churn-review.md`.
   - Run the post-implementation drift/churn validator.
5. `validate-publication-freshness`
   - Run runtime route, capability, extension, generated projection, and
     proposal registry freshness validators required by changed targets.
   - When a freshness check fails, refresh only through the canonical publisher
     for that artifact family.
   - Rerun the failed validator and adjacent projection validators.
6. `classify-repo-hygiene`
   - Classify repo-hygiene residue.
   - Delete only through repo-hygiene cleanup authorization and helper paths.
   - Retain durable evidence unless a higher retention policy authorizes
     retirement.
7. `classify-worktree-hygiene`
   - Run proposal worktree hygiene classification.
   - If non-packet residue blocks hygiene, stop with the exact next route,
     usually closeout-worktree or closeout-change.
8. `run-evidence-only-reviews`
   - Run post-integration architecture review after conformance and drift pass.
   - Run packet terminal evaluator or lifecycle-postmortem when configured or
     when the terminal run is blocked, nonterminal, cancelled, or unusually
     retried.
   - Treat both outputs as evidence-only.
9. `resolve-git-github-route`
   - If no Git mutation is required, record not-applicable route evidence.
   - If mutation is required, delegate to closeout-change or closeout-worktree.
   - When branch-no-pr hosted landing is selected, require provider preflight,
     exact source-SHA checks, governed landing authorization, branch cleanup
     authorization, fetch, sync, and local/main/origin equality proof through
     the existing Git/GitHub route.
   - If checks are missing but route policy allows hosted checks, trigger the
     canonical branch/check path. If checks fail, record the exact failing
     check, SHA, workflow, and next route.
10. `emit-terminal-receipt`
    - Emit the packet-local aggregate terminal receipt.
    - Verdict is `archive-ready` only when every required gate passed, all
      expected retained evidence is current, and hygiene is not blocked.
    - Verdict is `blocked` with exact blocker and next canonical route
      otherwise.

## Terminal Receipt Schema Expectations

Add `proposal-packet-terminal-closeout-receipt-v1`. The receipt must include:

- `schema_version`;
- packet id, packet path, proposal kind, packet status, and terminal run id;
- target outcome and actual verdict;
- profile digest and profile validation evidence;
- durable implementation state evidence refs;
- implementation conformance receipt and validator refs;
- post-implementation drift/churn receipt and validator refs;
- publication freshness validators, publisher refresh receipts, and rerun refs;
- generated/input non-authority validation refs;
- run-health and capability or extension publication validation refs;
- repo-hygiene classification and cleanup authorization refs, when applicable;
- worktree hygiene classification refs;
- post-integration architecture review support receipt refs;
- packet terminal evaluator or lifecycle-postmortem refs, when applicable;
- Git/GitHub route refs, exact-SHA check refs, and branch authorization refs,
  when applicable;
- final archive-ready or blocked verdict;
- blocker class, blocker detail, and next canonical route for blocked results;
- retained evidence inventory and expected-no-new-evidence-loop declaration;
- explicit non-authority declarations for proposal inputs, generated outputs,
  generated prompts, host state, dashboards, chat, tool state, and model
  memory.

## Evidence Retention Model

The workflow must define the expected retained evidence set before running
terminal checks. Expected evidence includes the profile validation, terminal
receipt, validator outputs, publisher receipts, hygiene classifier outputs,
cleanup authorization receipts when cleanup occurs, Git/GitHub route receipts
when Git mutation occurs, evidence-only review outputs, and final verdict.

The final receipt must distinguish:

- retained authoritative evidence owned by existing routes;
- retained evidence-only review outputs;
- private local raw evidence;
- repo-publishable evidence receipts;
- generated read models and projections;
- proposal-local lineage.

If generating required evidence creates new residue, the workflow classifies
that residue before claiming terminality. It may loop only while newly created
evidence is within the expected retained evidence set. Unexpected residue
blocks with the exact owner route.

## Packet Postmortem And Evaluator Hook

Add a packet terminal evaluator hook that can reuse lifecycle-postmortem
evidence binding or add a packet-specific evaluator template. The hook is:

- required for blocked, nonterminal, cancelled, rollback, or repeated-retry
  terminal runs;
- optional for clean archive-ready runs;
- evidence-only in every case;
- used to generate structured lifecycle improvement findings;
- forbidden from authorizing closeout, archive, promotion, publication,
  cleanup, branch landing, branch deletion, or Git mutation.

## Git/GitHub Exact-SHA Handling

The workflow does not invent Git or GitHub authority. It validates or delegates
to the existing default work-unit and change-closeout state machine routes.

When hosted checks are required:

- the source branch must be pushed before exact-SHA check evaluation;
- required checks must be evaluated at the exact source SHA;
- branch-no-pr hosted landing must have provider no-PR preflight evidence;
- branch-no-pr hosted landing must have governed landing authorization;
- branch cleanup must have governed cleanup authorization;
- final sync must prove local `main`, `origin/main`, and landed ref alignment;
- failed or missing checks produce a blocked terminal receipt with exact check
  and SHA evidence.

## Publication Freshness Handling

The workflow must run freshness validators for publication families touched by
the packet's promotion targets. A failed freshness check has only one repair
path: invoke the owning canonical publisher. After publisher refresh, rerun the
failed validator and adjacent projection validators. Direct edits to generated
outputs are invalid.

## Placement Rationale

This belongs in packet lifecycle because the subject is packet terminal state:
implementation conformance, drift/churn, packet receipts, packet support files,
proposal status, archive readiness, and packet-local aggregate evidence.

It does not belong in closeout-worktree because that wrapper decomposes dirty
worktree residue into Change candidates and must not become packet lifecycle
authority.

It does not belong in closeout-change because Change closeout owns Git route,
receipt, rollback, cleanup, and sync semantics, not packet conformance,
publication freshness, or archive readiness.

It does not belong in archive-proposal because archive-proposal owns archive
relocation after readiness is proven. Terminal closeout may authorize an
archive-ready verdict, but archive-proposal remains the movement route.

It does not belong in lifecycle-postmortem because postmortem is optional,
read-only, post-run, evidence-only, and cannot authorize lifecycle transition
or archive readiness.
