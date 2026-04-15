# Packet Execution Contract

This file is the single source of truth for generic packet-execution behavior
within the `octon-concept-integration` family.

## Baseline Execution Bundle

The baseline packet execution surface is:

- `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/packet-to-implementation/stages/01-implement-packet.md`

Packet-generation bundles may target that execution surface directly or use it
as the baseline for implementation-prompt generation.

## Execution Expectations

Packet execution must:

- treat the packet as execution input rather than authority,
- re-ground the live repo before making implementation claims,
- detect packet-time drift and stop when execution would become unsafe,
- select validators appropriate to the packet kind,
- retain evidence and residual risk disclosures,
- and only claim closeout readiness when the implemented result is validated
  and no longer depends on proposal-only truth.
