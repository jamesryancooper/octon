# Acceptance Criteria

The proposal may be promoted only when all criteria below are satisfied.

## Architecture criteria

- [ ] The promoted architecture preserves Octon's distinction between the
      Constitutional Engineering Harness and Governed Agent Runtime.
- [ ] The Run Journal is defined as control/evidence substrate, not a rival
      Control Plane.
- [ ] Authored authority remains under `framework/**` and `instance/**`.
- [ ] Live run control truth remains under `state/control/execution/**`.
- [ ] Retained evidence remains under `state/evidence/**`.
- [ ] Generated/read-model outputs remain derived-only and non-authoritative.
- [ ] Proposal promotion targets remain within `.octon/**`.

## Contract criteria

- [ ] `run-event-v2.schema.json` exists and validates typed, causal,
      hash-linked events.
- [ ] `run-event-ledger-v2.schema.json` exists and validates manifest integrity.
- [ ] `runtime-state-v2.schema.json` exists and explicitly derives from journal.
- [ ] `state-reconstruction-v2.md` defines deterministic reconstruction and
      drift handling.
- [ ] Runtime spec surfaces are aligned with constitutional runtime contracts.

## Runtime criteria

- [ ] `runtime_bus` is the sole canonical append path.
- [ ] Material side effects cannot occur before valid authorization and journal
      refs exist.
- [ ] Capability invocation event pairs are emitted for supported capability
      packs.
- [ ] Checkpoint, resume, rollback, and closeout events are emitted and linked to
      side artifacts.
- [ ] `runtime-state.yml` can be reconstructed from `events.ndjson`.
- [ ] Replay defaults to dry-run/sandbox and cannot repeat live side effects
      without new authorization.

## Evidence criteria

- [ ] Every consequential fixture Run has a retained closeout evidence bundle.
- [ ] Evidence snapshot hashes match the control journal at closure.
- [ ] Operator read models include source refs, freshness, and non-authority
      classification.
- [ ] Redaction, if used, preserves lineage and auditability.

## Assurance criteria

- [ ] `validate-run-journal-contracts.sh` exists and passes on valid fixtures.
- [ ] The validator fails closed on missing events, reordered events, hash
      mismatches, generated authority misuse, and replay side-effect attempts.
- [ ] Architecture conformance validation invokes the Run Journal validator.
- [ ] Support-target admission validation requires journal/reconstruction proof.

## Closure criteria

- [ ] A closure certification record lists the promoted files, validator outputs,
      fixture runs, negative tests, evidence roots, and unresolved exceptions.
- [ ] No browser/API/MCP/frontier-support admission is claimed by this proposal.
- [ ] The proposal is archived or closed under Octon's proposal lifecycle after
      promotion or rejection.
