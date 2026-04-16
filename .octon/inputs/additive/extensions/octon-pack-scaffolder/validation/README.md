# Octon Pack Scaffolder Validation

Validate this additive pack with:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/inputs/additive/extensions/octon-pack-scaffolder/validation/tests/test-scaffold-shapes.sh
bash .octon/inputs/additive/extensions/octon-pack-scaffolder/validation/tests/test-generated-pack-contracts.sh
```

## Coverage

- pack contract and manifest fragment shape
- command, skill, context, and validation asset presence
- documented scaffold defaults and refusal rules
- sample generated pack outputs checked with the existing extension and
  capability publication validators in a temporary repo

## Ownership Rule

Apply the canonical extension ownership model from:

- `/.octon/framework/engine/governance/extensions/README.md`

Extension-local implication:

- scenarios and tests in `validation/**` validate only this pack's additive
  authoring contract
- publication, compatibility evaluation, and quarantine remain core concerns
