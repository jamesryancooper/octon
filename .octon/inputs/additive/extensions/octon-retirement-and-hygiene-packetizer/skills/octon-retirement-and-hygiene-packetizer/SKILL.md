---
name: octon-retirement-and-hygiene-packetizer
description: >
  Composite extension-pack skill that routes repo-hygiene and retirement
  planning inputs to the appropriate additive draft flow.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Retirement And Hygiene Packetizer

Resolve one retirement or hygiene planning route and dispatch to the matching
leaf skill.

## Bundle Matrix

- `scan-to-reconciliation` - summary-grade hygiene scan plus retirement
  coverage reconciliation
- `audit-to-packet-draft` - audit-backed cleanup packet draft and optional
  migration proposal draft
- `registry-gap-analysis` - coverage, staleness, and contradiction review for
  retirement-registry and retirement-register data
- `ablation-plan-draft` - non-authoritative ablation-plan drafting with
  protected-surface guardrails

## Core Workflow

1. Normalize composite dispatcher inputs into one routing payload.
2. Resolve the published route with `resolve-extension-route.sh`.
3. Return the route receipt immediately when `dry_run_route=true`.
4. Stop on any non-`resolved` routing outcome.
5. Execute the selected leaf skill and retain summary artifacts under
   `/.octon/state/evidence/runs/skills/`.

## Outputs

- route receipt when routing is previewed or blocked
- flow-specific non-authoritative draft outputs
- retained run evidence under
  `/.octon/state/evidence/runs/skills/octon-retirement-and-hygiene-packetizer/`
- optional checkpoints under
  `/.octon/state/control/skills/checkpoints/octon-retirement-and-hygiene-packetizer/`
- optional migration proposal draft under
  `/.octon/inputs/exploratory/proposals/migration/<proposal_id>/`

## Boundaries

- Additive only. Do not mint authority from raw pack paths.
- Reuse `repo-hygiene`, retirement registry, retirement register, closeout
  reviews, ablation workflow, and claim gate as authoritative reads only.
- Never update `retirement-registry.yml`, `retirement-register.yml`,
  `closeout-reviews.yml`, `claim-gate.yml`, or build-to-delete receipts.
- Never auto-delete, auto-demote, auto-register, or auto-packetize into the
  live build-to-delete packet.
- Rewrite any delete-safe signal into a governed ablation-review candidate in
  extension-authored outputs.
- Force protected or claim-adjacent surfaces to `never-delete`.

## References

- `references/io-contract.md`
- `references/boundary.md`
- `references/evidence-map.md`
