---
title: Export Harness
description: Materialize repo_snapshot or pack_bundle exports from the root-manifest profile contract.
access: agent
argument-hint: "--profile repo_snapshot|pack_bundle --output-dir <path> [--pack-ids <csv>]"
---

# Export Harness `/export-harness`

Materialize a manifest-governed harness export.

## Usage

```text
/export-harness --profile repo_snapshot --output-dir /tmp/octon-export
/export-harness --profile pack_bundle --output-dir /tmp/octon-pack-bundle --pack-ids docs,node-ts
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--profile` | Yes | Export profile. Allowed values: `repo_snapshot`, `pack_bundle`. |
| `--output-dir` | Yes | Empty directory path where the export root and receipt will be written. |
| `--pack-ids` | No* | Comma-separated pack ids. Required for `pack_bundle`; ignored for `repo_snapshot`. |

\* `--pack-ids` is required only when `--profile pack_bundle`.

## Implementation

Run:

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh --profile repo_snapshot|pack_bundle --output-dir <path> [--pack-ids <csv>]
```

Behavior:

1. Validate the v2 root manifest and companion manifests.
2. Resolve selected packs from either `instance/extensions.yml.selection.enabled` (`repo_snapshot`) or `--pack-ids` (`pack_bundle`).
3. Compute the full transitive dependency closure from `inputs/additive/extensions/<pack-id>/pack.yml`.
4. Fail closed on missing payloads, dependency cycles, conflicts, or compatibility mismatch.
5. Materialize the export to `<output-dir>/.octon/`.
6. Write `<output-dir>/export.receipt.yml`.

`full_fidelity` is advisory only and must use a normal Git clone.

## Output

- `<output-dir>/.octon/` containing the exported profile payload
- `<output-dir>/export.receipt.yml` with profile, manifest schema versions, pack selection, dependency closure, and exported paths

## References

- **Runner:** `.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`
- **Canonical:** `.octon/octon.yml`
- **Desired extension config:** `.octon/instance/extensions.yml`
