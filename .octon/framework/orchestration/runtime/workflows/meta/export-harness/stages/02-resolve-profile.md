# Step 2: Resolve Profile Payload

## Actions

1. Read `/.octon/octon.yml` and validate the v2 root-manifest profile contract.
2. Read `/.octon/framework/manifest.yml`, `/.octon/instance/manifest.yml`, and `/.octon/instance/extensions.yml`.
3. For `repo_snapshot`, resolve enabled packs from `instance/extensions.yml.selection.enabled`.
4. For `pack_bundle`, resolve selected packs from the explicit `pack_ids` input.
5. Compute the full transitive dependency closure from `inputs/additive/extensions/<pack-id>/pack.yml`.
6. Fail closed on missing payloads, dependency cycles, conflicts, or compatibility mismatch.

## Output

- resolved export payload set
- ordered dependency closure
- explicit failure receipt when closure cannot be resolved
