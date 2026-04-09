# Octon Architectural Hardening, Simplification, Disclosure-Calibration, and Recertification Proposal Packet

**Repository:** `https://github.com/jamesryancooper/octon`  
**Grounding date:** 2026-04-09  
**Packet posture:** preserve the already-substantiated bounded Unified Execution Constitution; close the remaining hardening and hygiene weaknesses without reopening settled constitutional design.

**Audit inclusion note:** this revised packet now includes the full implementation audit as `AUDIT.md` plus a packet-local digest/crosswalk in `01-audit-annex-and-crosswalk.md`, so the proposal is self-contained rather than merely audit-dependent.

---

### A. Executive Hardening Verdict

Octon’s current repository already materially substantiates a **bounded, support-target-scoped Unified Execution Constitution**. The constitutional kernel, dual precedence, workspace/mission/run layering, canonical approval-exception-revocation families, durable run roots, classed evidence, canonical RunCard/HarnessCard disclosure, top-level lab and observability domains, adapter-mediated portability, support-target admissions/dossiers, and active closure/release lineage should be **preserved**, not reopened. This packet therefore does **not** recommend a greenfield redesign, a support-scope expansion, or a rollback of the attained constitutional structure.

The hardening program is compatible with preserving the current bounded claim, but only if Octon treats the next release as a **hardening recertification release**, not as a wider architectural or support-universe leap. Five issue classes should be treated as **claim-critical for the next recertified release**:

1. **Lab scenario / dossier / proof reference integrity**  
2. **Host-workflow / host-adapter authority purity**  
3. **Runtime artifact-depth validation for stage-attempt / checkpoint / continuity / contamination / retry families**  
4. **Disclosure and HarnessCard calibration, especially `known_limits` and residual-item honesty**  
5. **Retirement / retain-rationale discipline for transitional, shim, and scaffold surfaces that could otherwise survive closure ambiguously**

These do **not** negate the present active bounded claim. They **do** create the main ways the next claim-bearing release could become overstated if left un-hardened.

Everything else in the packet is lower-severity by comparison: support-universe evidence deepening, evaluator breadth, agency-kernel simplification, retirement-register depth, and operator-clarity cleanup. Those matter, but they should be handled without destabilizing the already-proven constitutional core.

The packet’s governing rule is simple: **freeze the admitted support universe, preserve the constitutional kernel, harden the weak seams, recalibrate disclosure, and only then recertify.**

---

### B. Live Canonical Surface and Claim-Preservation Map

The following live surfaces are treated as **preserve by default** because the audit found them materially implemented and claim-bearing:

| Live surface family | Current role | Preserve / change | Packet stance |
|---|---|---|---|
| `/.octon/framework/constitution/**` | Supreme canonical kernel | **Preserve** | No redesign; only small clarification and recertification cross-link additions if required |
| `/.octon/framework/constitution/contracts/registry.yml` | Canonical vs shim/projection/mirror authority map | **Preserve + harden** | Extend only where new release-hardening reports or explicit demotions must be registered |
| `/.octon/framework/constitution/claim-truth-conditions.yml` | Live truth conditions for closure claims | **Preserve + harden** | Add only the extra hardening checks that now matter for future recertification |
| `/.octon/octon.yml` and `/.octon/README.md` | Root manifest and super-root constitutional topology | **Preserve** | Do not reopen topology or root-class structure |
| `/.octon/instance/charter/**` | Workspace charter pair | **Preserve** | Keep objective hierarchy intact |
| `/.octon/instance/orchestration/missions/**` | Mission continuity authority | **Preserve** | Keep mission as continuity authority, not atomic execution primitive |
| `/.octon/state/control/execution/runs/**` | Canonical live run control root | **Preserve + harden** | Keep run-centered execution; deepen validator coverage |
| `/.octon/state/control/execution/{approvals,exceptions,revocations}/**` | Canonical live authority families | **Preserve + harden** | Prove host projection purity and lineage more aggressively |
| `/.octon/state/continuity/**` | Canonical continuity family | **Preserve + harden** | Strengthen continuity-artifact validation and disclosure depth |
| `/.octon/state/evidence/runs/**` | Canonical retained run evidence | **Preserve + harden** | Tighten runtime-family completeness and lab/proof linkage |
| `/.octon/state/evidence/control/execution/**` | Canonical retained authority evidence | **Preserve + harden** | Improve lineage assertions and release review parity |
| `/.octon/state/evidence/disclosure/**` | Canonical RunCard / HarnessCard / release disclosure roots | **Preserve + recalibrate** | Keep as canonical; improve claim calibration and residual disclosure |
| `/.octon/state/evidence/lab/**` | Canonical retained lab evidence | **Preserve + harden** | Add deterministic authored-scenario ↔ retained-evidence alignment |
| `/.octon/framework/lab/**` | Top-level authored lab domain | **Preserve + harden** | No new lab root; normalize scenario manifests and integrity checks inside current root |
| `/.octon/framework/observability/**` | Top-level authored observability domain | **Preserve** | Extend only where disclosure / release review needs more explicit receipts |
| `/.octon/framework/engine/runtime/adapters/{host,model}/**` | Replaceable non-authoritative adapter roots | **Preserve + harden** | Keep adapter model; add stronger purity and conformance receipts |
| `/.octon/framework/capabilities/packs/**` | Governed capability pack regime | **Preserve** | No support widening before hardening-close |
| `/.octon/instance/governance/support-targets.yml` + admissions + dossiers | Bounded admitted support universe | **Preserve + harden** | Freeze support scope; deepen parity and evidence within current universe |
| `/.octon/instance/governance/retirement-register.yml` | Build-to-delete ledger | **Preserve + harden** | Increase operational depth; do not redesign mechanism |
| `/.octon/instance/governance/disclosure/release-lineage.yml` | Single active release lineage | **Preserve + update at recertification only** | Keep current release active until hardened successor is fully certified |
| `/.github/workflows/**` | Live enforcement layer | **Preserve + harden** | Extend current workflows rather than proliferating new top-level control planes |

**Claim-preservation rule:** until the hardening packet closes the claim-critical items, do not widen `support-targets.yml`, do not admit new adapters or packs, and do not publish a new active claim-bearing release.

---

### C. Repository-Grounded Preserved Baseline

The following are already sufficiently implemented and should **not** be destabilized:

#### C1. Constitutional kernel and dual precedence

Octon now has a real constitutional kernel and an explicit split between **normative authority precedence** and **epistemic grounding precedence**. This is not a place for redesign. The hardening program should only add recertification checks where the closure logic needs them.

**Preserve as-is:**
- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/framework/constitution/precedence/epistemic.yml`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/claim-truth-conditions.yml`

#### C2. Objective hierarchy and mission/run split

The current hierarchy — **workspace charter → mission charter → run contract → stage-attempt family** — is correct and should not be destabilized. The repo has already crossed the “mission is not the only execution primitive” threshold.

**Preserve as-is:**
- `/.octon/instance/charter/**`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/state/control/execution/runs/**`

#### C3. Canonical authority migration

Authority has already moved into canonical artifacts. Labels/comments/checks are no longer the intended authority source. Preserve that architecture and harden its enforcement.

**Preserve as-is:**
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exceptions/**`
- `/.octon/state/control/execution/revocations/**`
- `/.octon/state/evidence/control/execution/**`

#### C4. Durable run semantics and evidence classes

The repo already treats runs as durable lifecycle units with manifests, runtime state, checkpoints, rollback posture, evidence classification, and replay indices. Preserve this shape; do not collapse back into mission-only or chat-continuity assumptions.

**Preserve as-is:**
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/continuity/**`
- `/.octon/state/evidence/runs/**`
- `/.octon/instance/governance/contracts/disclosure-retention.yml`

#### C5. Top-level lab and observability

Lab and observability are already first-class authored domains. Keep them top-level. The hardening problem is not whether they should exist, but whether their references and disclosures are fully path-clean and recertification-ready.

**Preserve as-is:**
- `/.octon/framework/lab/**`
- `/.octon/framework/observability/**`

#### C6. Adapter-mediated portability and capability packs

The portable-kernel vs non-portable-adapter split is correct. Support-target boundedness, adapter contracts, and capability-pack admissions are already the right shape.

**Preserve as-is:**
- `/.octon/framework/engine/runtime/adapters/{host,model}/**`
- `/.octon/framework/capabilities/**`
- `/.octon/framework/capabilities/packs/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**`

#### C7. Disclosure, release-lineage, and closure bundles

The repo already has the correct core disclosure model:
- canonical RunCards,
- canonical HarnessCard for the active release,
- explicit release lineage,
- explicit closure truth surfaces,
- generated/effective parity checks.

Do not reopen this architecture. Harden it.

**Preserve as-is:**
- `/.octon/state/evidence/disclosure/**`
- `/.octon/instance/governance/disclosure/**`
- `/.octon/instance/governance/closure/**`
- `/.octon/generated/effective/closure/**`

---

### D. Residual Claim-Critical and Non-Critical Issue Ledger

#### D1. Claim-critical issues

These issues do **not** invalidate the active bounded claim today, but they **must** be closed before the next recertified release can honestly continue the same claim posture.

| Issue ID | Title | Paths affected | Issue type | Action class | Execution mode | Why it matters |
|---|---|---|---|---|---|---|
| **CC-01** | Authored lab scenario / dossier / proof reference integrity | `framework/lab/**`, `instance/governance/support-dossiers/**`, `support-target-admissions/**`, `state/evidence/lab/**`, `state/evidence/runs/**/assurance/**` | claim-critical hardening / validator depth | harden | staged hardening | Future release claim honesty depends on complete-proof and admitted-universe references resolving deterministically |
| **CC-02** | Host projection authority purity | `.github/workflows/**`, `framework/engine/runtime/adapters/host/**`, `state/control/execution/{approvals,exceptions,revocations}/**`, `state/evidence/control/execution/**` | claim-critical hardening | harden | targeted cutover | Future release would become dishonest if workflows, labels, checks, or comments can silently recreate authority |
| **CC-03** | Runtime artifact-depth validation for stage-attempt / checkpoint / continuity / contamination / retry families | `framework/constitution/contracts/runtime/**`, `state/control/execution/runs/**`, `state/continuity/**`, `state/evidence/runs/**` | claim-critical hardening / validator depth | harden | staged hardening | Future durable-run / resumability claims need deeper deterministic coverage than “artifact families exist” |
| **CC-04** | HarnessCard and disclosure calibration | `instance/governance/disclosure/**`, `state/evidence/disclosure/releases/**`, `generated/effective/closure/**`, `instance/governance/closure/**` | disclosure calibration | recalibrate | targeted cutover | Current `known_limits: []` understates residual hardening work and could overstate the next release if left unchanged |
| **CC-05** | Retirement / retain-rationale discipline for transitional surfaces | `instance/governance/retirement-register.yml`, `instance/governance/contracts/closeout-reviews.yml`, `state/evidence/validation/publication/build-to-delete/**`, release closure roots | claim-critical hardening / retirement discipline | harden / normalize | targeted cutover | The next recertified release should not silently carry transitional or demoted surfaces without explicit retain-vs-retire rationale and release-reviewed disposition |

#### D2. Claim-strengthening but not currently claim-invalidating issues

| Issue ID | Title | Paths affected | Issue type | Action class | Execution mode | Why it matters |
|---|---|---|---|---|---|---|
| **CS-01** | Support-universe empirical depth | `support-dossiers/**`, `state/evidence/disclosure/runs/**`, `state/evidence/lab/**`, proof-plane roots | empirical evidence depth | harden | ongoing evidence deepening | Increases confidence and reduces tuple fragility, but current bounded claim is still supportable |
| **CS-02** | Evaluator and hidden-check breadth | `framework/assurance/evaluators/**`, `framework/lab/**`, CI workflows | empirical evidence depth | harden | ongoing evidence deepening | Improves anti-overfitting posture and proof credibility |

#### D3. Simplification / retirement / hygiene issues

| Issue ID | Title | Paths affected | Issue type | Action class | Execution mode | Why it matters |
|---|---|---|---|---|---|---|
| **SR-01** | Agency-kernel persona residue | `framework/agency/**`, `instance/ingress/AGENTS.md`, root `AGENTS.md`, `CLAUDE.md` | simplification | simplify / demote | staged hardening | Interpretive ambiguity remains higher than necessary |
| **SR-02** | Retirement-register operational depth | `instance/governance/retirement-register.yml`, closeout / support review contracts | retirement | harden / normalize | staged hardening | Build-to-delete is real but still shallow |
| **SR-03** | Residual shim / mirror retention rationale | `framework/constitution/contracts/registry.yml`, `retirement-register.yml`, disclosure/closure release bundle | simplification / retirement | normalize | targeted cutover | Keeps canonical vs shim status explicit and honest |
| **SR-04** | Generated/effective operator ambiguity | `generated/effective/**`, projection parity reports | simplification | harden | targeted cutover | Avoids projection-over-authority confusion |

---

### E. Proposal/Packet Delta Summary

The earlier proposal and design packet in this thread assumed Octon still needed to become a unified execution constitution. The current repo and audit materially supersede that assumption.

**What changes now:**

1. **From target-state invention to hardening program.**  
   The constitutional kernel, run-centered execution model, top-level lab, top-level observability, support-target boundedness, and release/closure discipline are already live.

2. **From support expansion to support freezing.**  
   The right next move is not more adapters, more packs, or more tuple admissions. It is stronger proof, cleaner lab/dossier alignment, stronger host-authority purity, deeper runtime-family validation, and calibrated disclosure.

3. **From greenfield contract creation to contract-depth hardening.**  
   Most required contract families already exist. The hardening packet therefore focuses on validator depth, lineage purity, disclosure calibration, and release-closeout discipline.

4. **From “is Octon a UEC?” to “how does Octon keep that bounded claim honest over time?”**  
   The central architectural question is now recertification integrity, not initial attainment.

5. **From abstract build-to-delete to operational retirement.**  
   The repo already has a retirement register. The delta is to deepen its operational use and require retention-vs-retirement rationale at each release close.

---

### F. Layer-by-Layer Hardening Architecture

#### 1. Design Charter / Constitutional Layer
- **Remain correct:** constitutional singularity, dual precedence, claim-truth discipline, support-target bounded claim framing
- **Harden:** add explicit recertification-facing hardening checks into claim-truth / closure bundle inputs
- **Simplify:** continue demoting historical charter-like surfaces to shims
- **Deferred:** physical deletion of historical charters where lineage still benefits from retention
- **Why:** the architecture is already correct; only claim-preservation hardening is required

#### 2. Intent / Objective Layer
- **Remain correct:** workspace → mission → run → stage hierarchy
- **Harden:** stronger validation and disclosure coverage for stage-attempts, checkpoints, and continuity artifacts
- **Simplify:** no structural change
- **Deferred:** broader run-only/mission-only support differentiation beyond current admitted tiers
- **Why:** the model is right; the validator/disclosure depth is the remaining softness

#### 3. Durable Control Layer
- **Remain correct:** authored authority vs operational truth vs generated projection boundaries
- **Harden:** add explicit release-closeout checks that generated/effective status never outruns authored closure/disclosure
- **Simplify:** no new control surfaces
- **Deferred:** operator UX simplification around generated/effective views
- **Why:** preserve class-root system-of-record behavior

#### 4. Policy / Authority Layer
- **Remain correct:** canonical approvals / grants / exceptions / revocations, support-target and exclusion interplay
- **Harden:** workflow and host adapter purity so no host-native affordance can mint authority
- **Simplify:** none in the authority model itself
- **Deferred:** richer host adapter reporting ergonomics
- **Why:** this is the highest-risk area for future claim drift

#### 5. Agency Layer
- **Remain correct:** single accountable orchestrator kernel, routing, delegation discipline, memory/ownership surfaces
- **Harden:** explicit non-authoritative labeling of any remaining identity/persona overlays in ingress and agency-adjacent surfaces
- **Simplify:** continue demoting persona-heavy ingress and agent identity surfaces from the operational path
- **Deferred:** full physical deletion of retained identity overlays if they remain useful lineage references
- **Why:** current ambiguity is mostly interpretive, not authoritative

#### 6. Runtime Layer
- **Remain correct:** durable run semantics, runtime-state, run-manifest, stage-attempt root, checkpoints, rollback posture
- **Harden:** artifact-depth validation and disclosure for stage-attempt / checkpoint / continuity / contamination / retry families
- **Simplify:** no structural runtime change
- **Deferred:** deeper runtime analytics beyond hardening requirements
- **Why:** the durable run model is already present; the weak seam is proof depth

#### 7. Verification / Evaluation Layer
- **Remain correct:** six proof planes, evaluator routing, deterministic validation families
- **Harden:** stronger evaluator diversity, hidden-check path references, behavioral/recovery evidence depth
- **Simplify:** no structural change
- **Deferred:** major evaluator-family expansion
- **Why:** proof exists; its traceability and breadth should strengthen

#### 8. Lab / Experimentation Layer
- **Remain correct:** top-level authored lab plus retained lab evidence roots
- **Harden:** deterministic scenario indexing and dossier/admission/proof/evidence resolution
- **Simplify:** no new lab roots
- **Deferred:** broad scenario-family expansion
- **Why:** the remaining issue is path hygiene, not missing architecture

#### 9. Governance / Safety Layer
- **Remain correct:** bounded support universe, exclusions, review contracts, closure / recertification machinery
- **Harden:** residual-ledger, retention-rationale, and known-limits release discipline
- **Simplify:** none
- **Deferred:** broader governance UX/reporting
- **Why:** governance is already strong; the missing piece is explicit residual-item management

#### 10. Observability / Reporting Layer
- **Remain correct:** RunCards, HarnessCards, measurement/intervention evidence, failure taxonomies, parity reporting
- **Harden:** known-limits calibration, artifact-depth summary rollups, release-bound hardening receipts
- **Simplify:** none
- **Deferred:** richer operator dashboards
- **Why:** disclosure is real but slightly over-optimistic

#### 11. Improvement / Evolution Layer
- **Remain correct:** retirement register, drift watch, review contracts, recertification triggers
- **Harden:** operational build-to-delete practice, explicit release-by-release retirement/retention review
- **Simplify:** none
- **Deferred:** broader ablation corpus
- **Why:** the mechanism exists; the discipline needs more operational depth

#### 12. Canonical / Shim / Mirror / Projection Layer
- **Remain correct:** registry already distinguishes these classes explicitly
- **Harden:** tie each retained shim/mirror/projection to a release-bound rationale
- **Simplify:** continue shrinking non-canonical interpretive surfaces
- **Deferred:** physical deletion where historical retention still helps lineage
- **Why:** authority is already singular, but human interpretation still benefits from stricter hygiene

---

### G. Contract and Artifact Remediation Matrix

> Expanded, family-by-family detail appears in `03-contract-and-artifact-remediation-matrix.md`. This section states the required disposition for each required family.

| Artifact family | Current status | Canonical / shim / projection status | Required action | Validator / CI / disclosure implication | Closure criteria |
|---|---|---|---|---|---|
| Harness Charter | Implemented | Canonical | **Preserve** | No change beyond claim-truth cross-link additions if needed | Constitutional singularity unchanged |
| Workspace Charter | Implemented | Canonical | **Preserve** | Keep objective SSOT role | No fallback to retired bootstrap objective |
| Mission Charter | Implemented | Canonical continuity surface | **Preserve** | No change | Mission remains continuity authority, not atomic execution primitive |
| Run Contract | Implemented | Canonical | **Preserve + harden** | Add runtime-family completeness checks | Every admitted consequential run has complete control/evidence linkage |
| Run Manifest | Implemented | Canonical | **Preserve + harden** | Link-integrity checks | Manifest refs resolve to real artifacts |
| ApprovalRequest | Implemented | Canonical | **Preserve** | Keep route / quorum enforcement | No host-only substitutes |
| ApprovalGrant | Implemented | Canonical | **Preserve + harden** | Host projection must cite canonical grant | Grant lineage is provable |
| ExceptionLease | Implemented | Canonical | **Preserve + harden** | Same as above | Lease lineage is provable |
| Revocation | Implemented | Canonical | **Preserve + harden** | Same as above | Revocation lineage is provable |
| QuorumPolicy | Implemented | Canonical | **Preserve** | Continue binding requests to quorum templates | No request validates without required quorum policy |
| DecisionArtifact | Implemented | Canonical | **Preserve** | Continue as authority truth anchor | Every route-bearing run has canonical decision evidence |
| Host Adapter Contract | Implemented | Canonical non-authoritative / projection-only | **Harden** | Add CI purity assertions | No workflow path can recreate host-native authority |
| Model Adapter Contract | Implemented | Canonical replaceable adapters | **Preserve + strengthen** | Refresh evidence / conformance on recertification | No widening without conformance and dossier evidence |
| Capability / Pack Contracts | Implemented | Canonical | **Preserve** | Freeze scope; evidence deepen only | No new pack admissions before hardening close |
| Stage-Attempt Contract | Implemented | Canonical | **Harden** | Add presence/content validators and disclosure counts | Every required stage-attempt validates |
| Checkpoint | Implemented | Canonical | **Harden** | Add checkpoint-link and state-digest validation | Runtime-state always points to valid checkpoints |
| Continuity Artifact | Implemented as family | Canonical | **Harden** | Add continuity-linkage validator and applicability rules | Handoff / resumability is deterministic |
| Contamination Record | Implemented as family | Canonical | **Harden** | Add contamination evidence + reset proof requirements | Contamination posture is runtime-backed, not implicit |
| Retry Record | Implemented as family | Canonical | **Harden** | Add retry-class / trigger / outcome validation | Retry posture is explicit and auditable |
| Assurance Reports (all proof planes) | Implemented | Canonical | **Preserve + strengthen** | Behavioral/recovery reports must resolve to lab evidence deterministically | No proof-plane claim without retained evidence refs |
| Intervention Record | Implemented | Canonical | **Preserve** | Keep intervention disclosure visible in RunCards / release review | No hidden human repair in recertified release bundle |
| Measurement Record | Implemented | Canonical | **Preserve + strengthen** | Add freshness / artifact-depth rollups | Release metrics remain traceable and support-bounded |
| RunCard | Implemented | Canonical | **Preserve + harden** | Add artifact-depth completeness summary fields | Canonical per-run disclosure stays calibrated |
| HarnessCard | Implemented | Canonical | **Recalibrate** | `known_limits` and support-boundary wording must match residual ledger | No authored release artifact overstates residual reality |
| Evidence Retention / Disclosure Retention Contract | Implemented | Canonical | **Preserve + minor harden** | Reinforce mirror/projection handling in release closeout | Mirror/projection surfaces stay subordinate |
| Support Target Admissions | Implemented | Canonical | **Preserve + harden** | Add dossier/proof/lab parity checks | No tuple is claim-bearing without clean admission evidence |
| Support Dossiers | Implemented | Canonical | **Preserve + harden** | Deterministic scenario/evidence resolution | Dossier references become mechanically clean |
| Closure / Recertification / Release-Lineage artifacts | Implemented | Canonical claim-bearing | **Harden + recalibrate** | Add residual ledger, hardening reports, two-pass recertification rule | Next release can honestly remain claim-complete |

---

### H. Control, Authority, and Host-Projection Hardening Plan

#### H1. Preserve the current authority architecture

Do **not** move authority back into:
- labels
- comments
- checks
- workflow env flags
- generated/effective status files
- release notes
- operator memory

Canonical authority remains in:
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exceptions/**`
- `/.octon/state/control/execution/revocations/**`
- `/.octon/state/evidence/control/execution/**`

#### H2. Add host-authority-purity validation

**New validator scripts**
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-host-authority-purity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-host-adapter-projection-parity.sh`

**New or updated suite contracts**
- `/.octon/framework/assurance/governance/suites/host-authority-purity.yml`
- `/.octon/framework/assurance/governance/suites/host-projection-parity.yml`

**Workflow updates**
- update `/.github/workflows/pr-autonomy-policy.yml`
- update `/.github/workflows/validate-unified-execution-completion.yml`
- update `/.github/workflows/closure-validator-sufficiency.yml`
- update `/.github/workflows/uec-drift-watch.yml`

**What these checks must assert**
1. No workflow step may treat a label, check, or comment as sufficient approval.
2. Every host-sourced gate or status projection must cite a canonical DecisionArtifact and, where applicable, ApprovalGrant / ExceptionLease / Revocation.
3. Workflow messaging must direct maintainers toward canonical artifact repair, not host-native state manipulation.
4. Host adapter contracts must enumerate their projected canonical artifact families, and those enumerations must match what workflows actually touch.
5. Release closure must fail if any host-only authority path is detected.

**Required retained evidence**
- `state/evidence/validation/publication/build-to-delete/<date>/host-authority-purity.yml`
- `state/evidence/disclosure/releases/<next-release>/closure/host-authority-purity-report.yml`

**Acceptance criteria**
- A repository-wide scan of `.github/workflows/**` returns zero patterns where merge, allow, unblock, approve, or lane transitions are keyed only from labels/comments/checks.
- A generated `host-authority-purity` receipt is green in two consecutive runs.
- The next release closure bundle includes a host-authority-purity report.

**If unresolved**
- Future claim honesty is at risk because canonical-authority truth conditions could be violated.

#### H3. Strengthen approval / exception / revocation lineage

Add lineage validators so that every authority-bearing run can prove:

- canonical approval request exists if approval was needed
- canonical grant exists if route was allow
- canonical lease exists if rule relaxation occurred
- canonical revocation exists if live authority was withdrawn
- canonical decision artifact exists for every routed consequential run
- RunCard and retained run evidence both cite the same authority lineage

**New validator**
- `/.octon/framework/assurance/governance/suites/authority-lineage-completeness.yml`

**Required closure receipt**
- `state/evidence/disclosure/releases/<next-release>/closure/authority-lineage-completeness.yml`

---

### I. Runtime, Continuity, Evidence, and Validation-Depth Hardening Plan

The runtime model is already right. The hardening task is to make completeness deterministic and visible.

#### I1. Runtime-family depth validator

**New suite contracts**
- `/.octon/framework/assurance/runtime/suites/runtime-family-depth.yml`
- `/.octon/framework/assurance/runtime/suites/continuity-linkage.yml`
- `/.octon/framework/assurance/runtime/suites/contamination-retry-depth.yml`

**New validator scripts**
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-runtime-family-depth.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-continuity-linkage.sh`

**Workflow updates**
- update `/.github/workflows/validate-unified-execution-completion.yml`
- update `/.github/workflows/closure-validator-sufficiency.yml`
- optionally update `/.github/workflows/architecture-conformance.yml` to surface runtime-family depth earlier

#### I2. Family-specific requirements

**Stage-attempt family**
- For every admitted run class that requires stage execution, at least one concrete stage-attempt artifact must exist.
- `runtime-state.yml` must point to a valid current or terminal stage-attempt ref.
- Stage-attempt artifacts must resolve to run ref, stage kind, outcome, and evidence refs.

**Checkpoint family**
- `runtime-state.yml` must point to a valid checkpoint.
- Checkpoints must correspond to control/evidence state transitions.
- Terminal runs must have a closeout or completion checkpoint.

**Continuity family**
- For mission-backed, resumable, or multi-session runs, a continuity artifact must exist under `state/continuity/**`.
- For run-only classes where continuity is not required, explicit `not_applicable` treatment must exist in runtime/disclosure.

**Contamination family**
- If a model adapter or run class claims contamination detection/reset posture, the run bundle must either contain a contamination record or an explicit clean `not_detected` record.

**Retry family**
- If a retry class exists in run contract or runtime behavior, retry records must exist even when count is zero, so retry posture is explicit.

#### I3. Promote runtime-family completeness into disclosure

Update RunCard generation so each RunCard contains a compact `artifact_depth` block:

```yaml
artifact_depth:
  stage_attempts: complete|partial|not_applicable
  checkpoints: complete|partial|not_applicable
  continuity: complete|partial|not_applicable
  contamination: present|clean-none|not_applicable
  retries: present|zero-recorded|not_applicable
```

This prevents “it exists somewhere in the tree” ambiguity.

#### I4. Required retained receipts

- `runtime-family-depth-report.yml`
- `continuity-linkage-report.yml`
- `contamination-retry-depth-report.yml`

under the release closure root:

- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/**`

**Acceptance criteria**
- All admitted tuple exemplars pass runtime-family depth checks
- RunCards expose artifact-depth summaries
- No release can certify if required runtime-family reports are absent or partial without explicit retention rationale

**If unresolved**
- Future durable-run and resumability claims become weakly substantiated rather than deterministic.

---

### J. Verification, Evaluation, Lab, and Empirical Coverage Hardening Plan

#### J1. Preserve the six proof planes

Do **not** collapse or redefine:
- structural
- functional
- behavioral
- maintainability
- governance
- recovery

The proof-plane architecture is already correct.

#### J2. Harden authored-lab scenario resolution

The hardening problem is not lack of lab. It is that authored lab assets, support dossiers, support admissions, proof-plane reports, and retained lab evidence must resolve cleanly and deterministically.

**Canonical authored lab registry**
- extend `/.octon/framework/lab/scenarios/registry.yml`

This should provide:
- canonical `scenario_id`
- authored scenario path
- scenario kind (`behavioral`, `recovery`, `shadow`, `fault`, `hidden_check`)
- retained evidence expectations
- applicable support tuples or workload tiers

**Dossier updates**
- each `support-dossiers/**/dossier.yml` should reference `scenario_id`s that resolve through the registry
- where needed, add explicit `scenario_manifest_ref` fields

**Proof-plane report updates**
- behavioral and recovery reports should cite:
  - `scenario_id`
  - authored scenario manifest ref
  - retained lab evidence ref(s)
  - replay / shadow / fault evidence ref(s) where applicable

**Retained lab evidence updates**
- retain per-scenario evidence index manifests under `state/evidence/lab/**` so proof and closure do not rely on directory naming alone

#### J3. Add deterministic integrity validators

**New suites**
- `/.octon/framework/assurance/behavioral/suites/lab-reference-integrity.yml`
- `/.octon/framework/assurance/recovery/suites/lab-replay-shadow-fault-integrity.yml`
- `/.octon/framework/assurance/governance/suites/support-dossier-admission-parity.yml`

**New scripts**
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-lab-reference-integrity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-support-dossier-parity.sh`

**Workflow updates**
- update `/.github/workflows/closure-validator-sufficiency.yml`
- update `/.github/workflows/uec-drift-watch.yml`
- optionally update `/.github/workflows/architecture-conformance.yml`

**Acceptance criteria**
- every `required_lab_scenarios` entry in every admitted dossier resolves to an authored scenario manifest in `framework/lab/**`
- every cited lab scenario has matching retained lab evidence or an explicit `not_executed / not_required` rationale
- every behavioral and recovery proof report resolves to retained evidence
- two consecutive green lab-reference-integrity runs before release certification

#### J4. Evaluator and hidden-check strengthening

This is **not** claim-critical for the next release, but it should be improved.

**Required work**
- add evaluator-coverage summary to release bundle
- require at least one refreshed evaluator-backed review for each boundary-sensitive admitted tuple per recertification cycle
- require at least one hidden-check-backed or adversarial scenario execution per boundary-sensitive tuple where supported

**Paths**
- `/.octon/framework/assurance/evaluators/**`
- `/.octon/framework/lab/**`
- `/.octon/state/evidence/benchmarks/**`
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/support-universe-evidence-depth-report.yml`

#### J5. Support-universe empirical deepening

No support widening. Instead:

- refresh at least one exemplar run per admitted tuple within the recertification window, **or**
- retain an explicit carry-forward rationale that no invalidation trigger fired and no tuple-local artifact changed

For **boundary-sensitive** tuples, require:
- one normal exemplar
- one adverse / recovery / shadow / evaluator-strengthened exemplar per recertification cycle

This deepens evidence without pretending the support universe is broader than it is.

---

### K. Portability, Adapters, Capability Packs, and Support-Target Recertification Plan

#### K1. Freeze support scope during hardening

Until **CC-01** through **CC-04** are closed:
- do not add new tuples to `support-targets.yml`
- do not admit new capability packs
- do not admit new host adapters
- do not admit new model adapter families
- do not widen locale or workload tiers

All changes to:
- `support-targets.yml`
- `support-target-admissions/**`
- `support-dossiers/**`
- `framework/engine/runtime/adapters/**`
- `framework/capabilities/packs/**`

should require an explicit “blocked until hardening-close” note unless they are pure evidence-refresh or integrity-fix changes.

#### K2. Keep the portable-kernel / replaceable-adapter split

**Portable kernel — preserve**
- constitutional kernel
- contract families
- run/control/evidence/disclosure model
- support-target boundedness
- proof-plane model

**Non-portable adapters — preserve and recertify**
- host adapters
- model adapters
- capability packs

#### K3. Adapter and pack recertification

For the next release, adapters and packs should be **re-attested**, not widened.

**Host adapters**
- verify non-authoritative status in prose, runtime, and workflows
- verify projected artifacts are canonical refs only

**Model adapters**
- refresh conformance evidence for the currently admitted model classes only
- no new model family admissions

**Capability packs**
- refresh admission/dossier evidence for currently admitted packs only
- especially `browser` and `api`, because they are higher-interpretation surfaces

#### K4. Unsupported-case behavior remains unchanged

Unsupported cases should continue to:
- fail closed,
- or degrade to stage-only where policy already permits it,
- or route to governance exclusion.

Do not soften exclusions to make the support universe look larger.

---

### L. Canonical / Shim / Mirror / Projection Simplification and Demotion Plan

#### L1. Preserve the canonical/shim map

Do not flatten or simplify away the explicit distinctions already present in:
- `framework/constitution/contracts/registry.yml`
- `instance/governance/disclosure/release-lineage.yml`
- evidence/disclosure retention contracts

These distinctions are now a strength.

#### L2. Add release-bound residual-surface rationale

For every still-retained:
- ingress projection
- historical shim
- subordinate-governance shim
- historical mirror
- generated/effective projection

the next release should include one of:

- `retired`
- `retained_with_rationale`
- `projection_only`
- `historical_only`

in a release-local residual ledger:

- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/residual-ledger.yml` **(new)**

This is the easiest way to reduce operator confusion without destabilizing lineage.

#### L3. Simplify ingress / identity surfaces

**Current candidates**
- `/.octon/AGENTS.md`
- `/AGENTS.md`
- `/CLAUDE.md`
- `/.octon/instance/ingress/AGENTS.md`
- residual persona/identity surfaces under `framework/agency/**`

**Action**
- keep permanent ingress projections if still useful
- explicitly mark any identity or persona overlays as non-authoritative inside the files themselves
- remove any wording that sounds like co-equal execution authority
- add retention-vs-retirement rationale for each in the residual ledger

#### L4. Generated/effective projections

Generated/effective closure and support-target projections should stay, but release closeout should require:
- parity report green
- clear “projection-only” language in relevant operator-facing docs
- no operator-facing statement implying generated/effective files are authored authority

---

### M. Deletion, Retirement, Ablation, and Build-to-Delete Plan

#### M1. Make retirement real each release

Update:
- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/instance/governance/contracts/support-target-review.yml`
- release closeout workflow/contracts

so that each release must record:

- surfaces retired this release
- surfaces retained this release with rationale
- planned retirement trigger for each retained transitional surface
- whether any ablation was performed
- if no retirement occurred, why not

#### M2. Retire or demote the following first

**Priority retirement / demotion candidates**
1. persona-heavy ingress / identity wording
2. any historical charter-like surface no longer needed for operator comprehension
3. any mirror-only disclosure artifacts that can now be replaced by canonical release disclosure
4. any lingering workflow-native status conventions that remain only for habit, not function

#### M3. Required ablation discipline

For every retained transitional surface, require one of:
- a direct ablation,
- a usage proof,
- or a stated dependency proving why it cannot yet be removed.

No surface should remain in the “transitional but unexplained” state across releases.

#### M4. Build-to-delete evidence receipts

Add release receipts:
- `retirement-rationale-report.yml`
- `shim-demotion-report.yml`
- `ablation-review-report.yml`

under:
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/**`

**Acceptance criteria**
- every residual shim/projection/mirror surface has an explicit release disposition
- at least one transitional surface is either retired or demoted further in the next release
- retirement register is no longer “alive but shallow”; it reflects actual ongoing constitutional hygiene

---

### N. Disclosure, HarnessCard, Closure, and Release-Lineage Recalibration Plan

#### N1. Preserve bounded claim wording

Do **not** weaken the repo into “directionally good” language.  
Do **not** inflate the repo into universal-completion language.

Keep the active claim phrased as:
- bounded
- admitted
- finite
- support-universe scoped

#### N2. Recalibrate HarnessCard `known_limits`

The next release should not use `known_limits: []` unless:

- all claim-critical issues are closed,
- all non-critical residuals are either retired or explicitly retained with rationale,
- and the residual ledger is empty or purely informational.

Until then, `known_limits` should minimally state:

1. lab scenario / dossier / proof reference integrity is under hardening-close review until the release’s integrity report is green,
2. host-adapter projection purity is continuously audited and any workflow-native authority recreation invalidates recertification,
3. runtime artifact-depth validation for stage-attempt / checkpoint / continuity / contamination / retry families is being deepened and is claim-critical for the release,
4. support universe remains intentionally finite and is not being widened in this release.

This is not self-undermining. It is claim-calibrated honesty.

#### N3. Add residual issue ledger to the release closure bundle

New file:
- `/.octon/state/evidence/disclosure/releases/<next-release>/closure/residual-ledger.yml`

It should include every open residual with:
- issue ID
- severity
- type
- retention rationale or closeout evidence
- whether leaving it unresolved would invalidate future claim honesty
- next review / target release

This should become the canonical generator for the authored HarnessCard `known_limits` block.

#### N4. Recertification gating rules

Before the next active release can supersede the current one, require:

1. zero unresolved **claim-critical** items
2. explicit closure or approved retention rationale for every remaining non-critical item
3. two consecutive green runs of:
   - host-authority-purity
   - lab-reference-integrity
   - runtime-family-depth
   - disclosure-calibration / known-limits parity
4. green authored ↔ generated/effective projection parity
5. updated HarnessCard, closure claim, release-lineage, and recertification-status projections
6. no support-target expansion in the same release

#### N5. Release-lineage handling

- keep the current active release active until the hardening recertification release is fully certified
- add the next release to `release-lineage.yml` as staged / pending until all closure conditions pass
- once certified, demote the current release to historical, with reason:
  - “superseded by hardening recertification release; no support-universe widening”

---

### O. Final Claim-Honesty and Recertification Judgment

The current bounded claim can remain honestly asserted **during** the hardening program **if and only if** Octon follows three rules:

1. **Do not widen the admitted support universe while claim-critical hardening items remain open.**
2. **Do not publish a new active claim-bearing release until CC-01 through CC-05 are closed.**
3. **Do not continue using disclosure that implies zero caveats once the packet has formally recorded residual hardening work.**

Under those conditions, the present active bounded claim remains honest. The repo already materially substantiates it.

The next recertified release can also honestly remain claim-complete **if and only if**:

- no claim-critical hardening findings remain open,
- every non-critical residual has explicit closure or approved retention rationale,
- the hardening validators pass twice consecutively,
- authored closure/disclosure and generated/effective projections remain in deterministic parity,
- the support universe remains bounded and unchanged,
- and no host-projection authority leakage or lab-reference integrity failures remain unresolved.

What would invalidate future claim honesty:

- any host-only approval or label-only authority path
- any unresolved dossier/admission/proof lab reference integrity failure
- any missing required runtime-family artifacts for admitted classes
- any authored HarnessCard / closure artifact that still overstates known limits
- any transitional or shim surface left claim-bearing without explicit retain-vs-retire rationale in the closure bundle
- any support-universe widening without dossier-backed, proof-backed admission review

---

### P. Prioritized Execution Program

#### Phase 1 — Claim-critical hardening (do first)

**1. CC-01: lab reference integrity**
- extend `framework/lab/scenarios/registry.yml`
- add `verify-lab-reference-integrity.sh`
- add assurance suites for lab-reference and dossier/admission parity
- update dossiers and proof-plane reports to resolve through the registry
- add release closure reports

**2. CC-02: host authority purity**
- add `verify-host-authority-purity.sh`
- update host adapter contracts to list projected canonical artifact families explicitly
- update workflows to ban host-only approval logic
- add release closure purity report

**3. CC-03: runtime-family depth**
- add `runtime-family-depth`, `continuity-linkage`, and `contamination-retry-depth` suites
- add validator scripts
- update RunCard generation with artifact-depth summaries
- add release closure reports

**4. CC-04: disclosure calibration**
- update authored HarnessCard source
- add `residual-ledger.yml`
- add disclosure-calibration release report and authored/generated parity assertion

**5. CC-05: retirement / retain-rationale discipline**
- update `retirement-register.yml` with explicit retain-vs-retire disposition fields
- require closeout review artifacts to record rationale for every transitional, shim, or mirror surface carried forward
- add `verify-retirement-rationale.sh` and a release closure retirement-rationale report
- block certification if a claim-adjacent transitional surface survives without explicit reviewed rationale

- add `verify-release-known-limits.sh`
- update closure bundle and generated/effective parity expectations

**Exit condition for Phase 1**
- all five claim-critical items green in CI
- two consecutive passes
- no support-target changes merged during the phase

#### Phase 2 — Non-critical but immediate hardening

**5. CS-01: support-universe evidence depth**
- refresh exemplar runs or carry-forward rationale per admitted tuple
- require extra recovery/behavioral depth for boundary-sensitive tuples

**6. CS-02: evaluator / hidden-check breadth**
- add evaluator coverage report
- require at least one strengthened review path for boundary-sensitive tuples

**7. SR-03 / SR-04: residual ledger and projection clarity**
- attach explicit retained / retired / projection-only rationale to remaining ambiguous surfaces

**Exit condition for Phase 2**
- release closure bundle contains support-universe evidence-depth report and residual ledger
- no unresolved non-critical issue lacks disposition

#### Phase 3 — Simplification and build-to-delete operationalization

**8. SR-01: agency-kernel simplification**
- update ingress and agency overlays with explicit non-authoritative labels
- demote or retire at least one persona-heavy transitional surface

**9. SR-02: retirement-register deepening**
- require retirement or retention rationale every release
- add ablation review receipt

**Exit condition for Phase 3**
- retirement register updated in real terms
- at least one transitional surface retired or demoted
- no retained transitional surface is unexplained

#### Phase 4 — Hardening recertification release

**10. Closure / disclosure / lineage update**
- produce next release closure bundle
- publish recalibrated HarnessCard
- run parity checks
- update `release-lineage.yml`
- only then activate the next release

**Final release gate**
- zero open claim-critical issues
- residual ledger complete
- parity green
- support universe unchanged
- claim wording still bounded and finite
