# ADR 037: Artifact Surface Clean-Break Rename

- Date: 2026-02-22
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: `/.octon/cognition/_meta/architecture/content-plane/` naming and path authority

## Context

Octon no longer treats publishing/content concerns as foundational planes.
Recent architecture changes established governance, runtime, continuity, and
knowledge as foundational planes while publication concerns remain optional.

The remaining optional architecture corpus still used the legacy
`content-plane` name, legacy path, and content-plane terminology, causing
conceptual drift and avoidable ambiguity.

## Decision

Adopt `artifact-surface` as the sole canonical name and path for the optional
artifact publication architecture corpus.

This clean-break includes:

- Directory rename:
  - `/.octon/cognition/_meta/architecture/content-plane/`
  - ->
  - `/.octon/cognition/_meta/architecture/artifact-surface/`
- Runtime layer doc rename:
  - `runtime-content-layer.md`
  - ->
  - `runtime-artifact-layer.md`
- Terminology canonicalization across active architecture docs:
  - `Content Plane` -> `Artifact Surface`
  - `HCP` -> `HAS`
  - `Octon Content Graph` -> `Octon Artifact Graph`
- Cross-surface call-site updates:
  - continuity plane integration contract
  - knowledge-plane related-doc links
  - optional-surface references in active docs
- No compatibility alias retained for the removed `content-plane` path.

## Consequences

### Benefits

- Removes naming drift between foundational-plane contracts and optional
  publication architecture docs.
- Establishes explicit artifact-oriented terminology aligned with bounded
  surfaces and migration governance.
- Simplifies discovery by keeping a single optional-surface identifier/path.

### Risks

- Existing links to `content-plane` paths will fail.
- Historical references can be reintroduced if validators/banlist are not
  updated.

### Mitigations

- One-shot call-site migration across active docs in the same change set.
- Add legacy-banlist entries for removed `content-plane` path and
  `runtime-content-layer.md` file path.
- Record migration evidence bundle and runtime indexes updates.
