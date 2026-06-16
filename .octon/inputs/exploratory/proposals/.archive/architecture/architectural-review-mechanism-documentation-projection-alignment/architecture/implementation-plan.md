# Implementation Plan

## Workstream 1: Product Feature Decision

1. Inspect product feature catalog conventions.
2. Decide whether `architectural-review-mechanism` should be a product feature.
3. Either add the feature entry and navigation file, or document the durable
   exclusion rule in product feature guidance and the governed mechanism index.
4. Run product feature catalog validation.

## Workstream 2: Naming And Invocation Alignment

1. Resolve the canonical relationship between `domain-architecture-audit` and
   `audit-domain-architecture`.
2. Resolve the canonical relationship between `surface-architecture-audit` and
   `audit-surface-architecture`.
3. Update methodology, skill registries, command manifests, workflow
   references, and generated-publication inputs according to the chosen route.
4. Preserve `architecture-readiness-audit` as the canonical readiness slug.
5. Extend naming and skills/commands validators to check the chosen mapping.

## Workstream 3: Mechanism Index And Doctrine Coverage

1. Update the governed mechanism index and mechanism detail page to cover all
   declared review modes or record explicit omissions.
2. Update architectural-review methodology docs to distinguish canonical modes,
   invocation aliases, evidence roots, and lifecycle authority.
3. Keep extension-owned packetization under
   `.octon/inputs/additive/extensions/octon-concept-integration/` as an input
   boundary, not native authority.

## Workstream 4: Validator And Fixture Coverage

1. Add or update validator cases for canonical mode coverage.
2. Add negative controls for stale names, missing command facades, missing
   product feature rationale, missing mechanism-index refs, and generated
   authority overclaims.
3. Verify lifecycle gate validators still require
   `support/pre-integration-architecture-review.yml` only for architecture
   acceptance and implementation authorization.

## Workstream 5: Publication Refresh

1. Regenerate capability routing through
   `.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`.
2. Regenerate host projections through
   `.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`.
3. Regenerate proposal registry through
   `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`.
4. Validate generated artifact handles and publication state.

## Workstream 6: Closeout Gates

1. Run implementation conformance after durable changes land.
2. Run post-implementation drift/churn after conformance passes.
3. Refuse implemented closeout if generated projections, validators, command
   surfaces, or mode naming remain stale.

## Rollback

Revert authored docs, manifests, registries, command surfaces, validators, and
tests. Regenerate derived projections from the reverted authored state. Retain
proposal-local and validation evidence as non-authoritative audit records.
