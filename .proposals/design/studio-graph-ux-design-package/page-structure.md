# Page Structure for Studio Graph UX

**Pages**

```text
00 Cover
  Frame: Cover / Harmony Studio Graph UX
  Frame: Cover / Product Goals
  Frame: Cover / Data Model Summary

01 Foundations
  Frame: Foundations / Grid / Desktop 1600x1000 / Primary
  Frame: Foundations / Grid / Desktop 1366x860 / Minimum
  Frame: Foundations / Color Styles
  Frame: Foundations / Type Styles
  Frame: Foundations / Spacing Scale
  Frame: Foundations / Iconography
  Frame: Foundations / State Model
  Frame: Foundations / Interaction Principles

02 Components
  Frame: Components / Primitives
  Frame: Components / Shell
  Frame: Components / Inventory
  Frame: Components / Graph
  Frame: Components / Inspector
  Frame: Components / Dock
  Frame: Components / Feedback

03 Screens
  Frame: Desktop / 1600x1000 / Overview / Default
  Frame: Desktop / 1600x1000 / Overview / Workflow Selected
  Frame: Desktop / 1600x1000 / Overview / Workflow Selected With Issues
  Frame: Desktop / 1600x1000 / Overview / Dense Graph
  Frame: Desktop / 1600x1000 / Search / Results
  Frame: Desktop / 1600x1000 / Search / No Results
  Frame: Desktop / 1600x1000 / State / No Selection
  Frame: Desktop / 1600x1000 / State / Loading
  Frame: Desktop / 1600x1000 / State / Error
  Frame: Desktop / 1600x1000 / Dock / Apply Audits
  Frame: Desktop / 1600x1000 / Dock / Staged Edits
  Frame: Desktop / 1366x860 / Validation / Default
  Frame: Desktop / 1366x860 / Validation / Workflow Selected
  Frame: Desktop / 1366x860 / Validation / Dense Graph
  Frame: Desktop / 1366x860 / Validation / Dock

04 Prototype
  Frame: Prototype / Browse Graph
  Frame: Prototype / Inspect Workflow
  Frame: Prototype / Filter And Search
  Frame: Prototype / Review Audit
  Frame: Prototype / Stage Safe Edits

05 Specs
  Frame: Specs / Shell / Redlines
  Frame: Specs / Inventory / Anatomy
  Frame: Specs / Graph / Canvas Rules
  Frame: Specs / Graph / Node Anatomy
  Frame: Specs / Graph / Edge Behavior
  Frame: Specs / Inspector / Anatomy
  Frame: Specs / Dock / Anatomy
  Frame: Specs / Keyboard And Pointer
```

**Component Names**

```text
Primitives / Button
Primitives / Icon Button
Primitives / Badge
Primitives / Filter Chip
Primitives / Search Field
Primitives / Segmented Control
Primitives / Status Pill
Primitives / Divider
Primitives / Tooltip
Primitives / Empty State
Primitives / Loading State

Shell / Header
Shell / Header Title Block
Shell / Workspace Path
Shell / Section Title
Shell / Status Bar
Shell / Status Metric

Inventory / Sidebar
Inventory / Workflow Search
Inventory / Filter Bar
Inventory / Workflow Row
Inventory / Workflow Meta Badge
Inventory / Workflow List Container

Graph / Canvas
Graph / Toolbar
Graph / Toolbar Button
Graph / Minimap
Graph / Legend
Graph / Node
Graph / Node Badge
Graph / Edge
Graph / Edge Arrow
Graph / Selection Halo
Graph / Hover Relationship Preview
Graph / Cluster Card

Inspector / Panel
Inspector / Header
Inspector / Title Block
Inspector / Metadata Row
Inspector / Dependency Summary
Inspector / Step Row
Inspector / Issue Row
Inspector / Quick Action Bar
Inspector / Quick Action Button

Dock / Container
Dock / Tab Bar
Dock / Tab
Dock / Audit Search
Dock / Audit Filter
Dock / Audit Row
Dock / Audit Preview
Dock / Patch Preview
Dock / Action Group
Dock / Apply Arm Toggle
Dock / Message Banner

Feedback / Inline Banner
Feedback / Toast
Feedback / Error Panel
Feedback / Warning Panel
Feedback / Success Panel
```

**Variant Properties**

- `Primitives / Button`: `Type=Primary,Secondary,Tertiary,Destructive` `State=Default,Hover,Pressed,Disabled`
- `Primitives / Icon Button`: `Type=Default,Selected,Danger` `State=Default,Hover,Pressed,Disabled`
- `Primitives / Badge`: `Tone=Neutral,Info,Success,Warning,Error`
- `Primitives / Filter Chip`: `State=Default,Hover,Selected,Disabled`
- `Inventory / Workflow Row`: `State=Default,Hover,Selected,Dimmed` `Health=Clean,Warning,Broken`
- `Graph / Node`: `State=Default,Hover,Selected,Related,Dimmed` `Health=Clean,Warning,Broken` `Role=Root,Intermediate,Leaf,Cyclic`
- `Graph / Edge`: `State=Default,Highlighted,Dimmed` `Direction=Inbound,Outbound`
- `Inspector / Step Row`: `State=Default,Hover` `Status=OK,Missing`
- `Inspector / Issue Row`: `Severity=Info,Warning,Error`
- `Dock / Tab`: `State=Default,Hover,Selected`
- `Dock / Audit Row`: `State=Default,Hover,Selected` `Status=Applied,Failed`
- `Dock / Apply Arm Toggle`: `State=Disarmed,Armed`

**Recommended Frame Contents**

- `Desktop / 1600x1000 / Overview / Default`: no workflow selected, full graph visible, inventory populated, inspector empty state
- `Desktop / 1600x1000 / Overview / Workflow Selected`: one node selected, inbound/outbound edges highlighted, inspector populated
- `Desktop / 1600x1000 / Overview / Workflow Selected With Issues`: selected node in broken state, issue badges visible, inspector issue list expanded
- `Desktop / 1600x1000 / Overview / Dense Graph`: many nodes, minimap visible, unrelated nodes dimmed, search/filter active
- `Desktop / 1600x1000 / Search / Results`: search term entered, matching rows and nodes emphasized
- `Desktop / 1600x1000 / Search / No Results`: zero-result state in list and graph
- `Desktop / 1600x1000 / Dock / Apply Audits`: audits tab active with search, filters, row list, preview
- `Desktop / 1600x1000 / Dock / Staged Edits`: staged edits tab active with patch preview and guarded apply controls
- `Desktop / 1366x860 / Validation / Default`: minimum supported desktop check for shell balance, graph legibility, and empty-state clarity
- `Desktop / 1366x860 / Validation / Workflow Selected`: minimum supported desktop check for selected-state readability and inspector fit
- `Desktop / 1366x860 / Validation / Dense Graph`: minimum supported desktop check for dense-state navigation and graph controls
- `Desktop / 1366x860 / Validation / Dock`: minimum supported desktop check for audits and staged-edit dock usability

**Prototype Links**

- `Prototype / Browse Graph`: Overview Default -> Workflow Selected -> Dense Graph
- `Prototype / Inspect Workflow`: Overview Workflow Selected -> Inspector-focused state
- `Prototype / Filter And Search`: Overview Default -> Search Results -> No Results
- `Prototype / Review Audit`: Dock Apply Audits -> selected audit preview
- `Prototype / Stage Safe Edits`: Dock Staged Edits -> Armed state -> confirmation state

**Naming Rule**
Use exact slash-based naming everywhere:

- Pages: `NN Name`
- Frames: `Category / Size / Surface / State`
- Components: `Group / Component`
- Variants: concise properties only, no freeform names
