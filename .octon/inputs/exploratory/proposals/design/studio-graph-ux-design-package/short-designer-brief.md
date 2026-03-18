# Short Designer Brief for Studio Graph UX

**Product**
Octon Studio is a desktop workflow-mapping tool for technical maintainers. Its core job is to make a repo’s workflow system understandable at a glance, expose broken or inconsistent definitions quickly, and let users move from discovery into safe review actions.

**Primary User**
Platform engineer, repo maintainer, or systems-oriented developer working with many interdependent workflows.

**Primary Tasks**

- See the full workflow landscape quickly.
- Find a specific workflow fast.
- Understand dependencies and dependents.
- Spot missing files, broken metadata, and registry mismatches.
- Inspect one workflow in detail without losing graph context.
- Review prior apply actions and stage safe edits deliberately.

**What Success Looks Like**

- A user can identify where a workflow sits in the system in under 10 seconds.
- A broken workflow is visually obvious in the list, graph, and inspector.
- A dense graph remains usable through focus, filtering, and dimming.
- Safe actions feel intentional and clearly separated from exploration.

**Core Experience Principles**

- Graph-first, but not graph-only.
- Overview first, detail on demand.
- One selection model across list, graph, and inspector.
- Problems should be visible at every layer.
- High-risk actions should be gated and never feel casual.
- Dense-state readability matters more than decorative complexity.

**Key Constraints**

- Desktop-first workbench.
- Primary design target: `1600 x 1000`.
- Minimum supported desktop: `1366 x 860`.
- Workflows may contain cycles.
- Current runtime is not truly streaming; design for request/result, not live event choreography.
- Current data supports workflow name/ID, dependency links, issue count, step count, step list, issue list, audits, staged edits, zoom, and global counts.

**Required Screens / States**

- Loaded default overview
- Selected workflow with related paths highlighted
- Workflow with issues
- Dense graph with search/filter active
- No selection
- No search results
- Apply audits view
- Staged edits view
- Loading / empty / error states

**Deliverables Needed**

- High-fidelity desktop workbench design
- Component system for graph, list, inspector, dock, and status bar
- Interaction spec for pointer and keyboard
- Visual state system for default, hover, selected, related, warning, broken, dimmed
