---
name: "export-harness"
description: "Materialize repo_snapshot or pack_bundle exports from the v2 root-manifest profile contract and fail closed unless repo_snapshot has a clean published enabled-pack closure and exported packs satisfy the Packet 13 pack contract."
steps:
  - id: "validate-request"
    file: "stages/01-validate-request.md"
    description: "validate-request"
  - id: "resolve-profile"
    file: "stages/02-resolve-profile.md"
    description: "resolve-profile"
  - id: "materialize-export"
    file: "stages/03-materialize-export.md"
    description: "materialize-export"
  - id: "verify-export"
    file: "stages/04-verify-export.md"
    description: "verify-export"
---

# Export Harness

_Generated README from canonical workflow `export-harness`._

## Usage

```text
/export-harness
```

## Purpose

Materialize repo_snapshot or pack_bundle exports from the v2 root-manifest profile contract and fail closed unless repo_snapshot has a clean published enabled-pack closure and exported packs satisfy the Packet 13 pack contract.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/export-harness`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/export-harness/workflow.yml`.

## Parameters

- `profile` (text, required=true): Export profile: repo_snapshot or pack_bundle
- `output_dir` (folder, required=true): Empty directory where the export root and export.receipt.yml will be written
- `pack_ids` (text, required=false): Comma-separated pack ids. Required only for pack_bundle.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `export_root` -> `{{output_dir}}/.octon/`: Materialized harness export rooted at .octon/
- `export_receipt` -> `{{output_dir}}/export.receipt.yml`: Receipt describing the exported profile payload, manifest schema versions, and resolved pack closure

## Steps

1. [validate-request](./stages/01-validate-request.md)
2. [resolve-profile](./stages/02-resolve-profile.md)
3. [materialize-export](./stages/03-materialize-export.md)
4. [verify-export](./stages/04-verify-export.md)

## Verification Gate

- [ ] export root exists at <output_dir>/.octon/
- [ ] export.receipt.yml exists at <output_dir>/
- [ ] repo_snapshot exports octon.yml, framework/**, instance/**, and the clean published enabled-pack dependency closure only
- [ ] pack_bundle exports only selected packs plus dependency closure and remains trust-agnostic
- [ ] exported pack payloads satisfy `octon-extension-pack-v4`

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/export-harness/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/export-harness/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `export-harness` |
