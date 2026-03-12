# Full Designer Brief for Studio Graph UX

Below is a self-contained designer brief with the current Studio requirements and data model already extracted.

**Studio Graph UX Brief**
Design a desktop interface for a workflow mapping tool called `Harmony Studio`. Its primary purpose is to help maintainers understand workflow relationships quickly, identify broken or inconsistent workflow definitions, inspect a selected workflow in detail, and move safely into review or corrective actions.

**Primary User**
A technical maintainer or platform engineer working with a large set of workflows and their dependencies.

**Primary Jobs To Be Done**

- Understand the full workflow landscape at a glance.
- Find a specific workflow fast.
- See what a workflow depends on and what depends on it.
- Identify broken workflow metadata or missing files.
- Inspect workflow details without leaving the graph context.
- Safely move from inspection into review and staged fixes.

**Current Product Scope**
The product already includes these functional areas:

- Workflow inventory and validation overview
- Dependency graph canvas
- Workflow detail inspector
- Apply audit browser
- Staged edit buffer with patch preview and guarded apply flow
- Persistent status bar

The graph is not a standalone diagram tool. It is the center of a larger workflow review surface.

**Overall Layout**
Use a desktop workbench layout with five regions:

- Top header
- Left inventory rail
- Center graph canvas
- Right inspector panel
- Bottom dock for audits and staged edits
- Bottom-most compact status bar

Design targets:

- Primary design target: `1600 x 1000`
- Minimum supported desktop: `1366 x 860`

Recommended layout proportions:

- Header: 8-10% height
- Main workbench: 50-60% height
- Bottom dock: 25-30% height
- Status bar: 3-4% height

**1. Top Header**
Purpose:

- Orient the user immediately
- Confirm which repo/workspace is loaded

Must include:

- Product title: `Harmony Studio`
- Current workspace or repo root path
- Optional global health summary

Display guidance:

- Simple, high-clarity strip
- Title on the left, workspace path below or beside it
- Optional utility actions on the right later, but not required now

**2. Left Rail: Workflow Inventory**
Purpose:

- Fast scanning and precise navigation
- Alternative to navigating the graph directly

Each workflow row currently has:

- Workflow label
- Workflow ID
- Step count
- Issue count
- Selected state

Recommended row design:

- Primary line: workflow display name
- Secondary line: canonical workflow ID
- Right-side badges: number of steps, number of issues
- Clear selected state
- Clear warning/error state if issues exist

Required interactions:

- Click to select workflow
- Selection must sync the graph and inspector
- Keyboard navigation should be supported
- Search/filter should be included in the design

Recommended filters:

- All
- Has issues
- Clean
- No dependencies
- No dependents
- Search by name or ID

**3. Center: Graph Canvas**
Purpose:

- Provide the main spatial model of the workflow system

Current graph behavior:

- Workflows are laid out left-to-right by dependency depth
- Root workflows appear to the left
- Downstream workflows appear to the right
- Cycles are possible and should be treated as valid exploratory cases
- Cyclic or unresolved nodes are pushed into a fallback band/column
- Node selection already exists
- Edge data exists, but the current UI does not draw edges yet

Graph content to include:

- Nodes for workflows
- Directed edges for dependencies
- Visual indication of selected node
- Visual indication of related nodes when one is selected
- Optional background grid or spatial guide
- Optional minimap for dense graphs

Each node should display:

- Workflow display name
- Workflow ID
- Step count badge
- Issue count badge
- Optional dependency count badges if design supports them

Node states to design:

- Default
- Hover
- Selected
- Connected-to-selected
- Warning
- Broken
- Filtered/dimmed

Required interactions:

- Click node to select
- Hover should preview connected relationships
- Drag to pan
- Scroll or pinch to zoom
- Fit view
- Reset view
- Focus selected node
- Keyboard panning and zooming
- Clear empty-space interaction rules

Recommended graph controls:

- Zoom in
- Zoom out
- Reset
- Fit all
- Fit selection
- Optional toggle between `Map` and `Focus` modes

Critical requirement:

- The graph must remain legible in both sparse and dense states

Dense-graph behaviors to design:

- Dim unrelated nodes
- Highlight only 1-hop or 2-hop neighborhood
- Collapse groups or clusters if needed
- Search result spotlighting
- Optional dependency path tracing

**4. Right Panel: Inspector**
Purpose:

- Show full detail for the selected workflow
- Convert graph selection into actionable understanding

Current selected-workflow content available:

- Selected title
- Description
- Dependency summary
- File/path summary
- Step list
- Validation issue list

Inspector should include:

- Workflow title
- Canonical ID
- Description
- Dependency summary
- Source/path info
- Step list
- Issue list
- Quick actions

Step list currently supports:

- Step ID
- File name/path
- Status
- Description

Issue list currently supports:

- Issue code
- Issue message
- Optional related path in the message text

Empty state content:

- “No workflow selected”
- Guidance that the user can select from the graph or the workflow list

Quick actions to design:

- Center in graph
- Open source file
- Copy path
- Stage safe edits

**5. Bottom Dock: Audits And Staged Edits**
This should be designed as a docked tab area rather than two separate large blocks. Two tabs:

`Apply Audits`
Purpose:

- Review previous apply attempts and their outcomes

Currently available data:

- Audit count
- Search query
- Status filter: All / Applied / Failed
- Audit row status
- Audit summary
- Audit path
- Audit preview text

Required controls:

- Refresh
- Copy path
- Open file
- Search
- Filter by status

`Staged Edit Buffer`
Purpose:

- Show pending edits before they are written

Currently available data:

- Staged file count
- Patch preview text
- Export status text
- Apply armed state

Required controls:

- Stage Safe Edits
- Clear
- Export Patch Preview
- Arm Apply / Disarm Apply
- Apply to Files

Critical safety requirement:

- Apply must feel intentionally gated
- The user must review before applying
- The UI must make it obvious that writes are blocked until apply is armed

**6. Status Bar**
Purpose:

- Lightweight system confidence and session state

Current status content available:

- Workflow count
- Edge count
- Validation issue count
- Staged edit count
- Whether apply is armed
- Selected workflow ID
- Zoom percentage

Design this as:

- A compact single-line system bar
- Readable but not visually dominant

**Validation And Error Types The UI Must Support**
Current issue types include:

- Missing workflow file
- Invalid workflow frontmatter
- Missing workflow steps
- Missing step file
- Missing registry entry
- Unknown workflow dependency
- Missing manifest entry

Important constraint:

- The current data model gives issue code and message, but not a formal severity tier
- Design should work with a simple “has issue” model now, while leaving room for warning/error/critical later

**Interaction Rules**
Selection sync:

- Selecting from list, graph, or search must update all surfaces

Graph interactions:

- Click selects
- Hover previews related paths
- Drag pans
- Scroll zooms
- Double click or equivalent focuses selected node

Inspector interactions:

- Any step or issue row can support secondary actions later, but selection is the primary requirement now

Audit interactions:

- Clicking an audit row loads its preview and path details

Staged-edit interactions:

- No apply action without explicit arming
- Preview should always be visible before write

**Visual Design Requirements**
The interface should feel:

- Technical
- Calm
- High-information
- Safe
- Precise

Visual priorities:

- Selection must be unmistakable
- Relationship highlighting must be easy to follow
- Error states must stand out immediately
- Background chrome should stay quiet
- Dense graphs should still feel navigable

Use:

- Strong contrast
- Clear card structure
- Distinct edge styling
- Meaningful badge system
- Non-color-only state indicators

**Accessibility Requirements**

- All key states must be distinguishable without color alone
- Text contrast must be high
- Hit targets should be generous
- Zoom cannot be the only path to understanding content
- Keyboard access should be designed, not added later

**Data Available Today**
You can safely design around these fields now:

- Global: workflow count, edge count, issue count, zoom %, selected workflow, staged count, audit count, apply armed state
- Workflow list item: label, ID, selected, issue count, step count
- Graph node: label, ID, x/y position, selected
- Inspector: title, description, dependency summary, path summary, steps, issues
- Audit item: path, status, summary, selected
- Edit buffer: staged count, patch preview, export status, apply armed state

**Data Not Reliably Available Yet**
If the design depends on these, engineering work will be needed:

- Rich edge metadata in the UI
- Formal issue severity
- Workflow grouping/tags
- Last modified timestamps
- Ownership metadata
- Search ranking metadata
- Dependency counts on nodes
- Live streaming execution events in the graph view

**What The Designer Should Deliver**

- Full workbench layout
- Graph canvas spec
- Node and edge component spec
- Inventory rail spec
- Inspector spec
- Bottom dock spec
- Empty/loading/error/dense states
- Interaction and keyboard behavior
- State system for clean/warning/broken/selected/related
- Responsive behavior for narrower desktop widths

If useful, I can convert this into:

1. a polished one-page product design brief,
2. a wireframe-ready component inventory,
3. or annotated low-fidelity screen specs.
