# Acceptance Criteria

## Packet-level acceptance

- [ ] Proposal manifests validate under the base and architecture proposal standards.
- [ ] `proposal_id` matches the final directory name.
- [ ] Promotion targets are all outside `inputs/exploratory/proposals/**`.
- [ ] No durable target promoted from this packet retains proposal-path dependencies.

## Architecture acceptance

- [ ] `octon.yml` remains a root manifest but no longer carries dense runtime-resolution tables that belong in delegated registries.
- [ ] Runtime-resolution v1 spec, schema, instance selector, and generated/effective route bundle exist.
- [ ] Contract registry declares runtime-resolution and route-bundle path families.
- [ ] Architecture specification explains the target state without duplicating full registry matrices.

## Runtime acceptance

- [ ] Every material side-effect inventory entry has authorization coverage, request builder, grant ref, receipt ref, denial reason code, and negative controls.
- [ ] Runtime refuses stale generated/effective route bundles.
- [ ] Runtime refuses generated/cognition or generated/proposals as authority.
- [ ] Runtime refuses raw `inputs/**` as direct policy or runtime dependency.
- [ ] Runtime refuses unadmitted packs, unpublished extensions, and quarantined extensions.

## Publication acceptance

- [ ] Generated/effective runtime artifacts have current artifact maps, generation locks, publication receipts, and freshness metadata.
- [ ] Direct runtime string-path reads of generated/effective artifacts are replaced by freshness-checked handles.
- [ ] Stale generated/effective artifacts deny or stage before side effects.

## Support and pack acceptance

- [ ] Admissions and dossiers live under the declared claim-state partitions.
- [ ] Support target refs, proof bundle refs, support cards, and generated support matrix all agree.
- [ ] Runtime pack routes are compiled into generated/effective outputs or the old runtime pack projection is explicitly marked transitional.
- [ ] Pack admission cannot widen beyond support-target admission.

## Extension acceptance

- [ ] `state/control/extensions/active.yml` is compact and digest-oriented.
- [ ] Dependency closure and required-input expansion live in generation locks/artifact maps.
- [ ] Quarantine state is runtime-enforced.
- [ ] Effective extension catalog has current publication and compatibility receipts.

## Proof and operator acceptance

- [ ] `octon doctor --architecture` reports no blocking failures.
- [ ] Operator read models carry source refs, freshness, and non-authority disclaimers.
- [ ] Closure certification, publication freshness receipt, support proof refresh, and authorization coverage evidence exist under retained evidence roots.
