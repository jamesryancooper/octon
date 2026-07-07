# Target Architecture

Proposal lifecycle host projection is governed by a single explicit naming
matrix that maps each surface across:

- lifecycle route id
- workflow id
- command id
- skill id
- prompt-set id
- canonical operator command
- compatibility aliases
- Codex projection status
- Claude projection status
- Cursor projection status
- host support rationale
- deprecation or retention posture

The matrix distinguishes three layers:

1. Internal lifecycle authority: route ids, workflow ids, receipt schemas, and
   prompt-set ids.
2. Source-owned operator declarations: capability command manifests, skill
   manifests, extension manifests, product catalog entries, and host adapter
   support declarations.
3. Derived host projections: `.codex`, `.claude`, `.cursor`, generated/effective
   routing, generated/effective artifact maps, and generated extension catalog
   entries.

Canonical operator surfaces should be symmetric where the domain is symmetric.
For example, packet and program delivery should expose a predictable pair of
operator commands unless a host-specific support constraint is explicit.

Compatibility aliases remain legal when they preserve existing workflows, but
they must be marked as aliases and must not create independent lifecycle,
workflow, receipt, cleanup, archive, Git, or terminal-proof authority.
