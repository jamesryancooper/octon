# Step 3: Content Migration

Transform content to meet the v2 root-manifest and export-profile contract.

## Actions

1. Update canonical docs so `bootstrap_core`, `repo_snapshot`, `pack_bundle`,
   and advisory-only `full_fidelity` are described consistently.
2. Replace legacy top-level extension API references with
   `octon.yml.versioning.extensions.api_version`.
3. Route export guidance to `/export-harness`; do not describe whole-tree copy
   as the default install/export path.
4. Update command, workflow, and catalog surfaces so the new export path is
   discoverable.

## Output

- manifest fields rewritten
- canonical docs updated
- export guidance updated to `/export-harness`
- remaining follow-up, if any
