# ADR 026: Engine Bounded Surfaces Clean-Break Migration

- Date: 2026-02-20
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: top-level runtime domain structure in active harness docs and validators

## Context

The harness previously used a top-level `/.octon/runtime/` domain for executable runtime artifacts. The repository is moving to explicit bounded surfaces (`runtime`, `governance`, `practices`) where that separation is materially present and independently owned.

For the runtime domain itself, keeping `runtime` as both top-level domain and internal surface would create ambiguous naming and ownership boundaries. A clean break to `engine/` provides a stable parent boundary while preserving `runtime/` as the executable surface.

## Decision

Adopt `/.octon/engine/` as the top-level domain and enforce these canonical surfaces:

- `/.octon/engine/runtime/` for executable authority
- `/.octon/engine/governance/` for normative runtime policy/contracts
- `/.octon/engine/practices/` for operating standards
- `/.octon/engine/_ops/` for mutable operational assets
- `/.octon/engine/_meta/` for architecture/evidence documentation

Remove `/.octon/runtime/` in the same migration and update validators/CI references to fail on legacy reintroduction.

## Consequences

### Benefits

- Clear separation between executable runtime authority and normative/operational documentation.
- Better long-term correctness: path resolution and contract checks target one canonical domain.
- Stronger migration enforcement via explicit legacy-path ban and validator checks.

### Risks

- Path churn across scripts/docs/workflows can miss edge references.
- Historical records continue to mention old paths and may create confusion.

### Mitigations

- Apply one-shot replacement for active call-sites and validators in the same change set.
- Enforce deprecated-path checks in harness validation.
- Keep historical references in append-only records, while keeping active docs canonical.
