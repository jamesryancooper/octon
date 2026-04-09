# Audit Annex and Proposal Crosswalk

The packet is now **self-contained** because it includes the full implementation audit in `AUDIT.md`. This annex complements that audit with a packet-local digest, issue inventory, and remediation crosswalk. It is **not** a fresh full re-audit, and it no longer stands in for the audit itself.

The packet should therefore be read in this order:

1. `00-main-packet.md`
2. `AUDIT.md`
3. `01-audit-annex-and-crosswalk.md`
4. `02-issue-ledger.md`
5. `03-contract-and-artifact-remediation-matrix.md`
6. execution / disclosure / checklist appendices

---

## 1. Audit role and precedence inside the packet

This annex follows the precedence model required for the packet:

1. **The live Octon repository** is the source of truth for implementation reality.
2. **The live canonical constitutional and claim-bearing surfaces** define present architecture and present claim boundaries.
3. **The full implementation audit in `AUDIT.md`** is the authoritative synthesis of current strengths, residual weaknesses, and non-problems.
4. **This annex** is the packet-local digest and crosswalk that maps the audit into the hardening program.
5. **Prior proposal material** is historical lineage only where the live repo and the audit are silent.

That means the audit is neither optional context nor a side note. `AUDIT.md` is the detailed evidence-bearing synthesis; this annex is the interpretive bridge between that audit and the hardening program.

---

## 2. What the audit found already materially implemented and worth preserving

The audit did **not** find Octon to be pre-constitutional, pre-run-first, or pre-attainment. It found a materially real, bounded Unified Execution Constitution that should be preserved while weak seams are hardened.

| Audit-preserved strength | Canonical roots / surfaces | Packet stance |
|---|---|---|
| Constitutional kernel is real | `/.octon/framework/constitution/**` | Preserve; do not redesign |
| Dual precedence is real | `precedence/normative.yml`, `precedence/epistemic.yml` | Preserve; only add hardening-facing clarifications if needed |
| Workspace → mission → run layering is real | `/.octon/instance/charter/**`, `/.octon/instance/orchestration/missions/**`, `/.octon/state/control/execution/runs/**` | Preserve; do not collapse back into mission-only execution |
| Canonical authority artifacts are real | `state/control/execution/{approvals,exceptions,revocations}/**` | Preserve; harden lineage and host-projection purity |
| Durable run / continuity / evidence classes are real | `state/control/execution/runs/**`, `state/continuity/**`, `state/evidence/runs/**` | Preserve; deepen validator coverage |
| Lab is a top-level authored domain | `/.octon/framework/lab/**` | Preserve; normalize scenario and proof references |
| Observability is a top-level authored domain | `/.octon/framework/observability/**` | Preserve; only extend where disclosure / release-close needs more explicit receipts |
| Adapter-mediated portability is real | `framework/engine/runtime/adapters/{host,model}/**` | Preserve; harden adapter purity |
| Support-target boundedness is real | `support-targets.yml`, admissions, dossiers | Preserve; freeze scope during hardening |
| RunCards / HarnessCards / release-lineage exist as canonical disclosure surfaces | `state/evidence/disclosure/**`, `instance/governance/disclosure/**`, `instance/governance/closure/**` | Preserve; recalibrate known limits and residual disclosure |

---

## 3. What the audit found still weak enough to matter for recertification

### 3.1 Claim-critical hardening findings

These findings do **not** negate the current active bounded claim. They **do** determine whether the next claim-bearing release can honestly continue that claim.

| Finding ID | Audit determination | Why it is claim-critical for the next recertified release | Primary roots |
|---|---|---|---|
| **CC-01** | Lab scenario / dossier / admission / proof reference integrity remains too soft | Future support-universe and proof claims can overstate reality if authored scenario refs, dossier refs, admissions, proof reports, and retained lab evidence do not resolve deterministically | `framework/lab/**`, support dossiers / admissions, `state/evidence/lab/**`, proof-plane roots |
| **CC-02** | Host workflow / host adapter projection purity is not yet strong enough | Workflows, labels, checks, comments, or adapter projections must never silently recreate authority outside canonical artifacts | `.github/workflows/**`, `framework/engine/runtime/adapters/host/**`, authority control / evidence roots |
| **CC-03** | Runtime artifact-depth validation is still shallower than the claim now needs | Stage-attempt, checkpoint, continuity, contamination, and retry families must be validator-covered, not merely present by path | runtime contract roots, run / continuity / run-evidence roots |
| **CC-04** | Disclosure and HarnessCard calibration still understate known caveats | Claim-bearing disclosure cannot imply zero caveats or perfect closure where hardening work is still open | authored disclosure, release disclosure, closure bundle, generated/effective parity roots |
| **CC-05** | Retirement / retain-rationale discipline is not yet operational enough for recertification | Transitional, shim, mirror, or scaffold surfaces must not silently survive release close without explicit reviewed disposition and rationale | retirement register, closeout review contracts, build-to-delete evidence / closure roots |

### 3.2 Claim-strengthening but not currently claim-invalidating findings

| Finding ID | Audit determination | Why it matters | Primary roots |
|---|---|---|---|
| **CS-01** | Support-universe empirical evidence depth should be strengthened before expansion | The admitted support universe should be deepened empirically before new tuples are admitted | dossiers, admissions, RunCards, lab evidence, proof planes |
| **CS-02** | Evaluator and hidden-check breadth remains thinner than ideal | Improves proof credibility and anti-overfitting posture | assurance / evaluator / CI roots |
| **SR-01** | Agency-kernel and ingress simplification remains worthwhile | Reduces interpretive ambiguity around orchestrator-kernel authority | agency / ingress / overlay surfaces |
| **SR-02** | Retirement-register operational depth remains shallower than ideal | Strengthens build-to-delete discipline and recurring recertification hygiene | retirement register, closeout review contracts, release review roots |
| **SR-03 / SR-04** | Projection / mirror and residual-surface operator clarity can be improved further | Reduces confusion between canonical authority and useful projections while keeping retained surfaces explicitly justified | generated/effective / projection parity roots, registry, retirement roots |

---

## 4. What the audit explicitly did **not** say

The audit is important not only for what it found weak, but for what it **did not** call for:

- It did **not** call for a greenfield target-state redesign.
- It did **not** call for reopening the constitutional kernel.
- It did **not** call for widening the support universe before hardening-close.
- It did **not** call for creating a second control plane outside canonical authority / control / evidence roots.
- It did **not** call for promoting host-native workflow surfaces into authority.
- It did **not** treat generated/effective projections as authored authority.

That negative space matters. The proposal packet should be read as a **hardening packet for an attained bounded state**, not as a rescue plan for a missing one.

---

## 5. Audit-to-proposal crosswalk

Detailed audit evidence for every row below lives in `AUDIT.md`; the table maps each finding to the primary packet-planning files that act on it.

| Audit finding | Primary packet sections | Primary archive files |
|---|---|---|
| **CC-01** lab reference integrity | A, D, F(8), J, O, P | `00-main-packet.md`, `02-issue-ledger.md`, `04-phase-execution-program.md`, `05-path-specific-execution-program.md`, `07-recertification-checklists.md` |
| **CC-02** host projection authority purity | A, D, F(4/9/12), H, O, P | `00-main-packet.md`, `02-issue-ledger.md`, `03-contract-and-artifact-remediation-matrix.md`, `04-phase-execution-program.md`, `05-path-specific-execution-program.md`, `07-recertification-checklists.md` |
| **CC-03** runtime artifact-depth validation | A, D, F(2/6), I, O, P | `00-main-packet.md`, `02-issue-ledger.md`, `03-contract-and-artifact-remediation-matrix.md`, `04-phase-execution-program.md`, `05-path-specific-execution-program.md`, `07-recertification-checklists.md` |
| **CC-04** disclosure / HarnessCard calibration | A, D, F(10), N, O, P | `00-main-packet.md`, `02-issue-ledger.md`, `06-disclosure-delta-examples.md`, `07-recertification-checklists.md` |
| **CC-05** retirement / retain-rationale discipline | A, D, F(11/12), M, N, O, P | `00-main-packet.md`, `02-issue-ledger.md`, `04-phase-execution-program.md`, `05-path-specific-execution-program.md`, `07-recertification-checklists.md` |
| **CS-01** support-universe empirical deepening | D, F(7/9), J, K, P | `00-main-packet.md`, `02-issue-ledger.md`, `04-phase-execution-program.md`, `07-recertification-checklists.md` |
| **CS-02** evaluator / hidden-check breadth | D, F(7/8), J, P | `00-main-packet.md`, `02-issue-ledger.md`, `04-phase-execution-program.md`, `07-recertification-checklists.md` |
| **SR-01** agency-kernel simplification | D, F(5/12), L, M, P | `00-main-packet.md`, `02-issue-ledger.md`, `04-phase-execution-program.md`, `05-path-specific-execution-program.md` |
| **SR-02** retirement-register operational depth | D, F(11), M, P | `00-main-packet.md`, `02-issue-ledger.md`, `04-phase-execution-program.md`, `05-path-specific-execution-program.md`, `07-recertification-checklists.md` |
| **SR-03 / SR-04** canonical / shim / mirror clarity | D, F(3/12), L, M, N | `00-main-packet.md`, `02-issue-ledger.md`, `03-contract-and-artifact-remediation-matrix.md`, `06-disclosure-delta-examples.md` |

---

## 6. Packet completeness note

This revised archive is complete in the sense that it now contains:

- the **main A–P hardening packet**,
- the **full implementation audit**,
- the **audit annex and crosswalk**,
- the **expanded issue ledger**,
- the **contract/artifact remediation matrix**,
- the **execution programs**,
- the **disclosure delta examples**,
- the **recertification checklists**,
- and the **source-basis / source-anchor files**.

The proposal is therefore no longer merely *audit-aware*; it is **audit-internalized**.
