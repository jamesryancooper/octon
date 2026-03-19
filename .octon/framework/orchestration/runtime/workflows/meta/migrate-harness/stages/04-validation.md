# Step 4: Validation

Verify the migrated harness is functional under the v2 root-manifest and
profile contract.

## Actions

1. Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
2. Run `bash .octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh --profile repo_snapshot --output-dir <empty-temp-dir>`.
3. Confirm `export.receipt.yml` is emitted and `full_fidelity` is rejected as advisory-only.
4. Confirm the packet-4 repo-instance boundary validator passes and is included in the harness alignment profile.
5. Confirm `START.md`, `catalog.md`, and canonical architecture docs all point to the v2 manifest shape and packet-4 instance authority model.

## Output

| Section | Content |
|---------|---------|
| **Migration Summary** | Control-plane files created, transformed, or removed |
| **Preserved Content** | Custom content retained under framework/instance/state boundaries |
| **Validation Status** | Pass/fail with alignment and export evidence |
| **Export Status** | `repo_snapshot` verification result |
| **Post-Migration Notes** | Any manual follow-up needed |
