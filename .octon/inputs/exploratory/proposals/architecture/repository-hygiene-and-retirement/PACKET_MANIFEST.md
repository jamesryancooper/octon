# Packet Manifest

This file enumerates every artifact in the `repository-hygiene-and-retirement`
proposal packet and records the intended reading order. It is an inventory and
reading aid only; lifecycle authority remains with `proposal.yml` and
`architecture-proposal.yml`.

## Packet root

- canonical packet path:
  `/.octon/inputs/exploratory/proposals/architecture/repository-hygiene-and-retirement/`
- packet status: `in-review`
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
9. `architecture/source-to-remediation-matrix.md`
10. `architecture/file-change-map.md`
11. `architecture/implementation-plan.md`
12. `architecture/migration-cutover-plan.md`
13. `architecture/validation-plan.md`
14. `architecture/acceptance-criteria.md`
15. `architecture/closure-certification-plan.md`
16. `architecture/follow-up-gates.md`
17. `architecture/conformance-card.md`
18. `resources/risk-register.md`
19. `resources/assumptions-and-blockers.md`
20. `resources/evidence-plan.md`
21. `resources/rejection-ledger.md`
22. `resources/source_inputs/**`
23. `resources/repo_evidence/**`
24. `navigation/artifact-catalog.md`
25. `SHA256SUMS.txt`

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
- `architecture/source-to-remediation-matrix.md`
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
- `resources/source_inputs/01_user_request_rust_shell_cleanup.md`
- `resources/source_inputs/02_user_request_transitional_surfaces.md`
- `resources/source_inputs/03_user_request_repo_hygiene_capability_spec.md`
- `resources/source_inputs/04_user_request_proposal_packet_generation.md`
- `resources/repo_evidence/01_ingress_constitutional_and_profile_excerpts.md`
- `resources/repo_evidence/02_super_root_and_proposal_contract_excerpts.md`
- `resources/repo_evidence/03_runtime_command_support_and_workflow_excerpts.md`
- `resources/repo_evidence/04_retirement_and_ablation_spine_excerpts.md`
- `resources/repo_evidence/05_runtime_workspace_and_ci_excerpts.md`
- `resources/repo_evidence/06_proposal_workspace_observations.md`

## Notes

- The packet is self-contained enough for review, handoff, archive, or later
  promotion without chat-history reconstruction.
- Repo-local workflow integrations are modeled as dependent implementation
  surfaces because active proposals may not mix `.octon/**` and non-`.octon/**`
  promotion targets.
