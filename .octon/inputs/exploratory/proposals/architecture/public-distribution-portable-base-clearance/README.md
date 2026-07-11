# Public Distribution Portable Base Clearance

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

Framework is portable by architectural role but the current repository has no license, notice, provenance, SBOM, or publication-clearance surface. Exporting the whole framework root would exceed the smallest maintainable first-release closure and could publish uncleared or unnecessary material.

## Confirmed Current Evidence

- **Confirmed evidence:** The framework manifest lists broad subsystems but not an export component dependency closure.
- **Confirmed evidence:** No repository license, notice, provenance, clearance, or SBOM files were found in the reviewed surfaces.
- **Confirmed evidence:** The framework currently contains thousands of tracked files, executable scripts, Rust/runtime material, templates, fixtures, prompts, examples, and documentation.
- **Confirmed evidence:** The adopted baseline requires Apache-2.0 core coverage and MIT-0 only for designated neutral copy-out templates.

## Target Outcome

Create component-level dependency and clearance records so portable_dropin can export only the smallest dependency-closed, publication-cleared base with zero unknown paths.

## Scope

- Decompose the promised workflows into explicit export components and dependencies.
- Record component-level origin, AI assistance, license coverage, sensitivity review, and publication status.
- Define the path-override mechanism but keep it inactive: the first release permits zero provenance exceptions (PD-024 governs) until a maintainer baseline revision activates the PD-008 override path.
- Define quarantine and exclusion for unknown or ambiguous origin.

## Non-Goals

- No unsupported legal conclusion or provenance exception.
- No additive packs or project-specific examples in the base.
- No public release, trademark registration, or separately managed signing key.

## Adopted Decisions Implemented

- **Sponsor decision:** First release is the smallest dependency-closed portable base that delivers promised workflows.
- **Sponsor decision:** All exported framework content requires publication, provenance, sensitivity, and license clearance.
- **Sponsor decision:** Apache-2.0 covers core; MIT-0 applies only to designated neutral copy-out templates.
- **Sponsor decision:** AI-assisted work is a provenance category, not automatic exclusion or clearance.
- **Sponsor decision:** Unknown or ambiguous external origin blocks export.

## Superseded Approaches

- **Removed or superseded:** Exporting all framework files solely because they live under framework.
- **Removed or superseded:** Allowing first-release provenance exceptions.
- **Removed or superseded:** Maintaining unbounded file-by-file provenance when component inheritance is sufficient.
- **Removed or superseded:** Adding third-party notices without an actual obligation.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.

