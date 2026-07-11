---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Executive Overview

## Purpose

This package lets an external architect verify the proposed Octon Public
Distribution Model without treating the conversation, this intake, or the
proposal program as authority.

## Problem

The current repository combines canonical Octon framework development,
repository-specific authority, raw inputs, operational state, retained
evidence, generated outputs, host projections, and release automation. That
shape is useful for self-hosting development but is not a safe public
distribution boundary.

## Proposed Answer

**Sponsor decision:** Keep the full development workspace private and produce a
separate public `octon` repository from a deterministic, exact-commit,
allowlist-only `portable_dropin` artifact. The public repository has synthetic
history and contains only publication-cleared portable core, neutral bootstrap
material, and reviewed public-repository-only files.

**Sponsor decision:** Downstream projects commit an exact core lock and their
own authority. They verify and materialize core locally. Updates may change only
core-owned paths.

**Sponsor decision:** Runtime state, raw evidence, generated output, caches,
logs, and host projections remain local by default. Hosted Git receives only
durable authored material and minimum classified receipts needed for a real
collaboration, governance, release, recovery, or retention requirement.

## Architectural Verdict

**Confirmed repository evidence:** Octon's class-root architecture already
distinguishes portable framework, repository instance authority,
non-authoritative input, mutable state and evidence, and generated output.

**Recommendation:** Treat the architecture as partly aligned. The conceptual
roots support the target, but profiles, export behavior, bootstrap, downstream
delivery, evidence semantics, Git posture, and release controls must be
implemented or narrowed before publication.

**Assumption:** Repository and hosted-platform evidence is a point-in-time
snapshot from 2026-07-09. The external architect must re-run material checks
before relying on them for implementation or release.

**Unresolved human judgment:** The maintainer must still approve exposure
disposition, exact component clearance, any ambiguous rights or name risk,
repository operations, first public-tree push, and final publication.

## Review Status

The implementation program `octon-public-distribution-model` is
`in-review`. It is not accepted and has not implemented, migrated, pushed, or
published anything. The external architect should independently challenge every
claim in the verification checklist.

Primary sources: `SRC-001` through `SRC-019`. Program context:
`.octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model/`.
