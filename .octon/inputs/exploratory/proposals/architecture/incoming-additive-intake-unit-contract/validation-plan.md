# Validation Plan

Run these checks against the proposal packet during proposal review:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
```

Run these checks during a later implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --path <fixture>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh
```

Add implementation fixtures for:

- valid minimal intake envelope;
- missing `intake.yml`;
- malformed YAML;
- mismatched `intake_id`;
- missing `payload/`;
- empty `payload/`;
- raw top-level payload outside `payload/`;
- symlink and hardlink path escapes;
- nested `.incoming` or `.archive` roots;
- candidate extension pack inside `payload/`;
- candidate core skill inside `payload/`;
- missing provenance;
- opaque binary payload;
- oversized payload;
- secret or proprietary material declarations.
