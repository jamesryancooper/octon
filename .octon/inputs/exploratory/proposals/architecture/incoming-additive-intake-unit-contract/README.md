# Incoming Additive Intake Unit Contract

_Status: Draft architecture proposal_

This packet proposes the smallest durable contract for
`.octon/inputs/additive/.incoming/<intake-id>/` units. It remains
non-authoritative proposal input until promoted through the listed durable
Octon targets.

## Recommendation

Define only a partial and minimal intake-unit shape: a required
non-authoritative envelope plus a required raw payload root. Do not require
incoming units to already be normalized extension packs, core skills, retained
evidence, generated output, runtime state, publication material, or
host-projection sources.

## Purpose

An incoming additive intake unit exists to preserve raw candidate material long
enough for governed classification and disposition. Before classification, the
unit must identify what was staged, why it was staged, where the raw payload is,
what provenance is known, and which risks are visible. It must not claim that
the payload is installable, trusted, normalized, active, published, or retained
evidence.

## Proposed Layout

```text
.octon/inputs/additive/.incoming/<intake-id>/
  intake.yml
  payload/
  README.md
```

`intake.yml` and `payload/` are required. `README.md` is optional and
non-authoritative. All payload content remains under `payload/` and is treated
as raw source material until a governed lifecycle step creates durable artifacts
outside `.incoming/**`.

## Authority Boundaries

- `.incoming/**` and `.archive/**` are raw input zones only.
- Incoming metadata is intake bookkeeping, not runtime or policy authority.
- Candidate extension packs or skill bundles inside `payload/` are opaque raw
  payloads until classification and normalization admit them.
- Archive movement or retention evidence requires separate governed
  disposition and cannot be inferred from this proposed shape.

## Promotion Targets

- `.octon/framework/cognition/_meta/architecture/inputs/README.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/`
- `.octon/framework/engine/governance/inputs/additive/`
- `.octon/framework/capabilities/runtime/commands/process-incoming-intake.md`
- `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/README.md`
- `.octon/inputs/additive/README.md`
- `.octon/inputs/additive/.incoming/README.md`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/current-state-gap-map.md`
5. `architecture/implementation-plan.md`
6. `architecture/acceptance-criteria.md`
7. `validation-plan.md`
8. `RISK-REGISTER.md`
9. `support/implementation-grade-completeness-review.md`
