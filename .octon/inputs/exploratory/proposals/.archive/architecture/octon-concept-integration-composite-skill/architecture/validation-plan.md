# Validation Plan

## Validation Goals

Prove that the landed capability is:

1. structurally valid as an extension pack
2. publishable through the existing extension pipeline
3. visible through generated capability routing and host projections
4. able to generate a standard-valid architecture proposal packet
5. able to attach a packet-specific executable implementation prompt without
   bypassing the proposal-packet-first model

## Required Validation Layers

### 1. Extension-pack contract validation

Run the additive pack validator against the new pack and confirm:

- `pack.yml` satisfies `octon-extension-pack-v3`
- required contract references are present and valid
- content entrypoints point at legal pack buckets
- provenance and trust hints are structurally valid

### 2. Extension publication validation

With the pack enabled in repo-owned desired state:

- publish extension state
- confirm the pack survives quarantine
- confirm `generated/effective/extensions/catalog.effective.yml` includes the
  pack and its `routing_exports`
- confirm the published pack contains the projected command and skill assets

### 3. Capability routing validation

After extension publication:

- republish capability routing
- confirm the extension command appears in
  `generated/effective/capabilities/routing.effective.yml`
- confirm the extension skill appears in
  `generated/effective/capabilities/routing.effective.yml`
- confirm artifact provenance records the extension origin correctly

### 4. Host projection validation

Republish host projections and confirm the new command and skill are
materialized for supported host adapters without introducing stale or orphaned
entries.

### 5. End-to-end functional validation

Run the capability against a bounded sample source and confirm it:

- performs prompt-set preflight alignment when required
- generates extraction output
- generates verification output
- materializes a standard-valid architecture proposal packet
- generates a packet-specific executable implementation prompt as support
  material
- retains run evidence under `state/evidence/**`

### 6. Proposal-packet validation

Validate the emitted proposal packet with:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`

## Minimum Evidence For Closure

- one clean extension-pack contract validation run
- one clean extension publication run with no blocking quarantine for the pack
- one clean capability routing publication run showing both command and skill
  exports
- one clean host projection validation run
- two consecutive clean proposal-packet validation passes from an actual
  capability run

## Explicit Non-Goals For Validation

- No support-target widening proof is required.
- No new capability-pack admission proof is required.
- No workflow-classification changes are required unless a later design adds a
  workflow wrapper.
