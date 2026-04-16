# Octon Retirement And Hygiene Packetizer Validation

Validate the extension family and its publication path with:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
```

Optional host-projection coverage:

```bash
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh
```

Optional proposal-draft validation:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <draft> --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh --package <draft>
```

## Extension-Local Tests

- `validation/tests/test-routing-contract.sh`
- `validation/tests/test-boundary-contract.sh`
- `validation/tests/test-repo-hygiene-composition.sh`
- `validation/tests/test-protected-surface-guardrails.sh`
- `validation/tests/test-draft-output-non-authoritative.sh`
- `validation/tests/test-host-projection-publication.sh`

These tests are designed to run under a temporary fixture with the pack enabled
so the repo-owned desired posture can remain disabled by default.
