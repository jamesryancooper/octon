# Architecture Readiness Scorecard

Project:
Review scope:
Reviewer:
Date:

## Scoring rubric

- 0 = absent
- 1 = implicit / informal / assumed
- 2 = partial / inconsistent / bypassable
- 3 = explicit / enforced / observable / testable

## Severity rubric

- Critical = blocks implementation readiness
- High = major risk; should be fixed before broad implementation
- Medium = important but can be sequenced
- Low = improvement opportunity

## Hard gate rule

The design automatically fails implementation-readiness if any of the following dimensions score below 2:

- Objective integrity
- Authority and delegation
- Policy and admission control
- State/evidence/auditability
- Recovery/reversibility/continuity
- Control-plane vs execution-plane separation

---

## 1. Objective integrity

Weight: 10
Score: __ / 3

Checks:

- Objectives are first-class, explicit, and discoverable
- Objectives include scope, constraints, and success criteria
- Objectives are revision-controlled
- Actions remain traceable to objectives
- Closed/invalid objectives cannot admit new work

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 2. Authority and delegation

Weight: 10
Score: __ / 3

Checks:

- Actor identity is explicit
- Authority is bounded by action/resource/time
- Delegation is governed
- Authority cannot self-expand
- High-risk actions revalidate authority at use time

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 3. Policy and admission control

Weight: 10
Score: __ / 3

Checks:

- All side effects pass through admission control
- Policy outcomes are allow / block / escalate
- Policy logic is separate from execution logic
- Policy versions and decisions are recorded
- Failure of policy evaluation defaults safely

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 4. Planning and bounded execution

Weight: 8
Score: __ / 3

Checks:

- Work is planned before execution
- Assumptions and uncertainties are explicit
- Preconditions and postconditions exist
- Work is decomposed into bounded steps
- Replanning is governed

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 5. Coordination and concurrency control

Weight: 7
Score: __ / 3

Checks:

- Shared governed resources are coordinated
- Locks / leases / deduplication exist where needed
- Long-running work emits heartbeats
- Cancellation is explicit
- Duplicate/conflicting execution is controlled

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 6. Runtime and execution integrity

Weight: 8
Score: __ / 3

Checks:

- Executors use declared inputs and pinned context
- Retries are bounded and visible
- Side effects are idempotent or duplicate-safe
- Irreversible actions receive stronger controls
- Workers do not silently make governance decisions

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 7. State model, evidence, and auditability

Weight: 10
Score: __ / 3

Checks:

- State transitions are modeled explicitly
- Evidence captures who/what/why/when/authority
- Traceability exists end to end
- Audit records are tamper-evident or durable
- A run can be reconstructed after the fact

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 8. Observability and assurance

Weight: 8
Score: __ / 3

Checks:

- Logs/metrics/traces are structured around runs/objectives
- Assurance checks are independent enough to challenge producers
- Governance bypass and orphaned execution are detectable
- Assurance can block or gate progress
- Operational signals support diagnosis under failure

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 9. Recovery, reversibility, and continuity

Weight: 10
Score: __ / 3

Checks:

- Rollback or compensation is defined
- Partial failures have controlled handling
- Orphaned/stalled work is recoverable
- Continuity state supports safe resume
- Recovery procedures are testable

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 10. Domain and boundary integrity

Weight: 7
Score: __ / 3

Checks:

- Orchestration, execution, reasoning, assurance, and continuity are distinct
- Interfaces are explicit
- Dependencies are directional and minimal
- Shared state has ownership
- No domain silently rewrites another domain's rules

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 11. AI-agent safety architecture

Weight: 7
Score: __ / 3

Checks:

- Capability is not treated as authority
- Sensitive actions are mediated through governance
- External content cannot override policy
- Tool exposure is scoped to objective context
- Prompt/model/config changes are governed
- Uncertainty results in block or escalate

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 12. Classical software architecture quality

Weight: 5
Score: __ / 3

Checks:

- Modularity is strong
- Cohesion is high
- Coupling is low
- Concerns are separated cleanly
- Extensibility and maintainability are preserved
- Security and testability are architectural

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## 13. Control-plane vs execution-plane separation

Weight: 10
Score: __ / 3

Checks:

- The control plane owns objectives, authority, policy, scheduling, run state, evidence indexing, and recovery orchestration
- The execution plane performs bounded admitted work
- The execution plane cannot self-authorize
- Policy is not duplicated in workers
- The control plane can stop, revoke, or quarantine execution

Evidence:
Gaps:
Severity:
Required follow-up artifact(s):

---

## Weighted total

Enter each weighted score as: score × weight

- Objective integrity: __
- Authority and delegation: __
- Policy and admission control: __
- Planning and bounded execution: __
- Coordination and concurrency control: __
- Runtime and execution integrity: __
- State model, evidence, and auditability: __
- Observability and assurance: __
- Recovery, reversibility, and continuity: __
- Domain and boundary integrity: __
- AI-agent safety architecture: __
- Classical software architecture quality: __
- Control-plane vs execution-plane separation: __

Total weighted score: __ / 300

## Readiness thresholds

- 260-300 = strong architecture; implementation-ready with ordinary follow-up
- 220-259 = conditionally ready; fix listed gaps before broad implementation
- 180-219 = materially incomplete; targeted redesign required
- below 180 = not implementation-ready

Hard gate failure overrides total score.

---

## Critical gap register

For every Critical gap, record:

- Gap title:
- Affected dimension:
- Why it blocks readiness:
- Exact artifact(s) to create/update:
- Owner:
- Target sequence:

---

## Promotion decision

Select one:

- Approve for implementation
- Approve with conditions
- Hold pending remediation
- Reject and redesign

Decision rationale:

---

## Required next actions

1.
2.
3.
