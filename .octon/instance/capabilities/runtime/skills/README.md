# Repo-Native Skills

`/.octon/instance/capabilities/runtime/skills/` contains repo-owned skill
definitions, manifests, configuration, and input resources that should remain
instance-native rather than becoming reusable additive packs.

Instance skills follow the native skill convention: one concise skill token
binds the manifest ID, registry key when present, directory contract,
`SKILL.md` frontmatter, and slash command. Use repo-native or domain-purpose
tokens; do not add extension-style namespaces unless the skill is promoted into
an additive extension pack.
