# Acceptance Criteria

The proposal-system update is ready for promotion when all of the following are true.

## A. Preserved Invariants
1. The promoted design explicitly keeps proposals temporary and non-canonical.
2. The promoted design explicitly keeps the current four proposal kinds: `design`, `migration`, `policy`, `architecture`.
3. The promoted design explicitly keeps the current active lifecycle statuses: `draft`, `in-review`, `accepted`, `implemented`, `rejected`, `archived`.
4. The promoted design explicitly keeps `proposal.yml` and the subtype manifest as the proposal-local authority pair.
5. The promoted design explicitly keeps `/.octon/generated/proposals/registry.yml` subordinate to proposal manifests.

## B. Contract Alignment
6. `proposal-standard.md`, `proposal.schema.json`, `validate-proposal-standard.sh`, and the registry schema agree on archive semantics, including `superseded`.
7. `architecture-proposal-standard.md`, the architecture template manifest, the architecture schema, and the architecture validator agree on one subtype contract.
8. The architecture subtype contract requires `architecture_scope` and `decision_type`.
9. `migration-proposal-standard.md`, the migration template manifest, the migration schema, and the migration validator agree on one subtype contract.
10. The migration subtype contract requires `change_profile` and `release_state`.
11. `policy-proposal-standard.md`, the policy template manifest, the policy schema, and the policy validator agree on one subtype contract.
12. The policy subtype contract requires `policy_area` and `change_type`.
13. No promoted schema requires a field that the matching live template and validator reject.
14. No promoted validator accepts a field shape that the matching schema forbids.

## C. Registry Integrity
15. A deterministic registry rebuild path exists for `/.octon/generated/proposals/registry.yml`.
16. Registry generation or validation fails closed on duplicate proposal ids.
17. Registry generation or validation fails closed on missing package paths.
18. Registry generation or validation fails closed on kind or status mismatches between packet and projection.
19. Registry generation or validation fails closed on invalid archive metadata in archived entries.
20. Active proposal workflows invoke the registry rebuild or equivalent projection step instead of relying on manual registry edits.
21. CI or the equivalent proposal validation gate blocks drift between manifests and the committed registry.

## D. Archive Integrity
22. The main archive contains only standard-conformant archived packets or else invalid packets are removed from the main registry until normalized.
23. `mission-scoped-reversible-autonomy` is either normalized into a valid archived packet or excluded from the main registry.
24. `self-audit-and-release-hardening` no longer uses `archived_from_status: proposed` in any main-registry packet.
25. `harness-integrity-tightening` no longer uses `archived_from_status: proposed` in any main-registry projection.
26. `capability-routing-host-integration` is either reconstructed into a complete archived packet or removed from the main registry.
27. Archived design entries retained in the main registry resolve to visible, standard-conformant packets or are explicitly split out of the main projection.
28. Implemented archives keep non-empty promotion evidence.
29. Archived packets in archive paths always use `status: archived`.

## E. Lifecycle And Workflow Completion
30. A generic `validate-proposal` workflow exists.
31. A `promote-proposal` workflow exists.
32. An `archive-proposal` workflow exists.
33. Each new workflow has a canonical workflow package under `.octon/framework/orchestration/runtime/workflows/meta/`.
34. Each new workflow writes a retained bundle under `.octon/state/evidence/runs/workflows/`.
35. Each workflow bundle includes `bundle.yml`, `summary.md`, `commands.md`, `validation.md`, and `inventory.md`.
36. `promote-proposal` refuses to complete when any promotion target retains a proposal-path backreference.
37. `promote-proposal` refuses to complete unless the source proposal is `accepted`.
38. `archive-proposal` refuses to complete unless archive metadata, archive path, and registry state are all coherent.
39. `implemented` is only reachable after promotion proof exists.
40. `archived` is only reachable after archive proof exists.

## F. Navigation Simplification
41. The promoted design keeps `navigation/source-of-truth-map.md` as the manual semantic navigation artifact.
42. Source-of-truth-map templates require external authorities, proposal-local precedence, projections, evidence surfaces, and boundary rules.
43. The promoted design turns `navigation/artifact-catalog.md` into generated inventory rather than hand-authored semantic authority.
44. Current proposal packages remain compatible during the transition, even if artifact-catalog generation is phased in incrementally.

## G. Rollout And Ongoing Enforcement
45. The updated proposal system can validate every active manifest-governed proposal package in the repo.
46. The updated proposal system can rebuild the registry from active and archived packets without manual repair during normal operation.
47. The updated proposal system does not create any new canonical dependency on proposal-local paths.
48. The updated proposal system keeps evidence in `state/evidence/**` rather than under proposal-local paths or `generated/**`.
49. The proposal pack can be archived only after the promoted durable surfaces and the archive normalization inventory are no longer dependent on proposal-local guidance.
