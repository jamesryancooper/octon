# Step 2: Identify Gaps

Report:

- **Missing required files** — files that MUST exist
- **Missing standard directories** — directories needed for this harness's use case
- **Legacy root-manifest keys** — top-level portability keys that must move into nested v2 fields
- **Missing Packet 2 control metadata** — `instance/extensions.yml`, companion-manifest fields, and export-profile semantics
- **Missing Packet 4 repo-instance surfaces** — ingress, bootstrap, locality,
  cognition, missions, repo-native capabilities, and enabled overlay-capable
  roots that must exist under `instance/**`
- **Active mixed-path repo-instance references** — control-plane docs or
  workflows that still use retired repo-context, continuity, or legacy mission
  roots
- **Instance preservation risks** — any planned framework update step that
  would rewrite repo-owned `instance/**` authority without an explicit
  migration contract
- **Non-standard files/directories** — items that need review or categorization
