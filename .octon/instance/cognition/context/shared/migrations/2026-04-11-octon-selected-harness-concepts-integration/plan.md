# Octon Selected Harness Concepts Integration Plan

- `run_id`: `2026-04-11-octon-selected-harness-concepts-integration`
- `executed_on`: `2026-04-11`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `cutover_mode`: `additive-refinement`
- `selection_rationale`: Repo ingress defaults `pre-1.0` work to `atomic`,
  and the selected harness concepts packet refines existing canonical
  authority, control, and evidence surfaces without justifying a transitional
  dual-truth model.
- `prompt_ref`: `/.octon/framework/scaffolding/practices/prompts/2026-04-11-octon-selected-harness-concepts-integration-packet-execution.prompt.md`

## Implementation Plan

1. Add canonical assurance and adapter contracts for review findings,
   dispositions, distillation, hardening recommendations, and tool-output
   envelopes.
2. Extend mission autonomy with proposal-first classification defaults and
   materialize mission-local classification state under
   `state/control/execution/missions/**`.
3. Add repo-owned workflow contracts for failure-distillation and
   evidence-distillation plus repo-owned tool-output budget overlays.
4. Materialize exemplar run-local review findings and review dispositions as
   retained evidence and live run-control state.
5. Add retained evidence bundles and derived summaries for failure
   distillation, evidence distillation, and tool-output-envelope validation.
6. Wire the new surfaces into alignment validators, mission control helpers,
   and harness structure checks.
7. Run two consecutive validation passes and retain a migration evidence
   bundle with commands, inventory, evidence, and validation results.

## Impact Map

- contracts:
  - `/.octon/framework/constitution/contracts/assurance/**`
  - `/.octon/framework/constitution/contracts/adapters/**`
  - `/.octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json`
  - `/.octon/framework/engine/runtime/spec/mission-classification-v1.schema.json`
- repo policy and workflow overlays:
  - `/.octon/instance/governance/policies/**`
  - `/.octon/instance/governance/contracts/**`
  - `/.octon/instance/agency/runtime/**`
- live control state:
  - `/.octon/state/control/execution/missions/**`
  - `/.octon/state/control/execution/runs/**/authority/**`
- retained evidence:
  - `/.octon/state/evidence/runs/**/assurance/**`
  - `/.octon/state/evidence/validation/**`
  - `/.octon/state/evidence/migration/**`
- generated:
  - `/.octon/generated/cognition/distillation/**`

## Compliance Receipt

- single control plane preserved: yes
- single retained proof plane preserved: yes
- proposal-local truth promoted into authority: no
- generated summaries authoritative: no
- approval-boundary widening introduced: no

## Exceptions/Escalations

- Packet target paths are treated as candidate landing zones only. Where the
  live repo already uses newer canonical families, implementation follows the
  live family and records the deviation in retained evidence instead of
  reviving stale proposal paths.
