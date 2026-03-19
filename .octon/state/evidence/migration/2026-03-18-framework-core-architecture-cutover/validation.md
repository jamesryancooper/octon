# Validation

## Gate Results

- `validate-overlay-points.sh`: PASS (`errors=0`)
- `validate-framework-core-boundary.sh`: PASS (`errors=0`)
- `validate-harness-structure.sh`: PASS (`errors=0 warnings=0`)
- `validate-agent-only-governance.sh`: PASS (`errors=0`)
- `validate-services.sh --profile dev-fast`: PASS (`errors=0 warnings=0`)
- `validate-skills.sh --profile dev-fast`: PASS (`all checks passed`)
- `alignment-check.sh --profile harness`: PASS (`errors=0`)

## Contract Assertions Verified

- Framework-local `_ops/state/**` roots are absent from live framework
  surfaces.
- Overlay validator path resolution and enabled-overlay-point coverage are
  enforced.
- Framework core boundary violations fail closed before the harness profile can
  proceed.
- Engine, assurance, skills, services, and capability-policy consumers now
  resolve stateful paths to canonical `instance/**`, `state/**`, or
  `generated/**` targets.
- The skill output-scope contract now accepts Packet 3 repo-absolute
  `/.octon/**` roots and the existing deliverable path classes used by the
  live skills registry.
- Active exploratory proposal/support material no longer carries Packet 3
  legacy framework-state paths.
- Continuity retention contracts recognize the new Packet 3 evidence buckets
  for `capabilities`, `skills`, `services`, and `engine`.
- Unexpected top-level `/.octon/` entries and non-bundle `framework/*`
  entries now fail closed, preventing residual parallel roots such as
  `/.octon/engine`, `/.octon/.octon`, or `framework/continuity`.
- Active assurance scripts, workflow-runner tests, skill templates, and
  framework guidance no longer depend on the retired `output/` class root.
- Legacy `framework/**/_ops/state/**` paths are removed from the git index,
  not just from the working tree layout.
- The framework core boundary validator now fails closed on live control-plane
  references to the retired `output/` root.
- Active CI/workflow guardrails and non-archived plan or migration materials no
  longer special-case the retired `output/**` surface or the old
  `generated/output/README.md` note path.
- Active framework references no longer point at legacy `.octon/ideation` or
  `.octon/continuity` roots, and the boundary validator now rejects those
  literals outside allowed historical/validator surfaces.
