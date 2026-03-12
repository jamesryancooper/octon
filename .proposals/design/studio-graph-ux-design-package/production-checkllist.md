# Production Checklist for Studio Graph UX

Here’s the exact production checklist to work through. It follows the required page/frame structure, uses the exact naming system, and includes the components, screens, states, prototype flows, and spec frames needed for the Harmony Studio graph UX deliverable.   

## 1) Set up the design file

* [ ] Create pages exactly as:

  * [ ] `00 Cover`
  * [ ] `01 Foundations`
  * [ ] `02 Components`
  * [ ] `03 Screens`
  * [ ] `04 Prototype`
  * [ ] `05 Specs`
* [ ] Set primary screen size to desktop `1600 x 1000`
* [ ] Include minimum supported desktop validation at `1366 x 860`
* [ ] Add file note at top: `Graph-first workflow workbench for workflow discovery, inspection, and safe action`
* [ ] Use exact slash-based naming for frames and components throughout the file  

## 2) Create the cover designs

* [ ] `Cover / Harmony Studio Graph UX`
* [ ] `Cover / Product Goals`
* [ ] `Cover / Data Model Summary`

Include product name, date, owner, status, JTBD, success criteria, and a summary of available vs unavailable data.  

## 3) Create the foundation designs

* [ ] `Foundations / Grid / Desktop 1600x1000 / Primary`
* [ ] `Foundations / Grid / Desktop 1366x860 / Minimum`
* [ ] `Foundations / Color Styles`
* [ ] `Foundations / Type Styles`
* [ ] `Foundations / Spacing Scale`
* [ ] `Foundations / Iconography`
* [ ] `Foundations / State Model`
* [ ] `Foundations / Interaction Principles`

These foundations must define the desktop grid, three-pane workbench behavior, shell spacing, minimum widths, color roles, typography, spacing tokens, radius tokens, and state logic before final screens are built.  

## 4) Create the component designs

Build primitives first, then shell and feature components, then dock and feedback. All key variants should exist before final screens.  

### Primitives

* [ ] `Primitives / Button`
* [ ] `Primitives / Icon Button`
* [ ] `Primitives / Badge`
* [ ] `Primitives / Filter Chip`
* [ ] `Primitives / Search Field`
* [ ] `Primitives / Segmented Control`
* [ ] `Primitives / Status Pill`
* [ ] `Primitives / Divider`
* [ ] `Primitives / Tooltip`
* [ ] `Primitives / Empty State`
* [ ] `Primitives / Loading State`

### Shell

* [ ] `Shell / Header`
* [ ] `Shell / Header Title Block`
* [ ] `Shell / Workspace Path`
* [ ] `Shell / Section Title`
* [ ] `Shell / Status Bar`
* [ ] `Shell / Status Metric`

### Inventory

* [ ] `Inventory / Sidebar`
* [ ] `Inventory / Workflow Search`
* [ ] `Inventory / Filter Bar`
* [ ] `Inventory / Workflow Row`
* [ ] `Inventory / Workflow Meta Badge`
* [ ] `Inventory / Workflow List Container`

### Graph

* [ ] `Graph / Canvas`
* [ ] `Graph / Toolbar`
* [ ] `Graph / Toolbar Button`
* [ ] `Graph / Minimap`
* [ ] `Graph / Legend`
* [ ] `Graph / Node`
* [ ] `Graph / Node Badge`
* [ ] `Graph / Edge`
* [ ] `Graph / Edge Arrow`
* [ ] `Graph / Selection Halo`
* [ ] `Graph / Hover Relationship Preview`
* [ ] `Graph / Cluster Card`

### Inspector

* [ ] `Inspector / Panel`
* [ ] `Inspector / Header`
* [ ] `Inspector / Title Block`
* [ ] `Inspector / Metadata Row`
* [ ] `Inspector / Dependency Summary`
* [ ] `Inspector / Step Row`
* [ ] `Inspector / Issue Row`
* [ ] `Inspector / Quick Action Bar`
* [ ] `Inspector / Quick Action Button`

### Dock

* [ ] `Dock / Container`
* [ ] `Dock / Tab Bar`
* [ ] `Dock / Tab`
* [ ] `Dock / Audit Search`
* [ ] `Dock / Audit Filter`
* [ ] `Dock / Audit Row`
* [ ] `Dock / Audit Preview`
* [ ] `Dock / Patch Preview`
* [ ] `Dock / Action Group`
* [ ] `Dock / Apply Arm Toggle`
* [ ] `Dock / Message Banner`

### Feedback

* [ ] `Feedback / Inline Banner`
* [ ] `Feedback / Toast`
* [ ] `Feedback / Error Panel`
* [ ] `Feedback / Warning Panel`
* [ ] `Feedback / Success Panel` 

## 5) Add the required state designs

* [ ] Design explicit component states for:

  * [ ] default
  * [ ] hover
  * [ ] selected
  * [ ] dimmed
  * [ ] disabled
  * [ ] warning
  * [ ] broken
* [ ] Ensure graph nodes include:

  * [ ] clean
  * [ ] warning
  * [ ] broken
  * [ ] selected
  * [ ] related-to-selected
  * [ ] cyclic or fallback
* [ ] Ensure inventory row states match graph states
* [ ] Ensure issue states are not color-only
* [ ] Ensure selection is unmistakable across list, graph, and inspector  

## 6) Create the core screen designs

* [ ] `Desktop / 1600x1000 / Overview / Default`
* [ ] `Desktop / 1600x1000 / Overview / Workflow Selected`
* [ ] `Desktop / 1600x1000 / Overview / Workflow Selected With Issues`
* [ ] `Desktop / 1600x1000 / Overview / Dense Graph`
* [ ] `Desktop / 1600x1000 / Search / Results`
* [ ] `Desktop / 1600x1000 / Search / No Results`
* [ ] `Desktop / 1600x1000 / State / No Selection`
* [ ] `Desktop / 1600x1000 / State / Loading`
* [ ] `Desktop / 1600x1000 / State / Error`
* [ ] `Desktop / 1600x1000 / Dock / Apply Audits`
* [ ] `Desktop / 1600x1000 / Dock / Staged Edits`
* [ ] `Desktop / 1366x860 / Validation / Default`
* [ ] `Desktop / 1366x860 / Validation / Workflow Selected`
* [ ] `Desktop / 1366x860 / Validation / Dense Graph`
* [ ] `Desktop / 1366x860 / Validation / Dock`

These are the required visual screens for the product’s main jobs: overview, selection, issue inspection, dense-state navigation, search, empty/loading/error states, and the docked review/apply surfaces.  

## 7) Ensure the graph-specific UX is visually designed

* [ ] Show directed edges, not just nodes
* [ ] Design hover highlighting for dependencies
* [ ] Design selected-node neighborhood emphasis
* [ ] Include pan/zoom controls
* [ ] Include fit all / fit selection / reset controls
* [ ] Include minimap if density requires it
* [ ] Define dense-graph behavior
* [ ] Define search emphasis in the graph
* [ ] Design node anatomy with workflow name, ID, step count, issue count
* [ ] Design edge behavior for default, highlighted, and dimmed states   

## 8) Ensure the inspector is visually designed

* [ ] Include title
* [ ] Include canonical ID
* [ ] Include description
* [ ] Include dependency summary
* [ ] Include source/path information
* [ ] Include step list
* [ ] Include issue list
* [ ] Include quick actions
* [ ] Design empty state for no selection
* [ ] Design long-description behavior
* [ ] Design long-path wrapping or truncation behavior  

## 9) Ensure the bottom dock is visually designed

* [ ] Use tabs for:

  * [ ] `Apply Audits`
  * [ ] `Staged Edits`

### Apply Audits

* [ ] Search
* [ ] Status filters
* [ ] Audit row list
* [ ] Preview panel
* [ ] Open action
* [ ] Copy path action

### Staged Edits

* [ ] Staged file count
* [ ] Patch preview
* [ ] Export status
* [ ] Stage Safe Edits action
* [ ] Clear action
* [ ] Export Patch Preview action
* [ ] Arm/Disarm Apply control
* [ ] Apply to Files action

### Safety treatment

* [ ] Make apply-arming visually unmistakable
* [ ] Make preview visible before write
* [ ] Make writes clearly blocked until armed   

## 10) Create the prototype designs

* [ ] `Prototype / Browse Graph`
* [ ] `Prototype / Inspect Workflow`
* [ ] `Prototype / Filter And Search`
* [ ] `Prototype / Review Audit`
* [ ] `Prototype / Stage Safe Edits`

Link flows for list selection, graph selection, hover path review, search/filtering, dock tab switching, audit review, and apply arming.  

## 11) Create the spec / handoff designs

* [ ] `Specs / Shell / Redlines`
* [ ] `Specs / Inventory / Anatomy`
* [ ] `Specs / Graph / Canvas Rules`
* [ ] `Specs / Graph / Node Anatomy`
* [ ] `Specs / Graph / Edge Behavior`
* [ ] `Specs / Inspector / Anatomy`
* [ ] `Specs / Dock / Anatomy`
* [ ] `Specs / Keyboard And Pointer`

Also include notes for state behavior, selection sync, dense-graph behavior, and high-risk apply gating. Label any assumptions that need engineering or product confirmation.  

## 12) Final review checklist before handoff

* [ ] Every major state has a designed screen
* [ ] Every major component has variants
* [ ] Naming matches the agreed structure exactly
* [ ] File is understandable without repo access
* [ ] Dense-graph scenario is included
* [ ] Broken-workflow scenario is included
* [ ] Accessibility checks are covered
* [ ] Key information is understandable outside the graph canvas  
* [ ] Primary screens work at `1600 x 1000` and remain usable at `1366 x 860`

The shortest practical way to think about it is: **design foundations first, then components, then the 15 required screens including minimum-size validation, then the 5 prototype flows, then the 8 handoff/spec frames**. That will give you everything needed to start and complete the visual design work for Harmony Studio’s graph-first workbench.  
