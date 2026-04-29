---
title: Engineering Principles & Standards (Authoritative)
description: Binding engineering standards aligned to agent-first, system-governed, complexity-calibrated operation.
status: Binding
mutability: immutable
agent_editable: false
risk_tier: critical
change_policy: human-override-only
owner: "octon-maintainers"
last_reviewed: 2026-04-29
applies_to:
  - Architecture
  - Code
  - Documentation
  - Configuration
  - Delivery practices
---

# Engineering Principles & Standards (Authoritative)

> This protected principles charter is authoritative only within the
> subordinate principles surface. It is not the repo-local constitutional
> kernel; supreme repo-local constitutional authority lives under
> `/.octon/framework/constitution/**`.

**Status:** Binding
**Applies to:** Architecture, code, documentation, configuration, delivery practices
**Canonical goal:** Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.
**Operational goal:** High-integrity delivery with **minimal sufficient complexity**, strong auditability, and durable profile-driven reuse intent for agent operation, with live support claims bounded by published support targets and retained disclosure proof.

> This authoritative charter is immutable by default and may be changed only
> through explicit human override under `change_policy: human-override-only`.
> All overrides must preserve traceability and constitutional coherence.

## Human Override Record

- override_ledger_id: `OVR-2026-03-13-001`
- rationale: Rename the canonical harness and governed runtime identity from Octon to Octon.
- responsible_owner: `octon-maintainers`
- review_date: `2026-06-30`
- override_scope: Direct charter framing rename for the active product and runtime identity, plus aligned terminology in canonical governance text.
- review_and_agreement_evidence: Explicit human instruction in Codex on 2026-03-13 to rename Octon to Octon and implement the clean-break cutover.
- intentional_exception_log_link: `../exceptions/principles-charter-overrides.md#ovr-2026-03-13-001`

- override_ledger_id: `OVR-2026-04-29-001`
- rationale: Align the protected principles charter to the live Octon Governed Autonomy Stack closure surfaces without widening support or authority.
- responsible_owner: `octon-maintainers`
- review_date: `2026-07-31`
- override_scope: Add lifecycle framing for Safe Start, Safe Continuation, Continuous Stewardship, Connector Admission Runtime, Constitutional Self-Evolution, and Federated Trust.
- review_and_agreement_evidence: Explicit human instruction in Codex on 2026-04-29 to harden and close the Octon Governed Autonomy Stack in the live repository.
- intentional_exception_log_link: `../exceptions/principles-charter-overrides.md#ovr-2026-04-29-001`

---

## 0A) Scope and Terms (SSOT for This Document)

- **Subsystem:** A service, library/module, or bounded feature area with a distinct owner.
- **Public surface:** Any API, schema, event, config, CLI, interface, or contract consumed outside its owning subsystem.
- **Boundary:** The seam between subsystems/layers; crossings happen only via declared public surfaces.
- **SSOT hub:** The canonical entry document for a subsystem/domain.
- **Significant change:** A change that alters a public surface/boundary, persistent data model, dependency framework baseline, configuration surface, or introduces a reusable abstraction.

---

## 0) Non-Negotiables (Always True)

1. **Agent-first purpose**: Octon standardizes governed agent operation through shared contracts, workflows, capabilities, safety controls, and auditability.
2. **System-governed model**: governance is encoded in contracts, policies, workflows, and enforcement checks that run by default.
3. **Human governance role**: humans remain policy authors, exception handlers, and escalation authority.
4. **Complexity calibration**: complexity must be justified by risk, scale, safety, performance, or compliance; reject under-engineering and over-engineering.
5. **Complexity fitness**: complexity must be proportional, intentional, and maintainable.
6. **Single Source of Truth (SSOT)** exists for requirements, contracts, and operational reality.
7. **Deterministic and operationally shippable**: deterministic where required, debuggable, observable, safe to roll out, safe to roll back.
8. **Security by default**: least privilege, safe dependency practices, sensitive data guarded.
9. **Consistency over novelty**: prefer established patterns of this codebase.
10. **Convivial constraints are enforceable**: non-trivial planning and review must explicitly assess capability expansion, attention/interrupt behavior, extraction risk, and anti-manipulation safeguards.

---

## 0B) Canonical Framing (Normative)

### 0B.1 Agent-First Purpose

- Octon standardizes governed agent operation through shared contracts, workflows, capabilities, safety controls, and auditability.
- Profile-driven reuse across projects remains an architectural goal; live
  support claims stay bounded by published support targets and retained
  disclosure proof.
- Humans are governance and escalation authority, not the primary standardization target.

### 0B.2 System-Governed Model

- Octon is **system-governed**.
- Governance runs through default-on contracts, policies, workflows, and enforcement checks.
- Humans handle policy authorship, exceptions, and escalation handling.

### 0B.3 Managed Complexity

- Governing rule: **as simple as possible, as complex as necessary**, balanced for reliability, operability, and future change.
- Favor **minimal sufficient complexity** over simplicity-only framing.
- Favor the **smallest robust solution that meets constraints**.
- Use **Complexity Calibration** and **Complexity Fitness** as standard evaluation language.

### 0B.4 Delivery Defaults

- Delivery defaults prioritize deterministic behavior, observable operations, and reversible change.

### 0B.5 Convivial Constraints (Normative)

- Convivial constraints are binding for non-trivial change and must be explicit in planning and review artifacts.
- Canonical minimum requirements are defined in `../controls/convivial-impact-minimums.md` and `../controls/convivial-impact-minimums.yml`.
- Governance enforcement must validate these constraints across Tier 2/3 planning templates and governed review checklist surfaces by default.

### 0B.6 Governed Autonomy Lifecycle Surfaces (Normative)

- Safe Start standardizes drop-in governed start through Engagement, Project Profile, Work Package, Decision Request, Evidence Profile, Preflight Evidence Lane, Tool/MCP Connector Posture, and Run Contract Candidate surfaces.
- Safe Continuation standardizes mission-scoped continuation through Autonomy Window, Mission Runner, Mission Queue, Action Slice, Continuation Decision, Mission Run Ledger, and Mission Evidence Profile surfaces.
- Continuous Stewardship standardizes finite, non-executing care through Stewardship Program, Stewardship Epoch, Stewardship Trigger, Stewardship Admission Decision, Idle Decision, Renewal Decision, and Stewardship Ledger surfaces; it must not become an infinite agent loop.
- Connector Admission Runtime standardizes operation-level connector and capability admission through Connector Operation, Connector Trust Dossier, Connector Evidence Profile, Connector Drift Record, Connector Quarantine, support-target proof hooks, and operation-level capability mapping.
- Constitutional Self-Evolution standardizes evidence-to-evolution through Evolution Program, Evolution Candidate, Evidence-to-Candidate Distillation Record, Governance Impact Simulation, Assurance Lab Promotion Gate, Evolution Proposal Compiler, Constitutional Amendment Request, Promotion Runtime, Recertification Runtime, and Evolution Ledger surfaces; it must not self-authorize durable governance change.
- Federated Trust standardizes compatibility and proof interchange through Octon Compatibility Profile, external project compatibility inspection, safe external adoption posture, Portable Proof Bundle, Attestation Envelope, Local Acceptance Record, Trust-Domain hook, proof import/export, attestation verify/accept/reject, revocation, and expiry behavior.
- Imported proof, external attestations, generated projections, proposal packets, chat, host UI state, labels, and comments are not authority. They may become evidence only through local verification, retained receipts, and a valid Local Acceptance Record where applicable.
- Material execution remains bound to run contracts, context packs, execution authorization, authorized-effect tokens, retained evidence, rollback posture, and support-target gates.

---

## 0C) Charter Evolution Contract (Supersession + Sync)

- This charter is authoritative and immutable by default.
- Clarifications and non-breaking refinements require explicit human override and
  must preserve canonical framing coherence.
- For major framing shifts, require an explicit human override documented
  directly in this charter with:
  - rationale
  - responsible owner
  - review date
  - override scope
  - review-and-agreement evidence
  - intentional, non-automated exception log reference
- Automation may propose framing changes but must not approve or apply major
  framing-shift overrides.
- Every direct edit under override must append a record in
  `../exceptions/principles-charter-overrides.md`.
- Protected branch default: merge through PR. Direct `main` pushes are
  break-glass only and must carry a `BREAK-GLASS: OVR-YYYY-MM-DD-NNN`
  commit-footer reference that matches the override ledger.
- Keep principles discovery surfaces synchronized with the active framing:
  `README.md`, `index.yml`, and linked ADR records.

---

## 1) Principle Precedence Order (How We Resolve Tensions)

When principles conflict, choose the earliest applicable rule:

1. **Correctness & Safety**
2. **Design Integrity (cohesion, boundaries, change cost)**
3. **Complexity Calibration (minimal sufficient complexity with explicit justification)**
4. **Maintainability & Operability (debuggability, observability, runbooks)**
5. **Performance & Efficiency (measured, budgeted)**
6. **Delivery Speed**

**Exceptions are allowed only via the Exception Protocol (Section 9).**

---

## 2) Core Principles (What We Believe + What We Do)

### P1 - SSOT Hubs, Not Doc Sprawl

**Intent:** Documentation is a compact map to truth, not a parallel universe.

**Do**

- Maintain **SSOT hubs** for each domain: "what it is," "where it lives," "how it works," "how to change it."
- Use **progressive disclosure**: hub -> overview -> deep dives (only when needed).
- Keep docs close to the thing they describe (or link to the authoritative place).

**Don't**

- Duplicate the same truth across multiple documents.
- Create "misc" docs that become dumping grounds.

**Proof**

- Every doc has an owner, last-reviewed date, and canonical links.
- Each subsystem SSOT hub is reachable from the repository primary entry point (root README or docs index).

### P2 - Explicit Boundaries & Contracts

**Intent:** Clear seams prevent architecture entropy.

**Do**

- Define boundaries using **modules, packages, service interfaces, or APIs**.
- Treat boundaries as contracts: inputs/outputs, invariants, failure modes.
- Cross boundaries only through declared public surfaces; no internal reach-in/backdoor imports.
- Enforce boundaries with tooling/tests where possible (dependency rules, lint rules, compile-time checks).

**Don't**

- Reach across layers "just this once."
- Create shared "utils" that become a junk drawer.

**Proof**

- A new boundary or cross-boundary dependency requires an ADR/RFC (thresholds in Section 7).

### P3 - Complexity Calibration (KISS, YAGNI, and robustness in balance)

**Intent:** Build only the complexity you can justify and sustain, while meeting robustness and operational constraints.

**Do**

- Default to **minimal sufficient complexity** that satisfies requirements and constraints.
- Choose the **smallest robust solution that meets constraints**.
- Delay generalization until you can name at least **2 real consumers** or **1 imminent change** with evidence.
- Prefer plain data structures over frameworks when the value is not clear.
- Explicitly justify complexity with risk, scale, safety, performance, or compliance.

**Don't**

- Prebuild "platforms," "engines," or "generic abstractions" without proven need.
- Use SOLID/DRY as a reason to add indirection when it reduces clarity.
- Under-engineer critical paths that require durability, safety, or compliance.

**Proof**

- Each added abstraction states: what it replaces, what it prevents, why it is justified, and the cost it adds.

### P4 - Subtractive Bias (Reduce Before You Add)

**Intent:** The cleanest system is the one with less to maintain.

**Do**

- Before adding anything, ask: **Can we delete, consolidate, inline, or reuse?**
- Prefer **one good path** over many configurable ones.
- Replace "options" with **defaults + rare overrides**.

**Don't**

- Add "temporary" flags/config that become permanent.
- Keep dead code "just in case."

**Proof**

- Every PR includes a **complexity delta**: what got simpler, what got more complex.

### P5 - Minimal Additive Change (When Justified)

**Intent:** Counterbalance YAGNI without enabling bloat.

**Do**

- Add small forward-looking hooks only when they prevent near-term churn and have a plausible next step.
- Require an **exit plan** for each additive hook (how it gets removed/solidified).

**Don't**

- Add extension points without a named, near-term scenario.

**Proof**

- Additive changes include: scenario, time horizon, and removal criteria.

### P6 - Design Integrity & Clean Code

**Intent:** The system stays conceptually coherent as it grows.

**Do**

- Optimize for: **cohesion, low coupling, clear naming, obvious flow, minimal indirection**.
- Refactor toward stable concepts; remove "cleverness."

**Don't**

- Hide behavior behind magic.
- Trade readability for micro-optimizations without data.

**Proof**

- Code should be explainable quickly: "A new engineer can locate and change the behavior in one sitting."

### P7 - Quality Engineering is Part of "Done"

**Intent:** Quality is not a phase; it is an invariant.

**Do**

- Tests match risk: unit + integration + contract tests where it matters.
- Use static analysis, formatting, linting, and type safety to prevent regressions.
- Reproduce bugs with tests before fixing when feasible.

**Don't**

- Merge failing tests, flaky tests, or unreviewed changes to critical paths.

**Proof**

- CI is authoritative; "green or it does not ship."

### P8 - Operability & Observability by Design

**Intent:** If we cannot operate it, we do not own it.

**Do**

- Instrument meaningful events, metrics, and traces.
- Provide actionable logs (who/what/why/next) and stable error semantics.
- Document runbooks for critical subsystems.

**Don't**

- Ship "black box" components.
- Treat post-incident work as optional.

**Proof**

- Every major capability has: failure modes, dashboards/metrics, and rollback strategy.

### P9 - Controlled Change (Compatibility + Migration)

**Intent:** Keep users and systems stable as we evolve.

**Do**

- Version public APIs/contracts.
- Provide migration paths and deprecation timelines.
- Prefer additive compatible changes over breaking ones; break only with justification.

**Don't**

- Introduce breaking changes without a plan and communication.

**Proof**

- "Breaking change" requires ADR + rollout plan + migration documentation.

### P10 - Security & Privacy by Default

**Intent:** Security is continuous and boring (in a good way).

**Do**

- Least privilege, safe secrets handling, dependency hygiene, and threat modeling for major changes.
- Validate inputs at boundaries; treat external data as hostile.

**Don't**

- Log sensitive data.
- Add dependencies casually.

**Proof**

- Dependency additions include: reason, alternatives, and risk notes.

---

## 3) Documentation Standards (SSOT Hubs)

### Doc Types (Allowed)

- **Hub** (SSOT index): the canonical entry point for a domain/subsystem.
- **ADR**: architecture decision record (what we decided + why).
- **How-to**: operational steps (runbooks, migrations, troubleshooting).
- **Reference**: precise contracts, schemas, API docs.
- **Rationale/Overview**: compact explanation of concepts and boundaries.

### Rules

- Every subsystem/domain has one canonical SSOT hub.
- SSOT hubs include, at minimum:
  - Scope (what is in/out)
  - Public surface links (API/schema/event/config/CLI/interface contracts)
  - Change guide (where behavior changes are made, key invariants/tests, rollout/rollback notes)
  - Operations links (dashboards/alerts/logs/runbooks) where applicable
  - Owner and last-reviewed date
- **Every doc declares**: owner, scope, intended audience, and canonical links.
- Non-hub docs link back to the canonical SSOT hub.
- **No duplicate truths**: if a fact has a single canonical place, others link to it.
- **Docs must be searchable and skimmable**: headings, bullets, short sections.
- **Docs freshness**: hubs and runbooks must be reviewed at least quarterly (or after major changes).

---

## 4) Architecture Standards (Boundaries, Dependencies, Config)

### Boundaries

- Each subsystem states: **responsibilities, non-responsibilities, public surface, invariants**.
- Cross-boundary calls require explicit interfaces/contracts and use only declared public surfaces.

### Dependencies

- Prefer fewer dependencies. Choose boring, stable, well-supported libraries.
- No transitive dependency explosions without justification.
- Dependency additions require: "Why this library" + "Why not build/buy alternative."

### Configuration

- **Configuration is public surface**: every config key has an owner, default, documented meaning, and retirement trigger when temporary.
- **Configuration budget**: every config key has an owner, default, and sunset policy.
- Prefer **convention over configuration**.
- Avoid "configuration drift": config changes must be versioned and tested.

---

## 5) Code Standards (Clarity, Consistency, Maintainability)

- Prefer readability: clear naming, small functions, explicit error handling.
- Avoid hidden control flow (magic reflection, excessive metaprogramming) unless it clearly reduces complexity overall.
- One obvious way to do common tasks: follow established project conventions.
- Refactors are welcome when they reduce complexity and improve integrity.
- Avoid mixed refactor + behavior-change PRs unless the risk tradeoff is explicitly justified.

---

## 6) Technical Debt Policy (Prevent, Track, Pay Down)

- Maintain a **Debt Register** with: item, cost, risk, owner, proposed fix, priority, and target window.
- Debt must be **intentional**: if we take debt, we record the reason and paydown trigger.
- "TODO" requires an issue reference or removal before merge (except trivial local notes).

---

## 7) Decision Protocols (RFC/ADR Thresholds)

### ADR required when

- Making a significant change that is hard to undo
- Introducing/changing a boundary, public API, or persistent data model
- Adding significant dependencies or frameworks
- Adding new major configuration surfaces
- Making a breaking change or major migration

### Lightweight RFC required when

- Multiple plausible solutions exist and tradeoffs are non-trivial
- The change affects multiple teams/subsystems

**Rule:** If the change is hard to undo, it needs a decision record.

### ADR minimum fields

- Context
- Decision
- Alternatives considered
- Consequences
- Owner
- Date
- Review-by (or revisit trigger)
- Links
- For major framing-shift overrides, include: override scope, responsible owner,
  review date, review/agreement evidence, and intentional non-automated
  exception log linkage.

---

## 8) Definition of Done (PR Gate)

A change is "done" only if:

- Scope is tight and unrelated churn is avoided.
- Scope and boundaries are explicit
- Tests match risk and pass reliably
- Docs SSOT hub updated (or intentionally unchanged with justification)
- Observability/operability impact addressed (logs/metrics/runbooks as needed)
- Critical subsystem runbooks are linked from the SSOT hub.
- Complexity impact explained (what got simpler / what got more complex)
- Performance-motivated changes include a measurement method and before/after evidence when practical.
- Rollback or mitigation is clear for risky changes

---

## 9) Exception Protocol (How We Break the Rules Safely)

Exceptions are allowed only if they include:

1. **Written rationale** (what principle is being violated and why)
2. **Timebox** (when it must be revisited)
3. **Owner** (accountable person/team)
4. **Exit plan** (how we return to compliance)
5. **Evidence** (why the exception is worth it)

No timebox = no exception.

### Additional Requirement for Major Framing Shifts

A major framing-shift exception is valid only with an explicit human override
recorded in this charter that includes:

1. **Rationale** (why framing must shift)
2. **Responsible owner** (accountable human)
3. **Review date** (revalidation checkpoint)
4. **Override scope** (exact boundaries of the shift)
5. **Review-and-agreement evidence** (who reviewed and agreed)
6. **Intentional, non-automated exception log linkage**
7. **Override ledger id** in
   `../exceptions/principles-charter-overrides.md`

---

## 10) Enforcement (How We Adhere Strictly)

### Automated (CI/Tooling)

- Formatting, lint, type checks
- Test gates + flake quarantine policy
- Docs build/link checks where applicable
- Dependency policy checks (allowlist/blocklist)
- Boundary enforcement (module rules / architecture tests)

### Human (Review + Rituals)

- Code review uses a standard rubric (scope, boundaries, SSOT, complexity delta, operability).
- Weekly debt triage (prioritize deletion and simplification work).
- Quarterly integrity review of hubs, boundaries, dependencies, and config budgets.

---

## 11) Quick Rules (Memorize These)

- **Prefer deletion and consolidation before addition.**
- **No new abstraction without evidence, clear payback, and constraint fit.**
- **Favor minimal sufficient complexity over simplicity-only shortcuts.**
- **One SSOT hub per domain; link, don't duplicate.**
- **Boundaries are contracts; crossing them is a decision.**
- **If it's hard to undo, write it down (ADR).**
- **If we can't operate it, we don't ship it.**
- **Exceptions require a timebox and an exit plan.**
- **Major framing shifts require explicit human override and non-automated exception logging.**
