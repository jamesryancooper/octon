# Validation Plan

_Status: Draft proposal validation plan_

## Packet Validation

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
cd .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction && shasum -a 256 -c SHA256SUMS.txt
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

## Implementation Validation

Implementation is not authorized by this draft packet. If accepted and
implemented later, the implementation route must add or run:

- lifecycle plan smoke test for `proposal-program` against the Governed Workflow
  Runtime transition parent program;
- effective extension catalog fixture where `lifecycle_contracts: []` is
  present without `lifecycle-contract` and does not block unrelated lifecycle
  discovery;
- effective extension catalog fixture where a non-empty lifecycle contract list
  without `lifecycle-contract` still fails closed;
- proposal registry generator portability test or explicit Bash version guard
  test;
- proposal standard validator test proving registry synchronization can run
  through the supported shell path;
- retained evidence check for disclosed fallback/manual lifecycle creation.
