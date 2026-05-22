# Source Evidence

This packet was created from repository evidence only. It does not inspect or
process any incoming intake payload beyond repository metadata already visible
as files.

## Primary Surfaces

- `.octon/instance/ingress/AGENTS.md`: establishes that raw `inputs/**` never
  becomes a direct runtime or policy dependency, and that agents can produce
  candidate artifacts but cannot authorize effects.
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`:
  records topology and authority classes used to preserve framework, instance,
  state, generated, and input boundaries.
- `.octon/framework/cognition/_meta/architecture/inputs/README.md`: defines
  input taxonomy and non-authority posture.
- `.octon/framework/cognition/_meta/architecture/inputs/additive/README.md`:
  defines additive inputs and current incoming marker expectations.
- `.octon/inputs/README.md`: records that inputs are not runtime authority.
- `.octon/inputs/additive/README.md`: documents additive input staging and
  non-authority.
- `.octon/inputs/additive/.incoming/README.md`: documents incoming staging,
  current marker expectations, and non-authority.
- `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`:
  defines the governed intake workflow boundary.
- `.octon/framework/capabilities/runtime/commands/process-incoming-intake.md`:
  defines the command contract for processing incoming intake.
- `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`:
  defines workflow steps and lifecycle separation.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh`:
  validates current intake unit boundaries.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`:
  scans for raw input authority leakage.
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh`:
  covers incoming validator behavior.

## Current Repository Observation

The repository currently contains a legacy incoming unit with
`intake-status.yml` and raw top-level payload content. This proposal does not
rewrite it. A later migration would need to wrap raw payload under `payload/`
and replace marker metadata with `intake.yml` only after governance approval.

The repository also contains `.archive` staging structure. This proposal treats
archive migration as separate governance work because archive rewrite can alter
raw retention history.

## Architectural Inference

Because incoming additive intake exists before route classification, it needs
only enough structure to make the unit observable, bounded, and fail-closed.
Requiring normalized extension-pack or core-skill shape at intake would collapse
the lifecycle boundary and risk giving raw material apparent authority.
