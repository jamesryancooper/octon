# Cutover Checklist

## Before implementation

- [ ] Proposal packet reviewed in non-authoritative posture.
- [ ] Workstream owners assigned.
- [ ] Current architecture conformance output retained.
- [ ] Current support-target refs captured.
- [ ] Current generated/effective publication state captured.
- [ ] Current compatibility surfaces listed.

## Structural hardening

- [ ] Contract registry updated.
- [ ] Architecture specification updated.
- [ ] Root manifest slimmed or refactored without losing bindings.
- [ ] Overlay legality unchanged.
- [ ] Active-doc hygiene validator passes.

## Runtime hardening

- [ ] Material side-effect inventory expanded.
- [ ] Authorization coverage map expanded.
- [ ] Runtime paths tested.
- [ ] Negative controls pass.
- [ ] Run lifecycle transition validator passes.

## Support cutover

- [ ] Admissions partitioned.
- [ ] Dossiers partitioned.
- [ ] Support-target refs updated.
- [ ] Support matrix regenerated.
- [ ] Support-pack-admission validator passes.
- [ ] Active mission support defaults audited.

## Publication cutover

- [ ] Publication freshness contract added.
- [ ] Generated/effective outputs regenerated where required.
- [ ] Publication receipts retained.
- [ ] Stale-output denial fixtures pass.

## Pack/extension cutover

- [ ] Pack lifecycle registry normalized.
- [ ] Runtime admissions generated/validated.
- [ ] Extension active dependency locks grouped.
- [ ] Quarantine behavior validated.

## Boot cutover

- [ ] Ingress manifest simplified.
- [ ] Closeout workflow moved/referenced.
- [ ] Bootstrap START updated.
- [ ] Operator boot validator passes.

## Proof closeout

- [ ] Architecture health report retained.
- [ ] Support proof bundles retained.
- [ ] RunCard/HarnessCard/SupportCard examples retained.
- [ ] Denial bundles retained.
- [ ] Replay/recovery bundles retained.
- [ ] Two clean passes retained.

## Archive readiness

- [ ] All promotion targets exist outside proposal path.
- [ ] No canonical target depends on proposal path.
- [ ] `proposal.yml` can move to `implemented` then archive with evidence.
