# Assumptions and Blockers

## Assumptions

1. v1/v2/v3 surfaces may not yet exist in the live repo; this v4 packet is written against the expected progression and requires fail-closed compatibility if prior layers are absent.
2. The live support-target posture remains bounded-admitted-finite.
3. Browser/API capability packs remain non-live unless separately admitted.
4. Connector admission must not silently widen support claims.

## Blockers

1. Full effectful MCP/API/browser support requires proof not currently present.
2. Release Envelope requires a later proposal.
3. Stewardship Portfolio requires v3 and at least two program/repo surfaces.
4. Campaign promotion requires evidence-backed go decision.

## Compatibility shim

If prior v1-v3 runtime surfaces are absent, implementation should still land contracts/governance/validators and expose connector commands in inspect/stage-only fail-closed mode.
