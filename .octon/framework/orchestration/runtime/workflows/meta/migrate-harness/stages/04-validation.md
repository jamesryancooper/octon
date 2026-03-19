# Step 4: Validation

Verify the migrated harness is functional under the v2 root-manifest and
profile contract.

## Actions

1. Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
2. Run `bash .octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh --profile repo_snapshot --output-dir <empty-temp-dir>`.
3. Confirm `export.receipt.yml` is emitted and `full_fidelity` is rejected as advisory-only.
4. Confirm the packet-4 repo-instance boundary validator passes and is included in the harness alignment profile.
5. Confirm the packet-5 overlay validator and bootstrap-ingress validator both pass and are included in the harness alignment profile.
6. Confirm the packet-6 locality registry validator and locality publication-state validator both pass and are included in the harness alignment profile.
7. Confirm `START.md`, `catalog.md`, and canonical architecture docs all point to the v2 manifest shape plus the packet-4, packet-5, and packet-6 authority model.

## Output

| Section | Content |
|---------|---------|
| **Migration Summary** | Control-plane files created, transformed, or removed |
| **Preserved Content** | Custom content retained under framework/instance/state boundaries |
| **Validation Status** | Pass/fail with alignment and export evidence |
| **Export Status** | `repo_snapshot` verification result |
| **Post-Migration Notes** | Any manual follow-up needed |
