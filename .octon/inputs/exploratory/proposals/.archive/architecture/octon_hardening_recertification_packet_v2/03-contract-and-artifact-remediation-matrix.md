# Contract and Artifact Remediation Matrix

This matrix is intentionally implementation-grade. For each family it records:

- current status
- canonical vs shim / projection / mirror status
- key current path(s)
- validator/runtime status
- disclosure status
- required remediation
- release-close criteria

---

## 1. Harness Charter

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/framework/constitution/CHARTER.md`
  - `/.octon/framework/constitution/charter.yml`
- **Validator/runtime status:** already consumed by constitutional precedence and closure logic
- **Disclosure status:** reflected indirectly through active HarnessCard and closure bundle
- **Required remediation:** preserve; add only cross-links if new hardening-close reports become claim-truth inputs
- **Release-close criteria:** no conflicting charter-like surface is marked co-equal authority

## 2. Workspace Charter

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/instance/charter/workspace.md`
  - `/.octon/instance/charter/workspace.yml`
- **Validator/runtime status:** consumed by objective hierarchy and run contract grounding
- **Disclosure status:** reflected through closure claim and support-target scope
- **Required remediation:** preserve unchanged
- **Release-close criteria:** no fallback to retired bootstrap objective surfaces

## 3. Mission Charter

- **Current status:** implemented and live
- **Canonical status:** canonical continuity authority
- **Current paths:**
  - `/.octon/instance/orchestration/missions/**`
  - `/.octon/instance/orchestration/missions/registry.yml`
- **Validator/runtime status:** mission registry already distinguishes mission role from execution unit
- **Disclosure status:** reflected in RunCards and support dossiers for mission-backed tuples
- **Required remediation:** preserve; no structural change
- **Release-close criteria:** mission remains continuity/ownership authority, not sole atomic execution primitive

## 4. Run Contract

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json`
  - `/.octon/state/control/execution/runs/**/run-contract.yml`
- **Validator/runtime status:** live runtime family; needs deeper artifact-depth validation
- **Disclosure status:** summarized in RunCards and closure support-universe evidence
- **Required remediation:** preserve + harden
- **Release-close criteria:** every admitted consequential run passes runtime-family depth validation against run-contract requirements

## 5. Run Manifest

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/control/execution/runs/**/run-manifest.yml`
- **Validator/runtime status:** live runtime envelope; link integrity should be deepened
- **Disclosure status:** feeds RunCards / retained run evidence
- **Required remediation:** preserve + harden
- **Release-close criteria:** manifest refs resolve to real stage/checkpoint/evidence artifacts for all admitted tuples

## 6. ApprovalRequest

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/control/execution/approvals/requests/**`
- **Validator/runtime status:** authority family is live; lineage validator to be strengthened
- **Disclosure status:** represented in authority evidence and release closeout
- **Required remediation:** preserve
- **Release-close criteria:** no authority-bearing run requiring approval lacks a canonical request artifact

## 7. ApprovalGrant

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/control/execution/approvals/grants/**`
  - authority grant bundles under `/.octon/state/evidence/control/execution/**`
- **Validator/runtime status:** live, but lineage purity should be deepened
- **Disclosure status:** must remain referenced from run evidence and closure bundles
- **Required remediation:** preserve + harden
- **Release-close criteria:** no host projection can stand in for a missing canonical grant

## 8. ExceptionLease

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/control/execution/exceptions/**`
- **Validator/runtime status:** live family; lineage and disclosure linkage should deepen
- **Disclosure status:** must surface through authority evidence and closure reports
- **Required remediation:** preserve + harden
- **Release-close criteria:** every active lease referenced by run evidence is canonical and resolvable

## 9. Revocation

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/control/execution/revocations/**`
- **Validator/runtime status:** live family; lineage purity should deepen
- **Disclosure status:** must surface in authority evidence and closure reports
- **Required remediation:** preserve + harden
- **Release-close criteria:** any run depending on revocation state cites canonical revocation artifacts only

## 10. QuorumPolicy

- **Current status:** implemented and live
- **Canonical status:** canonical governance contract
- **Current paths:**
  - `/.octon/instance/governance/contracts/quorum-policies/**`
- **Validator/runtime status:** consumed by approvals / authority evaluation
- **Disclosure status:** indirect, via approval route evidence
- **Required remediation:** preserve
- **Release-close criteria:** requests requiring quorum remain linked to canonical quorum policies

## 11. DecisionArtifact

- **Current status:** implemented and live
- **Canonical status:** canonical evidence
- **Current paths:**
  - `/.octon/state/evidence/control/execution/authority-decision-*.yml`
- **Validator/runtime status:** core authority truth anchor; should remain the object all host projections point at
- **Disclosure status:** referenced in run evidence and closeout
- **Required remediation:** preserve
- **Release-close criteria:** every routed consequential run has canonical decision evidence

## 12. Host Adapter Contract

- **Current status:** implemented and live
- **Canonical status:** canonical, but non-authoritative / projection-only
- **Current paths:**
  - `/.octon/framework/engine/runtime/adapters/host/**`
- **Validator/runtime status:** needs stronger host-authority-purity checks
- **Disclosure status:** should be referenced in support tuples and RunCards where relevant
- **Required remediation:** harden
- **Release-close criteria:** zero host-native authority recreation paths in workflows or adapter contracts

## 13. Model Adapter Contract

- **Current status:** implemented and live
- **Canonical status:** canonical replaceable adapter family
- **Current paths:**
  - `/.octon/framework/engine/runtime/adapters/model/**`
- **Validator/runtime status:** live; evidence/conformance should refresh at recertification
- **Disclosure status:** appears in RunCards / HarnessCard and support tuples
- **Required remediation:** preserve + strengthen (evidence, not architecture)
- **Release-close criteria:** no widening; refreshed conformance evidence for admitted model classes

## 14. Capability / Pack Contracts

- **Current status:** implemented and live
- **Canonical status:** canonical pack regime
- **Current paths:**
  - `/.octon/framework/capabilities/packs/**`
  - repo-local overlays/admissions under `/.octon/instance/governance/**`
- **Validator/runtime status:** already governed by admissions and support targets
- **Disclosure status:** packs disclosed through tuples and run evidence
- **Required remediation:** preserve; no new admissions during hardening
- **Release-close criteria:** current packs remain bounded and dossier-backed

## 15. Stage-Attempt Contract

- **Current status:** implemented as schema family + live roots
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/framework/constitution/contracts/runtime/stage-attempt-v2.schema.json`
  - `/.octon/state/control/execution/runs/**/stage-attempts/**`
- **Validator/runtime status:** live family; needs deeper content and linkage validation
- **Disclosure status:** currently indirect; should become visible in RunCard artifact-depth block
- **Required remediation:** harden
- **Release-close criteria:** every required stage-attempt artifact validates and is reflected in disclosure

## 16. Checkpoint

- **Current status:** implemented as schema family + live roots
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/framework/constitution/contracts/runtime/checkpoint-v1.schema.json`
  - `/.octon/state/control/execution/runs/**/checkpoints/**`
- **Validator/runtime status:** live family; deeper link validation required
- **Disclosure status:** indirect; should appear in RunCard artifact-depth summary
- **Required remediation:** harden
- **Release-close criteria:** runtime-state never references a missing or invalid checkpoint

## 17. Continuity Artifact

- **Current status:** live family
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/continuity/**`
  - continuity schema family under `/.octon/framework/constitution/contracts/runtime/**`
- **Validator/runtime status:** present; continuity-linkage validator needed
- **Disclosure status:** currently indirect; should become explicitly summarized where continuity is applicable
- **Required remediation:** harden
- **Release-close criteria:** every admitted class requiring continuity has deterministic linkage and disclosure

## 18. Contamination Record

- **Current status:** live family
- **Canonical status:** canonical
- **Current paths:**
  - contamination roots under `/.octon/state/control/execution/runs/**/contamination/**`
  - contamination schema family under `/.octon/framework/constitution/contracts/runtime/**`
- **Validator/runtime status:** present; needs explicit clean / detected coverage
- **Disclosure status:** currently indirect; should become explicitly summarized
- **Required remediation:** harden
- **Release-close criteria:** contamination/reset posture is runtime-backed and auditable for admitted classes that claim it

## 19. Retry Record

- **Current status:** live family
- **Canonical status:** canonical
- **Current paths:**
  - retry roots under `/.octon/state/control/execution/runs/**/retry-records/**`
  - retry schema family under `/.octon/framework/constitution/contracts/runtime/**`
- **Validator/runtime status:** present; zero-retry / retry-class handling should be explicit
- **Disclosure status:** currently indirect; should become explicitly summarized
- **Required remediation:** harden
- **Release-close criteria:** retry posture is explicit for all admitted classes where retries are part of runtime semantics

## 20. Assurance Reports (all proof planes)

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/evidence/runs/**/assurance/**`
- **Validator/runtime status:** already live and substantive; behavioral / recovery should tighten lab-reference parity
- **Disclosure status:** summarized in RunCards and closure bundles
- **Required remediation:** preserve + strengthen
- **Release-close criteria:** proof-plane claims resolve cleanly to retained evidence and lab references

## 21. Intervention Record

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/evidence/runs/**/interventions/**`
- **Validator/runtime status:** present and materially used
- **Disclosure status:** already surfaces in RunCards / review bundles
- **Required remediation:** preserve
- **Release-close criteria:** no hidden human repair in recertified release bundle

## 22. Measurement Record

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/evidence/runs/**/measurements/**`
- **Validator/runtime status:** present; could benefit from freshness / artifact-depth rollups
- **Disclosure status:** summarized in RunCards and closure bundles
- **Required remediation:** preserve + strengthen
- **Release-close criteria:** measurement summaries remain traceable and support-bounded

## 23. RunCard

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/state/evidence/disclosure/runs/**/run-card.yml`
- **Validator/runtime status:** present and used; should gain artifact-depth block
- **Disclosure status:** already canonical per-run disclosure
- **Required remediation:** preserve + harden
- **Release-close criteria:** RunCards become the explicit place where runtime-family completeness is visible

## 24. HarnessCard

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - authored source under `/.octon/instance/governance/disclosure/**`
  - active release copy under `/.octon/state/evidence/disclosure/releases/**`
- **Validator/runtime status:** parity-backed
- **Disclosure status:** live claim-bearing surface
- **Required remediation:** recalibrate `known_limits` and tie it to residual ledger
- **Release-close criteria:** no authored release artifact overstates residual reality

## 25. Evidence Retention / Disclosure Retention Contract

- **Current status:** implemented and live
- **Canonical status:** canonical governance contract
- **Current paths:**
  - `/.octon/instance/governance/contracts/disclosure-retention.yml`
- **Validator/runtime status:** already influences evidence classification / disclosure behavior
- **Disclosure status:** indirectly represented in evidence classes and release bundles
- **Required remediation:** preserve + minor harden for mirror/projection handling in closeout
- **Release-close criteria:** mirror/projection status remains subordinate and explicit

## 26. Support Target Admissions

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/instance/governance/support-target-admissions/**`
- **Validator/runtime status:** already part of bounded support universe; needs stronger dossier/proof/lab parity checks
- **Disclosure status:** closure and support-universe evidence rely on them
- **Required remediation:** preserve + harden
- **Release-close criteria:** no tuple remains claim-bearing with broken dossier/proof/lab references

## 27. Support Dossiers

- **Current status:** implemented and live
- **Canonical status:** canonical
- **Current paths:**
  - `/.octon/instance/governance/support-dossiers/**`
- **Validator/runtime status:** already substantive; needs deterministic scenario/evidence resolution
- **Disclosure status:** support-universe coverage and closure bundle depend on them
- **Required remediation:** preserve + harden
- **Release-close criteria:** every required scenario and proof reference resolves cleanly

## 28. Closure / Recertification / Release-Lineage artifacts

- **Current status:** implemented and live
- **Canonical status:** canonical claim-bearing surfaces
- **Current paths:**
  - `/.octon/instance/governance/closure/**`
  - `/.octon/instance/governance/disclosure/release-lineage.yml`
  - `/.octon/state/evidence/disclosure/releases/**`
  - `/.octon/generated/effective/closure/**`
- **Validator/runtime status:** present and active
- **Disclosure status:** active release claim already depends on them
- **Required remediation:** harden + recalibrate by adding residual ledger, hardening reports, and two-pass recertification discipline
- **Release-close criteria:** next active release is only cut over after all claim-critical items close and parity remains green
