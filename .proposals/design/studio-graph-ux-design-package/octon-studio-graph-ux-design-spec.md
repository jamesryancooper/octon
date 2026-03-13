# Octon Studio Graph UX Design Spec

## 1) Key product requirements extracted from the docs

Octon Studio is a desktop workflow-mapping workbench for technical maintainers. The graph is the center of the experience, but the product also includes workflow inventory and validation overview, a workflow detail inspector, an apply-audit browser, a staged edit buffer with guarded apply flow, and a persistent status bar. The core jobs are fast landscape understanding, fast workflow lookup, dependency tracing, broken-definition detection, detailed inspection without leaving graph context, and safe movement into review or corrective action.  

The shell is explicitly a six-region desktop workbench: top header, left workflow inventory rail, center graph canvas, right inspector panel, bottom dock, and bottom status bar. The recommended proportions are header 8–10% height, main workbench 50–60%, bottom dock 25–30%, and status bar 3–4%. The primary handoff size is desktop 1366 × 860.  

Selection is the backbone of the UX. Selecting from the list, graph, or search must update all surfaces. The graph must support click-to-select, hover relationship preview, pan, zoom, fit/reset, focus on selection, and dense-state emphasis/dimming. The inspector must convert selection into actionable detail. The dock must separate review history from staged writes, and apply must be intentionally gated.  

The current data model is enough to design concrete UI around workflow label/ID, step count, issue count, graph node position and selection, inspector title/description/dependency summary/path summary/steps/issues, audit path/status/summary/selection, staged count/patch preview/export status/apply armed state, and global counts such as workflow count, edge count, issue count, selected workflow, zoom, staged count, and apply-armed state. Important missing data includes formal issue severity, rich edge metadata, grouping/tags, timestamps, ownership, search ranking, dependency counts on nodes, and live streaming execution events. 

The required state coverage is explicit: default overview, workflow selected, workflow selected with issues, dense graph, search results, no results, no selection, loading, error, apply audits dock, and staged edits dock. The UI must also support consistent component states across default, hover, selected, dimmed, disabled, warning, and broken, with graph nodes additionally supporting related-to-selected and cyclic/fallback.  

The visual bar is not novelty; it is calm, technical, precise, readable, and safe. Dense graphs must stay usable. Problem states must be obvious across list, graph, and inspector. High-risk actions must feel deliberate and blocked until armed. Accessibility must not rely on color alone, and key information must be available outside the graph canvas.  

---

## 2) Proposed visual and interaction direction

### Overall direction

Use a **dark technical workbench** with quiet chrome and high-contrast content surfaces. This is the right fit for a graph-heavy desktop tool because it keeps the canvas visually deep, lets relationship highlights read clearly, and prevents the shell from competing with the graph. The interaction model is: **overview first, focused neighborhood second, actionable detail third, deliberate write actions last**. That aligns directly with the documented experience principles.  

### Visual system

Use these foundation tokens in `01 Foundations`:

* **Background** `#0F1318`
* **Surface** `#151B22`
* **Elevated Surface** `#1B232D`
* **Border** `#2A3441`
* **Primary Text** `#E8EEF5`
* **Secondary Text** `#A7B3C2`
* **Selection Accent** `#5BA7FF`
* **Neutral Badge** `#25303C`
* **Success** `#2FA36B`
* **Warning** `#E3A23B`
* **Error** `#E15B64`
* **Dimmed State** `#6B7788`

Type scale:

* **Page Title** 24/32, semibold
* **Panel Title** 16/24, semibold
* **Section Label** 12/16, uppercase, medium
* **Body** 14/20
* **Secondary Body** 13/18
* **Caption** 12/16
* **Mono / Technical Metadata** 12/16, monospace

Spacing tokens: `4, 8, 12, 16, 24, 32`
Radius tokens: `small=6`, `medium=10`, `large=14`
Shadow/elevation: one soft elevation token for floating canvas controls and dock preview panels. These token categories are explicitly required by the checklist. 

### Layout hierarchy

At `1366 × 860`, use this shell:

* **Header**: 72 px
* **Main workbench**: 510 px
* **Bottom dock**: 246 px
* **Status bar**: 32 px

Within the main workbench, use:

* **Left rail**: 288 px
* **Center graph canvas**: 690 px
* **Right inspector**: 332 px
* **Gutters**: 12 px between major panes
* **Outer shell padding**: 16 px

Minimum widths for narrower desktop:

* **Inventory rail**: 272 px
* **Graph canvas**: 620 px
* **Inspector**: 304 px

That keeps the graph dominant while preserving readable scanning in the inventory and enough width for real inspector content. It also stays inside the recommended left/center/right proportions from the component spec.  

### Region-by-region design

#### Top header

`Shell / Header` is quiet and orienting, not action-heavy.

Left side:

* `Shell / Header Title Block`
* Product title: **Octon Studio**
* Subtitle / secondary line: workspace root path via `Shell / Workspace Path`

Right side:

* Up to three compact `Shell / Status Metric` items only when useful:

  * total workflows
  * total issues
  * staged edits count

This preserves clarity without duplicating the full status bar. Repo identity is always visible, which the brief calls out as essential. 

#### Left workflow inventory rail

Top:

* `Inventory / Workflow Search`
* `Inventory / Filter Bar` with `All`, `Has issues`, `Clean`, `No dependencies`, `No dependents`

Body:

* `Inventory / Workflow List Container`

Each `Inventory / Workflow Row` is 56 px tall with:

* primary name on line 1
* canonical ID in mono on line 2
* right-aligned `Inventory / Workflow Meta Badge` for step count and issue count

State treatment:

* **Selected**: filled accent-tinted background, 2 px accent inset border
* **Broken**: issue badge switches to error tone, plus a 3 px leading status rail and alert icon
* **Dimmed**: 40% contrast reduction
* **Hover**: raised surface and subtle border brightening

Default ordering: alphabetical by workflow display name. Search is simple live contains-match against name and ID, because the docs explicitly say search ranking metadata is not reliably available yet. 

#### Center graph canvas

This is the dominant surface.

Canvas treatment:

* darker than side panes
* faint depth-column guides to reinforce left-to-right dependency structure
* subtle dot/grid texture only at low contrast
* no draggable nodes, because this is not a standalone diagram editor

Controls:

* `Graph / Toolbar` pinned top-right inside the canvas
* buttons: zoom in, zoom out, fit all, fit selection, reset
* `Primitives / Segmented Control` in the toolbar for `Map` and `Focus`
* `Graph / Minimap` bottom-right, shown in dense graph or when the full graph exceeds the viewport
* `Graph / Legend` bottom-left with compact markers for selected, related, issue, cyclic

Node design:

* `Graph / Node` = 184 × 60 px
* line 1: workflow name
* line 2: workflow ID in mono
* bottom-right compact `Graph / Node Badge` values for step count and issue count

Node states:

* **Default**: elevated surface, neutral border
* **Hover**: border brightens, shadow slightly increases
* **Selected**: 2 px accent border + `Graph / Selection Halo`
* **Related**: accent outline only
* **Dimmed**: 20–25% opacity, badges muted
* **Broken**: issue badge in error tone, top-right alert glyph, stronger border
* **Cyclic**: loop glyph + placement in a clearly labeled fallback band/column

Edge design:

* default 1 px neutral line with arrowhead
* highlighted 2 px accent line
* dimmed at 20% opacity
* no semantic edge coloring, because rich edge metadata is not available yet

This keeps dense graphs readable by making node cards compact, edges quiet by default, and focus states stronger than overview states.  

#### Right inspector panel

The inspector is the proof surface.

Top:

* `Inspector / Header`
* `Inspector / Title Block` with workflow title and canonical ID
* issue pill beside title when issues exist

Body sequence:

1. `Inspector / Dependency Summary`
2. source/path metadata using `Inspector / Metadata Row`
3. description
4. `Inspector / Quick Action Bar`
5. step list
6. issue list

Quick actions:

* Center in graph
* Open source file
* Copy path
* Stage safe edits

Ordering matters. For clean workflows, steps can appear before issues. For workflows with issues, the issue list moves above the step list so the problem is not buried. That directly supports “problem visibility at every layer.”  

Step rows:

* 64 px
* top line: step ID + status pill
* second line: file name/path
* third line: description

Issue rows:

* 64–76 px depending on message length
* mono issue code
* human-readable message
* inline path excerpt when present

Long descriptions wrap normally inside the inspector. Long paths truncate in the middle with full value on hover via `Primitives / Tooltip`, plus a copy-path action. That satisfies the inspector requirement to handle long descriptions and paths. 

#### Bottom dock

Use one full-width `Dock / Container` with `Dock / Tab Bar` and two tabs.

**Apply Audits**

* top control row: `Dock / Audit Search`, `Dock / Audit Filter`, refresh action
* body split 34/66:

  * left: audit rows
  * right: `Dock / Audit Preview`
* row anatomy: summary, path, status, selected state
* preview header includes open/copy path actions

**Staged Edits**

* top summary/action row:

  * staged file count
  * export status
  * Stage Safe Edits
  * Clear
  * Export Patch Preview
  * `Dock / Apply Arm Toggle`
  * Apply to Files
* body: full-width `Dock / Patch Preview`
* top banner: `Dock / Message Banner`

Apply gating:

* default banner: **Writes blocked**
* `Apply to Files` disabled while disarmed
* arming changes banner to warning tone: **Apply armed — review complete, writes enabled**
* disarm returns disabled state immediately
* the apply button is spatially separated from non-destructive actions

That is the strongest possible safe-action treatment within the documented scope.  

#### Bottom status bar

Single-line `Shell / Status Bar` with `Shell / Status Metric` items:

`Workflows` | `Edges` | `Issues` | `Staged` | `Apply` | `Selected` | `Zoom`

Behavior:

* far left: global counts
* center: selected workflow ID in mono
* far right: zoom %
* `Primitives / Status Pill` for apply armed/disarmed

The status bar is always present, low emphasis, and never the primary reading path. 

### Interaction model

#### Selection

One selection model across inventory, graph, inspector, and dock context.

* Click row or node selects workflow.
* Search does not auto-select.
* If a filter removes the selected workflow from the result set, selection clears.
* Clicking empty graph canvas clears selection.
  This matches the documented sync rule and prevents hidden or stale selection states.  

#### Hover relationship preview

On node hover:

* inbound and outbound 1-hop edges brighten
* directly connected nodes receive the `Related` state
* all unrelated nodes and edges dim
* preview disappears on pointer exit unless the node is selected

This gives fast dependency understanding without forcing selection. It is the primary “understand at a glance” mechanism in dense views. 

#### Pan / zoom / fit / reset

* Drag empty canvas to pan
* wheel/pinch to zoom
* double-click selected node = fit selection
* toolbar: zoom in, zoom out, fit all, fit selection, reset
* keyboard: `+`, `-`, `0`, `Esc`, arrow keys in inventory, `Enter` to select

Reset returns to full-map framing, not a random pan origin. This makes recovery from dense navigation immediate. 

#### Dense-state behavior

This is the most important design decision.

Dense graph mode uses:

* minimap on
* `Focus` mode available in toolbar
* selected node at full emphasis
* 1-hop neighborhood at 100%
* 2-hop neighborhood at ~60%
* everything else at ~20%
* search matches remain full emphasis even if outside selection neighborhood
* cyclic/unresolved nodes sit in a labeled fallback band so they do not visually pollute the main depth lanes

For current product reality, this is better than relying on semantic grouping or collapse, because grouping metadata is not reliably available yet. `Graph / Cluster Card` remains future-ready, but not a dependency of the main dense-state solution. 

### Required screen states

* **Default overview**: full graph visible, no selection, inspector empty, dock neutral
* **Workflow selected**: selected row/node, related edges and nodes highlighted, inspector populated
* **Workflow selected with issues**: broken row/node, issue badges visible, issue section elevated above steps
* **Dense graph**: minimap visible, focus mode on, unrelated nodes dimmed
* **Search results**: results highlighted in list and graph, unmatched dimmed
* **No results**: empty state in list and graph
* **No selection**: inspector empty state message
* **Loading**: skeleton list, placeholder graph, inspector loading
* **Error**: graph `Feedback / Error Panel`, inspector fallback, dock disabled
* **Apply audits dock**: audits tab active, selected row loads preview
* **Staged edits dock**: patch preview visible, apply gated by arming state

Those are the exact required states from the brief and checklist.  

### Brief rationale for the major decisions

**Dense graph readability**
I am relying on neighborhood emphasis, minimap, depth columns, a non-draggable graph, and a strong selected/related/dimmed hierarchy rather than decorative styling or semantic clustering. That is the safest way to preserve usability under current data constraints. 

**Problem visibility**
Issues appear in the same language everywhere: count badge, alert icon, stronger broken border, and inspector issue section prominence. Because formal severity is not available yet, the UX treats current issues as “broken” rather than pretending to distinguish severity tiers. 

**Safe-action gating**
The write path is deliberately isolated in the dock, preview-first, armed separately, and visually blocked until armed. Exploration happens in the main workbench; mutation happens only in the dock.  

**Information hierarchy**
The left rail answers “what exists,” the graph answers “how it relates,” the inspector answers “what it means,” and the dock answers “what do I do next.” That hierarchy makes the graph central without making it the only way to understand the system.  

---

## 3) Pages, frames, and components to create

### Pages and frames

Use the exact file/page structure from `page-structure.md`. 

#### `00 Cover`

* `Cover / Octon Studio Graph UX`
  File cover with product name, date, owner, status, and note: “Graph-first workflow workbench for workflow discovery, inspection, and safe action.”
* `Cover / Product Goals`
  JTBD, success criteria, experience principles
* `Cover / Data Model Summary`
  Available fields vs unavailable fields

#### `01 Foundations`

* `Foundations / Grid / Desktop 1600x1000 / Primary`
* `Foundations / Grid / Desktop 1366x860 / Minimum`
  Shell dimensions, pane widths, gutters, minimum widths
* `Foundations / Color Styles`
  Semantic palette above
* `Foundations / Type Styles`
  Page, panel, section, body, caption, mono
* `Foundations / Spacing Scale`
  4, 8, 12, 16, 24, 32
* `Foundations / Iconography`
  selection, issue, success, warning, error, cyclic, zoom, fit, copy, open
* `Foundations / State Model`
  clean / warning / broken / selected / related / dimmed / disabled
* `Foundations / Interaction Principles`
  single selection model, overview-to-detail, preview-before-write

#### `02 Components`

* `Components / Primitives`
* `Components / Shell`
* `Components / Inventory`
* `Components / Graph`
* `Components / Inspector`
* `Components / Dock`
* `Components / Feedback`

#### `03 Screens`

* `Desktop / 1600x1000 / Overview / Default`
* `Desktop / 1600x1000 / Overview / Workflow Selected`
* `Desktop / 1600x1000 / Overview / Workflow Selected With Issues`
* `Desktop / 1600x1000 / Overview / Dense Graph`
* `Desktop / 1600x1000 / Search / Results`
* `Desktop / 1600x1000 / Search / No Results`
* `Desktop / 1600x1000 / State / No Selection`
* `Desktop / 1600x1000 / State / Loading`
* `Desktop / 1600x1000 / State / Error`
* `Desktop / 1600x1000 / Dock / Apply Audits`
* `Desktop / 1600x1000 / Dock / Staged Edits`
* `Desktop / 1366x860 / Validation / Default`
* `Desktop / 1366x860 / Validation / Workflow Selected`
* `Desktop / 1366x860 / Validation / Dense Graph`
* `Desktop / 1366x860 / Validation / Dock`

#### `04 Prototype`

* `Prototype / Browse Graph`
* `Prototype / Inspect Workflow`
* `Prototype / Filter And Search`
* `Prototype / Review Audit`
* `Prototype / Stage Safe Edits`

#### `05 Specs`

* `Specs / Shell / Redlines`
* `Specs / Inventory / Anatomy`
* `Specs / Graph / Canvas Rules`
* `Specs / Graph / Node Anatomy`
* `Specs / Graph / Edge Behavior`
* `Specs / Inspector / Anatomy`
* `Specs / Dock / Anatomy`
* `Specs / Keyboard And Pointer`

### Components

Use the exact component names below. Variant behavior follows the documented structure, with the concrete styling and sizing defined in section 2. 

#### Primitives

* `Primitives / Button`
* `Primitives / Icon Button`
* `Primitives / Badge`
* `Primitives / Filter Chip`
* `Primitives / Search Field`
* `Primitives / Segmented Control`
* `Primitives / Status Pill`
* `Primitives / Divider`
* `Primitives / Tooltip`
* `Primitives / Empty State`
* `Primitives / Loading State`

#### Shell

* `Shell / Header`
* `Shell / Header Title Block`
* `Shell / Workspace Path`
* `Shell / Section Title`
* `Shell / Status Bar`
* `Shell / Status Metric`

#### Inventory

* `Inventory / Sidebar`
* `Inventory / Workflow Search`
* `Inventory / Filter Bar`
* `Inventory / Workflow Row`
* `Inventory / Workflow Meta Badge`
* `Inventory / Workflow List Container`

#### Graph

* `Graph / Canvas`
* `Graph / Toolbar`
* `Graph / Toolbar Button`
* `Graph / Minimap`
* `Graph / Legend`
* `Graph / Node`
* `Graph / Node Badge`
* `Graph / Edge`
* `Graph / Edge Arrow`
* `Graph / Selection Halo`
* `Graph / Hover Relationship Preview`
* `Graph / Cluster Card`

#### Inspector

* `Inspector / Panel`
* `Inspector / Header`
* `Inspector / Title Block`
* `Inspector / Metadata Row`
* `Inspector / Dependency Summary`
* `Inspector / Step Row`
* `Inspector / Issue Row`
* `Inspector / Quick Action Bar`
* `Inspector / Quick Action Button`

#### Dock

* `Dock / Container`
* `Dock / Tab Bar`
* `Dock / Tab`
* `Dock / Audit Search`
* `Dock / Audit Filter`
* `Dock / Audit Row`
* `Dock / Audit Preview`
* `Dock / Patch Preview`
* `Dock / Action Group`
* `Dock / Apply Arm Toggle`
* `Dock / Message Banner`

#### Feedback

* `Feedback / Inline Banner`
* `Feedback / Toast`
* `Feedback / Error Panel`
* `Feedback / Warning Panel`
* `Feedback / Success Panel`

### Key component treatments

* `Inventory / Workflow Row`: `State=Default,Hover,Selected,Dimmed` and `Health=Clean,Warning,Broken`; current product uses Clean and Broken, with Warning reserved for future severity support.
* `Graph / Node`: `State=Default,Hover,Selected,Related,Dimmed`, `Health=Clean,Warning,Broken`, `Role=Root,Intermediate,Leaf,Cyclic`; primary size 184 × 60.
* `Graph / Edge`: `State=Default,Highlighted,Dimmed`; neutral default, accent highlighted.
* `Inspector / Step Row`: `State=Default,Hover`, `Status=OK,Missing`.
* `Inspector / Issue Row`: `Severity=Info,Warning,Error`; current runtime can render all present issues with the Error treatment until severity exists.
* `Dock / Audit Row`: `State=Default,Hover,Selected`, `Status=Applied,Failed`.
* `Dock / Apply Arm Toggle`: `State=Disarmed,Armed`. 

---

## 4) Assumptions and gaps that need confirmation

1. **Issue severity is not formally available.** I am treating current nonzero issue states as effectively broken in the main UX, while still designing Warning as a future-ready component variant. 

2. **Search ranking is not available.** I am assuming simple contains-match on workflow name and ID, with results staying in the current list sort order rather than fuzzy-ranked. 

3. **Dependency counts on nodes are not reliable.** I am omitting dependency-count badges from the primary node design and using only step count and issue count. 

4. **Semantic grouping metadata is not available.** `Graph / Cluster Card` is future-ready only; the main dense-graph solution depends on dimming, neighborhood focus, search spotlighting, minimap, and the cyclic fallback band. 

5. **Open source file / copy path actions require host integration.** The UI includes these actions because they are in scope, but actual behavior depends on the platform shell or editor integration. 

6. **Current runtime is request/result, not truly streaming.** I am designing loading and status as discrete states and banners, not live execution choreography. 

---

## 5) Checklist confirmation against `design-checklist.md`

This direction satisfies the checklist structure and done gate. 

* **File setup**: uses the exact required pages, primary size `1600 x 1000`, minimum supported desktop `1366 x 860`, cover metadata, and the required file note.
* **Foundation styles**: defines all required color, type, spacing, radius, and elevation tokens.
* **Layout system**: defines the desktop grid, pane proportions, shell spacing, and minimum widths.
* **Component library**: includes every required primitive, shell, feature, dock, and feedback component using the exact names.
* **State coverage**: includes default, hover, selected, dimmed, disabled, warning, broken, plus graph related/cyclic states and matching list-row health states.
* **Core screens**: includes every required overview, search, state, and dock screen.
* **Graph UX**: includes visible edges, hover highlighting, selected-node neighborhood emphasis, pan/zoom controls, fit/reset, minimap, dense-graph behavior, and search emphasis.
* **Inspector**: includes title, canonical ID, description, dependency summary, source/path info, step list, issue list, quick actions, empty state, and long-text/path handling.
* **Bottom dock**: uses tabs for `Apply Audits` and `Staged Edits`, with all required controls and unmistakable apply arming.
* **Accessibility**: selection and issue states are not color-only; contrast is high; hit targets are comfortable; key info is available outside the graph.
* **Prototype**: the listed prototype frames cover list selection, graph selection, hover path review, search, dock switching, audit review, and arming apply.
* **Spec handoff**: the `05 Specs` frames cover shell redlines, graph spacing, node size, edge treatment, inspector spacing, dock anatomy, keyboard/pointer behavior, dense-graph rules, selection sync, and apply gating.
* **Final review**: every major state and component has coverage, naming matches exactly, the design is understandable without repo access, and it explicitly includes both dense-graph and broken-workflow scenarios.

This is implementation-ready as a product/design direction for the Octon Studio graph workbench, using only the documented scope and data model.
