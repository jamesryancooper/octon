# Packet Manifest

This file enumerates the artifacts in the
`host-tool-provisioning-and-multi-repo-portability` packet and records the
intended reading order. It is an inventory and reading aid only; lifecycle
authority remains with `proposal.yml` and `architecture-proposal.yml`.

## Packet root

- canonical packet path:
  `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/`
- packet status: `archived`
- proposal kind: `architecture`
- promotion scope: `octon-internal`

## Intended reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `README.md`
4. `navigation/source-of-truth-map.md`
5. `resources/input-baseline-and-source-normalization.md`
6. `resources/source-register.md`
7. `architecture/current-state-gap-map.md`
8. `architecture/target-architecture.md`
9. `architecture/file-change-map.md`
10. `architecture/implementation-plan.md`
11. `architecture/migration-cutover-plan.md`
12. `architecture/validation-plan.md`
13. `architecture/acceptance-criteria.md`
14. `architecture/closure-certification-plan.md`
15. `architecture/follow-up-gates.md`
16. `architecture/conformance-card.md`
17. `resources/risk-register.md`
18. `resources/assumptions-and-blockers.md`
19. `resources/evidence-plan.md`
20. `resources/rejection-ledger.md`
21. `resources/source_inputs/**`
22. `resources/repo_evidence/**`
23. `navigation/artifact-catalog.md`
24. `SHA256SUMS.txt`

## Artifact inventory

### Root
- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `PACKET_MANIFEST.md`
- `SHA256SUMS.txt`

### Navigation
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`

### Architecture working documents
- `architecture/target-architecture.md`
- `architecture/current-state-gap-map.md`
- `architecture/file-change-map.md`
- `architecture/implementation-plan.md`
- `architecture/migration-cutover-plan.md`
- `architecture/validation-plan.md`
- `architecture/acceptance-criteria.md`
- `architecture/closure-certification-plan.md`
- `architecture/follow-up-gates.md`
- `architecture/conformance-card.md`

### Resources
- `resources/input-baseline-and-source-normalization.md`
- `resources/source-register.md`
- `resources/risk-register.md`
- `resources/assumptions-and-blockers.md`
- `resources/evidence-plan.md`
- `resources/rejection-ledger.md`
- `resources/source_inputs/01_user_request_tmp_install_and_portability.md`
- `resources/source_inputs/02_user_request_multi_repo_portability.md`
- `resources/source_inputs/03_user_request_create_architecture_proposal.md`
- `resources/repo_evidence/01_bootstrap_and_profile_observations.md`
- `resources/repo_evidence/02_extension_activation_pattern_observations.md`
- `resources/repo_evidence/03_runtime_command_and_repo_hygiene_observations.md`

## Notes

- Host-scoped actual installs and receipts are intentionally outside the
  proposal promotion-target set because they are not repo-authored authority.
- The packet is structured to allow a later implementation to promote only
  durable `/.octon/**` surfaces while using host-scoped runtime state for the
  actual tool cache.
