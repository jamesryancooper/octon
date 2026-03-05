---
title: Harmony AI-Native, Human-Governed Methodology Implementation Guide
description: Provider-agnostic playbook for implementing Harmony methodology with SpecKit, PlanKit, FlowKit, ACP governance, and tiered gates.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/authority-crosswalk.md"
---

This guide defines how to implement Harmony in a provider-agnostic, auditable way.

ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.

## 1) Executive Summary

- Keep spec semantics authoritative through SpecKit and plan semantics authoritative through PlanKit.
- Use FlowKit and AgentKit for execution orchestration, with deterministic run records.
- Enforce CI/CD and policy gates by tier (`T1`, `T2`, `T3`) and ACP target (`ACP-1`, `ACP-2`, `ACP-3`).
- Require profile governance before implementation: `change_profile`, `release_state`, and `Profile Selection Receipt`.
- Default to provider-agnostic deployment/rollback abstractions; platform-specific commands are non-normative examples only.

## 2) Overview table — Kits vs External

| Method element | Classification | Expected output |
| --- | --- | --- |
| Spec-first authoring | AI-Toolkit (SpecKit) | `docs/specs/<feature>/...` |
| Plan and ADR generation | AI-Toolkit (PlanKit) | ADR + implementation plan |
| Flow orchestration | AI-Toolkit (FlowKit) | Executable flow run records |
| Agent execution | AI-Toolkit (AgentKit) | proposed diffs/tests/evidence |
| Policy and eval gates | AI-Toolkit (PolicyKit/EvalKit/TestKit) | gate receipts and decisions |
| Observability | AI-Toolkit (ObservaKit) | trace/log evidence with `trace_id` |
| Source control and CI | External platform | required checks + branch protection |
| Deployment and promotion | External platform | preview/staging validation + guarded promotion |

## 3) Lifecycle matrix (A→J): responsibilities, artifacts, commands, gates

### A — Spec

- Artifact: `docs/specs/<feature>/spec.md`
- Required: intent, scope, non-functionals, threat notes.
- Gate: spec validity and structural completeness.

### B — Shape and scope cuts

- Artifact: scoped plan with explicit out-of-scope boundaries.
- Required: rollback intent and rollout strategy.
- Gate: no implementation starts without bounded scope.

### C — Plan and acceptance criteria

- Artifacts: ADR, implementation plan, acceptance criteria.
- Required governance: profile selection fields recorded before build.
- Gate: plan and profile receipt consistency.

### D — Implementation

- Artifacts: proposed diffs, tests, and evidence packets.
- Required: deterministic AI config and run metadata when agents are used.
- Gate: no silent apply; all mutating work is reviewable.

### E — PR and sandbox validation

- Artifacts: PR body, preview/staging URL, evidence links.
- Required: flag strategy and rollback plan.
- Gate: required CI jobs and tier-aligned evidence.

### F — CI gates

- `T1`: lint/type/unit/secret scan/SBOM + receipt digest.
- `T2`: `T1` + contract/security checks + preview smoke + observability check.
- `T3`: `T2` + full STRIDE, verifier/recovery attestations, watch-window plan.

### G — Merge

- Required: protected-branch checks + review policy satisfied.
- Gate: merge blocked on any required gate failure.

### H — Promotion

- Required: ACP outcome + complete evidence + rollback-ready posture.
- Gate: promotion blocked on missing ACP receipt or unresolved escalation.

### I — Operate

- Required: SLO monitoring, error-budget controls, incident handling.
- Gate: freeze risky merges/promotions when burn-rate thresholds are breached.

### J — Learn

- Required: postmortem/retro outputs and ADR updates where applicable.
- Gate: unresolved high-severity findings feed next planning cycle.

## 4) File tree (minimum surfaces)

This tree is a reference profile, not a rigid repository requirement.
Equivalent layouts are acceptable when they preserve the same methodology
surfaces, governance contracts, and gate evidence paths.

```text
/docs/specs/<feature>/
/docs/implementation/<feature>.md
/docs/alignment/<feature>.md
/docs/security/<feature>/
/docs/sre/<feature>/
/packages/kits/{speckit,plankit,flowkit}/
/packages/contracts/
.github/workflows/
.harmony/cognition/practices/methodology/
```

## 5) Concrete snippets (minimal)

### Tier-to-ACP mapping

```yaml
tier_to_acp:
  1: ACP-1
  2: ACP-2
  3: ACP-3
```

### Profile governance receipt fields

```yaml
profile_selection_receipt:
  change_profile: atomic|transitional
  release_state: pre-1.0|stable
  selection_facts:
    downtime_tolerance: ""
    external_consumer_coordination: ""
    migration_or_backfill_required: false
    rollback_mechanism: ""
    blast_radius_and_uncertainty: ""
    compliance_or_policy_constraints: ""
  transitional_exception_note:
    required_when: "release_state=pre-1.0 && change_profile=transitional"
    rationale: ""
    risks: ""
    owner: ""
    target_removal_date: ""
```

### Gate policy sketch

```yaml
gates:
  t1: [lint, typecheck, unit, secret_scan, sbom]
  t2: [t1, contract_checks, security_checks, preview_smoke, observability]
  t3: [t2, full_stride, verifier_attestation, recovery_attestation, watch_window]
```

## 6) Command cookbook (copy‑paste)

```bash
# Validate methodology alignment
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,framing

# Validate deterministic output surface assumptions
rg -n "change_profile|release_state|Profile Selection Receipt" .harmony/cognition/practices/methodology

# Validate tier template contracts are parseable
ruby -ryaml -e 'Dir[".harmony/cognition/practices/methodology/templates/spec-tier*.yaml"].each { |f| YAML.load_file(f); puts "OK #{f}" }'

# Validate methodology index path integrity
awk '/^[[:space:]]*path:[[:space:]]*/{print $2}' .harmony/cognition/practices/methodology/index.yml | sed 's/"//g' | while read -r p; do [ -e ".harmony/cognition/practices/methodology/$p" ] || echo "MISSING $p"; done
```

## 7) Operating Rules (one page)

- Record exactly one profile (`atomic` or `transitional`) before implementation.
- Derive `release_state` from `version.txt` (`pre-1.0` when `<1.0.0` or prerelease).
- In `pre-1.0`, default to `atomic`; `transitional` requires explicit exception note with owner and target removal date.
- Align tier semantics to `T1/T2/T3` only; do not use alternate risk taxonomies.
- Keep rollout policy provider-agnostic; use platform-native preview/promote/rollback primitives.
- Treat migrations and audits as governed doctrine surfaces with key-level CI checks.
- Ensure all methodology markdown artifacts include metadata: `owner`, `audience`, `scope`, `last_reviewed`, `canonical_links`.

## Stop‑the‑line triggers (enforced)

- Missing profile receipt fields before implementation.
- Missing ACP receipt outcome for promotion decisions.
- Missing rollback plan or missing feature-flag control for tier-required changes.
- Missing observability evidence for changed flows where required.
- Security/secret-scan failures, unresolved high-severity policy violations.
- Transitional profile in `pre-1.0` without complete `transitional_exception_note`.

## Canonical References

- `AGENTS.md`
- `/.harmony/agency/governance/CONSTITUTION.md`
- `/.harmony/agency/governance/DELEGATION.md`
- `/.harmony/agency/governance/MEMORY.md`
- `/.harmony/cognition/practices/methodology/authority-crosswalk.md`
- `/.harmony/cognition/practices/methodology/risk-tiers.md`
- `/.harmony/cognition/practices/methodology/ci-cd-quality-gates.md`
