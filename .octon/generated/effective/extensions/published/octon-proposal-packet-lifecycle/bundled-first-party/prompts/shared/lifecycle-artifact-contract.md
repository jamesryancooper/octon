# Lifecycle Artifact Contract

Source lineage and evaluations are retained in packet `resources/**`.
Generated operational aids are retained in packet `support/**`.

Expected packet support outputs include:

- `support/proposal-packet-creation-prompt.md`
- `support/executable-implementation-prompt.md`
- `support/follow-up-verification-prompt.md`
- `support/custom-closeout-prompt.md`
- `support/correction-prompts/<finding-id>.md`
- `support/executable-program-implementation-prompt.md`
- `support/follow-up-program-verification-prompt.md`
- `support/program-correction-prompts/<finding-id>.md`
- `support/custom-program-closeout-prompt.md`
- `support/child-closeout-prompts/`

These files are operational aids and evidence pointers. They must not claim to
be source of truth.

Creation routes must produce a structured Markdown packet that is archive-ready
without requiring a generated build artifact. For architecture packets, the
artifact floor is:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `architecture/target-architecture.md`
- `architecture/current-state-gap-map.md`
- `architecture/implementation-plan.md`
- `architecture/validation-plan.md`
- `architecture/acceptance-criteria.md`
- `architecture/file-change-map.md`
- `architecture/cutover-checklist.md`
- `architecture/rollback-plan.md`
- `architecture/operator-disclosure.md`
- source-specific resources, including the complete audit, evaluation, gap
  analysis, traceability map, assumptions and blockers, risk register, and
  evidence plan when the source material supplies or implies those artifacts

Subtype standards remain the required floor when they are stricter or more
specific. Routes must record any intentionally omitted artifact and why it is
not implicated by the selected proposal scope.
