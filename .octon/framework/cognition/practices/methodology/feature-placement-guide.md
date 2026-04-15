---
title: Octon Feature Placement Guide
description: Practical decision matrix for placing new Octon features in core authority, executable capability, governed pack, adapter, proposal, or autonomy surfaces.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-04-15
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/constitution/CHARTER.md"
  - "/.octon/framework/constitution/precedence/normative.yml"
  - "/.octon/framework/cognition/_meta/architecture/specification.md"
  - "/.octon/framework/capabilities/README.md"
  - "/.octon/framework/capabilities/packs/README.md"
  - "/.octon/framework/engine/governance/extensions/README.md"
  - "/.octon/framework/orchestration/practices/workflow-authoring-standards.md"
  - "/.octon/framework/orchestration/practices/automation-authoring-standards.md"
  - "/.octon/framework/orchestration/practices/mission-lifecycle-standards.md"
---

# Feature Placement Guide

This guide is the operator-facing decision aid for placing new Octon features.
Canonical topology and placement authority remains in
`/.octon/framework/cognition/_meta/architecture/specification.md`.

Canonical always-on core in Octon means live authored surfaces in
`framework/**` and required repo-specific authored surfaces in `instance/**`.
Additive optional features belong in extension packs; broad action governance
belongs in capability packs or governance contracts; exploratory work remains
non-canonical.

## Decision Matrix

| Surface | Primary purpose | Choose this when | Do not use this when | Authority / runtime status | Typical examples |
| --- | --- | --- | --- | --- | --- |
| `framework/**` core authority | Portable authored Octon core | The feature must be always-on, portable, and part of the base harness model | It is repo-specific, optional, or raw input content | Authored authority; canonical portable core | constitution, engine runtime, capability taxonomy, workflow standards |
| `instance/**` repo-specific authority | Repo-owned live authority | The feature is live for this repo but not universal Octon baseline | It should be portable core or remain non-authoritative | Authored authority; repo-local beneath `framework/**` | `support-targets.yml`, `extensions.yml`, mission charters |
| `command` | Atomic instruction entrypoint | One focused action with little orchestration | The unit is multi-step, typed invocation, or scheduled autonomy | Live executable surface; contract is authored or published | single leaf command, one-shot packet trigger |
| `skill` | Composite instruction capability | One bounded multi-step capability | You need explicit stage orchestration, typed service API, or optional family packaging | Live executable surface; composite instruction-driven | `audit-domain-architecture`, composite dispatcher skill |
| `tool` | Atomic invocation capability | The agent should call a narrow typed operation and get a result | The feature is a narrative multi-step guide | Live executable surface; atomic invocation-driven | search/read operation, narrow browser or repo action |
| `service` | Composite invocation capability | The feature is a typed domain service with richer call contract | The value is instruction text or operator-facing staged flow | Live executable surface; composite invocation-driven | retrieval/query service, domain API client |
| `workflow` | Explicit multi-stage orchestration | You need operator-visible sequencing, stage contracts, and cross-surface coordination | It is a thin wrapper, one bounded skill, or recurrence/scheduling logic | Live authored orchestration surface with `workflow.yml` | `export-harness`, `migrate-harness` |
| `extension pack` | Optional additive feature family | The feature is a portable optional bundle with commands, skills, prompts, context, validation, provenance, trust, and publication needs | The feature must be core authority or is really a broad support-target-governed action surface | Raw pack is non-authoritative in `inputs/**`; runtime-facing use only through published effective outputs | `octon-concept-integration`, `nextjs`, `node-ts`, `docs` |
| `capability pack` | Govern a broad action surface | You need one policy or admission boundary over many related tools or actions | You are packaging prompts, templates, or an optional feature family | Live governed surface bounded by support targets; admitted separately | `repo`, `git`, `shell`, `browser`, `api`, `telemetry` |
| `governance policy / contract` | Declarative rules, bounds, schemas, claims | The feature changes what is allowed, required, evidenced, admitted, or claimed | You are implementing behavior itself | Authored authority; non-executable by itself | support targets, execution budgets, run-contract schema |
| `adapter` | Replaceable host/model integration boundary | The feature is about connecting Octon to a host or model interface | It is capability logic, workflow logic, or policy logic | Live runtime boundary; replaceable and non-authoritative | host adapter, model adapter |
| `proposal packet` | Exploratory design or migration packet | The work is still being proposed, analyzed, challenged, or synthesized before promotion | Anything live runtime or policy must depend on | Non-canonical `inputs/**`; discovery only via generated registry | architecture packet, constitutional challenge packet, migration packet |
| `automation / mission surface` | Recurring or long-horizon autonomy and continuity | You need scheduling, unattended launch, overlap or recovery ownership, or mission continuity | You only need one execution recipe for a single run | Mission authority is live repo-authored continuity surface; scheduling and control are runtime or control concerns, not workflow semantics | mission charter, recurring audit run, long-running agent |

## Rules Of Thumb

- Only `framework/**` and `instance/**` are authored authority.
- `inputs/**` is non-authoritative; never make raw inputs a direct runtime or
  policy dependency.
- Put portable always-on harness behavior in `framework/**`; put repo-owned
  live decisions in `instance/**`.
- If the feature changes rules, claims, approvals, evidence, or bounds, start
  with governance or contracts, not capabilities.
- If the feature is a host or model integration boundary, it is an adapter, not
  a capability.
- If the feature governs a broad action class under support targets, use a
  capability pack.
- If the feature is an optional bundled family with its own
  prompts, templates, skills, validation, or publication lifecycle, use an
  extension pack.
- Raw extension packs stay additive; runtime-facing extension consumption flows
  through published effective outputs.
- Use a workflow only for explicit multi-stage orchestration with real
  sequencing value.
- Use a skill when one bounded composite instruction contract is enough.
- Use a command, tool, or service when the unit is narrower than a skill or
  needs typed invocation.
- Proposals remain non-canonical until promoted; recurring or long-horizon
  autonomy belongs with automation or mission surfaces, not workflows.

## Surface Clarifications

- `extension pack` vs `skill/workflow`: an extension pack is a packaging,
  trust, compatibility, and publication boundary; a skill or workflow is an
  execution shape that may live in core or inside a published pack.
- `extension pack` vs `capability pack`: an extension pack bundles an optional
  feature family; a capability pack governs a broad action surface bounded by
  support targets.
- `workflow` vs `skill`: a workflow is explicit staged orchestration with
  operator-visible sequencing; a skill is one composite capability boundary.
- `proposal packet` vs live runtime surface: a proposal packet informs
  promotion work; live runtime and policy must not depend on it directly.
- `governance/contracts` vs executable capability: governance says what is
  allowed, required, and claimed; capabilities say how work is executed within
  those bounds.
- `adapter` vs capability: an adapter is an integration boundary to
  host, model, or runtime interfaces; a capability is a unit of work the agent
  performs.
- `automation/mission` vs `workflow`: automation and mission surfaces handle
  recurrence, continuity, overlap, and long-horizon autonomy; workflows define
  one execution recipe, not scheduling or unattended operation.

## Placement Checklist

1. Does this change what Octon allows, requires, admits, evidences, or claims?
   If yes, place it in governance policy or contract.
2. Is this a host or model integration boundary? If yes, place it as an
   adapter.
3. Is this still exploratory design, migration, or policy analysis? If yes,
   keep it as a proposal packet.
4. Is this about recurring execution, unattended launch, or long-horizon
   continuity? If yes, use automation or mission surfaces.
5. Must every supported repo have this as part of the base harness model? If
   yes, place it in `framework/**`.
6. Is it live only for this repo’s policy, config, support, mission, or
   activation state? If yes, place it in `instance/**`.
7. Does it govern a broad action surface across many related capabilities? If
   yes, use a capability pack.
8. Is it an optional additive family with its own bundle assets and publication
   lifecycle? If yes, use an extension pack.
9. If it is a live executable unit: one focused instruction -> command; one
   composite instruction -> skill; one atomic typed call -> tool; one
   composite typed call -> service; explicit multi-stage orchestration ->
   workflow.

## Basis

- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/capabilities/README.md`
- `/.octon/framework/capabilities/packs/README.md`
- `/.octon/framework/engine/governance/extensions/README.md`
- `/.octon/framework/orchestration/practices/workflow-authoring-standards.md`
- `/.octon/framework/orchestration/practices/automation-authoring-standards.md`
- `/.octon/framework/orchestration/practices/mission-lifecycle-standards.md`
- `/.octon/framework/constitution/CHARTER.md`
