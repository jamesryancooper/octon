# Principles Support Docs

Non-structural support documentation for the principles subsystem.

## Purpose

- Keep supporting governance/reference material out of structural roots.
- Preserve `principles/` root for canonical principle contracts.

## Contents

| File | Purpose |
|---|---|
| `flag-metadata-contract.md` | Canonical flag metadata requirements used by principles. |
| `promotable-slice-decomposition.md` | Decomposition guidance for promotable slices and small-batch changes. |
| `ra-acp-glossary.md` | Shared RA/ACP terminology and definitions. |
| `ra-acp-promotion-inputs-matrix.md` | Canonical promotion input and evidence matrix. |
| `waivers-and-exceptions.md` | Waiver and exception taxonomy for principle governance. |

## Structural Boundary

Do not place canonical principle contracts in this directory.
Canonical principles remain under:

- `.harmony/cognition/governance/principles/*.md`
