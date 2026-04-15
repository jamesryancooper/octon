# Validation Plan

## 1. Structural validation

### Required checks
- JSON schema validation for:
  - `instruction-layer-manifest-v2.schema.json` examples / fixtures
  - `execution-request-v2.schema.json` examples / fixtures
  - `execution-grant-v1.schema.json` examples / fixtures
  - `execution-receipt-v2.schema.json` examples / fixtures
- overlay legality check for any instance-side edits
- contract-family version coherence check
- ingress / manifest parity remains intact

### Proposed validators
- `validate-instruction-layer-manifest-depth.sh`
- `validate-capability-envelope-normalization.sh`

## 2. Runtime / control validation

Validate that:
- no material path bypasses `authorize_execution(request) -> GrantBundle`
- request / grant / receipt semantics stay aligned
- pack admission and execution-class policy agree with granted capability use
- no new mutable control root is introduced

## 3. Evidence retention validation

Validate that:
- instruction-layer manifests exist for representative consequential runs or fixtures
- raw payload refs are present whenever output-budget policy requires offload
- receipts include reason-code and envelope linkage expected by class policy
- retained evidence still lives under existing evidence roots, not under `generated/**` or proposal paths

## 4. Generated-output validation

This packet requires **no new generated family** for closeout. If any compiled capability view is added later, validate that:
- it is derived from authoritative/control sources
- it is publication-only
- runtime does not treat it as new authority

## 5. Operator / runtime usability validation

Validate operator-usable behavior, not just schema shape:
- a reviewer can inspect one enriched instruction-layer manifest and determine active packs/classes/budget policy without inference across many files
- a reviewer can inspect one receipt chain and determine request -> grant -> class -> pack -> envelope semantics
- architecture-conformance blocks regressions

## 6. CI integration

`architecture-conformance.yml` must run the new validators on relevant path changes. Closure requires:
- zero blocking failures
- two consecutive clean passes
