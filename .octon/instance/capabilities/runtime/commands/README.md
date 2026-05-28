# Repo-Native Commands

`/.octon/instance/capabilities/runtime/commands/` is reserved for
repo-specific command capabilities that should remain instance-owned rather
than becoming reusable additive packs.

Instance command IDs use concise repo-native or domain-purpose tokens. They do
not need an `octon-` namespace unless the command is intentionally promoted into
a reusable additive extension surface. Display names remain operator read
models, and generated host projections remain derived state.
