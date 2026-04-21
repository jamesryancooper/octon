---
title: Start Here
description: Boot sequence and orientation for the root .octon Constitutional Engineering Harness.
---

# .octon: Start Here

Use this document for the steady-state boot sequence. Canonical topology,
authority families, publication metadata, and doc roles live in
`/.octon/framework/cognition/_meta/architecture/contract-registry.yml`.

Bootstrap treats runtime helpers as portable operational support, not as a
second authority plane. The constitutional kernel anchor remains
`/.octon/framework/constitution/CHARTER.md`, authored lab assets remain under
`/.octon/framework/lab/`, and retained lab evidence remains under
`/.octon/state/evidence/lab/`.

## Boot Sequence

1. Enter through ingress.
   - repo-root `AGENTS.md` or `CLAUDE.md`
   - `/.octon/AGENTS.md`
   - `/.octon/instance/ingress/AGENTS.md`
2. Bind the constitutional and workspace objective surfaces.
   - `/.octon/framework/constitution/**`
   - `/.octon/instance/charter/workspace.md`
   - `/.octon/instance/charter/workspace.yml`
3. Bind structural orientation when the task touches topology, docs, bootstrap,
   publication, or placement rules.
   - `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
   - `/.octon/framework/cognition/_meta/architecture/specification.md`
4. Run the standard preflight before the first material task when local harness
   health or publication freshness matters.
   - `/bootstrap-doctor`
   - `provision-host-tools`
   - canonical workflow:
     `/.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/workflow.yml`
5. Resume continuity if the work is not greenfield.
   - repo continuity:
     `/.octon/state/continuity/repo/{log.md,tasks.json}`
   - scope continuity when one declared scope owns the work:
     `/.octon/state/continuity/scopes/<scope-id>/**`

## Authority Map

| Surface | Use |
| --- | --- |
| `framework/constitution/**` | Supreme repo-local control authority |
| `instance/charter/**` | Workspace objective authority |
| `instance/governance/**` | Repo-owned policy, support-target, exclusion, ownership, and governance disclosure authority |
| `instance/orchestration/missions/**` | Mission continuity authority |
| `state/control/**` | Mutable execution, publication, extension, and quarantine truth |
| `state/evidence/**` | Retained evidence, disclosure, and validation receipts |
| `state/continuity/**` | Handoff and resumption state |
| `generated/effective/**` | Runtime-facing derived outputs with receipt-backed freshness |
| `generated/cognition/**` | Non-authoritative operator and mission read models |
| `inputs/**` | Non-authoritative additive and exploratory inputs only |

Consequential execution binds mission, run, control, and evidence surfaces
without treating generated summaries or raw inputs as authority.

## Publication Model

- Runtime-facing effective outputs live under `generated/effective/**`.
- Operator and mission read models live under `generated/cognition/**`.
- Proposal discovery lives under `generated/proposals/registry.yml`.
- Generated outputs require the publication and freshness conditions declared in
  `contract-registry.yml#publication_metadata`.
- Retained publication receipts live under
  `state/evidence/validation/publication/**`.

## Human-Led Zone

`/.octon/inputs/exploratory/ideation/**` remains human-led. Autonomous access
is blocked unless a human explicitly scopes the request.

Proposal packets under `/.octon/inputs/exploratory/proposals/**` may inform
review or promotion work, but they remain non-authoritative lineage until their
content is promoted outside `inputs/**`.

## When You Need History

Historical wave, cutover, and proposal-lineage material no longer lives in this
boot document. Use:

- `/.octon/instance/cognition/decisions/index.yml` for durable ADR discovery
- `/.octon/instance/cognition/decisions/094-*.md` through `098-*.md` for the
  docs and topology remediation lineage
- `/.octon/state/evidence/migration/**` for retained migration evidence

## Minimal Next Actions

1. Read the ingress surface and workspace charter pair.
2. Read the structural registry if the task affects topology, docs, bootstrap,
   publication, or placement.
3. Run `/bootstrap-doctor` when freshness or local harness health is in doubt.
4. Resume continuity, then execute the highest-priority unblocked task.
