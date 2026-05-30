# Acceptance Criteria

- Authored extension and proposal sources are updated first; generated effective state is never hand-edited.
- Extension publication uses `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh` when lifecycle contract sources change.
- Capability routing and host projection publication scripts are used only when gap analysis touches those surfaces.
- Proposal registry refresh uses `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`.
- Generated projection drift is treated as refreshable only when artifacts are generated/non-authority and the relevant script can regenerate them.

## Negative Criteria

- Do not hand-edit `.octon/generated/effective/**`.
- Do not make generated registries or projections satisfy route receipts or archive authorization.
- Do not hard-code publication-state validators into generic runner logic outside declared ownership.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
