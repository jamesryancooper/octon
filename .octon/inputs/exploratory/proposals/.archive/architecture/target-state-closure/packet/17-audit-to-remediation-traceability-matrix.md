# 17. Audit-to-Remediation Traceability Matrix

| Audit blocker / finding | Packet section(s) | Path(s) primarily affected | Gate / validator | Acceptance condition |
|---|---|---|---|---|
| Empty evidence classification in active exemplar runs | 01, 06, 12, 13, 14, 15, 16 | `state/evidence/runs/*/evidence-classification.yml` | `validate-evidence-classification-nonempty.sh` | every active proof-bundle exemplar run has non-empty v2 classification |
| Green status contradicted by retained evidence | 03, 07, 12, 14, 15 | `state/evidence/disclosure/releases/*/closure/**`, instance mirrors | `validate-claim-truth-boundary.sh` | gate-status derives from validator outputs only |
| Superseded global-complete wording in active artifacts | 01, 07, 12, 15, 16 | measurement summaries, RunCards, HarnessCard, closure summaries | `validate-disclosure-wording-coherence.sh` | no superseded phrases in active claim-bearing artifacts |
| Cross-artifact support tuple / pack / route mismatch | 06, 07, 09, 12, 15, 16 | run-contract, run-manifest, decision, grant, RunCard, support-targets, adapters | `validate-cross-artifact-*` suite | all active exemplar bundles agree on tuple / packs / route / status |
| Split canonical run-contract lineage | 04, 12, 15, appendix contract catalog | current `objective/run-contract-v1`, `runtime/run-contract-v2` | `validate-single-canonical-run-contract-family.sh` | only `runtime/run-contract-v3` is live for claim-bearing runs |
| Mission authority under-normalized | 04, appendix contract catalog | `instance/orchestration/missions/**`, new schema path | `validate-mission-charter-bindings.sh` | all live mission files validate against mission-charter schema |
| Quorum embedded in mission-autonomy policy | 05, appendix contract catalog | `instance/governance/policies/mission-autonomy.yml`, new authority contracts | `validate-quorum-policy-bindings.sh` | quorum policy is first-class and referenced |
| Lease/revocation lifecycle under-normalized | 05, 16, appendix contract catalog | `state/control/execution/exceptions/**`, `revocations/**` | lifecycle validators | active leases/revocations are per-artifact or canonically indexed |
| Insufficient hidden-check / adversarial / evaluator-independence coverage | 08, 09, 12, 15 | `framework/lab/**`, assurance policy roots | `validate-lab-hidden-check-coverage.sh`, `validate-evaluator-independence.sh` | active tuples meet minimum lab/proof coverage |
| Residual architect / SOUL active-path risk | 10, 12, 16 | agency runtime, ingress, manifests, workflows | `validate-no-legacy-active-path.sh` | no active execution path depends on legacy persona surfaces |
| Build-to-delete not institutionalized | 11, 12, 16 | retirement registry, ablation receipts, drift reports | retirement / ablation / drift validators | transitional surfaces tracked and reviewable |
| Host labels/comments/checks still too influential | 05, 09, 12 | host adapters, AI review workflow, PR policy workflow | `validate-host-projection-non-authority.sh` | host surfaces are projection-only everywhere live |
| Claim-bearing mirrors authorable by humans | 03, 07, 12, 14 | instance disclosure / closure mirror paths | `validate-claim-surface-generated-only.sh` | mirrors are generator-owned only |
| Release bundle freshness not proven | 07, 12, 14, appendix regeneration map | release bundle root | `validate-release-bundle-freshness.sh` | active release bundle manifest proves freshness |
| Support-target matrix real but not evidentially dossier-backed | 09, 16 | `instance/governance/support-targets.yml` | `validate-support-dossier-completeness.sh` | every live tuple has a support dossier |
| Runtime resume/replay model present but not cleanly closure-validated | 06, 12 | run roots, replay manifests, external indexes | `validate-run-bundle-completeness.sh`, replay index validator | active exemplar bundles are replay-complete enough for claim |
