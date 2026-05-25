# Target Architecture

## Terminology Split

| Name | Meaning | Allowed Surfaces |
| --- | --- | --- |
| Governed Lifecycle Orchestration | Product capability | Product feature catalog, feature note, roadmap, operator docs |
| Lifecycle Runner | Runtime orchestration component | Runtime docs, code comments, skills, lifecycle model docs |
| Lifecycle Executor Adapter | Route execution component | Runtime docs, executor schemas, lifecycle model docs |
| Lifecycle Phase-Loop Model | Contract primitive | Lifecycle contract docs and schema explanations |
| Governed Lifecycle Control Loop | Behavioral/state-machine concept | Explanatory architecture prose only |

## Governed Definition

Governed means self-operating execution is allowed only through approved
Lifecycle Runner and Lifecycle Executor Adapter mechanisms. The system may
plan, gate, dispatch eligible routes, observe receipts, checkpoint, resume, and
fail closed, but it must never mint authority, widen scope, bypass human-only
boundaries, or treat non-authoritative state as approval.

## Naming Rules

- Product capability docs use `Governed Lifecycle Orchestration`.
- Runtime orchestration code and docs use `Lifecycle Runner`.
- Route execution code and docs use `Lifecycle Executor Adapter`.
- Contract docs use `Lifecycle Phase-Loop Model` for the generic phase-loop
  primitive while the machine field remains `phase_loop`.
- `Governed Lifecycle Control Loop` appears only in prose that explains the
  evidence-driven state-machine behavior.
- Do not shorten `Governed Lifecycle Orchestration` to `orchestration`.
  Octon already has workflow/orchestration surfaces, route-resolution scripts,
  and runtime workflow concepts.

## Legacy Handling

Preserve `Lifecycle Autopilot` only when the text is clearly historical,
archived, compatibility-oriented, or part of immutable retained evidence. Active
product capability, roadmap, validator, and current extension prose should use
the governed lifecycle terminology.
