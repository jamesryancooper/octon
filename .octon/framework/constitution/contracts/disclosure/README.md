# Constitutional Disclosure Contracts

`/.octon/framework/constitution/contracts/disclosure/**` defines normalized
disclosure artifacts for consequential runs and system-level claims.

## Live Status

Disclosure is now part of the live atomic execution model while remaining
subordinate to durable authority and retained evidence.

- RunCards summarize one consequential run from bound authority, retained
  evidence, structural/governance proof planes, observability, and replay
  references
- HarnessCards summarize one system-level support, benchmark, or release claim
  from support-target declarations plus retained proof bundles
- RunCards, HarnessCards, and release summaries may cite
  `publishable-evidence-receipt-v1` records when a hosted, shared, or
  release-facing claim summarizes private or local-only evidence
- local-only raw evidence remains represented by digest-backed local evidence
  refs inside publishable evidence receipts or by explicit disclosure
  limitations; raw payloads are not copied into disclosure artifacts
- disclosure never mints authority, widens support, or overrides the bound run
  contract

## Canonical Files

- `family.yml`
- `run-card-v2.schema.json`
- `harness-card-v2.schema.json`

## Canonical Roots

- Authored HarnessCard source: `/.octon/instance/governance/disclosure/`
- RunCards: `/.octon/state/evidence/disclosure/runs/<run-id>/`
- HarnessCards: `/.octon/state/evidence/disclosure/releases/<release-id>/`

Historical lab-local HarnessCard mirrors may remain under
`/.octon/state/evidence/lab/harness-cards/`, but they are no longer canonical
for supported live disclosure.

## Compatibility/Historical Surfaces

- `run-card-v1.schema.json`
- `harness-card-v1.schema.json`
- `/.octon/state/evidence/lab/harness-cards/**`

## Non-Authority Note

Generated effective closure views, run-local disclosure mirrors, and
historical lab-local HarnessCards remain derived or historical surfaces only.
They must not override authored disclosure or the active release bundle.

Generated read models may point at disclosure artifacts and publishable
evidence receipts as operator context only. They do not satisfy retained
evidence, support-proof, closeout, archive, policy, or authority gates.

## Validator Obligations

- `validate-bounded-claim-nomenclature.sh`
- `validate-review-packet-freshness.sh`
- `validate-contract-family-version-coherence.sh`
