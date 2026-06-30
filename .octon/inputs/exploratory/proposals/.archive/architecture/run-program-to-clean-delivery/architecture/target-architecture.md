# Target Architecture

## Decision

Add `run-program-to-clean-delivery` as a governed end-to-end lifecycle
capability that composes existing proposal-program lifecycle execution and
Proposal Program Delivery rather than replacing either.

The cleanest architecture is a small set of coordinated changes:

- a proposal-program runner mode or profile that can continue from accepted
  program state into delivery readiness;
- delivery workflow hardening so the default target is `cleaned` and
  branch-no-pr is selected only when policy allows and no PR predicate exists;
- route-owned stale receipt refresh and generated metadata refresh at stable
  digest boundaries;
- worktree hygiene handoff that can resolve exact-scope foreign residue without
  repeated operator prompts;
- publishable landing and cleanup evidence retention before local terminal
  evidence synthesis;
- terminal validation that proves `HEAD`, `main`, `origin/main`, residue
  classification, terminal proof, and disclosure-tier correctness.

## Existing Surfaces To Reuse

- `octon lifecycle run --lifecycle proposal-program --target <program> --execute-routes`
- `/proposal-program-delivery target=<program> outcome=cleaned`
- `closeout-change`
- `closeout-worktree`
- `repo-hygiene-cleanup`
- branch-no-pr preflight, landing authorization, landing, cleanup
  authorization, and branch cleanup helpers
- `write-terminal-closeout-local-evidence.sh`
- proposal registry and artifact index generators
- proposal program, child readiness, closeout, conformance, drift/churn,
  delivery, Change closeout, evidence disclosure, and terminal proof validators

## Authority Model

The new capability is an orchestration profile and route-selection improvement,
not a new authority root. It may sequence and retry route-owned steps, but it
must cite child-owned and Change-owned evidence instead of replacing it.

## Stop Conditions

The capability must stop for missing implementation authorization, failed
validators without route-owned correction, child authority conflicts, unresolved
foreign ownership, unsafe mutations, provider rules requiring PR, external
approval, stale or denied landing/cleanup authorization, or explicit operator
override.
