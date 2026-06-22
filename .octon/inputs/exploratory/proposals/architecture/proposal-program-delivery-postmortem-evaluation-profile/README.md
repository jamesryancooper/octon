# Proposal Program Delivery Postmortem Evaluation Profile

This child packet proposes a generic proposal-program delivery evaluation profile for the existing lifecycle postmortem mechanism.

The current built-in mechanism prepares retained post-run evidence and validates a broad postmortem structure. This child narrows one profile for completed proposal-program lifecycles so future postmortems consistently evaluate blocker chains, autonomy gaps, process efficiency, delivery proof chains, and follow-up proposal backlog candidates.

The profile remains evidence-only. It cannot authorize implementation, promotion, closeout, archive, delivery, cleanup, PR fallback, branch mutation, or `cleaned` claims.

## Useful Upgrades

- Bind proposal-program evidence explicitly: archived parent path, child terminal evidence, delivery receipt, terminal local evidence, lifecycle planner output, delivery workflow, delivery skill, assurance validators, and git helper evidence when present.
- Add a structured blocker taxonomy covering parent, child, linked proposal, generated artifact, lifecycle tooling or contract, worktree hygiene, git or delivery state, authorization boundary, and external permission scopes.
- Distinguish deterministic low-risk governed recovery from material effects that remain human-gated.
- Add efficiency diagnostics for full-registry churn, stale digest churn, generated-output refresh timing, repeated planner one-blocker discovery, repeated continue prompts, and local executor/runtime failures.
- Audit the delivery proof chain for archive, push, branch-no-PR landing, sync, cleanup authorization, branch cleanup, and cleaned claim when delivery evidence exists.
- Harden recommendation records with problem, proposed change, owning scope, autonomy gain, governance rationale, risks, acceptance criteria, suggested tests, and required governed route.
- Emit a postmortem-to-proposal handoff backlog that is evidence-only and suitable for later proposal creation after separate authorization.

## Generic Scope

The profile applies to completed `proposal-program` lifecycles. Delivery-specific sections are required only when delivery evidence exists; otherwise they must record `not_applicable` with evidence-backed reasoning.
