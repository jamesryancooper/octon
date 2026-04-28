# Rollback Plan

## Rollback trigger

Rollback if any of the following occur:

- Connector commands bypass run lifecycle or authorization.
- Generated connector projections are consumed as authority.
- Support-target claims are widened without proof.
- Live external execution becomes possible without trust dossier and authorization.
- Validators fail in a way that permits unsafe connector posture.
- Stage-only connectors can mutate external systems.

## Rollback procedure

1. Disable connector CLI commands by routing them to inspect-only fail-closed mode.
2. Remove or quarantine connector admissions under `instance/governance/connector-admissions/**`.
3. Mark any connector control states as `quarantined`.
4. Retain evidence under `state/evidence/connectors/**`.
5. Rebuild generated projections without connector live claims.
6. Re-run support-target and proposal validators.
7. File a Decision Request or ADR documenting rollback cause and follow-up.

## Reversal posture

Because v4 MVP admits no broad effectful external execution, rollback should be mostly configuration/control rollback. If any external operation was attempted, its connector receipt and rollback/compensation plan govern response.
