# Design Checklist for Studio Graph UX

**File Setup**

- Create pages exactly as defined: `00 Cover`, `01 Foundations`, `02 Components`, `03 Screens`, `04 Prototype`, `05 Specs`.
- Set the primary screen size to desktop `1600 x 1000`.
- Include minimum supported desktop validation at `1366 x 860`.
- Add a simple file cover with product name, date, owner, and status.
- Add a short note at the top of the file: `Graph-first workflow workbench for workflow discovery, inspection, and safe action`.

**Foundation Styles**

- Define color styles for:
  - background
  - surface
  - elevated surface
  - border
  - primary text
  - secondary text
  - selection accent
  - neutral badge
  - success
  - warning
  - error
  - dimmed state
- Define text styles for:
  - page title
  - panel title
  - section label
  - body
  - secondary body
  - caption
  - mono or technical metadata
- Define spacing tokens:
  - `4, 8, 12, 16, 24, 32`
- Define radius tokens:
  - small, medium, large
- Define shadow or elevation tokens if used.

**Layout System**

- Create a desktop grid for `1600 x 1000`.
- Create a validation grid for `1366 x 860`.
- Set column behavior for the three-pane workbench.
- Define shell spacing rules for:
  - header
  - left rail
  - graph canvas
  - inspector
  - bottom dock
  - status bar
- Decide and document minimum widths for:
  - inventory rail
  - graph canvas
  - inspector panel

**Component Library**

- Build primitives first:
  - `Primitives / Button`
  - `Primitives / Icon Button`
  - `Primitives / Badge`
  - `Primitives / Filter Chip`
  - `Primitives / Search Field`
  - `Primitives / Segmented Control`
  - `Primitives / Status Pill`
- Build shell components:
  - `Shell / Header`
  - `Shell / Status Bar`
  - `Shell / Section Title`
- Build feature components:
  - `Inventory / Workflow Row`
  - `Graph / Node`
  - `Graph / Edge`
  - `Graph / Toolbar`
  - `Graph / Minimap`
  - `Inspector / Step Row`
  - `Inspector / Issue Row`
  - `Dock / Audit Row`
  - `Dock / Tab`
  - `Dock / Apply Arm Toggle`
- Add all key variants before designing final screens.

**State Coverage**

- Design explicit component states for:
  - default
  - hover
  - selected
  - dimmed
  - disabled
  - warning
  - broken
- Ensure graph node states include:
  - clean
  - warning
  - broken
  - selected
  - related-to-selected
  - cyclic or fallback if visually distinct
- Ensure list row states match graph states.

**Core Screens**

- Create and complete:
  - `Desktop / 1600x1000 / Overview / Default`
  - `Desktop / 1600x1000 / Overview / Workflow Selected`
  - `Desktop / 1600x1000 / Overview / Workflow Selected With Issues`
  - `Desktop / 1600x1000 / Overview / Dense Graph`
  - `Desktop / 1600x1000 / Search / Results`
  - `Desktop / 1600x1000 / Search / No Results`
  - `Desktop / 1600x1000 / State / No Selection`
  - `Desktop / 1600x1000 / State / Loading`
  - `Desktop / 1600x1000 / State / Error`
  - `Desktop / 1600x1000 / Dock / Apply Audits`
  - `Desktop / 1600x1000 / Dock / Staged Edits`
  - `Desktop / 1366x860 / Validation / Default`
  - `Desktop / 1366x860 / Validation / Workflow Selected`
  - `Desktop / 1366x860 / Validation / Dense Graph`
  - `Desktop / 1366x860 / Validation / Dock`

**Graph UX Requirements**

- Show edges, not just nodes.
- Design hover highlighting for dependencies.
- Design selected-node neighborhood emphasis.
- Include pan/zoom controls and define how they look.
- Include fit/reset controls.
- Include minimap if graph density needs it.
- Define what happens visually in dense graphs.
- Define how search affects graph emphasis.

**Inspector Requirements**

- Include:
  - title
  - canonical ID
  - description
  - dependency summary
  - source/path information
  - step list
  - issue list
  - quick actions
- Design the empty state when nothing is selected.
- Design how long descriptions and long file paths wrap or truncate.

**Bottom Dock Requirements**

- Use tabs for:
  - `Apply Audits`
  - `Staged Edits`
- Apply Audits tab must include:
  - search
  - status filters
  - row list
  - preview panel
  - open/copy actions
- Staged Edits tab must include:
  - staged file count
  - patch preview
  - export status
  - stage safe edits
  - clear
  - export patch preview
  - arm/disarm apply
  - apply to files
- Make the apply-arming state visually unmistakable.

**Accessibility**

- Check contrast on all text and status colors.
- Do not rely on color alone for issue states.
- Ensure node and list selection are obvious.
- Make hit targets comfortable for dense UI.
- Ensure key information is available outside the graph canvas.

**Prototype**

- Link flows for:
  - selecting from list
  - selecting from graph
  - hovering dependency paths
  - searching workflows
  - switching dock tabs
  - reviewing an audit
  - arming apply
- Keep prototype simple and decision-focused, not motion-heavy.

**Spec Handoff**

- Add redlines for:
  - shell layout
  - graph canvas spacing
  - node sizes
  - edge treatment
  - inspector spacing
  - dock layout
- Add notes for:
  - state behavior
  - selection synchronization
  - dense-graph behavior
  - high-risk apply gating
- Label any design assumptions that require product or engineering confirmation.

**Final Review Before Handoff**

- Confirm every major state has a designed screen.
- Confirm every major component has variants.
- Confirm naming matches the agreed structure exactly.
- Confirm the file is understandable without repo access.
- Confirm the designer has included at least one dense-graph scenario and one broken-workflow scenario.
- Confirm the primary design works at `1600 x 1000` and remains usable at the minimum supported `1366 x 860`.
