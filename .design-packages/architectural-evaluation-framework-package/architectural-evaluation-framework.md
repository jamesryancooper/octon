# Architectural Evaluation Framework

Below is a **deep architectural evaluation framework** for a governed autonomous engineering environment.

Treat it as a **design-review standard**, **implementation-readiness audit**, and **promotion gate**. The goal is not merely to check whether components exist, but whether the architecture preserves the operating model under stress, scale, ambiguity, and failure.

## How to use it

Score each invariant from **0 to 3**:

* **0 — absent**: not designed or not enforced
* **1 — implicit**: assumed or informal
* **2 — partial**: implemented, but inconsistent or bypassable
* **3 — strong**: explicit, enforced, observable, and testable

Anything below **2** in objective binding, authority, policy, evidence, recovery, or plane separation is a material architectural gap.

---

## I. Architectural invariants

These are conditions that should remain true regardless of implementation details.

### A. Objective integrity

1. Every meaningful action is linked to an explicit objective identifier.
2. Every objective has scope, constraints, success criteria, and expiration or closure conditions.
3. Objectives are versioned; they are not silently mutated in place.
4. Objective changes require explicit revision, not ad hoc reinterpretation.
5. Objective-to-plan-to-action linkage is preserved end to end.
6. Expired or closed objectives cannot admit new work.

### B. Identity, authority, and delegation

1. Every human, agent, executor, and tool invocation has a distinct identity.
2. Authority is granted explicitly, not inferred from capability.
3. Authority is scoped by operation, resource, and duration.
4. Delegation is explicit and non-transitive by default.
5. High-impact actions re-check authority at the point of side effect.
6. No component can enlarge its own authority.

### C. Policy and admission control

1. All side-effecting actions pass through a single logical policy decision point.
2. Policy outcomes resolve only to allow, block, or escalate.
3. Policy evaluation is deterministic for the same inputs.
4. Policy inputs, version, and decision outcome are recorded.
5. Policy engine failure defaults to block or safe degrade, never silent allow.
6. Exception paths require scope, reason, approver, and expiry.

### D. Planning and bounded execution

1. Nontrivial work requires an explicit plan before execution.
2. Plans state assumptions, dependencies, and unresolved uncertainties.
3. Preconditions are validated before each major phase.
4. Work is decomposed into bounded steps with clear exit criteria.
5. Plan changes are explicit and linked to new evidence or approval.
6. Ambiguity that affects safety or authority causes block or escalate, not guesswork.

### E. Coordination and concurrency control

1. Conflicting side effects are protected by locks, leases, or equivalent coordination controls.
2. Locks have ownership, timeout, and recovery semantics.
3. Duplicate admission of the same work is detectable and suppressed.
4. Long-running work maintains heartbeats or progress signals.
5. Cancellation is first-class and propagates predictably.
6. Parallel execution cannot violate the integrity of shared governed resources.

### F. Execution semantics and runtime integrity

1. Executors operate from declared inputs and pinned context.
2. Side effects are idempotent or guarded against duplicate execution.
3. Retries are bounded, visible, and policy-aware.
4. Irreversible operations are explicitly classified and receive stronger controls.
5. Runtime environments are reproducible enough to explain outcome differences.
6. Execution logic does not embed hidden approval or policy logic.

### G. State, evidence, and auditability

1. State transitions are explicit and modeled, not inferred from logs.
2. Evidence records who acted, what changed, why, when, and under what authority.
3. Audit trails are append-only or tamper-evident.
4. There is full traceability from objective to plan to decision to action to artifact.
5. Evidence is queryable by objective, run, actor, and resource.
6. Audit fidelity survives redaction of sensitive values.

### H. Observability and assurance

1. Logs, metrics, and traces are structured around runs and objectives.
2. Assurance checks are independent enough to challenge producers.
3. Governance bypass, policy failure, orphaned runs, and recovery events emit alerts.
4. The system can reconstruct a run without relying on hidden tribal knowledge.
5. Assurance is part of the operating model, not a post-hoc reporting layer.
6. Observability covers both control decisions and runtime behavior.

### I. Recovery, reversibility, and continuity

1. Reversible mutations have defined rollback procedures.
2. Irreversible mutations have compensating-action playbooks.
3. High-impact operations snapshot or checkpoint prior state when feasible.
4. Orphaned, stalled, or partially failed runs are detectable and recoverable.
5. Recovery procedures are exercised, not merely documented.
6. Continuity state preserves enough context to resume governed work safely.

### J. Domain and boundary integrity

1. Control plane and execution plane are architecturally separate.
2. Reasoning, policy, execution, assurance, and continuity have explicit interfaces.
3. Cross-domain dependencies are directional and minimal.
4. Shared mutable state has clear ownership and access constraints.
5. New capabilities integrate through standard contracts rather than bespoke exceptions.
6. No domain can silently rewrite the rules governing another domain.

### K. Security, portability, and operational fitness

1. Secrets are exposed only to the minimum runtime surface that needs them.
2. Configuration is versioned, validated, and promotable across environments.
3. Capacity limits, rate limits, and backpressure are explicit.
4. Queue and delivery semantics match the risk profile of the action.
5. Modules remain independently testable and deployable where practical.
6. Architecture decisions and tradeoffs are documented as durable records.

---

## II. Failure mode analysis

These are the failure modes most likely to break this kind of system.

### 1. Objective drift

Work starts aligned to the objective, but execution gradually optimizes for convenience, local completion, or inferred intent.

**Typical causes**:

* objectives are too vague
* plans are allowed to mutate without revision
* action-to-objective linkage is weak

**Architectural response**:

* immutable objective versions
* explicit replanning
* hard traceability from objective to every material action

### 2. Policy bypass

Actions occur outside the governed decision path.

**Typical causes**:

* direct tool calls from executors
* side channels
* duplicate policy logic scattered across services

**Architectural response**:

* single logical admission path
* privileged operations only through governed contracts
* alerts on any unadmitted side effect

### 3. Authority inflation

An agent or runtime accumulates more power than intended.

**Typical causes**:

* long-lived credentials
* broad delegation
* capability mistaken for permission

**Architectural response**:

* least-privilege authority grants
* time-bounded delegation
* point-of-use revalidation for sensitive actions

### 4. Exception creep

Temporary overrides become the real operating model.

**Typical causes**:

* no expiry on overrides
* no review of exceptions
* escalation used as a shortcut

**Architectural response**:

* expiring exceptions
* exception ledger
* periodic review and hard removal of stale overrides

### 5. Hidden side effects

The system appears safe on paper, but external state changes happen before governance records them.

**Typical causes**:

* tools with implicit writes
* combined read/write interfaces
* optimistic execution before approval

**Architectural response**:

* separate read and write capabilities
* explicit side-effect classification
* commit only after policy admission

### 6. Non-reproducible execution

A run cannot be explained or replayed.

**Typical causes**:

* drifting inputs
* mutable prompts or configs
* unpinned environments

**Architectural response**:

* pinned inputs and runtime versions
* stored plan and policy versions
* evidence-rich re-execution envelopes

### 7. Duplicate or conflicting runs

The same task is executed twice or two tasks mutate the same governed surface incompatibly.

**Typical causes**:

* weak admission deduplication
* missing lease/lock semantics
* retries without idempotency

**Architectural response**:

* dedup keys
* resource locks or leases
* idempotent write design

### 8. Zombie execution

Executors continue after cancellation, policy revocation, or control-plane loss.

**Typical causes**:

* no heartbeat
* no lease expiry
* executor autonomy exceeds design

**Architectural response**:

* expiring leases
* periodic authority renewal
* kill and quarantine semantics

### 9. Audit theater

Large amounts of evidence exist, but they do not answer who did what, why, and under what authority.

**Typical causes**:

* unstructured logs
* evidence without schema
* missing linkage across systems

**Architectural response**:

* structured evidence model
* objective/run identifiers everywhere
* query paths designed before implementation

### 10. Assurance capture

Assurance checks exist but cannot actually stop bad work.

**Typical causes**:

* assurance runs too late
* assurance owned by delivery components
* failures are advisory only

**Architectural response**:

* assurance independence
* blocking gates at admission and promotion
* explicit failure semantics

### 11. Knowledge poisoning or staleness

Learning artifacts degrade future work instead of improving it.

**Typical causes**:

* no provenance
* no expiry or supersession model
* lessons stored as raw narrative only

**Architectural response**:

* provenance on knowledge entries
* versioning and supersession
* distinction between evidence, interpretation, and policy

### 12. Plane collapse

Control-plane concerns bleed into execution-plane code, or execution logic takes over governance.

**Typical causes**:

* convenience shortcuts
* shared databases without contracts
* policy embedded in workers

**Architectural response**:

* clear plane contracts
* no direct policy mutation from executors
* separate ownership and change control

---

## III. Design smells

These are fast indicators that the architecture is drifting.

### Governance smells

* **Objectives exist only in prose**: intent is not machine-enforceable.
* **Policy lives in scattered `if` statements**: governance is fragmented and un-auditable.
* **Allow-by-default behavior**: the architecture trusts absence of evidence.
* **No first-class escalation path**: humans are forced into out-of-band intervention.
* **Exceptions have no expiry**: temporary bypass becomes permanent policy.
* **Approvals without attached evidence**: human oversight becomes ceremonial.

### Execution smells

* **Executors can directly reach privileged tools**: side effects can outrun governance.
* **Workers contain approval logic**: execution plane is silently acting as policy engine.
* **Retries are unbounded**: failure can amplify into damage.
* **Long-running jobs have no heartbeat**: zombie execution is inevitable.
* **Irreversible actions look the same as reversible ones**: risk is not surfaced.

### State and evidence smells

* **Logs are plentiful but cannot answer basic audit questions**.
* **No stable run identifier across subsystems**.
* **State is reconstructed from ad hoc log interpretation**.
* **Evidence captures outputs but not rationale or authority**.
* **Sensitive data is either overexposed or redacted so heavily it loses audit value**.

### Modular integrity smells

* **Every new capability needs a special-case integration path**.
* **Reasoning components can write directly to governed state**.
* **Assurance depends on the same components it is meant to validate**.
* **Cross-domain imports form a web instead of a direction**.
* **Shared mutable global config controls unrelated concerns**.

### Learning and evolution smells

* **The knowledge base accepts unverified conclusions as facts**.
* **Incidents are documented, but nothing changes in policy or design**.
* **Architecture decisions are remembered socially, not recorded**.
* **Prompt changes alter behavior materially without governance review**.

---

## IV. AI-agent safety architecture checks

These are architecture-level checks, not prompt-level tricks.

1. **Capability is not authority**:

   An agent may know how to do something, but it cannot do it without explicit permission.

2. **Model output never directly triggers sensitive side effects**:

   There is always a mediated admission step.

3. **External content cannot rewrite governance**:

   Retrieved documents, instructions, or artifacts cannot override policy or authority rules.

4. **Agent memory is distinguished from source-of-truth state**:

   Memory can inform planning, but not redefine governed facts.

5. **Reasoning summaries are recorded separately from evidence**:

   Interpretation and proof are not conflated.

6. **Prompt or model changes are treated as governed configuration**:

   They can materially change behavior and should be versioned and reviewed.

7. **High-risk actions are tiered and escalated**:

   The agent does not decide alone on destructive, external, or irreversible operations.

8. **Tool exposure is minimal and context-bound**:

   The agent sees only the tools and resources needed for the current objective.

9. **Secrets do not leak into general planning context**:

   Secret material is scoped to the runtime that must use it.

10. **The system can interrupt the agent cleanly**:

    Cancel, revoke, and quarantine are first-class.

11. **The agent cannot self-authorize, self-approve, or self-amend policy**:

    Any self-modification path is separately governed.

12. **Post-action verification is independent of the acting agent**:

    The actor does not grade its own work without challenge.

13. **Uncertainty is surfaced, not hidden**:

    The architecture rewards block or escalate over fabricated confidence.

14. **Blast radius is bounded**:

    Rate limits, spend limits, scope limits, and resource limits constrain agent failure.

---

## V. Control-plane vs execution-plane validation

This is the most important structural split in the system.

### The control plane should own

* objective registration and lifecycle
* identity and authority evaluation
* policy evaluation and admission
* approval and escalation paths
* scheduling and coordination rules
* locks, leases, and cancellation authority
* run ledger and state model
* evidence indexing and governance observability
* continuity and recovery orchestration

### The execution plane should own

* isolated step execution
* runtime/tool invocation
* interaction with files, services, and external systems within admitted scope
* result reporting
* heartbeats and progress signals
* proposal of facts back to the control plane
* local retry behavior within strict policy bounds

### Hard validation rules

* The execution plane may **request** permission; it may not **grant** permission.
* The execution plane may **propose** state changes; it may not define authoritative governance state unilaterally.
* The control plane may **authorize** work; it should not be tightly coupled to tool-specific implementation details.
* Policies should not be duplicated in workers.
* A worker should not remain authorized indefinitely after disconnection from the control plane.
* The control plane must be able to stop, quarantine, or supersede any execution instance.

### Questions that should always have crisp answers

1. What exactly must happen before a worker may perform a side effect?
2. How does a worker prove it still holds valid authority?
3. Can two workers act on the same governed surface safely?
4. What happens when the control plane goes down mid-run?
5. What evidence is emitted before, during, and after side effects?
6. How is cancellation enforced?
7. Can a worker mutate policy, approvals, or objective definitions?
8. How are orphaned workers detected?
9. How are retries prevented from duplicating effects?
10. Can a run be reconstructed even if the worker disappears?

A weak answer to any of these is a structural defect, not a mere implementation gap.

---

## VI. Promotion gate for architecture readiness

A design should not be considered implementation-ready unless all of the following are true:

* objective, authority, and policy are first-class modeled concepts
* there is a single logical path for governed admission
* side effects are explicitly classified and controlled
* control-plane and execution-plane responsibilities are separated
* evidence and state models are defined before execution is built
* failure, rollback, and recovery semantics are designed up front
* assurance can block, not merely observe
* exceptions are governed, expiring, and auditable
* learning has provenance and does not silently rewrite truth
* the architecture remains understandable without relying on unwritten conventions

---

## VII. The shortest architectural test

The architecture is probably sound only if it can always answer, for any meaningful action:

* What objective justified this?
* What authority allowed it?
* What policy admitted it?
* What exact side effect occurred?
* What evidence proves it?
* How would it be reversed or compensated?
* What would have happened if uncertainty had remained unresolved?
* Which plane owned the decision, and which plane performed the work?

If even one of those questions is hard to answer, the architecture is not yet governed enough.
