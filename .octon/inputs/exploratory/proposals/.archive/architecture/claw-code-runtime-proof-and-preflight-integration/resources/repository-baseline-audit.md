# Repository Baseline Audit

## Octon baseline relevant to this packet

Observed baseline:
- single authoritative `.octon/` super-root
- authored authority only in `framework/**` and `instance/**`
- `state/**` split into continuity, evidence, and control
- `generated/**` derived-only
- overlay-capable repo authority only where declared and enabled
- explicit host adapters, lab scenario roots, bootstrap docs, workflow discovery, and observability governance already exist

## Load-bearing live anchors

- `README.md`
- `.octon/README.md`
- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/octon.yml`
- `.octon/framework/manifest.yml`
- `.octon/instance/manifest.yml`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/engine/runtime/adapters/host/repo-shell.yml`
- `.octon/framework/lab/README.md`
- `.octon/framework/lab/scenarios/registry.yml`
- `.octon/framework/observability/governance/failure-taxonomy.yml`
- `.octon/framework/observability/governance/reporting.yml`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/orchestration/runtime/workflows/tasks/README.md`
- `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/**`

## Overlay check

Enabled overlay points include governance policies, contracts, exclusions, adoption, retirement,
capability packs, decisions, agency runtime, and assurance runtime. This packet uses that fact only
to justify repo-owned policy placement under `instance/governance/policies/**`.

## Active proposal convention check

The live active architecture proposal workspace contains
`octon_bounded_uec_proposal_packet/`, which uses numbered narrative documents and a `resources/`
bundle. This packet inherits the sibling-architecture-packet idea and the resource-bundle habit,
but it follows the stricter packet requirements imposed by the current task:
manifest-governed root files, packet manifest, checksums, source-of-truth map, artifact catalog,
and explicit promotion targets.

## Bottom-line repo readiness

Repo readiness is good for this packet because all five selected concepts map to already-existing
families:
- host adapters
- lab scenarios
- bootstrap
- observability governance
- task workflows

The packet therefore recommends adaptation/refinement rather than net-new top-level architecture.
