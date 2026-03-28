# Implementation Plan

This proposal should be promoted as a staged transitional program, not as one
atomic cutover. The target architecture changes execution identity, authority
routing, runtime lifecycle, disclosure, and proof obligations across multiple
domains. A one-shot swap would either strand Octon in a half-constitutional
state or require a risky freeze across too many surfaces at once.

The promotion goal is still one coherent final state. Transitional here means
temporary coexistence with explicit retirement gates, not open-ended dual
models.

## Profile Selection Receipt

- Date: 2026-03-26
- Version source(s): `/.octon/octon.yml`
- Current version: `0.6.3`
- `release_state`: `pre-1.0`
- `change_profile`: `transitional`
- Selection facts:
  - downtime tolerance: internal harness work can absorb staged cutovers, but
    the blast radius is too wide for a safe atomic switch from mission-first to
    run-first execution
  - external consumer coordination ability: low external dependency pressure,
    but significant repo-local coordination across runtime, governance,
    bootstrap, assurance, and generated read models
  - data migration and backfill needs: high; mission control, retained
    evidence, generated read models, and approval/disclosure state need an
    explicit bridge to the run model
  - rollback mechanism: revert the latest completed wave, regenerate affected
    effective outputs, and restore the prior mission-centric behavior for any
    not-yet-retired surfaces
  - blast radius and uncertainty: very high; this proposal touches objective
    binding, authorization, runtime, assurance, observability, and disclosure
  - compliance and policy constraints: no consequential execution may lose
    objective binding, authority routing, or evidence guarantees during the
    transition
- Hard-gate outcomes:
  - mission-first and run-first execution need a temporary coexistence window
  - approval and disclosure artifacts need staged adoption before old host
    glue can be retired
  - generated projections and summaries need backfill from new run roots before
    old mission-only read models can be removed
  - lab and support-target declarations can land incrementally without
    weakening the current fail-closed posture
- Tie-break status: `transitional` selected because a hard gate requires
  temporary coexistence and backfill

## Transitional Program Invariants

- no new consequential execution path may bypass the existing engine-owned
  authorization boundary while the new authority engine is being introduced
- no new runtime path may depend on chat continuity as the only source of
  resumption state
- no new adapter or host affordance may become authority during the transition
- no new support claim may land without an explicit support-target declaration
  once the constitutional kernel exists
- coexistence between mission-first and run-first execution must be explicit,
  temporary, and measured against retirement criteria
- every completed wave must update docs, validators, and generated projections
  in the same branch as the behavior it changes

## Program Shape

### Wave 0: Constitutional Baseline

Scope:

- publish the constitutional kernel scaffolding under
  `framework/constitution/**`
- define normative and epistemic precedence, fail-closed obligations, evidence
  obligations, ownership-role taxonomy, and support-target schema
- align bootstrap and architecture docs so the constitutional kernel has one
  clear read path

Durable outputs:

- `framework/constitution/CHARTER.md`
- `framework/constitution/charter.yml`
- `framework/constitution/precedence/**`
- `framework/constitution/obligations/**`
- `framework/constitution/ownership/roles.yml`
- `framework/constitution/contracts/registry.yml`
- `framework/constitution/support-targets.schema.json`

Exit gate:

- one explicit constitutional kernel exists
- current durable docs and specs point to it rather than re-stating competing
  constitutional fragments
- no prompt or ingress surface claims authority outside the kernel

### Wave 1: Objective Binding Cutover

Scope:

- ratify the current objective brief and intent contract as the workspace-
  charter pair
- normalize mission charter expectations around continuity, ownership, and
  long-horizon autonomy
- add the run contract contract family and the run-control root
- define stage-attempt artifacts and retirement rules for mission-only
  execution assumptions

Durable outputs:

- constitutional objective contracts under
  `framework/constitution/contracts/objective/**`
- aligned `instance/bootstrap/OBJECTIVE.md`
- aligned `instance/cognition/context/shared/intent.contract.yml`
- aligned mission templates and mission contract guidance under
  `instance/orchestration/missions/**`
- new runtime control families under `state/control/execution/runs/**`

Exit gate:

- consequential execution has a defined run-contract shape
- mission-only execution is explicitly transitional rather than implicit steady
  state
- docs, schemas, and validators agree on workspace, mission, and run
  responsibilities

### Wave 2: Authority Engine Normalization

Scope:

- centralize approval, exception, revocation, and decision artifacts
- route current host-shaped approval flows through generic authority artifacts
- extend support-tier, egress, budget, reversibility, and ownership decisions
  through one route engine

Durable outputs:

- `framework/constitution/contracts/authority/**`
- runtime authority engine surfaces under `framework/engine/runtime/**`
- repo-owned policy overlays under `instance/governance/policies/**`
- populated control families under `state/control/execution/approvals/**`,
  `exceptions/**`, and `revocations/**`
- retained authority evidence under `state/evidence/control/execution/**`

Exit gate:

- every consequential route resolves through normalized decision artifacts and
  grant bundles
- host-specific approval projections are subordinate to generic authority
  artifacts
- unresolved ownership, invalid intent, unsupported support tier, or missing
  required evidence fail closed or stage only according to policy

### Wave 3: Runtime Lifecycle Normalization

Scope:

- make run roots the primary execution-time unit of truth
- move checkpoint, retry, rollback, contamination, and replay posture into the
  run lifecycle
- bridge existing mission control and continuity surfaces to consume run state
  instead of acting as the only execution container

Durable outputs:

- runtime contracts under `framework/constitution/contracts/runtime/**`
- run lifecycle implementation under `framework/engine/runtime/**`
- live control under `state/control/execution/runs/**`
- retained run evidence under `state/evidence/runs/**`
- generated effective and cognition consumers aligned to the new run model

Exit gate:

- consequential stages bind a run root before side effects
- checkpoints and resumption work from durable state
- mission continuity consumes run evidence instead of substituting for it
- replay pointers and evidence families exist for consequential runs

### Wave 4: Assurance, Lab, And Disclosure Expansion

Scope:

- preserve current structural and governance gates
- add functional, behavioral, recovery, and evaluator proof planes
- promote the lab as a top-level domain
- introduce RunCard and HarnessCard disclosure families

Durable outputs:

- `framework/constitution/contracts/assurance/**`
- `framework/constitution/contracts/disclosure/**`
- `framework/assurance/{functional,governance,recovery,evaluators}/**`
- `framework/lab/**`
- `framework/observability/**`
- retained evidence under `state/evidence/lab/**` and run disclosure families

Exit gate:

- consequential runs can emit RunCards
- support and benchmark claims can emit HarnessCards
- behavioral claims require explicit lab or replay evidence
- structural conformance is no longer the only blocking proof plane

### Wave 5: Agency Simplification And Adapter Hardening

Scope:

- simplify kernel agency surfaces around one accountable orchestrator
- retain additional roles only where separation-of-duties value is real
- publish adapter contracts for host and model families
- remove persona-heavy kernel assumptions that no longer carry boundary value

Durable outputs:

- aligned `framework/agency/**`
- model and host adapter contracts under runtime and constitutional surfaces
- explicit support-target declarations and adapter conformance criteria

Exit gate:

- kernel agency responsibilities are narrow, explicit, and runtime-backed
- adapter families are non-authoritative and replaceable
- support claims are bounded and evidence-backed

### Wave 6: Retirement, Cutover, And Closeout

Scope:

- remove mission-only execution assumptions once run-first execution is proven
- remove host-shaped approval logic that still acts as hidden authority
- retire obsolete compensating scaffolds that now have superior replacements
- update proposal, decision, continuity, and evidence records for closeout

Durable outputs:

- retired or deleted legacy shims
- updated durable docs, schemas, validators, and read models
- promotion evidence under `state/evidence/**`
- final decisions and migration records under `instance/cognition/**`

Exit gate:

- no live consequential execution path depends on the deprecated model
- no durable target depends on this proposal path
- retirement evidence exists for removed scaffolds
- the proposal can move to implemented and then archived status

## Cross-Cutting Workstreams

### Docs And Architecture

- unify `/.octon/README.md`, `/.octon/instance/bootstrap/START.md`,
  `/.octon/instance/bootstrap/OBJECTIVE.md`, the umbrella architecture spec,
  and new constitutional docs so they describe one control model
- update ingress projections so they point to the kernel rather than duplicating
  governance text
- keep proposal-local planning subordinate to promoted authority

### Runtime And State

- add run-control roots and retained run evidence roots
- bridge mission continuity to the run model
- add stage-attempt, checkpoint, rollback, contamination, and replay artifacts
- maintain fail-closed behavior while any coexistence window is active

### Governance And Policy

- centralize approvals, exception leases, revocations, support targets, and
  disclosure obligations
- reduce workflow-local approval logic to projections of authority artifacts
- preserve repo-owned governance rather than shifting policy into model prompts

### Assurance, Lab, And Disclosure

- keep current structural and governance checks as blocking gates
- add new proof planes without diluting existing ones
- define RunCard and HarnessCard schemas, generation logic, and gating rules
- keep replay and measurement evidence interpretable rather than purely
  voluminous

## Verification Gates

### Static Gates

- the constitutional kernel exists and is referenced by bootstrap and
  architecture docs
- workspace, mission, and run contracts resolve to one coherent contract
  family
- authority artifacts, route outcomes, and support-target declarations are
  schema-backed
- runtime state families resolve to the declared control and evidence roots

### Runtime Gates

- consequential runs can bind a run contract and emit decision, grant, and
  receipt artifacts
- checkpoints, retries, and resumption work from durable run state
- intervention events become retained evidence rather than hidden operator
  behavior
- RunCard generation works for consequential runs before old disclosure gaps
  are retired

### Assurance Gates

- structural and governance suites continue to pass
- new functional, behavioral, recovery, and evaluator suites exist for the
  promoted surfaces they govern
- lab experiments can emit retained evidence and drive new guardrails
- support claims are blocked when support-target evidence is missing

## Rollback Posture

- each wave must be promotable and revertible independently until the final
  retirement wave
- rollback restores the last fully coherent model rather than leaving partial
  constitutional drift on disk
- generated effective and cognition outputs must be regenerated on rollback if
  the reverted wave changed compiled views
- no rollback may preserve a model that silently bypasses objective binding,
  authority routing, or retained evidence guarantees

## Exit Condition

This proposal is complete only when one durable, machine-checked final state
exists where:

- the constitutional kernel is the supreme repo-local control regime;
- every consequential execution binds a run contract;
- the authority engine mediates all consequential side effects;
- runtime uses run roots, checkpoints, replay, and disclosure as normal
  operating behavior;
- mission remains continuity authority rather than the atomic execution unit;
- verification spans structural, functional, behavioral, governance, recovery,
  and evaluator proof planes;
- RunCards and HarnessCards are normal disclosure artifacts;
- host glue and model adapters no longer carry hidden authority;
- obsolete compensating scaffolds are retired or queued behind explicit
  deletion gates.
