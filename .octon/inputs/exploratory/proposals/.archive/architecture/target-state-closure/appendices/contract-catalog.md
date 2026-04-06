# Contract Catalog

This appendix gives a compact contract-family catalog with fields, ownership, lifecycle, canonical locations, runtime projections, enforcement owners, migration, and acceptance criteria.

## 1. Harness Charter
- **Current path(s):** `framework/constitution/CHARTER.md`, `framework/constitution/charter.yml`
- **Target path(s):** preserve
- **Schema/version:** `charter-v1`
- **Producer:** human constitutional owners
- **Consumer:** ingress, authority engine, runtime, assurance, disclosure
- **Lifecycle:** authored → amended → superseded
- **Machine enforcement:** constitution validator, projection generator
- **Migration:** consolidate any remaining parallel constitutional prose into shims
- **Acceptance:** one live charter kernel, no competing constitutional authority source

## 2. Workspace Charter
- **Current path(s):** `instance/charter/workspace.{md,yml}`
- **Target path(s):** preserve
- **Schema/version:** `workspace-charter-v1`
- **Producer:** repo governance owners
- **Consumer:** run-contract generator, authority engine, ingress
- **Lifecycle:** authored → amended → superseded
- **Machine enforcement:** workspace-charter validator
- **Migration:** align machine and pair contracts to run-contract-v3
- **Acceptance:** workspace pair validates and references only canonical runtime families

## 3. Mission Charter
- **Current path(s):** `instance/orchestration/missions/<mission-id>/mission.yml`
- **Target path(s):** preserve + add schema in `framework/constitution/contracts/objective/mission-charter-v1.schema.json`
- **Producer:** mission owners
- **Consumer:** authority engine, runtime, support-tier policy
- **Lifecycle:** authored → active → paused/retired
- **Machine enforcement:** mission-charter validator
- **Migration:** bind all live missions to mission-charter schema
- **Acceptance:** every live mission validates against standalone schema

## 4. Run Contract
- **Current path(s):** split between `objective/run-contract-v1` and `runtime/run-contract-v2`; live files under `state/control/execution/runs/<run-id>/run-contract.yml`
- **Target path(s):** canonical schema at `framework/constitution/contracts/runtime/run-contract-v3.schema.json`
- **Producer:** run generator / operator / automation / model draft, finalized by harness
- **Consumer:** authority engine, runtime, disclosure, assurance
- **Lifecycle:** drafted → routed → active → closed
- **Machine enforcement:** single-family validator
- **Migration:** v1/v2 become shims only
- **Acceptance:** all live claim-bearing runs reference v3

## 5. ApprovalRequest
- **Current path(s):** `state/control/execution/approvals/requests/**`
- **Target path(s):** preserve
- **Schema/version:** `approval-request-v1`
- **Producer:** harness, operator, or model-drafted request path
- **Consumer:** approvers, authority engine
- **Lifecycle:** created → pending → granted/denied/cancelled
- **Machine enforcement:** request schema validator
- **Migration:** none major
- **Acceptance:** every consequential approval flow begins from a request artifact

## 6. ApprovalGrant
- **Current path(s):** `state/control/execution/approvals/grants/**`
- **Target path(s):** preserve
- **Schema/version:** `approval-grant-v1`
- **Producer:** approvers/human authorities
- **Consumer:** authority engine, runtime
- **Lifecycle:** issued → active → expired/revoked
- **Machine enforcement:** grant schema validator
- **Migration:** rebind to standalone quorum policy
- **Acceptance:** no host surface acts as grant source

## 7. ExceptionLease
- **Current path(s):** aggregate set-file semantics
- **Target path(s):** `state/control/execution/exceptions/leases/<lease-id>.yml`
- **Schema/version:** `exception-lease-v1`
- **Producer:** human authorities
- **Consumer:** authority engine
- **Lifecycle:** issued → active → expired/renewed/revoked
- **Machine enforcement:** lease schema validator
- **Migration:** per-artifact normalization + optional generated index
- **Acceptance:** no live lease exists only in anonymous set form

## 8. Revocation
- **Current path(s):** aggregate set-file semantics
- **Target path(s):** `state/control/execution/revocations/<subject-class>/<revocation-id>.yml`
- **Schema/version:** `revocation-v1`
- **Producer:** human or break-glass authorities
- **Consumer:** authority engine, runtime
- **Lifecycle:** issued → enforced → closed
- **Machine enforcement:** revocation schema validator
- **Migration:** per-artifact normalization + optional generated index
- **Acceptance:** revocation path is explicit and machine-verifiable

## 9. QuorumPolicy
- **Current path(s):** implicit in mission-autonomy policy
- **Target path(s):** `framework/constitution/contracts/authority/quorum-policy-v1.schema.json`, instance declarations under `instance/governance/contracts/quorum-policies/**`
- **Producer:** governance owners
- **Consumer:** ApprovalRequest / ApprovalGrant / DecisionArtifact
- **Lifecycle:** authored → active → superseded
- **Machine enforcement:** quorum binding validator
- **Migration:** remove embedded quorum as canonical source
- **Acceptance:** approvals reference first-class quorum contracts only

## 10. DecisionArtifact
- **Current path(s):** `state/evidence/control/execution/authority-decision-*.yml`
- **Target path(s):** preserve
- **Schema/version:** `decision-artifact-v1`
- **Producer:** authority engine
- **Consumer:** runtime, disclosure, certification
- **Lifecycle:** emitted → immutable
- **Machine enforcement:** cross-artifact consistency validators
- **Migration:** none major
- **Acceptance:** every live route is represented by a decision artifact that agrees with all downstream artifacts

## 11. Model Adapter Contract
- **Current path(s):** `framework/engine/runtime/adapters/model/**`
- **Target path(s):** preserve
- **Schema/version:** `model-adapter-v1`
- **Producer:** runtime owners
- **Consumer:** runtime, support-target admission, assurance
- **Lifecycle:** drafted → conformance-tested → admitted → deprecated/retired
- **Machine enforcement:** adapter conformance validator
- **Migration:** keep provider-specific policy out of the kernel
- **Acceptance:** no live model support without adapter conformance

## 12. Capability/Tool Contract
- **Current path(s):** capability packs and manifests
- **Target path(s):** preserve, normalize contract declarations
- **Schema/version:** `capability-contract-v1`
- **Producer:** capability owners
- **Consumer:** authority engine, runtime, support matrix
- **Lifecycle:** authored → admitted → retired
- **Machine enforcement:** support subset validator
- **Migration:** widen only through governed pack admission
- **Acceptance:** every live pack in a support tuple is contract-backed

## 13. Host Adapter Contract
- **Current path(s):** `framework/engine/runtime/adapters/host/**`
- **Target path(s):** preserve
- **Schema/version:** `host-adapter-v1`
- **Producer:** runtime owners
- **Consumer:** authority engine, host projection layer
- **Lifecycle:** authored → admitted → deprecated/retired
- **Machine enforcement:** host non-authority validator
- **Migration:** keep host projections auditable
- **Acceptance:** no host-native surface authorizes execution

## 14. Run Manifest
- **Current path(s):** `state/control/execution/runs/<run-id>/run-manifest.yml`
- **Target path(s):** preserve
- **Schema/version:** `run-manifest-v1`
- **Producer:** runtime
- **Consumer:** replay, disclosure, assurance
- **Lifecycle:** opened → immutable closeout summary
- **Machine enforcement:** run bundle completeness validator
- **Migration:** none major
- **Acceptance:** every active exemplar run has a valid manifest

## 15. Execution Attempt / Stage Contract
- **Current path(s):** stage-attempt schema family and runtime roots
- **Target path(s):** runtime `stage-attempt-v2`
- **Schema/version:** `stage-attempt-v2`
- **Producer:** runtime
- **Consumer:** assurance, replay, continuity
- **Lifecycle:** created → executed → finalized
- **Machine enforcement:** stage-attempt validator
- **Migration:** objective family becomes shim only
- **Acceptance:** live runs bind runtime stage family only

## 16. Checkpoint
- **Current path(s):** runtime checkpoint schema + run roots
- **Target path(s):** preserve / upgrade if needed
- **Schema/version:** `checkpoint-v2` if current family insufficient
- **Producer:** runtime
- **Consumer:** resume, recovery proof, continuity
- **Lifecycle:** emitted → immutable
- **Machine enforcement:** checkpoint schema + recovery validator
- **Acceptance:** every material stage boundary is checkpointable and resumable

## 17. Continuity Artifact
- **Current path(s):** `state/continuity/{repo,scopes,missions,runs}/**`
- **Target path(s):** preserve + normalize run continuity
- **Schema/version:** `continuity-artifact-v1`
- **Producer:** runtime / humans with audit trail
- **Consumer:** next run, review, replay
- **Lifecycle:** updated during work, stabilized at closeout
- **Machine enforcement:** continuity validator
- **Acceptance:** run continuity exists and points to checkpoints and handoff notes

## 18. Assurance Report
- **Current path(s):** `state/evidence/runs/<run-id>/assurance/**`
- **Target path(s):** preserve
- **Schema/version:** plane-specific assurance report v1
- **Producer:** assurance / lab / evaluators
- **Consumer:** disclosure, certification
- **Lifecycle:** emitted → immutable
- **Machine enforcement:** proof-plane completeness validator
- **Acceptance:** every required plane for a live tuple is present and valid

## 19. Intervention Record
- **Current path(s):** `state/evidence/runs/<run-id>/interventions/**`
- **Target path(s):** preserve
- **Schema/version:** `intervention-record-v1`
- **Producer:** runtime, host adapters, humans
- **Consumer:** disclosure, certification, audits
- **Lifecycle:** appended → immutable
- **Machine enforcement:** intervention completeness validator
- **Acceptance:** no live claim excludes interventions if they occurred

## 20. Measurement Record
- **Current path(s):** `state/evidence/runs/<run-id>/measurements/**`
- **Target path(s):** preserve, normalize generated summaries
- **Schema/version:** `measurement-record-v1`
- **Producer:** runtime, observability, lab
- **Consumer:** RunCard, HarnessCard, certification
- **Lifecycle:** emitted → summarized → immutable snapshots
- **Machine enforcement:** wording coherence + completeness validators
- **Acceptance:** summaries are regenerated and claim-coherent

## 21. RunCard
- **Current path(s):** `state/evidence/disclosure/runs/<run-id>/run-card.yml`
- **Target path(s):** preserve
- **Schema/version:** `run-card-v1`
- **Producer:** generator only
- **Consumer:** humans, HarnessCard, certification
- **Lifecycle:** generated at closeout; immutable
- **Machine enforcement:** schema + cross-artifact validators
- **Acceptance:** every active exemplar run has a valid RunCard generated from canonical sources

## 22. HarnessCard
- **Current path(s):** release bundle + stable mirror
- **Target path(s):** canonical release-bundle artifact, generated stable mirror
- **Schema/version:** `harness-card-v2`
- **Producer:** generator only
- **Consumer:** release lineage, certification, humans
- **Lifecycle:** per release
- **Machine enforcement:** freshness + wording + projection parity validators
- **Acceptance:** active HarnessCard reflects only the active release bundle

## 23. Evidence Retention Contract
- **Current path(s):** schema family plus replay/external-index practice
- **Target path(s):** preserve and deepen
- **Schema/version:** `evidence-retention-contract-v1`
- **Producer:** constitutional / governance owners
- **Consumer:** replay store, disclosure, export logic
- **Lifecycle:** authored → active → superseded
- **Machine enforcement:** evidence-class and replay validators
- **Acceptance:** every active exemplar run is correctly classified and externally indexed where required
