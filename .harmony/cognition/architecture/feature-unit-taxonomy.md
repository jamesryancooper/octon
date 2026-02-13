---
title: Feature Unit Taxonomy (Examples)
description: Non‑normative examples mapping common features to Harmony lifecycle stages and AI‑Toolkit kits. Illustrative only; architecture decisions remain in the core documentation.
---

# Feature Unit Taxonomy — Non‑Normative Examples

These examples show how representative features map to the Harmony lifecycle (Spec → Plan → Implement → Verify → Ship → Operate → Learn) and how AI‑Toolkit kits interact. They are illustrative only and do not alter architectural decisions. All examples assume the canonical **polyglot monorepo** layout from `monorepo-polyglot.md` (vertical slices under `packages/<feature>`, control-plane kits under `packages/kits/*`, contracts in the root `contracts/` registry, and Python agents under `agents/*` using generated clients from `contracts/py`). See the Migration Playbook, Governance Model, Runtime Policy, and Tooling Integration for authoritative guidance.

Related docs: [overview](./overview.md), [migration playbook](./migration-playbook.md), [governance model](./governance-model.md), [runtime policy](./runtime-policy.md), [tooling integration](./tooling-integration.md), [knowledge plane](./knowledge-plane.md).

## User‑Facing Feature Units

### Organizational Billing & Payments (High Risk)

- Lifecycle
  - Spec: define billing models, pricing constraints, security/compliance needs.
  - Implement: integrate payment provider; deterministic HTTP calls.
  - Verify: financial correctness and security tests; contract checks.
  - Ship: gradual rollout via feature flags; instant rollback available.
  - Operate: monitor transactions; observability + audit logs.
  - Learn: update docs/ADRs; feed issues/findings to Knowledge Plane.
- Kits
  - SpecKit, PlanKit (requirements, BMAD plan)
  - ToolKit (HTTP, Git, Shell), DevKit (boilerplate generation)
  - PolicyKit (ASVS/security controls), GuardKit (PII redaction), VaultKit (secrets)
  - TestKit (contract/calculation tests), EvalKit (validate AI‑generated artifacts)
  - PatchKit/NotifyKit (PRs, approvals), ObservaKit (traces/logs/metrics)
- Artifacts
  - OpenAPI for billing endpoints; JSON Schemas for invoices.
  - Test reports validating amounts/tax; audit logs with trace IDs.
- Flags & Risk
  - High risk; ship behind flags; two‑person review for high‑risk per Governance Model.
  - HITL: navigator/finance/security review at spec and pre‑merge.

### OAuth Login & User Authentication (High Risk)

- Lifecycle
  - Spec → Implement → Verify with strong upfront design and threat modeling (STRIDE).
- Kits
  - SpecKit (flows, scopes, redirects), PlanKit (stack choices like NextAuth/Auth0)
  - StackKit (stack deltas), DiagramKit (auth flow diagrams)
  - PolicyKit (ASVS alignment), GuardKit (no token/secret leakage), HeadersKit (CSP/HSTS)
  - DevKit (boilerplate), TestKit (E2E auth flows), EvalKit (content sanity)
  - VaultKit (secrets), ObservaKit (trace each login attempt)
- Artifacts
  - OpenAPI for auth endpoints; config (IDs managed via VaultKit); trace‑linked run logs.
- Flags & Risk
  - High risk; new auth paths behind flags; mandatory security review; fail‑closed CI gates.

### Role‑Based Access Control (RBAC) (Medium → High)

- Lifecycle
  - Spec: roles/permissions matrix and ADR(s); Implement: enforce at routes/UI; Verify: authorization tests.
- Kits
  - PolicyKit (authorization rules), VaultKit (if role secrets/keys used)
  - DevKit/AgentKit (refactor to add guards), CodeModKit (inject guard patterns)
  - TestKit (contract/negative tests), ObservaKit (audit attempts with role attributes)
- Artifacts
  - RBAC policies (code/YAML), OpenAPI security requirements, test reports, compliance evidence.
- Flags & Risk
  - Medium to High depending on surface; feature‑flag new roles/paths; HITL on high‑risk changes.

---

## Internal Agentic Capabilities (Illustrative)

### Prompt Tuning & Management (Low → Medium)

- Lifecycle
  - Plan → Implement with Learn feedback. Maintain prompt templates and parameters; version and pin.
- Kits
  - AgentKit (execution), PromptKit (templates; optional when usage is light), ModelKit (approved models/prompts; hashes), EvalKit (content sanity), Knowledge Plane (provenance).
- Notes
  - Record prompt hashes, model versions, and idempotency/cache keys for determinism. Keep templates small and composable; avoid app logic in prompts.

### Knowledge Base Indexing & Grounding (RAG) (Medium)

- Lifecycle
  - Spec/Plan data sources; Implement indexing; Verify answer quality; Operate with observability.
- Kits
  - IngestKit (normalize), IndexKit (build indexes), QueryKit (deterministic queries), EvalKit + DatasetKit (citation/entailment), ObservaKit (trace retrieval ops). SearchKit optional for external sources.
- Notes
  - Start with first‑party docs/specs; defer external SearchKit until needed. Gate new corpora behind FlagKit; persist provenance in the Knowledge Plane.
  - Cross-service or cross-language calls for indexing/search APIs SHOULD go through contracts defined in `contracts/openapi` and `contracts/schemas`, with TS and Python consumers using generated clients from `contracts/ts` and `contracts/py` rather than ad‑hoc HTTP.

### Automated Code Refactoring & Migration (Medium)

- Lifecycle
  - Plan refactor/migration; Implement via controlled diffs; Verify with tests/contracts.
- Kits
  - AgentKit/DevKit (changes), CodeModKit (mechanical refactors), DepKit (dependency upgrades), TestKit (regression), PatchKit (PRs), PolicyKit (guardrails).
- Notes
  - Keep diffs scoped and reversible; prefer codemods for repetitive changes; run contract tests and static analysis gates in CI.

---

## Notes

- Determinism and provenance apply across all features (pin models, record prompt hashes, link PR/build/trace IDs).
- Sensitive data handling: all secret access via VaultKit; GuardKit scrubs emit boundaries (logs/traces); never substitute redaction for proper secret handling.
- Retrieval (RAG) features: gate new corpora behind FlagKit; evaluate answer quality via EvalKit + DatasetKit; log retrieval ops with ObservaKit; see Knowledge Plane guidance.
