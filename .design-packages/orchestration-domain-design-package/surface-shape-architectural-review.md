# Surface Shape Architectural Review

## Review Scope

This review evaluates the proposed orchestration surface shapes in
`.design-packages/orchestration-domain-design-package/` against five lenses:

- completeness
- soundness
- logical separation of responsibilities
- operability
- change safety

The review treats current Harmony surfaces and contracts as grounding evidence,
not as a requirement to preserve the proposal unchanged.

## Executive Verdict

The mature surface model is architecturally sound and logically structured.
After the revisions in this review and the addition of the contract set under
`contracts/`, the proposal is complete enough to serve as both:

- a credible target architecture
- an implementation-ready contract package

That means the proposal is:

- architecturally `sound`: yes
- architecturally `logical`: yes
- architecturally `complete enough for proposal`: yes
- architecturally `complete enough for direct implementation`: yes, at the
  contract level

## Remediations Applied During Review

The following proposal gaps were corrected during this review:

- added `workflows` and `missions` to `Example Surface Shapes`
- added `campaigns` to the canonical storage split
- normalized `automations` to include `policy.yml` consistently
- moved event-trigger selection into dedicated `trigger.yml`
- strengthened `watchers` with an explicit `emits.yml` contract artifact
- strengthened `queue` with `schema.yml` and explicit retry lane
- constrained `queue` to automation-ingress only
- strengthened `runs` with reverse-lookup projections under `by-surface/`
- codified the remaining interface and object contracts under `contracts/`
- codified progressive-disclosure and authority-layer rules for new surfaces

## Surface Determination Matrix

| Surface | Completeness | Soundness | Logic | Determination |
|---|---|---|---|---|
| `workflows` | high | high | high | complete and sound |
| `missions` | high | high | high | complete and sound |
| `campaigns` | medium-high | high | high | implementation-ready and optional |
| `automations` | high | high | high | implementation-ready with explicit policy contract |
| `watchers` | high | high | high | implementation-ready with explicit event contract |
| `queue` | high | high | high | implementation-ready with item and lease contract |
| `runs` | high | high | high | implementation-ready with explicit continuity linkage |
| `incidents` | high | high | high | implementation-ready with object and closure contract |

## Surface-By-Surface Review

### `workflows`

Verdict:

- architecturally complete
- sound
- logical

Why:

- Harmony already has a strong workflow contract
- bounded procedure definition is clearly separated from execution engines and
  schedule policy
- the shape supports both multi-file and single-file workflows

Residual risk:

- low

### `missions`

Verdict:

- architecturally complete
- sound
- logical

Why:

- Harmony already has a strong mission lifecycle and bounded-state model
- the shape clearly isolates initiative state from workflow definitions
- archive, scaffold, and registry responsibilities are explicit

Residual risk:

- low

### `campaigns`

Verdict:

- architecturally logical
- not required for core completeness

Why:

- it cleanly fills a strategic portfolio gap above missions
- it does not distort the rest of the model if kept optional

Residual risk:

- premature adoption could create unnecessary hierarchy before mission
  coordination actually requires it

### `automations`

Verdict:

- architecturally sound
- implementation-ready

Why:

- recurrence belongs here, not in workflows
- the shape now explicitly includes trigger, bindings, and policy

Implementation contract:

- codified in `contracts/automation-execution-contract.md`

Residual risk:

- if automation policy remains implicit, it will bleed back into workflows or
  external schedulers

### `watchers`

Verdict:

- architecturally logical
- implementation-ready

Why:

- watchers are the right place for long-lived detection
- adding `emits.yml` makes the downstream interface explicit instead of implied

Implementation contract:

- codified in `contracts/watcher-event-contract.md`

Residual risk:

- without a stable event contract, watchers and queue will couple through
  undocumented assumptions

### `queue`

Verdict:

- architecturally logical
- implementation-ready

Why:

- a queue is the right buffering boundary between detection and execution when
  asynchronous event load exists
- adding `schema.yml` and `retry/` makes the shape materially more complete
- constraining queue targets to automations keeps initiative state out of the
  ingestion plane

Implementation contract:

- codified in `contracts/queue-item-and-lease-contract.md`

Residual risk:

- without lease rules, the queue can become a source of duplicated or stuck
  execution

### `runs`

Verdict:

- architecturally sound
- implementation-ready

Why:

- Harmony already distinguishes durable evidence from active state
- the orchestration `runs` surface makes sense as a projection and linkage layer
  over continuity evidence
- reverse-lookup projections make the surface more usable for operators and
  audits

Implementation contract:

- codified in `contracts/run-linkage-contract.md`

Residual risk:

- if the split is not kept explicit, run data will be duplicated or drift
  across surfaces

### `incidents`

Verdict:

- architecturally sound
- logically placed as an override surface

Why:

- incidents should remain exception-focused and operator-visible
- a runtime incident object model is reasonable as long as governance policy
  remains separate

Implementation contract:

- codified in `contracts/incident-object-contract.md`

Residual risk:

- if runtime incident state becomes policy by implication, governance boundaries
  will blur

## Cross-Surface Findings

### Finding 1

Title:

- Missing interface contracts were the main completeness gap, not bad hierarchy

Impact:

- high

Explanation:

- The surface hierarchy was already sound.
- The main architectural weakness was that some proposed shapes did not make
  cross-surface interfaces explicit.
- This was strongest in `watchers`, `queue`, `automations`, and `runs`.
- Those gaps are now resolved by the implementation contract set.
- The ingestion path is now cleaner because `queue` is no longer modeled as a
  direct mission consumer.

### Finding 2

Title:

- The core model is already coherent around `workflows`, `missions`, and `runs`

Impact:

- high

Explanation:

- The strongest part of the proposal remains the mature core:
  `workflows -> missions -> runs`.
- The other surfaces are valuable only if they preserve that core separation.

### Finding 3

Title:

- Governance/runtime/continuity separation remains the make-or-break property

Impact:

- high

Explanation:

- The proposal stays logical only if:
  - governance owns policy,
  - runtime owns active state and executable surfaces,
  - continuity owns append-oriented evidence and handoff memory.

## Final Architectural Position

The proposal now has a good architectural shape.

It is:

- modular
- discoverable
- reasonably low-coupling at the responsibility level
- operable enough to propose and iterate on
- safe enough to evolve without locking Harmony into one oversized orchestration
  abstraction

The next step, if this proposal graduates toward implementation, is not to add
more surfaces. It is to codify the remaining cross-surface contracts before
introducing the proposed runtime directories.
