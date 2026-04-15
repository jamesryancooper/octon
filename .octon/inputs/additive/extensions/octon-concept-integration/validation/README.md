# Octon Concept Integration Validation

Validate the extension family and its publication path with:

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

## Extension-Local Test Convention

Extension-specific validation scripts live under:

- `validation/tests/*.sh`

Framework-generic assurance tests remain under:

- `/.octon/framework/assurance/runtime/_ops/tests/`

The generic discovery runner is:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh`

It scans every present extension under `/.octon/inputs/additive/extensions/*/`
for `validation/tests/*.sh` and runs them in lexical order.

Current executable scenario coverage for `octon-concept-integration` lives in:

- `validation/tests/test-prompt-contract.sh` for bundle-family structural parity
- `validation/tests/test-scenario-behavior.sh` for stale bundle, packet drift,
  multi-source conflict, and subsystem scope mismatch
- `validation/tests/test-scenario-fixtures.sh` for validator-backed scenario
  output fixtures covering packet drift, multi-source conflict, and
  subsystem-boundary handling

## Ownership Rule

Apply the canonical extension ownership model from:

- `/.octon/framework/engine/governance/extensions/README.md`

Extension-local implication:

- bundle-specific validation tests, fixtures, and helper scripts for
  `octon-concept-integration` live under `validation/**`.

The extension publication validator now also checks every bundle manifest and
its shared assets:

- the authored prompt-set manifest
- effective prompt bundle metadata
- retained prompt alignment receipts
- prompt asset projection paths and digests
- shared prompt reference projection paths and digests
- required prompt anchor inputs in the generation lock

The deterministic prompt-bundle freshness resolver lives at:

`/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh`

Prompt inventory, default alignment policy, base repo anchors, and packet
support filenames are authored in:

`prompts/<bundle>/manifest.yml`

When you are inspecting the published runtime-facing surface, the same bundle
manifest lives under the active compiled extension projection with the same
relative path.

Use the resolver to evaluate behavioral mode semantics:

- fresh published bundle -> allow
- stale bundle in `always` mode -> block pending explicit republish/re-alignment
- stale bundle in `auto` mode -> block
- stale bundle in `skip` mode -> degraded allow

Bundle-specific packet validators are summarized in `bundle-matrix.md`.

For generated proposal packets emitted by the packet-generation bundles, also
run:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package <packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh --package <packet-path>
```

Choose the second validator by bundle and packet kind:

- architecture-generating bundles, including `architecture-revision-packet` ->
  `validate-architecture-proposal.sh`
- policy-generating bundles, including `constitutional-challenge-packet` ->
  `validate-policy-proposal.sh`
- migration-generating bundles ->
  `validate-migration-proposal.sh`
