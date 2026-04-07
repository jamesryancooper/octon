# Target Architecture

This document extracts the standard architecture target from the companion
packet in `proposal/00_octon_completion_proposal_packet.md`. The packet remains
the richer design handoff. This file is the standard-conformant target-state
summary for the active proposal package.

## Architectural Thesis

Octon should finish as an evidence-first, bounded, fully unified execution
constitution. The target state is not a greenfield replacement. It preserves
the constitutional kernel, run-shaped control/evidence model, adapter
boundaries, support-target governance, disclosure patterns, lab domain, and
observability domain that already exist, and it hardens the remaining weak
seams until the completion claim is truthful.

## Claim Boundary

The target architecture allows the phrase `fully unified execution
constitution` only inside an explicit bounded support universe. The claim is
valid only when:

1. claim truth is computed from independent evidence rather than closure-local
   prose;
2. workspace, mission, run, stage, and attempt semantics are coherent and
   machine-enforced;
3. canonical authority artifacts govern all material execution paths;
4. retained runtime state is reconstructible from event-ledger truth plus
   checkpoints and evidence pointers;
5. proof-plane coverage is enforced for every admitted support tuple;
6. disclosure artifacts are generated from durable evidence;
7. retirement and build-to-delete obligations are current, owned, and
   measurable.

## Baseline To Preserve

The target state preserves these already-substantive assets:

- `.octon/framework/constitution/**` as the singular repo-local constitutional
  kernel;
- `.octon/state/control/execution/runs/**`,
  `.octon/state/evidence/runs/**`, and
  `.octon/state/evidence/disclosure/**` as run-shaped control and retained
  evidence roots;
- `.octon/framework/engine/runtime/adapters/host/**` and
  `.octon/framework/engine/runtime/adapters/model/**` as non-authoritative
  adapter boundaries;
- `.octon/framework/lab/**` and `.octon/framework/observability/**` as
  first-class domains;
- `.octon/instance/governance/support-targets.yml` and related admission and
  dossier surfaces as the bounded support-target regime;
- orchestrator-centered execution under `.octon/framework/agency/**`.

## Target-State Domain Changes

## 1. Constitutional Claim Truth

Target paths:

- `.octon/framework/constitution/claim-truth-conditions.yml`
- `.octon/instance/governance/closure/**`
- `.octon/generated/effective/closure/**`

End state:

- closure and claim outputs become generated summaries only;
- claim evaluation derives from admissions, dossiers, proof bundles, replay
  evidence, adapter conformance, and retirement state;
- any hand-authored closure artifact that can outstate machine truth is
  removed, generated, or demoted out of the claim path.

## 2. Objective Stack Coherence

Target paths:

- `.octon/instance/charter/**`
- `.octon/instance/orchestration/missions/**`
- `.octon/framework/constitution/contracts/objective/**`
- `.octon/state/control/execution/runs/**`

End state:

- the objective stack is explicit:
  `workspace charter -> mission charter -> run contract -> stage contract -> execution attempt`;
- mission-required runs cannot carry null mission linkage inside the live claim
  envelope;
- stage and attempt are distinct runtime objects, not overloaded names.

## 3. Authority Normalization

Target paths:

- `.octon/framework/constitution/contracts/authority/**`
- `.octon/framework/engine/runtime/**`
- `.octon/state/control/execution/approvals/**`
- `.octon/state/control/execution/exceptions/**`
- `.octon/state/control/execution/revocations/**`

End state:

- every consequential execution path emits route receipts, decision artifacts,
  and bound grant or lease context;
- exception leases are a live authority/control family with expiry, scope,
  quota, owner, and revocation semantics;
- host adapters remain projection-only and never mint authority.

## 4. Runtime Truth And Recovery

Target paths:

- `.octon/state/control/execution/runs/**`
- `.octon/state/continuity/**`
- `.octon/state/evidence/runs/**`
- `.octon/framework/constitution/contracts/runtime/**`

End state:

- runtime truth is reconstructible from an append-oriented event ledger and
  rich checkpoints;
- continuity artifacts describe current stage, blockers, approvals, and next
  recovery-safe steps without relying on chat continuity;
- compensation, contamination, retry, and rollback semantics are first-class
  runtime data.

## 5. Proof, Lab, And Evaluation Parity

Target paths:

- `.octon/framework/assurance/**`
- `.octon/framework/lab/**`
- `.octon/state/evidence/lab/**`

End state:

- structural, functional, behavioral, governance, recovery, and
  maintainability proof planes are real and blocking where required;
- admitted support tuples cite the required proof and lab bundles;
- consequential claim-included tuples have at least one independent evaluator
  path plus deterministic validation.

## 6. Observability And Disclosure

Target paths:

- `.octon/framework/observability/**`
- `.octon/framework/constitution/contracts/disclosure/**`
- `.octon/state/evidence/disclosure/**`

End state:

- traces, measurements, interventions, failures, and recovery outcomes are
  structured enough to support trustworthy replay and disclosure;
- RunCards and HarnessCards are generated from the evidence graph;
- closure status becomes a projection of the same evidence graph.

## 7. Support Targets, Adapters, And Admissions

Target paths:

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`
- `.octon/instance/capabilities/runtime/packs/admissions/**`

End state:

- support tuples are explicitly classified as unsupported, experimental,
  stage_only, supported, deprecated, or revoked;
- `stage_only` tuples remain outside the live completion claim until promoted;
- promotion, restriction, de-admission, and recertification rules are explicit
  and evidence-backed.

## 8. Retirement And Build-To-Delete

Target paths:

- `.octon/instance/governance/retirement/**`
- `.octon/state/evidence/governance/**`
- `.octon/framework/constitution/obligations/fail-closed.yml`

End state:

- every compensator, shim, staged exclusion, or persona-heavy remnant has an
  owner, review cadence, trigger, and deletion evidence;
- overdue or ownerless retirement items become claim blockers;
- build-to-delete becomes part of completion truth, not a post-claim cleanup
  promise.

## Notes

- Detailed reasoning, path-specific judgments, and migration sequencing remain
  in `proposal/00_octon_completion_proposal_packet.md`.
- Repo-local collateral such as `.github/workflows/**` may still be required
  during implementation, but this package keeps its manifest scope
  `octon-internal` to stay standards-conformant.
