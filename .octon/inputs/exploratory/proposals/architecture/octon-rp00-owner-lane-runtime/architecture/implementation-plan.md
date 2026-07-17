# Implementation Plan

## Preconditions

- Keep the implementation on a clean branch rooted at the exact current
  `origin/main`; do not mutate the dirty primary worktree or frozen candidate.
- Require accepted proposal review, strict pre-integration architecture review,
  and a fresh reviewed packet digest before code changes.
- Reconcile every durable edit to the manifest promotion targets.

## Atomic work

1. Define and register the nine strict owner-lane lifecycle schemas. Share
   common identifiers through duplicated strict definitions only where JSON
   Schema `$ref` resolution would introduce runtime network or path ambiguity.
2. Add the provider-repository mutation effect kind, authority issuance and
   verification, material inventory, and authorization coverage.
3. Implement `owner_lane.rs` as a closed state machine with pure validation and
   injectable process/HTTP boundaries. Add the kernel CLI and fixed askpass
   helper.
4. Add pre-send/response journaling, request digests, conditional observations,
   outcome-unknown reconciliation, terminalization, local destruction, and
   secret census.
5. Correct only the provider-authority lifecycle blocker path; preserve generic
   missing-evidence behavior.
6. Extend the GitHub control-plane contract/runbook to point to the executable
   boundary and its non-authority/support constraints.
7. Execute the full owner-lane runtime against a hermetic GitHub/Git fixture,
   retain its run and denial evidence, then update the existing live GitHub
   admission, dossier, and proof bundle to name only the exact owner-lane
   operation and those current proofs.
8. Run formatting, unit tests, shell fault fixtures, proposal validators,
   contract registry validation, material inventory/coverage validation,
   support proof/live-claim validation, conformance, drift, and diff hygiene.

## Rollback

Before first live use, rollback is a file-level revert of this packet's durable
targets. After any issuance attempt or provider request, code rollback cannot
erase credential or provider state; recovery follows the retained journal,
never resends an unknown request, and terminalizes the same credential.
