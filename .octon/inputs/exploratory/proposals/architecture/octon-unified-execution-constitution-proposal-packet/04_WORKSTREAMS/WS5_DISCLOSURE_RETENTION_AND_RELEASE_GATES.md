# WS5 — Disclosure, retention parity, and final closeout gating

## Purpose

Make RunCard/HarnessCard, evidence retention, and final release/claim gates mandatory and universal.

## Audit findings addressed

F-07, F-08, F-10, F-11, F-14, F-15, F-17, F-18, F-20

## Exact repo paths / subsystems to change

- `.octon/framework/constitution/contracts/disclosure/**`
- `.octon/framework/constitution/contracts/retention/**`
- `.octon/instance/governance/disclosure/**`
- `.octon/instance/governance/contracts/**`
- `.octon/instance/governance/closure/**`
- `.octon/state/evidence/disclosure/**`
- `.github/workflows/unified-execution-constitution-closure.yml`
- `.github/workflows/release-please.yml`

## Deliverables

- RunCard required for every supported consequential run and HarnessCard required for release claims.
- Exact machine-readable final claim predicate for 'fully unified execution constitution'.
- Governance overlays made blocking in release and closeout workflows.
- Disclosure parity between supported live envelope, retained proof, and retention rules.

## Implementation sequence

1. **Stabilize the current path**
   - confirm the exact live behavior on the listed subsystems
   - write a red/green acceptance matrix before editing
2. **Implement the cutover in runtime terms**
   - make the new target-state surface real in code and emitted artifacts
   - keep compatibility only where the packet explicitly allows it
3. **Backfill evidence**
   - update run evidence, proof, disclosure, and governance overlays so the new truth path is inspectable
4. **Delete or demote obsolete scaffolding**
   - remove what is no longer load-bearing
   - where removal is unsafe in the same step, register a named retirement trigger and owner

## Acceptance criteria

- [ ] No release/closeout claim succeeds without full disclosure bundle, retention evidence, and governance review receipts.
- [ ] Final target-state claim predicate is encoded as a blocking manifest/checklist in-repo.
- [ ] RunCard/HarnessCard are routine, not closure-only, for the supported live envelope.
- [ ] Historical certification artifacts are explicitly subordinate to ordinary live disclosure.

## Dependencies

- `WS2`
- `WS3`
- `WS4`

## Claim criteria unlocked by this workstream

- Mandatory disclosure claim
- Retention parity claim
- Honest final closeout claim

## Required evidence before calling this workstream complete

- code diff showing the new live path
- updated contract/artifact examples where applicable
- routine run evidence from the supported consequential envelope
- validator or workflow output proving the new gate/path is enforced
- explicit deletion or retirement note for any legacy surface touched

## Anti-patterns to avoid

- leaving the old surface on the critical path while calling the new one canonical
- proving the workstream only with a special closure or migration run
- treating new schema files as sufficient evidence of runtime completion
- widening support or claims during the workstream before proof/disclosure catch up
