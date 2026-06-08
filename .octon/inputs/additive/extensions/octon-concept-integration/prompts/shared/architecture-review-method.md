# Balanced Architecture Review Method

This shared method is the pack-owned review contract for architecture-focused
concept integration. It is derived from advisory source material, but it is not
a raw source library and does not make any intake or proposal packet
authoritative.

## Purpose

Use first-principles reasoning as the decomposition engine, then restore
current-system context before recommending architecture change.

The review must identify:

- what the system is fundamentally for;
- what the current system already knows or protects;
- which constraints are still real, stale, assumed, or negotiable;
- which complexity is essential, accidental, compensating, operational, or
  migration-related;
- which bottlenecks actually limit reliability, throughput, change speed,
  operator confidence, or reversibility;
- how each option can fail and how failure is detected, recovered, or rolled
  back;
- and whether the final change path fits Octon's authority, evidence,
  publication, generated-output, proposal, and host-projection boundaries.

## Required Review Sequence

1. Frame the review charter: decision needed, scope, time horizon, primary
   stakeholders, risk tolerance, non-negotiables, and out-of-scope items.
2. Identify the system job and essential outcomes before naming an
   implementation shape.
3. Build current reality maps: logical architecture, runtime behavior,
   data/state ownership, operational workflow, validators, publication paths,
   and human recovery paths.
4. Run current architecture steelmanning and Chesterton's Fence analysis before
   removing, replacing, or simplifying existing pieces.
5. Maintain a constraint ledger that separates hard, business, regulatory,
   operational, economic, organizational, historical, assumed, and expired
   constraints.
6. Maintain a complexity ledger that classifies essential, accidental,
   compensating, cognitive, operational, integration, and migration complexity.
7. Locate bottlenecks and leverage points before optimizing local structure.
8. Analyze failure modes, inversion cases, second-order effects,
   detectability, recoverability, mitigation, and owner.
9. Create a clean-sheet reference design only after current reality is mapped.
   Treat it as a comparison tool, not automatic destiny.
10. Compare keep, improve, refactor, wrap or isolate, partially replace, full
    redesign, and staged or hybrid options.
11. Score options against strategic fit, requirement fit, quality attributes,
    maintainability, reliability, security/compliance, cost of change,
    migration risk, reversibility, operational burden, adaptability, knowledge
    risk, and time-to-value.
12. Produce the smallest defensible recommendation with hardening criteria,
    validation burden, evidence requirements, rollback posture, and revisit
    triggers.

## Octon-Fit Gates

Architecture recommendations must pass these gates before packetization or
implementation:

- Authority gate: durable meaning belongs only in the correct authored
  framework, instance, extension-source, or proposal target surface.
- Input gate: raw source artifacts, incoming intake, proposal-local analysis,
  chat, model memory, generated views, and host projections are not authority.
- Evidence gate: claims that affect implementation readiness, publication,
  validation, conformance, or drift require retained receipts.
- Publication gate: generated and effective projections are refreshed only by
  governed publication scripts.
- Host-projection gate: host projections are never edited by hand.
- Validator gate: every recommended durable change has a matching validator,
  test, lint, scenario fixture, or explicit evidence plan.
- Reversibility gate: the implementation plan names rollback or containment
  before approving irreversible churn.
- Kernel gate: if the change requires constitutional, precedence, authority, or
  fail-closed changes, route to constitutional challenge instead of forcing an
  ordinary architecture packet.

## Required Deliverables

Architecture-review outputs should include:

- review charter;
- system job and first-principles decomposition;
- current reality maps;
- current architecture steelman;
- Chesterton's Fence inventory;
- constraint ledger;
- complexity ledger;
- bottleneck and leverage analysis;
- failure-mode and second-order-effects analysis;
- clean-sheet reference architecture;
- option set and decision matrix;
- quality scoring or quality-attribute assessment;
- hardening and approval plan;
- validation, evidence, publication, generated-output, and rollback plan;
- Octon-specific authority and proposal-fit notes.

The final recommendation must make clear whether the current architecture
should be preserved, improved, refactored, wrapped, partially replaced,
redesigned, deferred, or escalated.
