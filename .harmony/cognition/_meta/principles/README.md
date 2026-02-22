# Principles Support Docs

Non-structural support documentation for the principles subsystem.

## Purpose

- Keep non-normative support and compatibility pointers out of structural governance roots.
- Preserve governance surfaces (`principles/`, `controls/`, `exceptions/`) for canonical policy contracts.

## Contents

| File | Purpose |
|---|---|
| `waivers-and-exceptions.md` | Legacy pointer to the canonical governance exception contract. |

## Canonical Governance Controls

RA/ACP governance control contracts now live in:

- `.harmony/cognition/governance/controls/ra-acp-glossary.md`
- `.harmony/cognition/governance/controls/ra-acp-promotion-inputs-matrix.md`
- `.harmony/cognition/governance/controls/flag-metadata-contract.md`
- `.harmony/cognition/governance/controls/promotable-slice-decomposition.md`

## Canonical Governance Exception Contract

Waiver and exception taxonomy now lives in:

- `.harmony/cognition/governance/exceptions/waivers-and-exceptions.md`

## Structural Boundary

Do not place canonical principle contracts in this directory.
Canonical principles remain under:

- `.harmony/cognition/governance/principles/*.md`
