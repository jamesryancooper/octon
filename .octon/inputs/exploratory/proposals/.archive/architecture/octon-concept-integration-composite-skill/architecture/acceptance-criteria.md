# Acceptance Criteria

The proposal is ready to promote when all of the following are true.

## Pack Integrity

- A first-party bundled pack exists at
  `/.octon/inputs/additive/extensions/octon-concept-integration/`.
- The pack validates under the live extension-pack validator with no blocking
  errors.
- The pack internalizes the concept-integration prompt assets under its own
  `prompts/` bucket.
- The durable capability no longer requires any superseded root-level prompt
  copy at runtime.

## Capability Shape

- The pack contains a composite skill named `octon-concept-integration`.
- The skill contract defines the bounded phases needed to reach a validated
  architecture proposal packet and a packet-specific executable implementation
  prompt.
- The pack also contains a thin command wrapper named
  `/octon-concept-integration`.
- The command wrapper is published through extension routing and can be
  projected to supported host adapters.

## Publication And Discovery

- `instance/extensions.yml` contains the pack in repo-owned desired state.
- Extension publication succeeds and records the pack in
  `generated/effective/extensions/catalog.effective.yml`.
- Capability routing succeeds and records both the extension command and the
  extension skill in `generated/effective/capabilities/routing.effective.yml`.
- Artifact provenance correctly marks these entries as extension-derived rather
  than framework-native or instance-native.

## Functional Outcome

- A bounded sample run can generate:
  - extraction output
  - verification output
  - a manifest-governed architecture proposal packet under
    `inputs/exploratory/proposals/architecture/<proposal_id>/`
  - a packet-specific executable implementation prompt as packet support output
- The generated proposal packet passes the base and subtype proposal validators.

## Boundary Safety

- No canonical runtime or policy surface reads raw pack files directly.
- No proposal packet is treated as canonical authority.
- No new support-target, host-adapter, model-adapter, locale, or capability-pack
  claim is introduced.
- No new orchestration subsystem or `runtime/pipelines/` surface is introduced.

## Closure Gate

- Two consecutive clean end-to-end validation passes exist with no new blocking
  issues.
- Any residual limitation around extension skill registry publication is either:
  - explicitly avoided by the landed command-wrapper invocation model, or
  - separately tracked as follow-on work outside this packet's acceptance gate.
