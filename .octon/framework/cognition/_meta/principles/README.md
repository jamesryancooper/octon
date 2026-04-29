# Principles Support Docs

Non-structural support documentation for the principles subsystem.

## Purpose

- Keep non-normative support and compatibility pointers out of structural governance roots.
- Preserve governance surfaces (`principles/`, `controls/`, `exceptions/`) for canonical policy contracts.

## Canonical Index

- `index.yml` - machine-readable discovery index for principles support docs.

## Contents

| File | Purpose |
|---|---|
| `waivers-and-exceptions.md` | Legacy pointer to the canonical governance exception contract. |

## Canonical Governance Controls

RA/ACP governance control contracts now live in:

- `.octon/framework/cognition/governance/controls/ra-acp-glossary.md`
- `.octon/framework/cognition/governance/controls/ra-acp-promotion-inputs-matrix.md`
- `.octon/framework/cognition/governance/controls/flag-metadata-contract.md`
- `.octon/framework/cognition/governance/controls/promotable-slice-decomposition.md`

## Canonical Governance Exception Contract

Waiver and exception taxonomy now lives in:

- `.octon/framework/cognition/governance/exceptions/waivers-and-exceptions.md`

## Structural Boundary

Do not place canonical principle contracts in this directory.
Canonical principles remain under:

- `.octon/framework/cognition/governance/principles/*.md`

## Lifecycle Framing Support

The principles support layer now indexes the live governed autonomy lifecycle
framing by canonical surface name: Safe Start, Safe Continuation, Continuous
Stewardship, Connector Admission Runtime, Constitutional Self-Evolution, and
Federated Trust. This directory remains support-only; it does not authorize
execution, widen support, promote proposals, or accept imported proof.
