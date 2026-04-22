# Validation Plan

## 1. Structural validation

Required checks:

- class-root placement;
- contract registry consistency;
- root manifest profile validity;
- delegated registry existence;
- overlay legality;
- active-doc hygiene;
- proposal exclusion from runtime/policy resolution;
- generated-vs-authored discipline.

Validators:

- existing `validate-architecture-conformance.sh`;
- existing active-doc and contract-governance validators;
- new `validate-architecture-health.sh`.

## 2. Runtime authorization validation

Required checks:

- material side-effect inventory is complete;
- authorization coverage map includes every material path;
- every material path has request builder, authorization ref, grant ref, receipt
  ref, denial reason, negative controls, and tests;
- workflow compatibility wrapper routes through run-first lifecycle;
- protected execution requires hard enforce.

Validators/tests:

- existing `validate-authorization-boundary-coverage.sh`;
- existing `test-authorization-boundary-coverage.sh`;
- new negative-control fixtures for all G10 runtime blockers.

## 3. Run lifecycle validation

Required checks:

- run contract, run manifest, runtime state, rollback posture, checkpoints,
  evidence, replay pointers, disclosure, and evidence classification exist for
  bound/authorized/running/closed states;
- invalid transitions fail closed;
- staged/paused/revoked/failed states remain operator-visible.

Validator:

- new `validate-run-lifecycle-transition-coverage.sh`.

## 4. Support and admission validation

Required checks:

- physical claim-state partitioning;
- live tuple proof bundle;
- support dossier sufficiency;
- representative retained run disclosure;
- negative-control evidence;
- pack admission alignment;
- active mission support alignment;
- disclosure claim bounds.

Validator:

- new `validate-support-pack-admission-alignment.sh`.

## 5. Publication freshness validation

Required checks:

- generated/effective outputs have current publication receipts;
- freshness metadata ties to source graph;
- stale outputs fail closed;
- generated/cognition read models carry traceability;
- generated/proposals registry remains discovery-only.

Validator:

- new `validate-publication-freshness-gates.sh`.

## 6. Pack/extension validation

Required checks:

- raw additive extension input is not runtime authority;
- desired selection, active/quarantine state, generated/effective output, and
  publication receipts agree;
- pack governance/admission/support/routing/projection graph is coherent;
- skill/service projections do not depend on obsolete symlink-era semantics.

## 7. Proof-plane validation

Required checks:

- structural proof;
- behavioral/lab proof;
- governance/support proof;
- maintainability proof;
- recovery/reversibility proof;
- runtime enforcement proof.

Artifacts:

- SupportCard;
- HarnessCard;
- RunCard;
- denial bundle;
- replay bundle;
- recovery demonstration;
- proof-plane completeness report.

## 8. Operator usability validation

Required checks:

- boot path can be read in one pass;
- closeout workflow is separate from ingress orientation;
- architecture maps are generated, traceable, and non-authoritative;
- first-run doctor path is executable or fixture-backed.

Validator:

- new `validate-operator-boot-surface.sh`.

## 9. CI integration

`architecture-conformance.yml` must run all target-state validators. Closure
requires:

- zero blocking validation failures;
- two consecutive clean full health runs;
- retained validation evidence;
- no unresolved high-severity risks.
