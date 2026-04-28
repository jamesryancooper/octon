# Cutover Checklist

## Before implementation

- [ ] Confirm proposal packet is accepted for implementation.
- [ ] Confirm promotion targets are `.octon/**` only.
- [ ] Confirm no durable target will depend on this proposal path after promotion.
- [ ] Confirm repo-local live scope remains repo/git/shell/telemetry only.
- [ ] Confirm MCP/API/browser effectful use is out of scope.

## Contract cutover

- [ ] Add new schema/spec files.
- [ ] Register contracts in registry surfaces.
- [ ] Add architecture registry path-family entries.
- [ ] Add instance evidence-profile and preflight-lane policies.

## Runtime cutover

- [ ] Add CLI command parsing.
- [ ] Add compiler pipeline modules.
- [ ] Add prepare-only arming behavior.
- [ ] Add run-contract candidate output.
- [ ] Integrate with context-pack request builder.
- [ ] Ensure existing `octon run start --contract` remains unchanged for live execution.

## Validation cutover

- [ ] Add validators.
- [ ] Add tests for greenfield, existing, partial, conflicted, unsupported connector, missing charter, missing rollback, and valid repo-local flow.
- [ ] Run architecture health checks.
- [ ] Run proposal validation.

## Documentation/read-model cutover

- [ ] Add operator-facing docs for MVP `octon start/profile/plan/arm --prepare-only/decide/status`.
- [ ] Add generated read-model projection rules as non-authoritative.
- [ ] Update bootstrap/ingress docs only if necessary and without duplicating registry path matrices.

## Closeout

- [ ] Retain promotion evidence.
- [ ] Update generated proposal registry from manifests.
- [ ] Archive proposal only after durable targets stand alone.
