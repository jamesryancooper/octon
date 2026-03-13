# Minimal Implementation Blueprint

## Target Surfaces

- `.octon/engine/runtime/crates/studio/`
- `.octon/engine/runtime/run`
- `.octon/capabilities/runtime/commands/studio.md`
- `.octon/catalog.md`

## Minimum Deliverable

- Implement the desktop workbench shell described in
  `octon-studio-graph-ux-design-spec.md`.
- Preserve the graph-first layout with inventory rail, graph canvas, inspector,
  bottom dock, and status bar.
- Support the documented state coverage for default, selection, dense graph,
  search, no-selection, loading, error, and dock states.
- Keep risky file application flows explicitly gated.
