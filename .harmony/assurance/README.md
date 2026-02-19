# Assurance

Assurance is Harmony's legitimacy layer. It formalizes how quality, governance,
and trust combine into enforceable policy and auditable outcomes.

## Purpose

The Assurance subsystem defines and enforces:

- standards and measurable quality attributes
- policy precedence and override governance
- gate execution for local and CI enforcement
- auditability through evidence, attestations, and logs

Quality remains a measured dimension. Assurance is the system that governs and
proves legitimacy.

## Enforcement Engine

The local resolver and gate tooling is the authoritative assurance engine:

- policy source: `standards/weights/weights.yml`
- measurement source: `standards/scores/scores.yml`
- governance controls: `governance/*`
- execution entrypoints:
  `_ops/scripts/compute-assurance-score.sh` and `_ops/scripts/assurance-gate.sh`
- generated evidence: `.harmony/output/assurance/`

## Charter-Driven Flow

1. `CHARTER.md` defines priority and trade-off intent.
2. `standards/weights/weights.yml` defines policy weights.
3. `standards/scores/scores.yml` defines measured subsystem scores.
4. `_ops/scripts/compute-assurance-score.sh` resolves effective policy.
5. `_ops/scripts/assurance-gate.sh` enforces gates and drift checks.
6. Outputs and evidence are written under `../output/assurance/`.

Active umbrella chain:

`Assurance > Productivity > Integration`

Breaking-change note:

The legacy chain (`Trust > Speed of development > Ease of use > Portability >
Interoperability`) is no longer supported.

## Contents

| Path | Purpose |
|---|---|
| `CHARTER.md` | Charter-level policy intent and umbrella priority chain |
| `CHANGELOG.md` | Assurance subsystem release and breaking-change notes |
| `DOCTRINE.md` | Assurance rationale, scope, and subsystem relationships |
| `complete.md` | Definition of done checklist |
| `session-exit.md` | Session exit checklist |
| `standards/` | Standards and score/weight sources of truth |
| `governance/` | Precedence and override governance contracts |
| `governance/precedence.md` | Canonical precedence and merge-order contract |
| `trust/` | Attestations, evidence, and audit folders |
| `_ops/scripts/alignment-check.sh` | Profile-based alignment checks |
| `_ops/scripts/validate-harness-structure.sh` | Harness structure and discovery checks |
| `_ops/scripts/validate-audit-subsystem-health-alignment.sh` | Drift guardrail for audit-subsystem-health |
| `_ops/scripts/validate-commit-pr-alignment.sh` | Drift guardrail for commit/PR governance |
| `_ops/scripts/compute-assurance-score.sh` | Effective-weight and scorecard computation |
| `_ops/scripts/assurance-gate.sh` | Gate decision and warning/fail enforcement |

## Contract

- Read `complete.md` before marking work complete.
- Read `session-exit.md` before ending session or handoff.
- Treat Assurance artifacts as contract surfaces, not optional guidance.
