# Repository Baseline Audit

## Proposal-system baseline

- `/.octon/inputs/exploratory/proposals/README.md` requires manifest-governed proposals to include `proposal.yml`, exactly one subtype manifest, `README.md`, `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`, and optional `support/`.
- Architecture proposals must include `architecture-proposal.yml`, `architecture/target-architecture.md`, `architecture/acceptance-criteria.md`, and `architecture/implementation-plan.md`.
- Active proposal path must be `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/` and final directory name must equal `proposal_id`.

## Super-root baseline

- `/.octon/README.md` defines `.octon/` as the authoritative super-root.
- Class roots are `framework/`, `instance/`, `state/`, `generated/`, and `inputs/`.
- Only `framework/**` and `instance/**` are authored authority.
- `generated/**` never mints authority; `inputs/**` never becomes direct runtime or policy dependency.

## Manifest baseline

- `/.octon/octon.yml` is `octon-root-manifest-v2` with release version `0.6.34`.
- It defines portability profiles, generated commit defaults, runtime inputs, continuity roots, run roots, host/model adapter roots, capability roots, lab/observability roots, mission roots, and execution governance policy modes.

## Structural baseline

- `contract-registry.yml` is schema `architecture-contract-registry-v2` and is the canonical machine-readable structural authority subordinate to the constitution.
- `specification.md` is the human-readable companion and explicitly avoids restating competing topology matrices.
- Compatibility projections `execution`, `mission_autonomy`, and `documentation` are retained for current validators/runtime tooling.

## Constitutional baseline

- `CHARTER.md` defines Octon as a Constitutional Engineering Harness with a Governed Agent Runtime.
- The charter requires bounded support, explicit authority routing before material side effects, fail-closed behavior, runtime-real/proof-backed/disclosure-backed live claims, and no hidden human intervention.
- `normative.yml` orders authority from external obligations to constitutional kernel, repo governance, run artifacts, workspace/mission authority, run contract, lifecycle control, capability/adapter contracts, structural docs, and informative context.

## Runtime baseline

- `execution-authorization-v1.md` declares `authorize_execution(request: ExecutionRequest) -> GrantBundle` as mandatory before material execution.
- `kernel/src/main.rs` imports `authorize_execution` and exposes service/tool/validate/stdio/studio/run/workflow/orchestration command surfaces.
- Workflow execution is described as a compatibility wrapper over run-first lifecycle semantics.

## Governance/support baseline

- `support-targets.yml` uses `support_claim_mode: bounded-admitted-finite`.
- Live support includes repo-local governed, observe/read, repo-consequential, reference-owned, English primary, `repo-shell`, `ci-control-plane`, and capability packs `repo`, `git`, `shell`, `telemetry`.
- Frontier, GitHub, Studio, browser, API, and broader context surfaces are stage-only or non-live unless separately admitted.
- The repo-shell consequential admission is supported, requires proof planes and evidence refs, and points to a dossier.
- The repo-shell consequential dossier is qualified but has `minimum_retained_runs: 1` and `current_retained_runs: 1`.

## Capability baseline

- Runtime services have typed contracts, independence requirements, deny-by-default guardrails, scoped allowed tools, and shared policy preflight/enforcement.
- Skills have progressive-disclosure capability metadata, registries, scoped tool permissions, and host projections, but docs should reconcile symlink-era language with generated-routing projection language.

## State/evidence baseline

- `state/control/**` is mutable operational truth.
- `state/evidence/**` is retained evidence, disclosure, validation, and proof.
- `generated/effective/**` requires publication receipts and freshness artifacts before runtime trust.
- `generated/cognition/**` remains non-authoritative read model territory.
