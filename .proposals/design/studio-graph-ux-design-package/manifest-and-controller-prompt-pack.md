# Manifest and Controller Prompt Pack for Studio Graph UX

Below is a ready-to-run pack built around the exact page/frame structure, required screen list, named component groups, and current data constraints in the Harmony Studio docs. It sets the primary design target at `1600 x 1000`, validates the workbench at the minimum supported desktop `1366 x 860`, preserves the graph-first-but-not-graph-only model, and avoids inventing unsupported data such as ownership, timestamps, formal severity tiers, or rich edge metadata.

The most reliable automation is a phased run: lock the visual system first, then generate boards, then generate the core screens by delta from the anchor, then generate prototype/spec boards. That matches the required page order and helps keep shell proportions, selection treatment, dense-graph behavior, and apply gating consistent across all outputs.

## Run order

1. Paste the manifest once.
2. Run **Prompt A** to lock the style system.
3. Run **Prompt B**, then **Prompt C**, then **Prompt D**.
4. Use the rerun prompt for any frame that needs correction.

---

## 1) Manifest

```yaml
project: Harmony Studio Graph UX
source_of_truth:
  - full-designer-brief.md
  - short-designer-brief.md
  - component-spec.md
  - page-structure.md
  - design-checklist.md

global_contract:
  primary_design_target: "1600x1000 desktop"
  minimum_supported_desktop: "1366x860"
  product: "Harmony Studio"
  feel:
    - technical
    - calm
    - high-information
    - safe
    - precise
  experience_principles:
    - graph-first but not graph-only
    - overview first, detail on demand
    - one selection model across list graph inspector
    - problems visible at every layer
    - high-risk actions are gated
    - dense-state readability over decoration
  shell_regions:
    - top header
    - left inventory rail
    - center graph canvas
    - right inspector panel
    - bottom dock
    - compact status bar
  proportions:
    header_height: "8-10%"
    main_workbench_height: "50-60%"
    bottom_dock_height: "25-30%"
    status_bar_height: "3-4%"
    left_rail_width: "22-25%"
    center_canvas_width: "50-56%"
    right_panel_width: "22-25%"
  non_negotiables:
    - use exact slash-based frame names
    - keep one consistent visual system across all outputs
    - selection must be unmistakable
    - show directed edges, not nodes only
    - relationship highlighting must be easy to follow
    - issue states cannot rely on color alone
    - dense graphs must remain navigable
    - apply actions must feel intentionally gated
    - key information must remain understandable outside the graph
  do_not_invent:
    - ownership metadata
    - last modified timestamps
    - rich edge metadata not explicitly available in the current UI
    - formal issue severity tiers beyond the current issue model
    - workflow grouping or tags unless clearly marked conceptual
    - search ranking metadata
    - live streaming execution events
    - dependency-count badges as factual data unless clearly optional/conceptual
  rendering_guidance:
    - generate flat product UI images, not device mockups
    - no laptop frames, no hands, no desk scenes
    - front-on desktop app screenshot composition
    - crisp vector-like enterprise SaaS UI
    - quiet background chrome
    - highly legible labels where possible
    - use consistent shell proportions and component language

board_rules:
  cover:
    description: "Editorial summary boards, not product UI screens."
  foundations:
    description: "System boards for grid, tokens, iconography, state logic, and interaction principles."
  components:
    description: "Component catalog boards with clear variants and anatomy."
  screens:
    description: "High-fidelity product screens using the locked shell and style contract."
  prototype:
    description: "Flow boards showing linked transitions; clear and decision-focused, not motion-heavy."
  specs:
    description: "Annotated handoff boards with redlines, labels, spacing, and behavior notes."

anchor_frame: "Desktop / 1600x1000 / Overview / Workflow Selected"

phases:
  phase_a_style_lock:
    - "Foundations / Grid / Desktop 1600x1000 / Primary"
    - "Foundations / Grid / Desktop 1366x860 / Minimum"
    - "Components / Graph"
    - "Desktop / 1600x1000 / Overview / Workflow Selected"

  phase_b_boards:
    - "Cover / Harmony Studio Graph UX"
    - "Cover / Product Goals"
    - "Cover / Data Model Summary"
    - "Foundations / Color Styles"
    - "Foundations / Type Styles"
    - "Foundations / Spacing Scale"
    - "Foundations / Iconography"
    - "Foundations / State Model"
    - "Foundations / Interaction Principles"
    - "Components / Primitives"
    - "Components / Shell"
    - "Components / Inventory"
    - "Components / Inspector"
    - "Components / Dock"
    - "Components / Feedback"

  phase_c_screens:
    - "Desktop / 1600x1000 / Overview / Default"
    - "Desktop / 1600x1000 / Overview / Workflow Selected With Issues"
    - "Desktop / 1600x1000 / Overview / Dense Graph"
    - "Desktop / 1600x1000 / Search / Results"
    - "Desktop / 1600x1000 / Search / No Results"
    - "Desktop / 1600x1000 / State / No Selection"
    - "Desktop / 1600x1000 / State / Loading"
    - "Desktop / 1600x1000 / State / Error"
    - "Desktop / 1600x1000 / Dock / Apply Audits"
    - "Desktop / 1600x1000 / Dock / Staged Edits"
    - "Desktop / 1366x860 / Validation / Default"
    - "Desktop / 1366x860 / Validation / Workflow Selected"
    - "Desktop / 1366x860 / Validation / Dense Graph"
    - "Desktop / 1366x860 / Validation / Dock"

  phase_d_prototype_and_specs:
    - "Prototype / Browse Graph"
    - "Prototype / Inspect Workflow"
    - "Prototype / Filter And Search"
    - "Prototype / Review Audit"
    - "Prototype / Stage Safe Edits"
    - "Specs / Shell / Redlines"
    - "Specs / Inventory / Anatomy"
    - "Specs / Graph / Canvas Rules"
    - "Specs / Graph / Node Anatomy"
    - "Specs / Graph / Edge Behavior"
    - "Specs / Inspector / Anatomy"
    - "Specs / Dock / Anatomy"
    - "Specs / Keyboard And Pointer"

screen_directives:
  "Desktop / 1600x1000 / Overview / Workflow Selected":
    role: "visual anchor"
    must_show:
      - one selected workflow in graph and list
      - inbound and outbound edges highlighted
      - populated inspector with title, canonical ID, description, dependency summary, path info, steps, issues, quick actions
      - header, left rail, graph canvas, right inspector, bottom dock, status bar
      - strong but calm selection accent
  "Desktop / 1600x1000 / Overview / Default":
    must_show:
      - no workflow selected
      - full graph visible
      - populated inventory
      - inspector empty state
  "Desktop / 1600x1000 / Overview / Workflow Selected With Issues":
    must_show:
      - selected workflow in broken or warning treatment
      - issue badges visible in list and graph
      - inspector issue list expanded and prominent
      - problem state obvious without color alone
  "Desktop / 1600x1000 / Overview / Dense Graph":
    must_show:
      - many nodes and visible edges
      - minimap visible
      - unrelated nodes dimmed
      - selected neighborhood emphasized
      - search or filter visibly active
  "Desktop / 1600x1000 / Search / Results":
    must_show:
      - entered search term
      - matching rows emphasized
      - matching graph nodes spotlighted
      - non-matches reduced but still understandable
  "Desktop / 1600x1000 / Search / No Results":
    must_show:
      - zero-result treatment in inventory
      - graph no-results handling
      - clear recovery guidance
  "Desktop / 1600x1000 / State / No Selection":
    must_show:
      - graph visible but nothing selected
      - explicit inspector empty state guidance
  "Desktop / 1600x1000 / State / Loading":
    must_show:
      - loading treatment for shell and/or regions
      - believable placeholders for list, graph, inspector, dock
      - no misleading final data
  "Desktop / 1600x1000 / State / Error":
    must_show:
      - error panel or banner
      - graph/list/inspector remain readable where possible
      - safe recovery action affordances
  "Desktop / 1600x1000 / Dock / Apply Audits":
    must_show:
      - Apply Audits tab selected
      - search, status filters, audit list, selected preview, open/copy actions
      - audit status treatments for applied and failed
  "Desktop / 1600x1000 / Dock / Staged Edits":
    must_show:
      - Staged Edits tab selected
      - staged count, patch preview, export status
      - stage safe edits, clear, export, arm/disarm apply, apply to files
      - apply gating visually unmistakable
  "Desktop / 1366x860 / Validation / Default":
    must_show:
      - minimum supported desktop shell remains balanced
      - graph, inventory, inspector, dock, and status bar all remain readable
      - no workflow selected
      - empty-state clarity is preserved under tighter width
  "Desktop / 1366x860 / Validation / Workflow Selected":
    must_show:
      - selected workflow remains legible in graph and list
      - inspector fits without collapsing critical information
      - selected-state hierarchy remains clear at minimum supported width
  "Desktop / 1366x860 / Validation / Dense Graph":
    must_show:
      - dense-state graph remains navigable at minimum supported width
      - minimap and graph controls remain usable
      - dimming and neighborhood emphasis preserve clarity
  "Desktop / 1366x860 / Validation / Dock":
    must_show:
      - bottom dock remains usable at minimum supported width
      - audits and staged-edit content remain readable
      - apply gating remains clear and unmistakable

component_focus:
  graph:
    required_components:
      - "Graph / Canvas"
      - "Graph / Toolbar"
      - "Graph / Toolbar Button"
      - "Graph / Minimap"
      - "Graph / Legend"
      - "Graph / Node"
      - "Graph / Node Badge"
      - "Graph / Edge"
      - "Graph / Edge Arrow"
      - "Graph / Selection Halo"
      - "Graph / Hover Relationship Preview"
      - "Graph / Cluster Card"
  inventory:
    required_components:
      - "Inventory / Sidebar"
      - "Inventory / Workflow Search"
      - "Inventory / Filter Bar"
      - "Inventory / Workflow Row"
      - "Inventory / Workflow Meta Badge"
      - "Inventory / Workflow List Container"
  inspector:
    required_components:
      - "Inspector / Panel"
      - "Inspector / Header"
      - "Inspector / Title Block"
      - "Inspector / Metadata Row"
      - "Inspector / Dependency Summary"
      - "Inspector / Step Row"
      - "Inspector / Issue Row"
      - "Inspector / Quick Action Bar"
      - "Inspector / Quick Action Button"
  dock:
    required_components:
      - "Dock / Container"
      - "Dock / Tab Bar"
      - "Dock / Tab"
      - "Dock / Audit Search"
      - "Dock / Audit Filter"
      - "Dock / Audit Row"
      - "Dock / Audit Preview"
      - "Dock / Patch Preview"
      - "Dock / Action Group"
      - "Dock / Apply Arm Toggle"
      - "Dock / Message Banner"
```

This manifest preserves the exact required frames, the mandatory shell regions, the documented proportions, and the core screen behaviors the docs call for.

---

## 2) Prompt A — Style Lock

Use this first.

```text
Use the MANIFEST already provided in this thread as the operating contract.

Task:
Lock the Harmony Studio visual system before bulk generation.

Generate these frames in order:
1. Foundations / Grid / Desktop 1600x1000 / Primary
2. Foundations / Grid / Desktop 1366x860 / Minimum
3. Components / Graph
4. Desktop / 1600x1000 / Overview / Workflow Selected

Execution rules:
- Work one frame at a time, in order.
- Before each image, print:
  - exact frame name
  - 4-8 bullets describing what must be visible
  - the specific purpose of the frame
- Then generate exactly one design image for that frame.
- After each image, print a compact QC note:
  - what is working
  - what must remain fixed in later frames

Hard rules:
- Use the exact frame names.
- Preserve a single visual system across all outputs.
- Keep the product feeling technical, calm, precise, safe, and high-information.
- Preserve the desktop-first workbench with header, left rail, center graph canvas, right inspector, bottom dock, and compact status bar.
- Show directed edges in graph outputs.
- Make selection the strongest accent.
- Make issue states obvious without relying on color alone.
- Keep dense-state readability in mind even for the anchor.
- Do not invent unsupported data or metadata.
- Do not use device mockups, laptop frames, photos, or decorative scenes.
- Render as a clean front-on product UI image.

After image 4, print:
LOCKED STYLE CONTRACT

That contract must fix:
- shell proportions
- spacing character
- typography hierarchy
- color role strategy
- node anatomy
- edge anatomy
- badge treatment
- inspector anatomy
- dock treatment
- empty/loading/error treatment
- dense-graph strategy
- apply-gating treatment

Do not ask me for confirmation unless the source docs conflict.
Continue automatically through all 4 items in this prompt.
```

---

## 3) Prompt B — Boards

Run this after Prompt A.

```text
Use the MANIFEST already provided in this thread.
Use the LOCKED STYLE CONTRACT already established in this thread.

Task:
Generate the remaining cover, foundations, and component boards.

Generate these frames in order:
1. Cover / Harmony Studio Graph UX
2. Cover / Product Goals
3. Cover / Data Model Summary
4. Foundations / Color Styles
5. Foundations / Type Styles
6. Foundations / Spacing Scale
7. Foundations / Iconography
8. Foundations / State Model
9. Foundations / Interaction Principles
10. Components / Primitives
11. Components / Shell
12. Components / Inventory
13. Components / Inspector
14. Components / Dock
15. Components / Feedback

Execution rules:
- One frame at a time, in order.
- Before each image, print:
  - exact frame name
  - frame type: cover, foundation, or component board
  - 3-6 bullets describing what the board must communicate
- Then generate exactly one image for that frame.
- After each image, print:
  - pass notes
  - drift risks to avoid in later frames

Board-specific rules:
- Cover boards are editorial summary boards, not app screenshots.
- Foundation boards must look systematic and design-system-oriented.
- Component boards must show variants, anatomy, and state coverage clearly.
- Use the exact component names from the manifest where relevant.
- Keep the locked shell, type, and color logic consistent with Prompt A.
- Do not add unsupported product concepts.

Do not stop between frames unless the source docs conflict.
Continue automatically through all items in this prompt.
```

---

## 4) Prompt C — Core Screens

Run this after Prompt B.

```text
Use the MANIFEST already provided in this thread.
Use the LOCKED STYLE CONTRACT already established in this thread.
Use the anchor frame "Desktop / 1600x1000 / Overview / Workflow Selected" as the baseline shell and visual reference.

Task:
Generate the remaining high-fidelity product screens as controlled deltas from the anchor.

Generate these frames in order:
1. Desktop / 1600x1000 / Overview / Default
2. Desktop / 1600x1000 / Overview / Workflow Selected With Issues
3. Desktop / 1600x1000 / Overview / Dense Graph
4. Desktop / 1600x1000 / Search / Results
5. Desktop / 1600x1000 / Search / No Results
6. Desktop / 1600x1000 / State / No Selection
7. Desktop / 1600x1000 / State / Loading
8. Desktop / 1600x1000 / State / Error
9. Desktop / 1600x1000 / Dock / Apply Audits
10. Desktop / 1600x1000 / Dock / Staged Edits
11. Desktop / 1366x860 / Validation / Default
12. Desktop / 1366x860 / Validation / Workflow Selected
13. Desktop / 1366x860 / Validation / Dense Graph
14. Desktop / 1366x860 / Validation / Dock

Execution rules:
- One frame at a time, in order.
- Before each image, print:
  - exact frame name
  - 3-6 bullets describing purpose
  - 3-8 bullets listing state deltas vs the anchor frame
- Then generate exactly one design image for that frame.
- After each image, print:
  - what changed correctly
  - what stayed consistent
  - any remaining risk to watch for

Critical consistency rules:
- Do not redesign the shell from scratch.
- Reuse the same proportions, typography logic, component language, and graph styling.
- Only change what the frame state requires.
- Preserve synchronized selection behavior across list, graph, and inspector.
- Keep edges visible and directed.
- Keep issue treatment obvious in list, graph, and inspector.
- Keep dense graph readable with dimming, focus, and minimap when needed.
- Keep dock screens visibly different only where tab state and dock content require it.
- Make guarded apply treatment unmistakable in staged-edit outputs.

Do not ask for confirmation between screens.
Continue automatically through all items in this prompt.
```

---

## 5) Prompt D — Prototype and Specs

Run this after Prompt C.

```text
Use the MANIFEST already provided in this thread.
Use the LOCKED STYLE CONTRACT already established in this thread.
Use the generated core screens as the visual source for prototype and spec boards.

Task:
Generate the prototype flow boards and spec handoff boards.

Generate these frames in order:
1. Prototype / Browse Graph
2. Prototype / Inspect Workflow
3. Prototype / Filter And Search
4. Prototype / Review Audit
5. Prototype / Stage Safe Edits
6. Specs / Shell / Redlines
7. Specs / Inventory / Anatomy
8. Specs / Graph / Canvas Rules
9. Specs / Graph / Node Anatomy
10. Specs / Graph / Edge Behavior
11. Specs / Inspector / Anatomy
12. Specs / Dock / Anatomy
13. Specs / Keyboard And Pointer

Execution rules:
- One frame at a time, in order.
- Before each image, print:
  - exact frame name
  - frame type: prototype or spec
  - 3-6 bullets describing what must be communicated
- Then generate exactly one image for that frame.
- After each image, print a short QC note.

Prototype rules:
- Use high-fidelity frames derived from the approved screens.
- Make flow, state changes, and decision points clear.
- Keep motion cues minimal and functional.
- Use arrows, labels, and focused callouts where helpful.

Spec rules:
- Use annotation, redlines, spacing labels, and behavior notes.
- Emphasize shell layout, graph canvas spacing, node sizes, edge treatment, inspector spacing, dock layout, state behavior, selection sync, dense-graph behavior, and apply gating.
- Label any assumptions that require engineering or product confirmation.

Do not stop between items unless the source docs conflict.
Continue automatically through all items in this prompt.
```

---

## 6) Single-frame rerun prompt

Use this when one frame drifts and you want a controlled correction.

```text
Use the MANIFEST already provided in this thread.
Use the LOCKED STYLE CONTRACT already established in this thread.

Regenerate exactly one frame:

FRAME NAME:
{{PASTE EXACT FRAME NAME}}

Reason for rerun:
{{PASTE WHAT IS WRONG}}

Required corrections:
- {{correction 1}}
- {{correction 2}}
- {{correction 3}}

Keep fixed:
- shell proportions
- type hierarchy
- color role strategy
- component language
- node and edge anatomy
- inspector and dock treatment
- all details not explicitly listed as corrections

Before the image, print:
- exact frame name
- 3-6 bullets describing what will change
- 3-6 bullets describing what must stay fixed

Then generate exactly one corrected design image.
After the image, print a short change summary.
```

---

## 7) QA audit prompt

Use this after all phases to check coverage against the docs.

```text
Audit the generated Harmony Studio design set against the MANIFEST and the source docs.

Return:
1. Coverage table by frame name
2. Missing frames
3. Drift from locked style contract
4. Violations of source constraints
5. Missing component/state coverage
6. Accessibility risks
7. Dense-graph risks
8. Apply-gating risks
9. Top 10 fixes in priority order

Rules:
- Use exact frame names from the manifest.
- Flag any invented unsupported data.
- Flag any place where selection, issue treatment, or apply gating is too weak.
- Flag any place where graph-first has collapsed into graph-only.
- Be strict and concise.
```

This pack is grounded in the required workbench layout, the exact frame inventory, the named component system, the documented screen states, and the stated design goals: technical, calm, precise, safe, high-information, graph-first, dense-state-readable, and clearly gated for risky actions.
