# Source Context

## Terminology Decision

The operator asked to retire `Lifecycle Autopilot` terminology because it
implies autonomous authority, conflicting with governed execution boundaries.

Approved replacement split:

- Product capability: `Governed Lifecycle Orchestration`
- Runtime orchestration component: `Lifecycle Runner`
- Route execution component: `Lifecycle Executor Adapter`
- Contract primitive: `Lifecycle Phase-Loop Model`
- Behavioral/state-machine concept: `Governed Lifecycle Control Loop`

## Rules

1. Rename the product capability from `Lifecycle Autopilot` to `Governed
   Lifecycle Orchestration`.
2. Keep `Lifecycle Runner`, `Lifecycle Executor Adapter`, and `Lifecycle
   Phase-Loop Model` as technical nouns.
3. Use `Governed Lifecycle Control Loop` only in explanatory architecture
   prose.
4. Do not shorten `Governed Lifecycle Orchestration` to `orchestration`.
5. Define governed execution as self-operating only through approved
   runner/executor mechanisms; never self-authorizing.
6. Apply terminology semantically. Preserve historical, archived,
   compatibility, or roadmap references only when they clearly refer to legacy
   terminology.

## Repository Grounding

The current repo already separates the Lifecycle Runner from the Lifecycle
Executor Adapter and already treats `phase_loop` as context, not authority.
The naming gap is the current product capability term.
