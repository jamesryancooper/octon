# Production Workflow for Studio Graph UX

The best setup is to treat this as a **manifest-driven design run**, not a series of ad hoc image prompts.

The docs already give us a fixed page structure, exact frame names, exact component names, required states, and the 15 required screens including minimum-size validation. That means the most reliable automation is: **lock one visual system, define one screen manifest, then generate each screen as a controlled variation of the same shell**.  

### Best workflow

**1. Lock the style contract first**
Have me generate three “anchor” outputs before anything else:

* a **Foundations board**
* a **Components board**
* one **anchor screen**: `Desktop / 1600x1000 / Overview / Workflow Selected`

That works because the checklist explicitly requires foundations and components before final screens, and the brief is very specific about the intended feel: technical, calm, precise, safe, high-information, with unmistakable selection and strong problem visibility.  

**2. Use the required screens as a generation manifest**
After the anchor is approved, I should step through the required screen list in order, using the exact names from the spec:

* Overview states
* Search states
* No selection / loading / error
* Dock states

Those are already defined, so there is no ambiguity about what must be produced.  

**3. Generate by “delta,” not from scratch**
Each new screen should inherit the same:

* shell proportions
* color system
* type scale
* component language
* graph node/edge styling
* inspector structure
* dock treatment

Then only the state changes. For example, `Workflow Selected With Issues` should be the selected anchor screen plus broken-state node/list treatment, issue emphasis, and inspector issue elevation. `Dense Graph` should keep the same shell and swap in minimap visibility, dimming, and focus behavior. That matches the documented interaction and state model.  

**4. Keep prompts constrained to real data**
The prompt pack should avoid inventing fields the brief says are not reliably available, like ownership, timestamps, rich edge metadata, dependency counts on nodes, or search ranking. That keeps the visuals aligned to the real product scope.  

**5. Leave prototype/spec images until the screens are stable**
The docs require prototype and spec frames, but those should come after the visual language is locked. Otherwise the system drifts.  

---

### What I’d recommend you have me generate first

Use this order:

1. `Foundations / Grid / Desktop 1600x1000 / Primary`
2. `Foundations / Grid / Desktop 1366x860 / Minimum`
3. `Components / Graph`
4. `Desktop / 1600x1000 / Overview / Workflow Selected`
   ← this becomes the visual anchor
5. `Desktop / 1600x1000 / Overview / Default`
6. `Desktop / 1600x1000 / Overview / Workflow Selected With Issues`
7. `Desktop / 1600x1000 / Overview / Dense Graph`
8. `Desktop / 1600x1000 / Search / Results`
9. `Desktop / 1600x1000 / Search / No Results`
10. `Desktop / 1600x1000 / State / No Selection`
11. `Desktop / 1600x1000 / State / Loading`
12. `Desktop / 1600x1000 / State / Error`
13. `Desktop / 1600x1000 / Dock / Apply Audits`
14. `Desktop / 1600x1000 / Dock / Staged Edits`
15. `Desktop / 1366x860 / Validation / Default`
16. `Desktop / 1366x860 / Validation / Workflow Selected`
17. `Desktop / 1366x860 / Validation / Dense Graph`
18. `Desktop / 1366x860 / Validation / Dock`

That sequence follows the required system order while also giving you the highest-value core screens first.  

---

### The prompt structure that works best

Give me one controller prompt like this:

```text
Use the Harmony Studio Graph UX docs as the source of truth.

Create design images in a manifest-driven sequence.

Rules:
- Preserve the same visual system across all outputs unless a state change requires a visible delta.
- Use the exact required frame names.
- Keep the product feeling technical, calm, precise, safe, and high-information.
- Preserve the desktop-first shell and three-pane workbench with bottom dock and status bar.
- Do not invent unavailable data such as ownership, timestamps, rich edge metadata, dependency-count badges, or semantic grouping metadata.
- Keep selection unmistakable, problems obvious, dense graphs readable, and apply actions clearly gated.

For each item in the manifest:
1. State the exact frame name.
2. Summarize the purpose of the screen in 2-4 bullets.
3. List the visible regions and required components.
4. List the state deltas from the approved anchor design.
5. Generate one design image for that frame.
6. Move to the next manifest item automatically.

Generation order:
1. Foundations / Grid / Desktop 1600x1000 / Primary
2. Foundations / Grid / Desktop 1366x860 / Minimum
3. Components / Graph
4. Desktop / 1600x1000 / Overview / Workflow Selected
5. Desktop / 1600x1000 / Overview / Default
6. Desktop / 1600x1000 / Overview / Workflow Selected With Issues
7. Desktop / 1600x1000 / Overview / Dense Graph
8. Desktop / 1600x1000 / Search / Results
9. Desktop / 1600x1000 / Search / No Results
10. Desktop / 1600x1000 / State / No Selection
11. Desktop / 1600x1000 / State / Loading
12. Desktop / 1600x1000 / State / Error
13. Desktop / 1600x1000 / Dock / Apply Audits
14. Desktop / 1600x1000 / Dock / Staged Edits
15. Desktop / 1366x860 / Validation / Default
16. Desktop / 1366x860 / Validation / Workflow Selected
17. Desktop / 1366x860 / Validation / Dense Graph
18. Desktop / 1366x860 / Validation / Dock
```

---

### The key thing that makes this work

Do **not** ask me to “design the whole product in one go.”

UI image generation is strongest when there is:

* one locked visual anchor
* one stable shell
* one known component language
* one explicit state delta per screen

That is especially important here because the docs require consistent selection behavior, matching list/graph/inspector states, dense-graph readability, and explicit apply gating in the dock.  

### One important limitation

I can generate strong **high-fidelity concept screens** this way, but image generation is not the same as a true pixel-perfect Figma component system. The best use of this workflow is:

* first: generate the visual targets
* then: turn the chosen direction into actual components/specs

That lines up with the docs anyway, because the required deliverable is not just pretty screens, but also foundations, components, interactions, and specs.  
