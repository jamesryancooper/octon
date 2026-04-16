# Octon Pack Scaffolder Extension Pack

This bundled additive pack scaffolds new additive extension packs and common
pack-local assets under `/.octon/inputs/additive/extensions/<pack-id>/`.

It is designed to:

- scaffold a new extension pack root
- scaffold pack-local prompt bundles, skills, commands, context docs, and
  validation fixtures
- keep extension authoring additive and aligned with the existing extension
  publication model
- define one explicit dispatcher family plus six leaf scaffolds that can be
  published through the existing extension and capability routing surfaces

## Buckets

- `skills/` - family root plus explicit leaf scaffolding skills
- `commands/` - thin command wrappers for stable invocation
- `context/` - output shapes, examples, and usage guidance
- `validation/` - compatibility profile, scenarios, and extension-local tests

## Dispatcher

The family root `octon-pack-scaffolder` is authored as an explicit dispatcher.
Its route policy lives in `context/routing.contract.yml` and is eligible for
publication into `generated/effective/extensions/catalog.effective.yml` as
`route_dispatchers` when the pack is admitted and published.

Supported targets:

- `pack`
- `prompt-bundle`
- `skill`
- `command`
- `context-doc`
- `validation-fixture`

## Publication Workflow

If the repo later admits this pack, bring it to a published state with:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh
```

## Published Surfaces

When selected and published, this pack contributes:

- extension exports under
  `/.octon/generated/effective/extensions/published/octon-pack-scaffolder/bundled-first-party/`
- compiled extension metadata in
  `/.octon/generated/effective/extensions/catalog.effective.yml`
- compiled capability routing entries in
  `/.octon/generated/effective/capabilities/routing.effective.yml`
- host projections under `/.claude/`, `/.cursor/`, and `/.codex/`

## Boundary

This pack is additive only.

It may create or update raw pack content under
`/.octon/inputs/additive/extensions/<pack-id>/`, but it must not activate,
publish, quarantine, govern, or compile that pack.
Runtime-facing extension consumption must continue to flow through generated
effective extension outputs, never directly from raw pack paths.
