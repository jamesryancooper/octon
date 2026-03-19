# Assurance

Assurance is Octon's legitimacy layer. It formalizes how quality, governance,
and trust combine into enforceable policy and auditable outcomes.

## Purpose

The Assurance subsystem defines and enforces:

- standards and measurable quality attributes
- policy precedence and override governance
- gate execution for local and CI enforcement
- auditability through evidence, attestations, and logs

Quality remains a measured dimension. Assurance is the system that governs and
proves legitimacy.

## Bounded Surfaces

Assurance follows bounded surfaces with three canonical authorities:

- `runtime/` - executable assurance engine entrypoints and trust artifact
  runtime surfaces.
- `governance/` - normative assurance contracts, policy weights/scores, and
  override governance.
- `practices/` - operating checklists and assurance standards for human/agent
  execution discipline.

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.octon/instance/bootstrap/conventions.md`.

## Enforcement Engine

The local resolver and gate tooling is the authoritative assurance engine:

- policy source: `governance/weights/weights.yml`
- measurement source: `governance/scores/scores.yml`
- governance controls: `governance/*`
- execution entrypoints:
  `runtime/_ops/scripts/compute-assurance-score.sh` and
  `runtime/_ops/scripts/assurance-gate.sh`
- generated evidence: `.octon/generated/assurance/`

## Charter-Driven Flow

1. `governance/CHARTER.md` defines priority and trade-off intent.
2. `governance/weights/weights.yml` defines policy weights.
3. `governance/scores/scores.yml` defines measured subsystem scores.
4. `runtime/_ops/scripts/compute-assurance-score.sh` resolves effective policy.
5. `runtime/_ops/scripts/assurance-gate.sh` enforces gates and drift checks.
6. Generated assurance outputs are written under `.octon/generated/assurance/`,
   with validation evidence retained under `.octon/state/evidence/validation/`.

Active umbrella chain:

`Assurance > Productivity > Integration`

Breaking-change note:

The legacy chain (`Trust > Speed of development > Ease of use > Portability >
Interoperability`) is no longer supported.

## Contents

| Path | Purpose |
|---|---|
| `runtime/` | Runtime assurance execution surfaces and trust artifacts |
| `runtime/_ops/scripts/` | Assurance engine and alignment validator entrypoints |
| `runtime/trust/` | Attestations, evidence, and audit artifact surfaces |
| `governance/` | Charter, doctrine, changelog, precedence, and override contracts |
| `governance/weights/` | Policy weights and context contract |
| `governance/scores/` | Measured score inputs and evidence mapping |
| `governance/precedence.md` | Canonical precedence and merge-order contract |
| `practices/` | Completion/exit gates and operating standards |
| `practices/complete.md` | Definition of done checklist |
| `practices/session-exit.md` | Session exit checklist |

## Contract

- Read `practices/complete.md` before marking work complete.
- Read `practices/session-exit.md` before ending session or handoff.
- Treat Assurance artifacts as contract surfaces, not optional guidance.
