# Acceptance Criteria

These criteria define when the durable target architecture described by this
proposal has landed. The proposal package itself cannot satisfy them; they
must be evidenced in promoted durable surfaces outside the proposal path.

## Global Gate

Octon may claim bounded completion only when all criteria below are satisfied
at the same time and two consecutive validation passes, or an equally strong
recertification rule, produce no unresolved claim-blocking regressions.

## Criteria

### AC-1 Claim truth is evidence-derived

- Required durable surfaces:
  `.octon/framework/constitution/claim-truth-conditions.yml`,
  `.octon/instance/governance/closure/**`,
  `.octon/generated/effective/closure/**`
- Pass condition: closure and claim status are generated from independent
  evidence rather than authored directly.

### AC-2 Objective semantics are coherent

- Required durable surfaces:
  `.octon/instance/charter/**`,
  `.octon/instance/orchestration/missions/**`,
  `.octon/framework/constitution/contracts/objective/**`,
  `.octon/state/control/execution/runs/**`
- Pass condition: workspace, mission, run, stage, and attempt semantics are
  machine-enforced and no claim-included mission-required run carries null
  mission linkage.

### AC-3 Canonical authority artifacts govern material execution

- Required durable surfaces:
  `.octon/framework/constitution/contracts/authority/**`,
  `.octon/framework/engine/runtime/**`,
  `.octon/state/control/execution/approvals/**`,
  `.octon/state/control/execution/exceptions/**`,
  `.octon/state/control/execution/revocations/**`
- Pass condition: every material execution path consumes or emits canonical
  route, decision, grant, lease, or revocation artifacts.

### AC-4 Exception leases are normalized live state

- Required durable surfaces:
  `.octon/state/control/execution/exceptions/leases/**`
- Pass condition: leases have scoped ownership, expiry, revocation behavior,
  and runtime enforcement rather than existing only as compatibility-shaped
  artifacts.

### AC-5 Runtime state is reconstructible

- Required durable surfaces:
  `.octon/state/control/execution/runs/**`,
  `.octon/state/evidence/runs/**`,
  `.octon/framework/constitution/contracts/runtime/**`
- Pass condition: run state can be reconstructed from event-ledger truth plus
  checkpoints, manifests, and evidence pointers.

### AC-6 Checkpoint, continuity, and recovery data are rich enough to gate resume

- Required durable surfaces:
  `.octon/state/control/execution/runs/**`,
  `.octon/state/continuity/**`,
  `.octon/state/evidence/runs/**`
- Pass condition: resume behavior is driven by stage-aware checkpoints,
  continuity state, rollback posture, and recovery evidence rather than chat
  continuity or implicit convention.

### AC-7 Support-target admissions are truthful

- Required durable surfaces:
  `.octon/instance/governance/support-targets.yml`,
  `.octon/instance/governance/support-target-admissions/**`,
  `.octon/instance/governance/support-dossiers/**`
- Pass condition: no claim-included tuple is `stage_only`, `experimental`, or
  otherwise excluded from the admitted support envelope.

### AC-8 Proof-plane parity is enforced

- Required durable surfaces:
  `.octon/framework/assurance/**`,
  `.octon/framework/lab/**`,
  `.octon/state/evidence/lab/**`
- Pass condition: each admitted tuple satisfies its required proof planes with
  blocking enforcement or an equivalently strong gate.

### AC-9 Disclosure is generated from evidence

- Required durable surfaces:
  `.octon/framework/constitution/contracts/disclosure/**`,
  `.octon/state/evidence/disclosure/**`
- Pass condition: RunCards, HarnessCards, and closure summaries are generated
  from canonical evidence graphs.

### AC-10 Replay and retention obligations are met

- Required durable surfaces:
  `.octon/framework/constitution/contracts/retention/**`,
  `.octon/state/evidence/runs/**`,
  `.octon/state/evidence/disclosure/**`
- Pass condition: retained evidence is sufficient for replay, audit, and
  externalized evidence obligations required by admitted tuples.

### AC-11 Retirement and build-to-delete are live governance

- Required durable surfaces:
  `.octon/instance/governance/retirement/**`,
  `.octon/state/evidence/governance/**`
- Pass condition: transitional machinery is owner-backed, time-bounded, and
  deletion-evidenced; overdue retirement items block completion claims.

### AC-12 Persona-heavy or compatibility-only kernel residue is out of the live path

- Required durable surfaces:
  `.octon/framework/agency/**`,
  `.octon/framework/constitution/**`,
  `.octon/instance/ingress/AGENTS.md`
- Pass condition: any retained persona or compatibility surface is explicitly
  non-authoritative, bounded, and removable without affecting the kernel path.

## Evidence Expectations

- Passing these criteria requires durable evidence under `state/evidence/**`.
- Proposal-local prose is insufficient proof.
- Any repo-local collateral required to satisfy these criteria, such as
  workflow changes outside `.octon/**`, must be carried by linked work rather
  than treated as implicit completion.
