# Step 1: Backup Assessment

Read all existing files in the target `.octon` and create a migration plan for
the v2 root-manifest and profile contract.

## Actions

1. Validate harness schema compatibility first:
   - Read `.octon/octon.yml`.
   - Resolve `schema_version`.
   - Compare to `versioning.harness.supported_schema_versions`.
   - If unsupported, STOP and emit deterministic migration instructions from `versioning.harness.deterministic_upgrade_instructions`.
2. Inventory the current root-manifest shape:
   - top-level portability keys that must be removed
   - companion manifest versions
   - missing `instance/extensions.yml`
   - missing `inputs/additive/extensions/`
3. Note custom content that MUST be preserved:
   - custom prompts, workflows, commands
   - progress history and retained evidence
   - repo-specific instance context

4. Identify deprecated patterns:

| Old Pattern | Current Pattern |
|-------------|-----------------|
| top-level `class_roots` | `topology.class_roots` |
| top-level `extensions.api_version` | `versioning.extensions.api_version` |
| top-level `human_led` | `zones.human_led` |
| `full_fidelity.include` payload | advisory-only `full_fidelity.advisory` |
| broad additive-extension-root export | selected/enabled pack dependency closure |

## Output

Migration plan listing:
- files to preserve
- manifests and docs to rewrite
- new Packet 2 files to create
- export-profile and validator impact
- version-gate status (`supported` or `blocked-with-upgrade-instructions`)
