# Step 2: Identify Gaps

Report:

- **Missing required files** — files that MUST exist
- **Missing standard directories** — directories needed for this harness's use case
- **Legacy root-manifest keys** — top-level portability keys that must move into nested v2 fields
- **Missing Packet 2 control metadata** — `instance/extensions.yml`, companion-manifest fields, and export-profile semantics
- **Missing Packet 4 repo-instance surfaces** — ingress, bootstrap, locality,
  cognition, missions, repo-native capabilities, and enabled overlay-capable
  roots that must exist under `instance/**`
- **Missing Packet 5 overlay and ingress contract surfaces** — overlay
  registry strictness, `enabled_overlay_points`, reserved overlay roots, and
  root-adapter thinness that must converge in one cutover
- **Missing Packet 6 locality contract surfaces** — scope manifests,
  `generated/effective/locality/**`, `state/control/locality/**`, and
  locality fail-closed validators that must converge in one cutover
- **Active mixed-path repo-instance references** — control-plane docs or
  workflows that still use retired repo-context, continuity, or legacy mission
  roots
- **Overlay drift or ad hoc overlay-like paths** — repo-owned governance,
  agency, or assurance content outside the four ratified overlay roots
- **Ingress adapter drift** — root `AGENTS.md` or `CLAUDE.md` content that is
  not a symlink or byte-for-byte parity copy of `/.octon/AGENTS.md`
- **Instance preservation risks** — any planned framework update step that
  would rewrite repo-owned `instance/**` authority without an explicit
  migration contract
- **Non-standard files/directories** — items that need review or categorization
