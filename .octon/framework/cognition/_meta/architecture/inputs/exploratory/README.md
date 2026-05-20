# Exploratory Inputs

`inputs/exploratory/**` contains human-authored, non-authoritative material that
may inform governed Octon work. These surfaces are not runtime, policy,
generated, state/control, publication, retained evidence, or host-projection
authority.

Local README files under `.octon/inputs/exploratory/**` are point-of-use
contracts for contributors. This architecture document owns the cross-surface
taxonomy; local READMEs adapt these rules at the surface where work happens.

## Surface Contracts

| Surface | Purpose | Allowed contents | Prohibited contents | Lifecycle route | Validator coverage |
| --- | --- | --- | --- | --- | --- |
| `ideation/**` | Human-led divergent exploration, scratchpad material, imports, and structured research | Explicitly human-scoped notes, inbox material, brainstorms, projects, and project scaffolds | Autonomous intake, runtime dependencies, policy sources, generated output, retained evidence, and direct publication instructions | Governed proposal, plan, Change, retained evidence update, durable authored edit outside `inputs/**`, deletion, or advisory closeout with no promotion | `validate-exploratory-input-surfaces.sh` |
| `proposals/**` | Manifest-governed proposal packets and programs | `proposal.yml`, subtype manifests, packet-local support material, lifecycle status, and archived proposal packets | Runtime, policy, documentation, contract authority, generated output, retained evidence, and proposal-less loose files | Proposal lifecycle validation, acceptance, implementation, archival, rejection, or supersession | proposal validators and `validate-exploratory-input-surfaces.sh` |
| `plans/*.md` | Advisory implementation, migration, assessment, task, checklist, and backlog plans | Date-prefixed advisory planning files that remain outside workflow state | Receipts, completion evidence, runtime state, policy decisions, generated output, and retained evidence | Separate governed work, supersession, archival, or removal | `validate-exploratory-input-surfaces.sh` |
| `syntheses/*.md` | Advisory research consolidation and multi-source synthesis | Synthesis files with source framing and non-authoritative conclusions | Decisions, policy, runtime state, generated output, retained evidence, and installable packs | Governed proposal, plan, Change, evidence update, durable authored edit, supersession, or removal | `validate-exploratory-input-surfaces.sh` |
| `reports/<report-id>/` | Multi-file non-authoritative report sets that do not fit proposal, plan, or synthesis contracts | Report directory with `report.yml`, findings, appendices, and local support files | Runtime state, policy authority, generated output, retained evidence, extension packs, and root loose report files | Governed route, retained non-authoritative report history, archival, rejection, or removal | `validate-exploratory-input-surfaces.sh` |

## Authority Boundary

Exploratory inputs may be cited, reviewed, summarized, or used as source
material by governed workflows. They become durable only when a governed
proposal, plan, Change, retained evidence update, or authored edit outside
`inputs/**` accepts the relevant content under its own validation and evidence
rules.

Required route: governed proposal, plan, Change, retained evidence update, or durable authored edit outside `inputs/**`.
