---
title: Governance Model
description: Autonomous Control Point policy gates, waivers, risk rubric, and CI policy gates to achieve Velocity through Agentic Automation and Trust through Governed Determinism.
---

# Governance Model

Technical governance for the Octon Structural Paradigm (HSP) defines how changes are proposed, reviewed, validated, and released. This document specifies ACP gates, the waiver policy, CI/CD quality gates, and a risk assessment rubric. The goal is Velocity through Agentic Automation and Trust through Governed Determinism: rapid iteration without compromising correctness, security, or availability.

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [overview](./overview.md), [runtime architecture](./runtime-architecture.md), [runtime policy](./runtime-policy.md), [kaizen subsystem](./kaizen-subsystem.md), [tooling integration](./tooling-integration.md), [contracts registry](./contracts-registry.md), [python runtime workspace example](/.octon/scaffolding/practices/examples/stack-profiles/python-runtime-workspace.md)

## Objectives

- Enforce consistent, auditable controls across planning, development, and delivery.
- Align automated enforcement (CI/CD) with ACP policy decisions and human-on-the-loop oversight.
- Scale decision quality with a risk‑proportional rubric and clear waive‑with‑accountability mechanics.

## Scope

- Applies to all changes affecting production: code, configs, data models, infrastructure, and automated agent plans.
- Covers Planner/Verifier agent interactions, escalation responders, and CI/CD enforcement.

### Autopilot vs Copilot Scope Boundaries

- Autopilot (Kaizen layer) is cross‑cutting and limited to small, reversible, evidence‑driven, policyable changes that do not alter runtime semantics (e.g., docs hygiene, stale‑flag cleanup, span/log scaffolding, contract drift reports).
- Anything changing runtime behavior or involving higher‑risk refactors is Copilot: routed to owning slice(s) via CODEOWNERS and reviewed per repository policy.
- Bots may open PRs; they never approve or push to protected branches.
- During incidents/freezes, Kaizen operates in suggest‑only mode (issues over PRs) until the freeze lifts.

Ownership & Checks (Repository Policy)

- Ownership: `/kaizen/**` owned by platform/quality; CODEOWNERS patterns allow Kaizen PRs to touch `docs/**`, `.github/**`, `infra/**`, and per‑slice scaffolds (PR‑only; owners review).
- Required cross‑cutting checks run on all PRs: `docs_hygiene`, `flags_hygiene`, `otel_scaffold`, `contracts_drift`. These checks provide evidence and do not bypass ACP.

## Definitions

- ACP Gate: A mandatory policy decision point that governs promotion and escalation.
- Waiver: A time‑bound, documented override of a gate under controlled conditions.
- CI Gate: An automated check enforced in the pipeline that must pass to merge or deploy.
- Risk Rubric: Criteria used to categorize change risk and scale required controls.

---

## ACP Gates

ACP policy gates appear at defined phases. Each gate documents trigger conditions, required evidence/quorum, escalation conditions, and whether it is blocking.

### Gates

- Plan/Stage Gate
  - Trigger: Planner agent produces a non‑trivial or multi‑option plan (e.g., core refactor, DB migration).
  - Requirements: Plan rationale, alternatives, risk level, rollback strategy, evidence plan.
  - Outcome: Stage work and run ACP preflight to determine required ACP/evidence/quorum before promotion.

- Promotion Gate
  - Trigger: Merge to protected branch, deployment promotion, migration promotion, or other durable state transition.
  - Requirements: ACP rule match, reversibility metadata, required evidence bundle, budget compliance, quorum attestations (ACP-2/ACP-3).
  - Outcomes: `ALLOW`, `STAGE_ONLY`, `DENY`, or `ESCALATE` (policy-defined).
  - Blocking: Yes; only `ALLOW` may promote durable state.

- Finalization Gate
  - Trigger: Irreversible finalize actions (`ACP-4` classes).
  - Requirements: Explicit break-glass posture plus audited receipt trail.
  - Outcome: Default `DENY` unless break-glass policy is active and all constraints pass.

- Post‑Promotion Oversight
  - Trigger: ACP decision emitted for promote/finalize.
  - Requirements: Append-only receipt + digest + decision log entry.
  - Escalation: Humans are notified on unresolved quorum, risk threshold crossing, or policy `ESCALATE`.

### Documentation and Templates

- PR template includes: ACP decision summary, reason codes, receipt path, rollback handle.
- Planning template includes: risk class, evidence plan, quorum plan (where required), rollback strategy.

Additional templates:

- `.github/PULL_REQUEST_TEMPLATE/kaizen.md` for Kaizen PRs capturing: trigger signal/report links, change type (docs | dev_hygiene | observability_scaffold | contract_drift | perf_nudge), track (autopilot | copilot), and non‑negotiables checklist (no push to protected; no self‑approve; AI config pinned).

PR template (required fields):

- Risk class: Trivial | Low | Medium | High
- Determinism & provenance: model/provider/version if AI used; parameters; `trace_id` correlating PR ↔ CI ↔ traces
- Contracts changed: link to OpenAPI/JSON Schema diff and Pact/Schemathesis reports
- Flags & rollback: flag name(s), default OFF, and rollback plan

Principle: human judgment remains the ultimate arbitrator for unresolved high‑risk escalation paths.

Example Kaizen PR template (`.github/PULL_REQUEST_TEMPLATE/kaizen.md`):

```md
### Why
- What signal triggered this? (link to report)

### What changed (low-risk, reversible)
- …

### Evidence
- CI run: …
- Artifacts: oasdiff/report, trace plan, preview smoke link

### Safety
- Change type: docs | dev_hygiene | observability_scaffold | contract_drift | perf_nudge
- Track: autopilot | copilot
- Non-negotiables enforced: ✅ no push to protected, ✅ no self-approve, ✅ AI config pinned
```

---

## Waiver Policy

Waivers enable controlled, auditable exceptions when checks fail for known reasons (e.g., flaky test, external outage) and a critical change must proceed.

### Authorization

- Only designated roles may issue waivers, scoped by domain:
  - QA Lead: Test flake or transient CI instability.
  - Security Lead: Security scan findings and exceptions.
  - Tech Lead/Architect: Code quality or static analysis exceptions.
  - Product/Release Lead or On‑call: Emergency production change and deployment gating.

### Required Documentation

- Rationale: Concrete reason for the waiver and associated context.
- Scope: Exact check(s) waived; narrowest possible surface area.
- Risk and Mitigation: Risk acknowledgment, compensating controls, rollback path.
- Duration: One‑time or explicit expiration date; auto‑expire by default.
- Approver: Name/role of the authorizing individual.
- Record: Logged in the Knowledge Plane and source control (e.g., PR comment, commit message, or waiver register).

### Notification and Audit

- Notify relevant channels (e.g., Slack) for risky waivers and emergency merges.
- CI/CD and deployment tooling must capture who authorized the override and when.
- Post‑incident or release review validates that the waiver was justified and closed.

Summary: waivers are a safety valve for agility, with accountability and follow‑up.

---

## CI/CD Gates

Automated gates enforce non‑negotiable quality bars. Gates fail‑closed; merges and deployments are blocked until resolved or properly waived.

- Build Gate: Source compiles/builds successfully.
- Test Gate: Required test suites pass (unit on every commit; integration/extended suites as configured). Branch protection blocks merges until green.
- Static Analysis Gate: No new high‑severity findings; formatting and style enforced. Treat critical warnings as errors. (Typical tools: CodeQL, Semgrep.)
- Security Scan Gate: Dependency and container scanning, SBOM/license, secrets, and SAST/DAST controls must report no new critical issues. Security waivers required for exceptions.
- Contract Tests Gate: Contract-first interfaces (OpenAPI/JSON Schema) defined in the root `contracts/` registry are validated via consumer-driven contract tests (e.g., Pact) and fuzz/negative testing (e.g., Schemathesis) across both TypeScript and Python consumers. TS code uses generated types/clients from `contracts/ts`; Python agents and runtimes use generated clients from `contracts/py`. Failures block merges/deployments unless explicitly waived.
- Performance/Coverage Gate: Coverage does not regress beyond threshold; performance checks pass where applicable (often verified in staging).
- Policy Compliance Gate: Custom rules enforce architectural/policy constraints (e.g., authZ presence on public APIs). Align checks with ASVS/SSDF controls where applicable. Violations fail CI.
- Deployment Gate: Progressive rollout (canary → smoke tests → full) with automated halts on error rate spikes or failed smoke tests.

Gates are defined as code (e.g., GitHub Actions/GitLab/Jenkins) and changes to gating rules go through review.

---

## Risk Assessment Rubric

Risk level determines the rigor of controls. The rubric guides both Planner agent tagging and human processing.

### Risk Criteria

- Scope of change: localized vs. cross‑module or systemic.
- Area complexity/criticality: e.g., auth, payments, concurrency.
- Test coverage of affected area.
- Nature of change: bug fix, new feature, refactor, dependency upgrade.
- Environment impact: infra, deployment, schema/data migration.
- Reversibility: feature flags, toggles, or one‑way operations.
- Confidence: agent vs. human certainty and familiarity.
- Time pressure: urgent hotfixes treated as higher risk by default.

### Risk Levels and Required Controls

- Low
  - Typical: docs, cosmetic UI, minor refactors, patch‑level dependency updates.
  - Controls: 1 reviewer; standard CI gates; reversible by default.

- Medium
  - Typical: features behind flags, bug fixes in non‑critical components, single‑module changes with tests.
  - Controls: 1–2 reviewers; full CI; staging validation as needed.

- High
  - Typical: auth changes, large refactors, major dependency upgrades, concurrency/security‑critical paths, one‑way migrations.
- Controls: verifier + recovery attestations, design note, extended testing (load/security as applicable), canary + soak, explicit rollback plan, and pre‑production ACP evaluation.
- Quorum rule: ACP-2/ACP-3 promotions require policy-defined multi-agent quorum before merge and production promotion.

Branch protection and CI may encode risk‑aware rules (e.g., label‑based reviewer count; extended suites for high‑risk labels).

### Autopilot vs Copilot (Change‑Type Mapping)

- Autopilot (eligible under Trivial/Low):
  - Docs hygiene PRs (lint/links/titles), stale‑flag cleanup diffs, and preview smoke wiring. These changes still require normal review; no bot approvals or direct pushes are allowed.
- Copilot (Medium/High):
  - Observability scaffolding (adding missing spans/logs on changed paths with sample trace outlines), contract drift fixes (OpenAPI/JSON‑Schema with `oasdiff` evidence), performance budget adjustments, and threat‑model test PRs. Always require ACP evidence/quorum aligned to the risk rubric and applicable gates.

Non‑negotiables: bots never approve or push to protected branches; AI configs/models are pinned; every PR includes evidence and PR↔build↔trace correlation for provenance.

### Standard Labels and Bot Identity

- Bot identity: `@repo-improve-bot` (or similar) for clarity and auditability.
- Labels: `autopilot`, `copilot`, `needs-owner`, `risk:low|med|high`, `docs`, `observability`, `contracts`, `perf`, `flags`.
- Promotion gates: Autopilot PRs still require ACP evidence checks before promotion; bots cannot self-approve protected-branch promotion.
- Freeze respect: During release freezes/incidents, the Kaizen layer files issues (not PRs) and defers action until unfreezed.

---

## Governance Integration

The elements work together to deliver Velocity through Agentic Automation and Trust through Governed Determinism:

- Risk rubric drives the depth of ACP scrutiny and which CI suites run.
- CI gates encode objective, deterministic quality bars; ACP adds contextual judgment.
- Waiver policy provides a controlled escape hatch when necessary, with logging and expiration.
- Progressive deployment and monitoring create a fail‑closed posture with rapid rollback.
- Feature flags act as a primary runtime control across both TS apps and Python runtimes (for example, flows executed by the **platform runtime service** under `platform/runtimes/flow-runtime/**`); manual promote/rollback is recorded, and flag state changes are auditable.
- The **platform runtime service** provides a shared execution substrate whose run metadata (for example, `flow_id`, `flow_version`, `run_id`, `caller_kind`, `caller_id`, `project_id`, `environment`, `risk_tier`) is treated as governance evidence: Kaizen, planners, and reviewers use this data from the Knowledge Plane to assess risk, regressions, and waiver impact (see `runtime-architecture.md` and `knowledge.md`).

Transparency is foundational: approvals, waivers, risk levels, CI results, and runtime evidence are recorded and visible for retrospectives and audits.

---

## Operational Notes

- Templates: Keep PR and planning templates updated with approver fields and risk sections.
- Rollback Readiness: For high‑risk changes, require explicit rollback/toggle documentation.
- Knowledge Plane: Use it to store plan rationales, risk decisions, and waiver records for later analysis and rubric tuning.
- Post‑Incident Learning: Conduct lightweight, blameless postmortems for material incidents; capture root causes, actions, and follow‑ups in the Knowledge Plane. Optionally adopt a lightweight PostmortemKit to standardize templates and evidence when incident frequency/severity justifies it (see `kaizen-subsystem.md`).
- Traceability: Link CI runs, PRs, and deployments with trace IDs for provenance and faster audits.
- Continuous Improvement: Periodically adjust the rubric based on incident learnings and trend data.

---

## References

- [Agentic AI governance and accountability](https://arxiv.org/html/2506.22185)
- [Determinism in software and quality practices](https://thrawn01.org/posts/determinism-in-software---the-good,-the-bad,-and-the-ugly)
- [Feature flag risk mitigation patterns](https://launchdarkly.com/blog/what-are-feature-flags/)
