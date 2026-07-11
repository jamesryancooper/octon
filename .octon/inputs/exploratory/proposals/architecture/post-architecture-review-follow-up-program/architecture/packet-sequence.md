# Packet Sequence

Execution mode: `gated-parallel` — children inside a phase may run in
parallel; a child with declared dependencies may not begin until each
dependency passes its `verification` gate. Phases are operator pacing groups;
dependencies are the hard gates.

## Phase 0 (start immediately, parallel)

1. `retirement-register-compatibility-refresh` (F-04) — seed reference child;
   lowest-risk, already-overdue governance maintenance.
2. `runtime-spec-directory-index` (F-05) — independent navigability work.
3. `retained-evidence-operability-contract` (F-03, F-06) — the contract other
   evidence work builds on. **Pre-acceptance evidence gate:** targeted
   Prompt 5 (Domain Architecture Audit of the evidence-retention domain, not
   yet run) must exist as retained evidence, be cited, and carry a recorded
   disposition before this child is accepted; creation may proceed before the
   gate. Blocking findings stop the child lifecycle at the gate. See the
   registry entry's `pre_acceptance_evidence_gate` (including its
   `result_handling` block) for the full rule.

## Phase 1 (after phase-0 verification of declared dependencies)

4. `continuity-coherence-validator` (F-07) — no hard dependency; phase-1 for
   pacing so assurance-plane changes don't land simultaneously with phase-0
   evidence-contract work.
5. `evidence-classification-v2-migration` (F-09) — **hard dependency:**
   `retained-evidence-operability-contract` must pass verification first, so
   the migration follows the retention/lifecycle rules that contract defines.
   Through that dependency it inherits the targeted Prompt 5 gate evidence as
   required dependency input, cited before its own implementation planning.

## Phase 2 (after phase-1 starts clearing)

6. `historical-runcard-support-audit` (F-08) — no hard dependency; phase-2
   pacing because its remediation criteria are cheaper to define once
   evidence-operability decisions (phase 0/1) are settled.
7. `governance-quorum-revisit-trigger` (F-10) — conditional; created only if
   durable action is justified, else recorded as no-action at closeout.

## Gate Rules

- Dependency gate is `verification` for every declared dependency: the
  dependency child must have passed its own verification loop, with
  child-owned receipts, before the dependent child begins implementation.
- Parent evidence never satisfies a child gate. Each child carries its own
  creation, review, implementation, and verification receipts at its
  canonical sibling path.
- A blocked or rejected child does not block siblings without a declared
  dependency on it; the parent records the disposition and re-sequences.
