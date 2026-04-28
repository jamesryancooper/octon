# Migration / Cutover Plan

This architecture should land as an additive product lifecycle layer.

## Migration approach

1. Add contracts and validators first.
2. Add runtime compiler modules in prepare-only mode.
3. Add MVP CLI commands that create, inspect, and resolve Engagement,
   per-engagement Objective Brief, Work Package, and Decision Request artifacts
   but do not execute material effects.
4. Integrate run-contract candidate generation.
5. Add handoff to existing `octon run start --contract`.
6. Add generated operator projections only after canonical control/evidence
   surfaces are stable, and keep those projections non-authoritative.

## No big-bang replacement

Do not replace the current run-first lifecycle. Existing run commands remain valid and authoritative. The compiler prepares the first run; it does not become the runtime authority for material execution.

## Compatibility

Existing support-target and capability-pack posture remains unchanged.
Non-admitted connectors are stage-only, blocked, or denied in v1.
