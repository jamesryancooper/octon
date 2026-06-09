# Governed Cross-Surface Mechanisms

## Non-Authority Banner

This mechanism index is architecture/governance documentation. It is not runtime authority, policy authority, support authority, closeout authority, cleanup authority, retained evidence, mutable control truth, generated-effective authority, an operator read model, or a proposal receipt. It helps agents and humans find the surfaces that already own those roles.

Generated projections, raw inputs, host state, chat history, model memory, tool
availability, product feature catalog entries, lifecycle events, and
proposal-local receipts are not authority substitutes.

## Layered Terminology

Use `product features` in product documentation and the product feature
catalog. Product feature entries are navigation-only.

Use `governed cross-surface mechanisms` in architecture and governance
documentation when describing systems that span product contracts, runtime
specs, runtime implementations, generated projections, state/control,
retained evidence, validators, skills, and operator views.

Use concrete runtime/operator terms in runtime surfaces: lifecycles, workflows, routes, state machines, receipts, commands, and skills.

## Glossary

- feature: a product-facing navigation unit that points to authoritative,
  runtime, generated, evidence, and validation surfaces without minting
  authority.
- mechanism: an architecture/governance description of a cross-surface system
  and its authority boundaries.
- lifecycle: a declared route-progression contract with gates, receipts,
  phases, execution routes, checkpointing, and terminal outcomes.
- state machine: a formal state/transition contract for one lifecycle or
  closeout domain.
- workflow: an authored operational sequence or runner-owned execution model.
- route: one selected path through a lifecycle, workflow, or closeout policy.
- contract: an authored policy, schema, or spec that owns durable semantics.
- capability: a surfaced operation, skill, command, extension profile, or
  runtime affordance that must remain subordinate to its contracts.
- subsystem: a bounded owner of contracts, runtime, validation, generated
  projections, control state, or evidence.
- control plane: mutable operational truth, normally under
  `.octon/state/control/**`.
- evidence plane: retained factual proof, normally under
  `.octon/state/evidence/**`.

## Authority Class Guide

Mechanism entries use these classes:

- authored authority: durable framework or instance contracts, policy, specs,
  schemas, docs, workflows, and validators under `.octon/framework/**` or
  `.octon/instance/**`.
- product contract: product-level policy or schema surfaces under
  `.octon/framework/product/contracts/**`.
- runtime spec: authored runtime contracts under
  `.octon/framework/engine/runtime/spec/**`.
- runtime implementation: runtime crates, scripts, workflows, adapters, or
  executable skill definitions that perform declared behavior.
- mutable operational truth: current execution, quarantine, approval,
  lifecycle checkpoint, or publication control state under
  `.octon/state/control/**`.
- retained evidence: receipts, validation records, disclosure proof, and run
  evidence under `.octon/state/evidence/**`.
- generated-effective non-authority: generated runtime-discovery handles under
  `.octon/generated/effective/**`; consumers must resolve them through
  validator-backed runtime handles.
- generated operator read model: visibility-only projections under
  `.octon/generated/cognition/**`; they are never runtime, support, closeout,
  archive, or evidence-gate proof.
- publication input only: additive extension authoring surfaces under
  `.octon/inputs/additive/**`.
- exploratory raw input: proposal packets, research, and planning input under
  `.octon/inputs/exploratory/**`.
- navigation only: product feature docs, product catalog entries, maps, and
  indexes that point to owners without replacing them.
- compatibility only: retained shims, historical names, adapter mirrors, and
  generated compatibility projections that must not become current authority.

`state/control/**` is mutable operational truth, not retained evidence.
`state/evidence/**` is retained evidence, not generated output. Generated
operator read models are distinct from generated-effective runtime handles.

## Mechanism Entry Template

Each mechanism entry must name:

- authored authority surfaces
- product contracts and product feature navigation, when present
- runtime specs and runtime implementations
- mutable operational truth
- retained evidence
- generated-effective non-authority surfaces
- generated operator read models
- raw/input and publication-input-only surfaces
- navigation-only and compatibility-only surfaces
- validators and tests
- explicit non-authority boundaries
- ownership and delegation boundaries

## Required Mechanism Coverage

The machine-readable coverage index is `index.yml`. It covers:

- Change Closeout Lifecycle
- Governed Lifecycle Orchestration
- Governed Incoming Intake Routing
- Extension Packs
- Run Lifecycle v1
- Workflow system
- Execution authorization / effect-token system
- Evidence store / proof plane
- Lifecycle interaction receipts
- Repo hygiene cleanup
- Mission autonomy / Mission Runner
- Mission Plan compiler
- Generated effective/runtime resolution
- Operator read models

## Boundary Notes

Lifecycle, workflow, route, and state machine are not synonyms. A lifecycle may
use workflows and routes, and a lifecycle or closeout contract may define a
state machine, but each authority surface owns only its declared layer.

Repo hygiene may receive a handoff after Change closeout, but handoff does not
transfer cleanup ownership to proposal lifecycle or Change closeout. Detection
never authorizes deletion.

Mission Runner candidate preparation is planning and materialization readiness,
not material execution. Mission autonomy remains bounded by mission contracts,
support targets, policies, receipts, and validators.

Lifecycle interaction receipts are advisory dependency context. They do not
authorize target lifecycle work, select Change routes, satisfy closeout
receipts, authorize hosted landing, authorize branch cleanup, authorize repo
hygiene deletion, or satisfy proposal packet gates.

Parent proposal-program evidence may summarize child outcomes, but child
manifests, subtype manifests, review receipts, implementation prompts,
validation verdicts, promotion targets, acceptance criteria, conformance
receipts, drift/churn receipts, closeout receipts, and archive metadata remain
child-owned.

## Detail Pages

- `mechanisms/governed-lifecycle-orchestration.md`
- `mechanisms/change-closeout-and-repo-hygiene.md`
- `mechanisms/operator-read-models.md`

## Closeout Coverage

Use `aggregate-closeout-evidence-template.md` when a parent program needs to
summarize child outcomes without satisfying child-owned receipts.
