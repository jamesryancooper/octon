# Migration / Cutover Plan

## Cutover profile

Use a **stage-first connector admission cutover**.

The migration does not turn on live external capability execution. It creates:
- contracts;
- governance roots;
- control/evidence roots;
- CLI inspection/admission commands;
- validators;
- generated read-model targets;
- sample stage-only fixture.

## Steps

1. Add portable connector contracts under `framework/**`.
2. Add repo-specific connector governance roots under `instance/**`.
3. Add control/evidence root conventions under docs and validators.
4. Add stage-only fixture connector, preferably a no-op/local metadata connector.
5. Add CLI inspect/admit/quarantine/retire surfaces.
6. Wire runtime checks so material connector invocation remains denied unless operation is live-effectful, proof-backed, authorized, and effect-token verified.
7. Add generated projections only after canonical authored/control/evidence roots exist.
8. Run validators.
9. Retain promotion evidence.

## No-migration areas

No existing connector runtime is assumed to be live. Browser/API/MCP effectful execution remains deferred unless admitted separately through this new model.
