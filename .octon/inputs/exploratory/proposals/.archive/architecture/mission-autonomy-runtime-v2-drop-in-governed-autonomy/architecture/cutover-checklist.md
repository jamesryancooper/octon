# Cutover Checklist

## Pre-promotion

- [x] v1 Engagement / Project Profile / Work Package surfaces exist or fail-closed compatibility shims are clearly staged.
- [x] v2 schemas validate.
- [x] Mission continuation defaults fail closed.
- [x] CLI commands parse and are documented.
- [x] Prepare-only Mission Runner path is safe.
- [x] Mission Runner executes through existing run lifecycle and authorization.
- [x] Mission Queue, Continuation Decision, and Mission Run Ledger persist under `state/control/**`.
- [x] Mission evidence persists under `state/evidence/**`.
- [x] Generated read models remain projections only.
- [x] Connector admission defaults stage-only/blocked.
- [x] Validation suite passes except for documented pre-existing FCR-025 route-bundle digest drift in the broad runtime suite.

## Activation sequence

1. Promote contracts.
2. Promote policies.
3. Promote validators.
4. Promote runtime/CLI implementation.
5. Run static validation.
6. Run prepare-only mission continuation fixture.
7. Run repo-local single-run continuation fixture.
8. Run blocker fixture for expired lease.
9. Run blocker fixture for exhausted budget.
10. Run blocker fixture for tripped breaker.
11. Run blocker fixture for connector drift.
12. Publish operator docs.
13. Retain promotion evidence.
14. Archive proposal packet.

## Stop conditions

- Any material path bypasses authorization.
- Generated/input path becomes authority.
- Mission Queue replaces run lifecycle.
- Mission Run Ledger replaces run journals.
- Continuation proceeds despite failed gates.
- Connector operation executes effectfully without admission and authorization.
