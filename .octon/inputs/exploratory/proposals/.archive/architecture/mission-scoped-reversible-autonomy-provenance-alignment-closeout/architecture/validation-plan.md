# Validation Plan

## Goal

Prove that the provenance closeout is complete, historically coherent, and
runtime-neutral.

The implementation audit in
[`../resources/implementation-audit.md`](../resources/implementation-audit.md)
is the baseline for why this packet exists. The validation burden here is not
to re-prove MSRAOM runtime semantics from scratch, but to prove that the repo's
proposal lineage, decision trail, migration discovery, and operator guidance
now match the already-landed `0.6.3` runtime closeout.

## Proof strategy

Validation must prove all of the following on the same final tree:

1. proposal manifests and archive metadata are structurally valid
2. the generated proposal registry projects the normalized archive correctly
3. decision and migration discovery point to the new provenance-closeout record
4. canonical docs point readers to runtime/governance truth first and proposal
   lineage second
5. no runtime, policy, schema, control-truth, or generated-runtime semantic
   surface changed in the same branch

No single validator is sufficient. This closeout is proven only by the
combination of proposal validation, registry regeneration, doc-alignment
checks, index review, and no-runtime-delta inventory.

## Validation execution order

### 1. Proposal and archive integrity

- `validate-proposal-standard.sh --all-standard-proposals`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout`
- manual check of the normalized archived manifests for:
  - `status: archived`
  - archive metadata
  - `original_path`
  - `promotion_evidence`

Purpose:

- prove the current implementing packet is valid
- prove the archived steady-state and final-closeout packets are no longer
  malformed historical records
- prove the archive corpus can project without ambiguous lifecycle state

### 2. Proposal discovery integrity

- `generate-proposal-registry.sh --check`
- `test-generate-proposal-registry.sh`
- manual review of `/.octon/generated/proposals/registry.yml`

Purpose:

- prove the generated registry exactly matches the manifest corpus
- prove the normalized archived MSRAOM packets project into discovery
- prove the registry does not silently omit promoted historical packets

### 3. Architecture and documentation alignment

- `validate-version-parity.sh`
- `validate-architecture-conformance.sh`
- `alignment-check.sh --profile harness,mission-autonomy`

Purpose:

- prove the repo remains at a coherent `0.6.3` steady state
- prove the updated README, START, and architecture docs agree with the runtime
  authority model
- prove proposal lineage is treated as historical guidance rather than runtime
  dependency

### 4. Decision, migration, and evidence integrity

- manual structural review of:
  - `/.octon/instance/cognition/decisions/index.yml`
  - `/.octon/instance/cognition/context/shared/migrations/index.yml`
  - the new provenance-closeout ADR
  - the new migration plan
  - the required evidence-bundle file set

Purpose:

- prove there is one durable closeout ADR for provenance normalization
- prove migration discovery and decision discovery point at real records
- prove the evidence bundle contract is complete enough for promotion

### 5. No-runtime-delta proof

- diff inventory review of changed files
- manual confirmation that no changed file falls under:
  - runtime helper surfaces
  - mission-autonomy policy or ownership authority
  - live control truth
  - retained run/control evidence
  - generated runtime/effective/read-model outputs

Purpose:

- prove this packet is genuinely provenance-only
- block merge if runtime remediation is smuggled into a proposal-hygiene branch

## Blocking validator set

- `validate-proposal-standard.sh --all-standard-proposals`
- `generate-proposal-registry.sh --check`
- `validate-version-parity.sh`
- `validate-architecture-conformance.sh`
- `alignment-check.sh --profile harness,mission-autonomy`

## Required structural checks

The final tree must prove:

1. the archived steady-state and final-closeout proposal manifests are valid and archived
2. the generated registry includes those archived packets coherently
3. one new provenance-closeout ADR exists and is indexed
4. one new provenance-closeout migration plan exists and is indexed
5. the matching migration evidence bundle location is declared and populated with
   the expected file contract
6. canonical docs no longer require readers to infer MSRAOM closeout from
   runtime state alone
7. the current implementing proposal is archived only in the final closeout
   transaction, not prematurely

## Required evidence bundle

The cutover is not proven until the branch can show a provenance-closeout
evidence bundle under:

`/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/`

Required files:

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`

## Exit signal

The provenance-alignment cutover is validated only when:

- proposal validation is green
- the registry generator is green against the same tree
- decision and migration discovery are updated coherently
- docs and architecture surfaces point to the correct authority roots
- the no-runtime-delta inventory is clean
- no acceptance criterion remains unmet
