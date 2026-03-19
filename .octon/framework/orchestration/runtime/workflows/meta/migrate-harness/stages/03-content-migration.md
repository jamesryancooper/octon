# Step 3: Content Migration

Transform content to meet the v2 root-manifest, repo-instance, and
export-profile contracts.

## Actions

1. Update canonical docs so `bootstrap_core`, `repo_snapshot`, `pack_bundle`,
   and advisory-only `full_fidelity` are described consistently.
2. Replace legacy top-level extension API references with
   `octon.yml.versioning.extensions.api_version`.
3. Route export guidance to `/export-harness`; do not describe whole-tree copy
   as the default install/export path.
4. Rewrite active repo-instance references so ingress, bootstrap, locality,
   durable context, ADRs, missions, and repo continuity resolve to their
   canonical `instance/**` and `state/**` homes.
5. Rewrite active overlay and ingress references so
   `framework/overlay-points/registry.yml`,
   `instance/manifest.yml#enabled_overlay_points`,
   `/.octon/AGENTS.md`, and `instance/ingress/AGENTS.md` are described
   consistently.
6. Rewrite active locality references so
   `instance/locality/{manifest.yml,registry.yml,scopes/**}`,
   `generated/effective/locality/**`, and
   `state/control/locality/quarantine.yml` are described consistently.
7. Update command, workflow, and catalog surfaces so the new export path,
   overlay contract, locality contract, and repo-instance authority model are
   discoverable.

## Output

- manifest fields rewritten
- canonical docs updated
- repo-instance path references rewritten
- export guidance updated to `/export-harness`
- remaining follow-up, if any
