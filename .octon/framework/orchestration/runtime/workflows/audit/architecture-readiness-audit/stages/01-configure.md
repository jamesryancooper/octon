---
name: configure
title: "Configure Architecture Readiness Audit Workflow"
description: "Parse parameters and build a bounded execution plan with deterministic controls."
---

# Step 1: Configure Architecture Readiness Audit Workflow

## Input

- `target_path` (required)
- `severity_threshold` (default `all`)
- `run_cross_subsystem` (default `true`)
- `run_domain_architecture` (default `true`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Build an explicit execution plan and done-gate mode before any stage runs.

## Actions

1. Validate `target_path` exists and is readable.
2. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`).
3. Record requested supplemental stages without deciding applicability yet.
4. Persist bounded execution plan.
5. Record the selected review method id in run evidence (see below).
6. Load `.octon/instance/governance/policies/external-tool-integrity.yml`.

## Method selection (advisory, non-authority)

Select exactly one review method and record it in run evidence.
`balanced-architecture-review-method` is the default when no method is chosen;
recording it preserves the pre-suite behavior. Per the `review-routing.yml`
`method_selection` layer, `failure-mode-review-method` is the advised companion
for this occasion when runtime or governance failure behavior is in doubt.
Record the selected method id (`method`, bound to the `naming.yml`
methods.catalog) and the applied lens profile (`lenses_applied`, bound to
`lens-bank.yml`) through the `architectural-review-routing-decision-v2` artifact
(`routing-decision.yml`) in the existing run-evidence root
`.octon/state/evidence/runs/workflows/{run_id}/architectural-review/architecture-readiness-audit/`.
Method selection creates no lifecycle gate, grants the readiness output no
authority, and leaves the readiness verdict semantics and done-gate unchanged.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Deterministic controls are recorded
- [ ] Selected review method id is recorded in run evidence
