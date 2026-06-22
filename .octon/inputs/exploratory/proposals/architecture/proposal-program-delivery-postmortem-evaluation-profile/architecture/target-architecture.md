# Target Architecture

Extend `octon lifecycle postmortem` and `validate-lifecycle-postmortem.sh` with a proposal-program delivery evaluation profile.

## Target Behavior

- A completed proposal-program lifecycle can produce postmortem evidence under the existing lifecycle postmortem evidence root.
- The postmortem evaluator input can request the proposal-program delivery profile without losing the generic lifecycle postmortem contract.
- The profile binds relevant proposal-program evidence:
  - parent status and archived location;
  - child terminal status summaries;
  - retained-run evidence indexes;
  - parent and child closeout or archive evidence;
  - lifecycle planner route and blocker outputs;
  - delivery workflow receipt and terminal local evidence when present;
  - relevant validator, generated artifact, hygiene, and git/delivery proof refs.
- The profile emits structured sections for:
  - lifecycle timeline;
  - complete blocker map and owning scopes;
  - autonomy gaps;
  - efficiency gaps;
  - safety boundaries that should remain human-gated;
  - delivery proof-chain audit;
  - recommendation backlog;
  - regression test plan;
  - proposed next governed routes.

## Non-Authority Boundary

Postmortem profile outputs are retained evaluation evidence only. They do not authorize lifecycle transitions, repair child evidence, promote proposals, close out proposals, archive proposals, perform delivery, delete files, mutate branches, create PRs, or claim `cleaned`.

## Genericity Requirement

The profile must run for any completed proposal-program lifecycle. Branch-no-PR, cleanup, and cleaned-claim sections must degrade to evidence-backed `not_applicable` records when a completed program did not run delivery.
