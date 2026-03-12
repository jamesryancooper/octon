# Minimal Implementation Blueprint

## Target Surfaces

- `.harmony/engine/runtime/crates/studio/`
- `.harmony/engine/runtime/run`
- `.harmony/capabilities/runtime/commands/studio.md`
- `.harmony/catalog.md`

## Minimum Deliverable

- Implement the desktop workbench shell described in
  `harmony-studio-graph-ux-design-spec.md`.
- Preserve the graph-first layout with inventory rail, graph canvas, inspector,
  bottom dock, and status bar.
- Support the documented state coverage for default, selection, dense graph,
  search, no-selection, loading, error, and dock states.
- Keep risky file application flows explicitly gated.
