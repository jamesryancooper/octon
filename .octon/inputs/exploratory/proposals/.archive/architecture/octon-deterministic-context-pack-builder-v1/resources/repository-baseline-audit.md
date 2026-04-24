# Repository Baseline Audit

## 1. Super-root and authority model

Observed intake state:
- `/.octon/` is the single authoritative super-root.
- Top-level class roots are `framework/`, `instance/`, `state/`, `generated/`, and `inputs/`.
- Durable authored authority may live only under `framework/**` and `instance/**`.
- `state/**` is split into `state/control/**`, `state/evidence/**`, and `state/continuity/**`.
- `generated/**` is rebuildable and never mints authority.
- proposals under `inputs/exploratory/proposals/**` remain lineage-only and non-canonical.

## 2. Execution model

Observed intake state:
- the workspace charter pair says Runs, not Missions, are the atomic consequential execution unit
- `execution-request-v3` requires `context_pack_ref`, `execution_role_ref`, `risk_materiality_ref`, `support_target_tuple_ref`, and `rollback_plan_ref`
- `execution-authorization-v1` already requires context-pack provenance in authority routing
- the runtime README anchors the authority engine to run journal, run lifecycle, authorization boundary coverage, and operator read model surfaces

## 3. Context-adjacent current surfaces

Observed intake state:
- `context-pack-v1` exists and already requires authority sources, derived sources, omissions, budget, freshness, and generated_at
- `instruction-layer-manifest-v2` exists and already records workspace charter refs, run contract ref, support target tuple, authority refs, precedence stack, adapter projections, and source digests
- runtime event schema already includes `run.context_pack_bound`

## 4. Governance model

Observed intake state:
- support-target posture is `bounded-admitted-finite`
- default support route is `deny`
- repo-local-governed model adapter is supported
- frontier-governed model adapter remains stage-only
- relevant adapters already require evidence such as authority-decision artifact, instruction-layer manifest, runtime-event-ledger, control-evidence-root, and run-evidence-root
- no dedicated context-packing policy surface was found

## 5. Overlay legality

Observed intake state:
- `instance-governance-policies`, `instance-governance-capability-packs`, `instance-execution-roles-runtime`, and `instance-assurance-runtime` overlay points are legal and enabled
- this makes `/.octon/instance/governance/policies/context-packing.yml` a legal durable landing zone

## 6. Assurance posture

Observed intake state:
- assurance runtime validator scripts and tests are already first-class durable surfaces
- architecture-conformance CI already exists as a blocking workflow surface
- no dedicated context-pack-builder validator or test was found in the inspected repo surfaces

## Baseline conclusion

Octon already had the contractual and governance skeleton needed for deterministic Context Pack Builder v1. The implementation now adds the builder realization, receipt path, repo-local policy, canonical journal event binding, exact model-visible serialization/hash retention, and CI-enforced proof.
