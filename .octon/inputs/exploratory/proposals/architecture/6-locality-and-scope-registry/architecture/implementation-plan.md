# Implementation Plan

This proposal does not introduce a second locality system. It ratifies and
hardens the root-owned direction already visible in the live repository so
later packets can depend on one deterministic scope registry and one
fail-closed resolution pipeline.

## Workstream 1: Lock The Locality Control Surfaces

- Keep `instance/manifest.yml` as the repo-side locality binding surface.
- Normalize `instance/locality/manifest.yml` as the required locality control
  manifest with explicit schema version, registry binding, and
  `single-active-scope` resolution mode.
- Normalize `instance/locality/registry.yml` as the authoritative inventory
  root for declared scopes and repo-level locality metadata.
- Add the canonical `instance/locality/scopes/<scope-id>/scope.yml` subtree
  so per-scope authority is authored in one place.

## Workstream 2: Define And Enforce The Scope Manifest Contract

- Define the `scope.yml` schema with the ratified required fields and optional
  refinements.
- Enforce the v1 one-root-per-scope rule and the zero-or-one-active-scope
  rule.
- Keep `include_globs` and `exclude_globs` subordinate to `root_path` rather
  than allowing them to create disjoint rooted scopes.
- Convert any remaining locality assumptions expressed only through directory
  conventions into explicit scope manifests or explicit shared-context
  placement.

## Workstream 3: Compile Effective Locality Outputs

- Add generators for `generated/effective/locality/scopes.effective.yml`,
  `artifact-map.yml`, and `generation.lock.yml`.
- Ensure compiled locality outputs carry source digests, generator version,
  schema version, and generation timestamp.
- Ensure runtime-facing locality consumers read compiled effective outputs for
  freshness-protected lookup rather than improvising their own path scans.
- Keep generated effective locality outputs non-authoritative even when they
  are committed by default.

## Workstream 4: Add Fail-Closed Validation And Quarantine

- Add validators that reject missing or malformed locality control metadata.
- Add validators that reject duplicate scope ids, unsupported manifest shape,
  glob escape, and overlapping active scopes.
- Add `state/control/locality/quarantine.yml` as the mutable quarantine record
  for invalid scope state.
- Block runtime-facing scope resolution and downstream scope-bound publication
  whenever locality inputs or effective outputs are stale, invalid, or
  ambiguous.

## Workstream 5: Align Context, Missions, And Downstream Consumers

- Reclassify repo-owned durable context into `shared/**` versus
  `scopes/<scope-id>/**` instead of relying on mixed domain-path conventions.
- Keep missions under `instance/orchestration/missions/**` and add
  scope-reference semantics without letting missions define scope authority.
- Prepare downstream routing and host-integration work to consume scope
  metadata from authoritative manifests and compiled locality views.
- Align `.octon/README.md`, `.octon/instance/bootstrap/START.md`,
  `.octon/framework/cognition/governance/principles/locality.md`,
  `.octon/framework/capabilities/_meta/architecture/architecture.md`, and the
  umbrella architecture docs to describe the same scope registry model.

## Workstream 6: Sequence Continuity And Migration Cutover

- Preserve the blueprint rule that repo continuity moves into
  `state/continuity/repo/**` before locality cutover is treated as complete.
- Keep scope continuity blocked until locality registry and validation are
  canonical and fail closed.
- Only after the locality registry is validator-enforced should
  `state/continuity/scopes/<scope-id>/**` become legal.
- Remove any remaining legacy mixed-path locality assumptions only after the
  registry, effective outputs, and quarantine behavior have converged.

## Downstream Dependency Impact

This proposal is a prerequisite for:

- state, evidence, and continuity architecture work on scope continuity
- capability-routing and host-integration work on scope-aware routing inputs
- unified validation, fail-closed, quarantine, and staleness integration for
  locality
- migration and rollout cleanup of legacy mixed-path locality assumptions

## Exit Condition

This proposal is complete only when the durable `.octon/` control plane,
instance locality manifests, compiled effective locality outputs, validators,
missions, and scope-aware context placement rules all converge on one
root-owned locality model and no alternate locality topology or ambiguous path
resolution rule remains active.
