# Migration / Cutover Plan

## Overall posture

No named migration profile specific to this packet exists in the live repo. This work is therefore treated as an **additive same-root refinement**, not as a topology migration or big-bang cutover.

## No-migration rationale

- The canonical roots already exist.
- Both in-scope concepts are refinements of existing schema/policy/validator surfaces.
- No new top-level class root or new control/evidence family is required.
- The live support universe is not widened.

## Safe rollout sequence

1. **Schema-first additive branch**
   - add optional/additive fields to existing schemas
   - do not immediately hard-require them at schema level unless the emitter can populate them in the same branch

2. **Emitter alignment**
   - update manifest / request / grant / receipt emitters to populate new fields
   - update pack/policy surfaces to reflect the new semantics

3. **Validator introduction**
   - add new validators and regression tests
   - run locally and in CI against representative fixtures

4. **CI enforcement**
   - wire validators into `architecture-conformance.yml`
   - require at least one clean pass after the CI edit lands
   - require a second clean pass before packet closeout

5. **Closeout proof**
   - retain representative enriched artifacts and validator output
   - confirm no support-target or exclusion declaration changed

## Rollback / reversal

If refinement causes unacceptable breakage:
- revert touched schemas, overlays, and validators in one change set
- keep already-generated historical evidence as retained evidence
- do not delete historical receipts created during the failed attempt
- reopen the packet with the narrower fallback path only if the broader path is shown unsafe or infeasible

## What must survive rollback

- prior retained execution evidence
- prior support-target declarations
- prior constitutional contract family integrity
- this packet’s non-authoritative lineage
