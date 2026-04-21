# Proposal-Local Source-of-Truth Map

## Packet status

This proposal packet is non-authoritative because it lives under `/.octon/inputs/exploratory/proposals/**`. It may guide human review and promotion work, but it must not be referenced directly by runtime or policy code.

## Proposal-local reading precedence

1. `proposal.yml` — packet lifecycle, scope, and promotion targets.
2. `architecture-proposal.yml` — target-state decisions and current-state disposition.
3. `architecture/target-architecture.md` — human-readable target-state design.
4. `architecture/file-change-map.md` — path-specific remediation map.
5. `architecture/implementation-plan.md` and `architecture/validation-plan.md` — execution and validation programs.
6. `resources/full-architectural-evaluation.md` — mandatory evaluation source artifact.
7. Other resource files — supporting traceability, risk, evidence, and decision plans.

If proposal files conflict, `proposal.yml` and `architecture-proposal.yml` govern proposal lifecycle and intended promotion. They still do not become Octon runtime authority.

## Repo authority outside this packet

The proposal must preserve the following hierarchy:

| Class/root | Role |
|---|---|
| `/.octon/framework/**` | Portable authored framework authority and runtime contracts. |
| `/.octon/instance/**` | Repo-specific durable authored authority. |
| `/.octon/state/control/**` | Mutable operational control truth. |
| `/.octon/state/evidence/**` | Retained proof, receipts, replay, validation evidence. |
| `/.octon/state/continuity/**` | Active continuity and handoff state. |
| `/.octon/generated/**` | Derived read/effective models only; never source of truth. |
| `/.octon/inputs/**` | Non-authoritative proposals, exploratory inputs, and raw additive material. |

## Required promotion rule

Any durable remediation must be promoted to a proper authored, control, evidence, or generated-read-model target outside this packet. Direct runtime reads from this packet are invalid.

## Non-authoritative projections

Generated operator views, CI comments, GitHub checks, host labels, chat summaries, and proposal registries may mirror state but never mint authority. The target-state proposal strengthens that rule by requiring consistency validators and promotion receipts.
