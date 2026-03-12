# Wireframe-Ready Component Spec for Studio Graph UX

**Frame**

- Primary design target: `1600 x 1000`.
- Minimum supported desktop: `1366 x 860`.
- Five regions: header, left rail, graph canvas, right inspector, bottom dock, status bar.
- Main workbench proportions: left `22-25%`, center `50-56%`, right `22-25%`.
- Bottom dock: `28-32%` of window height.
- Status bar: compact single row.

**Header**

- Content: product title, current workspace path, optional global health summary.
- Display: quiet chrome, high clarity, strong orientation.
- Interaction: mostly passive; optional future global actions on right.

**Left Rail: Workflow Inventory**

- Content: search field, filter chips, scrollable workflow list.
- Each row: display name, canonical ID, step-count badge, issue-count badge, selected state.
- Interaction: click to select, keyboard up/down, enter to open, search live-filters graph and list.
- States: default, hover, selected, issue-present, filtered-out, empty-results.

**Center: Graph Canvas**

- Content: nodes for workflows, directed edges for dependencies, graph toolbar, optional minimap.
- Layout logic: left-to-right by dependency depth; roots on left, downstream to right, cycles placed in a fallback band.
- Toolbar: zoom in, zoom out, fit all, fit selection, reset, focus mode toggle.
- Interaction: click node to select, hover to preview neighbors, drag to pan, wheel/pinch to zoom, double click to focus.
- Dense handling: dim unrelated nodes, highlight 1-hop or 2-hop neighborhood, cluster or collapse groups if needed.
- States: overview, focused selection, dense filtered, no results, loading.

**Graph Node**

- Content: workflow name, workflow ID, step count, issue count.
- Size target: compact card, approximately `170-190px` wide and `52-64px` tall.
- States: default, hover, selected, connected-to-selected, warning, broken, dimmed.
- Rules: name is primary, ID secondary, badges compact, truncation allowed with full value on hover/inspector.

**Edge**

- Content: directed dependency connection.
- Display: subtle by default, stronger when related to selection, arrowed direction.
- States: default, highlighted, dimmed, invalid if future data supports it.
- Rules: edge readability must remain strong in dense states.

**Right Panel: Inspector**

- Content: workflow title, canonical ID, description, dependency summary, source/path info, step list, issue list, quick actions.
- Step row: step ID, file path/name, status, description.
- Issue row: issue code plus human-readable message.
- Quick actions: center in graph, open source, copy path, stage safe edits.
- Empty state: explicitly instruct user to select from graph or list.

**Bottom Dock**

- Use tabs: `Apply Audits` and `Staged Edits`.

**Apply Audits Tab**

- Content: search, status filters `All / Applied / Failed`, audit list, selected audit path, markdown preview.
- Actions: refresh, open file, copy path.
- States: none selected, applied success, failed audit, no audits.

**Staged Edits Tab**

- Content: staged file count, export/apply status message, patch preview.
- Actions: stage safe edits, clear, export patch preview, arm/disarm apply, apply to files.
- Safety rule: apply action must be visually gated; arming is explicit and prominent.

**Status Bar**

- Content: workflow count, edge count, issue count, selected workflow, zoom %, staged edit count, apply-armed state.
- Display: compact, always visible, low visual weight.

**Interaction Rules**

- Selection is synchronized across list, graph, and inspector.
- Search affects both list and graph.
- Empty-canvas click may clear focus.
- Keyboard support: arrows navigate list, enter selects, esc clears focus, `+/-` zoom, `0` fit/reset.
- High-risk actions belong in inspector or dock, not floating over the graph.

**Visual Direction**

- Technical, calm, precise.
- Strong contrast, restrained color use.
- Selection should be the strongest accent.
- Warning and error states must be unmistakable without relying on color alone.
- Motion should support orientation, not decoration.
