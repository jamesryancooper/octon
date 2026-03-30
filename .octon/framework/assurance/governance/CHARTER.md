# Assurance Governance Charter Shim

> Shim status: This file is a subordinate assurance-governance shim retained
> for compatibility with assurance tooling and weighting policy. Repo-local
> constitutional authority lives under `/.octon/framework/constitution/**`.
> This file may preserve assurance-local priority framing, but it may not act
> as a peer constitution or override the kernel.

**Purpose**
Preserve the assurance-local priority order and trade-off framing consumed by
assurance governance, weights, and scoring tooling.

**Scope**
This shim applies only as an assurance-local overlay beneath the constitutional
kernel. It does not create repo-local constitutional authority outside
`framework/constitution/**`.

---

## 1) Primary focus and priority chain

Octon optimizes for three umbrella outcomes, in this order:

1. **Assurance**
2. **Productivity**
3. **Integration**

This order is the default tiebreaker when assurance goals conflict.

---

## 2) What "good" means for Octon

### A. Assurance (highest priority)

**Definition:** Outcomes are correct, safe, policy-compliant, and explainable.

**Assurance umbrellas these primary attributes:**

* **Dependability**
* **Security**
* **Safety**
* **Reliability**
* **Availability**
* **Robustness**
* **Recoverability**
* **Auditability**
* **Observability**
* **Functional suitability**

**Assurance principle:** *No silent authority.* Every action is attributable,
bounded, and explainable.

---

### B. Productivity

**Definition:** Delivery throughput is maximized with low friction and bounded
autonomy.

**Productivity umbrellas these primary attributes:**

* **Autonomy**
* **Performance**
* **Scalability**
* **Complexity Calibration**
* **Evolvability**
* **Maintainability**
* **Completeness**
* **Operability**
* **Testability**
* **Deployability**
* **Usability**
* **Accessibility**
* **Configurability**
* **Sustainability**

**Productivity principle:** *Optimize the loop inside assurance boundaries.*

Autonomous execution is valid only when each run provides:

* a bound `intent_ref` to an approved intent contract version,
* machine-resolved delegation boundary routing (`allow`, `escalate`, `block`),
* workflow capability classification (`agent-ready`, `agent-augmented`, `human-only`).

---

### C. Integration

**Definition:** Octon works across repos, environments, and tools through
stable contracts.

**Integration umbrellas these primary attributes:**

* **Portability**
* **Interoperability**
* **Compatibility**

**Integration principle:** *Integrate through explicit versioned interfaces.*

---

## 3) Autonomy policy (bounded autonomy)

Autonomy is a first-class **Productivity** attribute and is valid only when
bounded by Assurance controls:

* deny-by-default policy boundaries
* approval gates for material side effects
* full audit trail of intent, plan, actions, and outputs
* observability sufficient to explain what happened
* recoverability for state-changing actions

**Autonomy levels (suggested):**

* **A0 Assistive:** suggests only
* **A1 Drafting:** produces artifacts, no side effects
* **A2 Executing (reversible):** runs actions with rollback
* **A3 Executing (bounded side effects):** changes repo state under policy + gates
* **A4 Semi-autonomous:** chains workflows with approvals at checkpoints
* **A5 Autonomous:** end-to-end within strict policies + continuous audit

Default stance: increase autonomy with maturity, never at the expense of
Assurance.

---

## 4) Trade-off rules (how Octon decides)

When assurance goals conflict, apply these rules:

1. **Assurance is non-negotiable.**
   If an optimization reduces explainability, reversibility, or policy compliance, it is rejected or gated.

2. **Productivity is optimized inside assurance constraints.**
   Favor automation, templates, and autonomy that remain bounded, auditable, and reversible.

3. **Integration requires explicit contracts, security controls, and tests.**
   Every integration must be versioned, least-privileged, and contract-tested.

4. **Attribute-level scoring remains the source of truth.**
   Umbrella scores are rollups for ordering and reporting, not substitutes for attribute evidence.

5. **Umbrella rollups must not hide critical assurance weaknesses.**
   Critical assurance attributes can constrain rollup interpretation and gate outcomes.

If top-priority attributes conflict, Octon requires:

* an explicit boundary decision (ADR),
* mitigations (break-glass, sampling, progressive disclosure),
* and evidence (tests, gates, docs).

---

## 5) Governance and enforcement

**Octon is led by active assurance policy weights and measurable scores:**

* **Weights are policy:** versioned, reviewed, ADR-backed
* **Scores are measurement:** updated frequently with evidence pointers
* Gates enforce that weight changes cannot be nudged silently
* Development planning must reference effective weights for the current context
* Umbrella ordering is deterministic: `Assurance > Productivity > Integration`

---

## 6) What we will not do

* We will not maximize performance at the cost of **untracked authority**.
* We will not accept autonomy that cannot be **explained, bounded, and undone**.
* We will not add integration-breaking platform assumptions without an explicit decision.
* We will not accumulate “profile sprawl” that makes the model unmaintainable.
* We will not create integrations that broaden attack surface without controls,
  tests, and version discipline.

---

## 7) Decision checklist (use in PRs/ADRs)

When proposing changes to Octon or adopting it in a repo:

* Which umbrella outcome does this improve (**Assurance**, **Productivity**, **Integration**)?
* Which outcome does it worsen (if any), and why is that acceptable?
* What is the impact on **Assurance** (auditability, safety, security, recoverability, correctness)?
* What evidence/gates prove the claim?
* If this introduces a new behavior, how is it versioned, observed, and rolled back?
* Does this increase autonomy? If yes, what autonomy level and what guardrails?

---

**Charter status:** Active
**Owner:** Octon governance
**Review cadence:** Quarterly (or per major release)
