# Generated Proposal Discovery

`generated/proposals/registry.yml` is Octon's only generated proposal
discovery surface.

## Rules

- It is rebuildable and non-authoritative.
- It is rebuilt deterministically from proposal manifests.
- It is committed by default for reviewability.
- Proposal manifests outrank the registry as proposal-local lifecycle sources.
- The main projection includes only standard-conformant packets.
- Archived design imports with `archive.archived_from_status=legacy-unknown`
  stay on disk for historical lineage but remain out of the main projection
  until normalized.
