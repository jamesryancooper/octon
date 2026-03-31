# Cutover Checklist

## Before editing

- [ ] Freeze the March 30 atomic cutover receipt as the live selector reference
- [ ] Preserve the supplied evaluation under `resources/`
- [ ] Confirm current HEAD already has the corrected disclosure family semantics

## Semantic changes

- [ ] Rebind every active non-disclosure family live receipt to the March 30 atomic cutover
- [ ] Preserve March 28–29 phase receipts only as explicit lineage
- [ ] Remove `inputs/additive/extensions/**` from authored-authority wording in `START.md`
- [ ] Narrow live support envelopes to retained proof-backed tuples
- [ ] Rewrite authored and retained HarnessCard summaries to the proved live envelope
- [ ] Narrow `.octon/**` portability/support wording to evidence-bounded language
- [ ] Replace placeholder owner identifiers in subordinate governance files

## Validator hardening

- [ ] Add family live-model validator
- [ ] Add bootstrap authority-surface validator
- [ ] Add support-target live-claim validator
- [ ] Add disclosure live-root validator
- [ ] Add subordinate owner placeholder validator
- [ ] Wire validators into `alignment-check.sh`
- [ ] Wire validators into `assurance-gate.sh`

## Release/disclosure verification

- [ ] Confirm the authored HarnessCard and retained release HarnessCard match
- [ ] Confirm no live claim exceeds the proved tuple and proof bundle
- [ ] Confirm lab-local HarnessCard mirrors remain historical only

## Closeout

- [ ] Run full alignment profile
- [ ] Retain validation receipts
- [ ] Record any repo-local non-`.octon/**` follow-on work separately
- [ ] Merge as one atomic branch change
- [ ] Do not leave any active family or live claim surface half-migrated
