# Screen Prompt Pack for Studio Graph UX

This document bundles the 18 individual design prompts for the Harmony Studio
graph UX in the recommended production order.

Use these prompts when you want to generate one design artifact at a time rather
than using the controller flow in `manifest-and-controller-prompt-pack.md`.

## Prompt 01

Frame: `Foundations / Grid / Desktop 1600x1000 / Primary`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Foundations / Grid / Desktop 1600x1000 / Primary`

This is a foundations board, not a product screen.

Goal:
Define the primary desktop layout system for Harmony Studio's graph-first workbench so all later components and screens inherit one clear shell.

Must show:
- the primary design target `1600 x 1000`
- shell regions: top header, left workflow inventory rail, center graph canvas, right inspector panel, bottom dock, compact status bar
- shell proportions:
  - header `8-10%` height
  - main workbench `50-60%` height
  - bottom dock `25-30%` height
  - status bar `3-4%` height
  - left rail `22-25%` width
  - center canvas `50-56%` width
  - right panel `22-25%` width
- grid, gutters, spacing rules, pane boundaries, and minimum width logic
- annotated layout guidance for later product screens

Rules:
- this is a systematic design-foundation board
- do not design a full app screen yet
- do not invent unsupported product data
- no device mockups, no desks, no decorative scenes
- make it technical, calm, precise, and presentation-ready

Output:
- one front-on foundation board image with labels, redlines, spacing notes, and region measurements
```

## Prompt 02

Frame: `Foundations / Grid / Desktop 1366x860 / Minimum`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Foundations / Grid / Desktop 1366x860 / Minimum`

This is a foundations validation board, not a product screen.

Goal:
Show how the primary Harmony Studio shell compresses to the minimum supported desktop `1366 x 860` without losing usability.

Must show:
- the same six shell regions as the primary layout
- compression rules for the smaller size
- what can tighten and what must not collapse
- minimum-width logic for inventory rail, graph canvas, inspector, and bottom dock
- validation emphasis for shell balance, graph readability, inspector usefulness, dock usability, and status-bar clarity

Rules:
- this is a validation board, not a redesign
- preserve the same design logic as the primary grid
- no full app screen yet
- no unsupported product data
- no decorative device or environment framing

Output:
- one front-on foundation board image with region labels, compression guidance, and validation notes
```

## Prompt 03

Frame: `Components / Graph`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Components / Graph`

This is a component board, not a full product screen.

Goal:
Define the complete graph component system for Harmony Studio so later screens can reuse one consistent graph language.

Required components:
- `Graph / Canvas`
- `Graph / Toolbar`
- `Graph / Toolbar Button`
- `Graph / Minimap`
- `Graph / Legend`
- `Graph / Node`
- `Graph / Node Badge`
- `Graph / Edge`
- `Graph / Edge Arrow`
- `Graph / Selection Halo`
- `Graph / Hover Relationship Preview`
- `Graph / Cluster Card`

Required states:
- node: default, hover, selected, related, dimmed, warning, broken, cyclic
- edge: default, highlighted, dimmed

Must communicate:
- left-to-right dependency layout
- visible directed edges
- strong selection hierarchy
- dense-graph readability
- minimap and control usefulness

Rules:
- component board only, not the full shell
- no invented unsupported data
- no semantic grouping treated as factual data
- no decorative device framing

Output:
- one component board image showing graph components, variants, annotations, and state behavior
```

## Prompt 04

Frame: `Desktop / 1600x1000 / Overview / Workflow Selected`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Overview / Workflow Selected`

This is the visual anchor screen for the product.

Goal:
Establish the primary Harmony Studio shell, hierarchy, component language, graph treatment, inspector treatment, dock treatment, and selection behavior.

Must show:
- full shell: header, left rail, graph canvas, right inspector, bottom dock, status bar
- one workflow selected in both list and graph
- inbound and outbound dependency edges highlighted
- selected neighborhood emphasized
- inspector populated with title, ID, description, dependency summary, path info, steps, issues, quick actions
- dock present and readable but secondary

Rules:
- primary design target `1600 x 1000`
- technical, calm, precise, safe, high-information
- no unsupported metadata
- no device mockups or scenery

Output:
- one polished high-fidelity product screen that serves as the visual anchor for all later screens
```

## Prompt 05

Frame: `Desktop / 1600x1000 / Overview / Default`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Overview / Default`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the loaded default overview before any workflow is selected.

State delta:
- no selected workflow row
- no selected graph node
- no highlighted dependency path
- inspector switches to a no-selection empty state

Must show:
- populated workflow list
- visible workflow graph with directed edges
- useful inspector empty state that teaches the next action
- dock and status bar preserved

Rules:
- reuse the anchor shell and visual system
- change only what is required for the no-selection state
- no unsupported data or decorative framing

Output:
- one high-fidelity product screen for the default overview state
```

## Prompt 06

Frame: `Desktop / 1600x1000 / Overview / Workflow Selected With Issues`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Overview / Workflow Selected With Issues`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the selected-workflow overview when the selected workflow has visible problems.

State delta:
- selected workflow remains selected in list and graph
- selected workflow is now in a broken/problem state
- issue badges become more prominent
- inspector issue section is elevated and expanded

Must show:
- problem visibility in list, graph, and inspector
- clear selected-state hierarchy
- calm, deliberate issue treatment without visual chaos

Rules:
- keep the same shell and component language as the anchor
- do not invent formal severity tiers beyond the current issue model

Output:
- one high-fidelity product screen for the selected-with-issues state
```

## Prompt 07

Frame: `Desktop / 1600x1000 / Overview / Dense Graph`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Overview / Dense Graph`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show that Harmony Studio remains usable when the graph is dense.

State delta:
- many more nodes and edges are visible
- selected node remains clear
- related neighborhood remains emphasized
- unrelated nodes are dimmed
- minimap and graph controls become more important

Must show:
- dense graph handling
- selected-state clarity
- readable edge hierarchy
- dock and inspector preserved

Rules:
- preserve the anchor shell and system
- no invented clustering/grouping data treated as factual

Output:
- one high-fidelity product screen proving dense-graph readability
```

## Prompt 08

Frame: `Desktop / 1600x1000 / Search / Results`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Search / Results`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the active search-results state with matching workflows emphasized across list and graph.

State delta:
- entered search term is visible
- matching rows and graph nodes are emphasized
- non-matches are reduced in prominence
- selected state, if present, remains stronger than match state

Must show:
- integrated search experience
- preserved graph context
- inspector behavior appropriate to a selected result or useful search guidance

Rules:
- reuse the anchor shell and hierarchy
- do not invent search ranking metadata

Output:
- one high-fidelity product screen for the search-results state
```

## Prompt 09

Frame: `Desktop / 1600x1000 / Search / No Results`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Search / No Results`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the zero-result search state clearly and calmly, with a recovery path.

State delta:
- search term is entered
- no rows match
- graph enters a no-results handling state
- inspector gives no-results guidance

Must show:
- clear distinction from error and no-selection
- deliberate zero-results treatment
- visible recovery guidance

Rules:
- preserve the anchor shell
- do not make the interface feel broken

Output:
- one high-fidelity product screen for the search no-results state
```

## Prompt 10

Frame: `Desktop / 1600x1000 / State / No Selection`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / State / No Selection`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the explicit no-selection state, where the workspace is ready but nothing is selected.

State delta:
- no selected row
- no selected node
- no highlighted dependency paths
- inspector provides no-selection guidance

Must show:
- a loaded, ready system
- meaningful graph overview
- useful inspector empty state

Rules:
- distinguish from search no-results and error
- preserve the anchor shell and visual system

Output:
- one high-fidelity product screen for the no-selection state
```

## Prompt 11

Frame: `Desktop / 1600x1000 / State / Loading`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / State / Loading`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show a believable loading state without pretending final data is already available.

State delta:
- list, graph, inspector, and dock are in a loading treatment
- final content is not yet present
- status bar communicates initialization/loading

Must show:
- stable shell
- clear loading behavior
- placeholders or skeletons where appropriate

Rules:
- do not invent fake final data
- preserve the anchor shell structure

Output:
- one high-fidelity product screen for the loading state
```

## Prompt 12

Frame: `Desktop / 1600x1000 / State / Error`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / State / Error`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show a structured, actionable error state without collapsing the workbench.

State delta:
- clear error banner or panel is visible
- some regions may be degraded
- recovery action is available

Must show:
- recognizable shell
- clear recovery path
- distinction from loading and no-results

Rules:
- keep the product calm and trustworthy
- no invented diagnostics beyond realistic generic messaging

Output:
- one high-fidelity product screen for the error state
```

## Prompt 13

Frame: `Desktop / 1600x1000 / Dock / Apply Audits`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Dock / Apply Audits`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the workbench with the bottom dock focused on reviewing apply audits.

State delta:
- `Apply Audits` tab is active
- dock becomes the primary task area
- audit search, status filters, row list, selected preview, and actions are visible

Must show:
- clear dock hierarchy
- applied vs failed treatments
- upper shell still present but secondary

Rules:
- preserve the anchor shell
- do not invent unsupported audit metadata

Output:
- one high-fidelity product screen for the Apply Audits dock state
```

## Prompt 14

Frame: `Desktop / 1600x1000 / Dock / Staged Edits`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1600x1000 / Dock / Staged Edits`

This screen must be a controlled delta from the anchor:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Show the workbench with the bottom dock focused on staged edits and guarded apply actions.

State delta:
- `Staged Edits` tab is active
- dock becomes the primary task area
- patch preview and action set are visible
- guarded apply treatment is unmistakable

Must show:
- staged file count
- patch preview
- status message
- actions: Stage Safe Edits, Clear, Export Patch Preview, Arm/Disarm Apply, Apply to Files

Rules:
- preserve the anchor shell
- make review-before-write feel natural
- do not invent extra approval models

Output:
- one high-fidelity product screen for the Staged Edits dock state
```

## Prompt 15

Frame: `Desktop / 1366x860 / Validation / Default`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1366x860 / Validation / Default`

This is a validation variant based on:
`Desktop / 1600x1000 / Overview / Default`

Goal:
Validate that the default overview remains usable at the minimum supported desktop size.

Must show:
- same product and same design system
- no workflow selected
- graph remains readable
- inventory remains usable
- inspector empty state remains clear
- dock and status bar remain functional

Rules:
- this is not a redesign
- preserve the primary design system faithfully
- compress intentionally, not accidentally

Output:
- one high-fidelity validation screen for the default overview at `1366 x 860`
```

## Prompt 16

Frame: `Desktop / 1366x860 / Validation / Workflow Selected`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1366x860 / Validation / Workflow Selected`

This is a validation variant based on:
`Desktop / 1600x1000 / Overview / Workflow Selected`

Goal:
Validate that the selected-workflow overview remains clear and actionable at the minimum supported desktop size.

Must show:
- selected workflow in list and graph
- visible inbound and outbound dependency paths
- inspector remains useful
- dock remains usable

Rules:
- not a redesign
- preserve selected, related, and dimmed hierarchy
- compress layout carefully

Output:
- one high-fidelity validation screen for the selected overview at `1366 x 860`
```

## Prompt 17

Frame: `Desktop / 1366x860 / Validation / Dense Graph`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1366x860 / Validation / Dense Graph`

This is a validation variant based on:
`Desktop / 1600x1000 / Overview / Dense Graph`

Goal:
Validate that the dense-graph state remains navigable and readable at the minimum supported desktop size.

Must show:
- many nodes and edges
- selected node remains clear
- neighborhood emphasis remains legible
- minimap and graph controls remain usable
- inspector and dock remain functional

Rules:
- not a redesign
- preserve graph readability first
- no invented grouping metadata

Output:
- one high-fidelity validation screen for the dense graph at `1366 x 860`
```

## Prompt 18

Frame: `Desktop / 1366x860 / Validation / Dock`

```text
Use the Harmony Studio Graph UX docs in `.proposals/studio-graph-ux` as the source of truth.

Create exactly one design artifact:
`Desktop / 1366x860 / Validation / Dock`

This is a validation variant based on the primary dock states:
- `Desktop / 1600x1000 / Dock / Apply Audits`
- `Desktop / 1600x1000 / Dock / Staged Edits`

Goal:
Validate that the bottom dock remains readable, usable, and clearly structured at the minimum supported desktop size.

Must show:
- dock as the primary task area
- upper shell still visible and contextual
- tab structure remains clear
- content grouping remains readable
- guarded apply remains unmistakable if the staged-edit state is shown

Rules:
- not a redesign
- preserve the same design system as the primary dock screens
- prioritize dock usability under tighter space

Output:
- one high-fidelity validation screen for the dock at `1366 x 860`
```
