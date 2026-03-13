---
title: Agent Runtime Caveats and Mitigations
description: Risk model for agent-as-runtime adoption, including operational caveats, required controls, and residual risk posture.
---

# Agent Runtime Caveats and Mitigations

Related docs: [agent-as-runtime model](./agent-as-runtime.md), [governance model](./governance-model.md), [runtime policy](./runtime-policy.md), [runtime architecture](./runtime-architecture.md)

## Purpose and Scope

This document captures the caveats of the agent-as-runtime model and defines required mitigations. It is normative for risk treatment when harness interpretation depends on agent-hosted semantic evaluation.

The caveats in this document are not reasons to reject the model. They are the control surface that keeps the model safe, auditable, and operationally practical.

## Risk Scoring Method

Each caveat is scored with:

- Likelihood: `1` (rare) to `5` (frequent)
- Impact: `1` (minor) to `5` (severe)
- Inherent risk score: `likelihood x impact` before mitigation
- Residual risk score: score after required controls are in place

Residual score targets:

- `1-4` low
- `5-9` medium
- `10-16` high
- `17-25` critical

## Risk Summary Table

| # | Caveat | Inherent Risk | Primary Mitigation | Residual Risk |
|---|---|---:|---|---:|
| 1 | Non-determinism in semantic interpretation | 16 | Fixture-calibrated acceptance and deterministic Tier 1 baseline | 9 |
| 2 | No semantic CI when agent/model unavailable | 15 | Tiered validation with deterministic Tier 1 always-on | 8 |
| 3 | Latency from repeated semantic evaluation | 12 | Content-hash caching and incremental scope evaluation | 6 |
| 4 | Cost volatility from model-dependent checks | 12 | Risk-based execution policy and budgeted run schedules | 7 |
| 5 | Weak auditability without structured evidence | 15 | Mandatory run records with traceable metadata | 6 |
| 6 | Offline or degraded-network operation gaps | 10 | Graceful degradation to Tier 1 and deferred semantic queue | 6 |
| 7 | Cross-agent capability variance | 16 | Compatibility profiles and conformance fixture packs | 8 |
| 8 | Reproducibility drift across agent/model versions | 20 | Pinned metadata capture and versioned rules/fixtures | 9 |

## Residual Risk Matrix

| Caveat # | Likelihood (Residual) | Impact (Residual) | Residual Score | Residual Band |
|---|---:|---:|---:|---|
| 1 | 3 | 3 | 9 | Medium |
| 2 | 2 | 4 | 8 | Medium |
| 3 | 2 | 3 | 6 | Medium |
| 4 | 2 | 3 | 6 | Medium |
| 5 | 2 | 3 | 6 | Medium |
| 6 | 3 | 2 | 6 | Medium |
| 7 | 2 | 4 | 8 | Medium |
| 8 | 3 | 3 | 9 | Medium |

Residual posture target for this model is medium-or-lower when all controls in this document are implemented.

## Caveat 1: Non-Determinism

### Problem

Semantic interpretation by an agent can vary across model versions, providers, and execution contexts.

### Impact

- Inconsistent policy outcomes across environments.
- Flaky semantic gates.
- Erosion of trust in automated checks.

### Required Mitigations

- Keep deterministic Tier 1 as a mandatory baseline gate.
- Require fixture-calibrated semantic evaluation for Tier 2.
- Include positive, negative, and edge-case fixtures for every governed contract.
- Fail closed on ambiguous semantic outcomes unless waived explicitly.

### Required Evidence

- Fixture pass/fail summary.
- Rule-set version and contract hash in run record.

### Residual Risk

Semantic variation remains possible, but bounded by fixtures and deterministic structural constraints.

## Caveat 2: No Semantic CI Without Agent Availability

### Problem

If agent/model execution is unavailable, semantic checks cannot run.

### Impact

- Incomplete quality signal in CI windows.
- Potential merge delays or policy bypass pressure.

### Required Mitigations

- Split validation into deterministic Tier 1 and semantic Tier 2.
- Make Tier 1 mandatory for every PR.
- Require Tier 2 on protected branch and release paths.
- Define controlled degrade mode: no release promotion without either Tier 2 success or explicit waiver.

### Required Evidence

- Tier 1 result artifact with deterministic validator output.
- Tier 2 status artifact or waiver record with approver and expiration.

### Residual Risk

Availability incidents can still delay semantic validation, but deterministic checks continue and governance remains explicit.

## Caveat 3: Speed

### Problem

Repeated semantic evaluation on unchanged inputs increases cycle time.

### Impact

- Slower PR feedback.
- Reduced developer throughput.

### Required Mitigations

- Content-hash caching for contracts, rules, and fixtures.
- Incremental evaluation scoped to changed files/services.
- Early Tier 1 fail-fast to avoid unnecessary Tier 2 runs.

### Required Evidence

- Cache hit/miss metrics in run records.
- Changed-scope manifest for each semantic run.

### Residual Risk

Cold-cache and large cross-cutting changes still incur latency.

## Caveat 4: Cost

### Problem

Agent/model evaluation introduces variable compute/token costs.

### Impact

- Budget unpredictability.
- Pressure to disable needed checks.

### Required Mitigations

- Risk-tiered execution policy (always-on where risk is high, sampled/triggered where low).
- Run Tier 2 where it matters most (protected branches, release gates, high-risk changes).
- Track per-run cost metrics and enforce budget thresholds.

### Required Evidence

- Cost fields in run records (model, usage, estimated spend).
- Periodic budget reports with variance explanations.

### Residual Risk

Price and workload volatility can still shift costs; budget controls limit unexpected spend.

## Caveat 5: Auditability

### Problem

Without standardized evidence, semantic decisions are not explainable or reviewable.

### Impact

- Difficult incident review.
- Weak compliance posture.
- Low confidence in agent-driven gates.

### Required Mitigations

- Mandatory run records for semantic checks.
- Standardized fields for identity, inputs hash, outputs summary, determinism metadata, and trace IDs.
- Retention and queryability requirements for run artifacts.

### Required Evidence

- Run record artifacts aligned to `.octon/capabilities/practices/services-conventions/run-records.md`.
- Trace correlation from PR to run record to CI check.

### Residual Risk

Evidence quality can degrade if conventions are not enforced; governance must periodically audit record completeness.

## Caveat 6: Offline Operation

### Problem

Semantic evaluation may not be available in offline or restricted-network environments.

### Impact

- Incomplete local validation.
- Deferred risk discovery.

### Required Mitigations

- Ensure Tier 1 is fully offline-capable.
- Support deferred Tier 2 execution when connectivity resumes.
- Mark semantic status explicitly as pending when offline.

### Required Evidence

- Tier 1 local artifact.
- Deferred semantic job queue entry or explicit offline status marker.

### Residual Risk

Some semantic regressions may surface later than ideal, but pending status remains visible and auditable.

## Caveat 7: Agent Compatibility Variance

### Problem

Different agent hosts expose different tool surfaces and behavior.

### Impact

- Inconsistent outcomes across host environments.
- Portability regressions despite content portability goals.

### Required Mitigations

- Declare compatibility profile per contract.
- Restrict required behavior to minimum tool surface (`read`, `glob`, `grep`, `bash`).
- Maintain conformance fixture packs for cross-host verification.

### Required Evidence

- Compatibility profile artifact.
- Conformance run results per supported host class.

### Residual Risk

Host differences still exist in optional features, but core behavior remains bounded by profile and conformance checks.

## Caveat 8: Reproducibility

### Problem

Agent/model and prompt changes can alter generation/evaluation outcomes over time.

### Impact

- Hard-to-reproduce historical decisions.
- Drift in generated implementations.

### Required Mitigations

- Version rules and fixtures as first-class artifacts.
- Capture pinned provenance metadata for generated implementations:
  - `contract_version`, `contract_hash`, `fixture_set_hash`, `rule_set_hash`
  - `agent_id`, `agent_version`, `model_id`, `prompt_hash`, `tool_surface_version`
  - `generated_at`
- Treat missing provenance metadata as a policy failure.

### Required Evidence

- `impl/generated.manifest.json` for generated implementations.
- Run records containing determinism/provenance fields.

### Residual Risk

Perfect replay is not guaranteed for semantic steps, but drift is measurable and governable.

## Control Checklist

Agent-as-runtime should not be considered production-ready unless all items below are true:

- Deterministic Tier 1 validator contract is implemented and enforced.
- Tier 2 is fixture-calibrated and fail-closed by default.
- Compatibility profiles exist for governed services.
- Conformance fixture packs run for supported host classes.
- Run records capture required provenance/evidence fields.
- Waiver process is explicit, auditable, and time-bounded.

## Operational Ownership

Suggested ownership model:

- Platform/architecture: compatibility profile standard, Tier 1 contract, conformance strategy.
- Service owners: contract completeness, fixture quality, semantic rule quality.
- Governance/release owners: waiver review, residual risk acceptance, periodic evidence audits.

## Summary

The caveats in the agent-as-runtime model are manageable when controls are explicit and evidence-backed. The key strategy is not to force semantic determinism where it is unrealistic; it is to bound variance with deterministic structure, fixtures, provenance, and governance.
