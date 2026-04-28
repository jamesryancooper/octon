# Validation Plan

## Structural validation

- Validate proposal packet using the proposal standard.
- Validate new schema files parse and are registered in the appropriate contract registries.
- Validate class-root placement: authored contracts under `framework/**`, repo authority under `instance/**`, control under `state/control/**`, retained proof under `state/evidence/**`, continuity under `state/continuity/**`, projections under `generated/**`, exploratory material under `inputs/**`.

## Compiler validation

Test cases:

1. Greenfield empty directory produces draft Engagement and adoption Decision Request.
2. Preexisting repo without `.octon/` produces preflight evidence and adoption plan without code mutation.
3. Existing valid `.octon/` repo binds authority and creates a Project Profile.
4. Partial `.octon/` repo produces `blocked` or `requires_decision` with reason codes.
5. Conflicted authority produces fail-closed outcome.
6. Unsupported required connector produces `stage_only` or `blocked`, not live readiness.
7. Missing workspace charter produces Decision Request or charter reconciliation proposal.
8. Missing validation commands produces Work Package with explicit validation gap.
9. Missing rollback posture blocks repo-consequential run readiness.
10. Valid repo-local work emits first run-contract candidate.

## Runtime validation

- Confirm compiler does not mutate project code during preflight.
- Confirm compiler does not invoke non-admitted tools/MCP/API/browser capabilities.
- Confirm connector posture resolves through machine-readable stage/block/deny policy and never admits support by itself.
- Confirm the per-engagement Objective Brief cannot rewrite the workspace-charter pair or authorize execution.
- Confirm run-contract candidate satisfies run-contract v3 required fields.
- Confirm `octon decide` writes Decision Request resolution evidence and canonical low-level refs without bypassing execution authorization.
- Confirm `octon status` reads Engagement control/evidence refs and does not rely on generated projections as authority.
- Confirm existing `octon run start --contract` remains the live execution entrypoint.
- Confirm authorization still requires context-pack receipt and support/capability posture before material effects.

## Evidence validation

- Confirm each Engagement has retained evidence refs.
- Confirm Project Profile facts trace to orientation evidence.
- Confirm Objective Brief facts trace to engagement objective evidence and workspace-charter refs.
- Confirm Work Package compilation writes evidence.
- Confirm Decision Requests retain human decision evidence and canonical low-level artifact refs.
- Confirm generated projections trace to control/evidence but are not consumed as authority.

## Fail-closed validation

The implementation must deny, block, or stage when:

- authority binding is missing;
- support target is invalid or stale;
- connector posture is non-admitted;
- context-pack request cannot be prepared;
- rollback posture is absent for repo-consequential work;
- required approval is missing;
- generated/effective handle is used directly;
- `inputs/**` or proposal-local paths are used as runtime source.
