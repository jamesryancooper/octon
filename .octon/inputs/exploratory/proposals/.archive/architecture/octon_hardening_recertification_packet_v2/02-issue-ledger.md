# Expanded Issue Ledger

This file expands the issue ledger from the main packet.

## Classification legend

- **Issue type**
  - `claim-critical hardening`
  - `claim-strengthening hardening`
  - `simplification`
  - `retirement`
  - `disclosure calibration`
  - `validator depth`
  - `empirical evidence depth`
- **Action class**
  - `preserve`
  - `harden`
  - `normalize`
  - `simplify`
  - `demote`
  - `retire`
  - `delete`
  - `postpone`
- **Execution mode**
  - `targeted cutover`
  - `staged hardening`
  - `ongoing evidence deepening`

---

## CC-01 — Authored lab scenario / dossier / proof reference integrity

- **Current repo paths**
  - `/.octon/framework/lab/**`
  - `/.octon/instance/governance/support-dossiers/**`
  - `/.octon/instance/governance/support-target-admissions/**`
  - `/.octon/state/evidence/lab/**`
  - `/.octon/state/evidence/runs/**/assurance/**`
- **Affected canonical target-state artifacts**
  - authored scenario manifests / scenario registry
  - dossier `required_lab_scenarios`
  - behavioral and recovery proof reports
  - retained lab evidence manifests
- **Issue type**: claim-critical hardening / validator depth
- **Action class**: harden
- **Execution mode**: staged hardening
- **Why this judgment is correct**
  - Lab is already real in substance.
  - The remaining weakness is reference integrity and deterministic resolution, not missing architecture.
- **Acceptance criteria**
  1. Every scenario ID cited in any admission or dossier resolves through the authored scenario registry.
  2. Every behavioral / recovery proof report resolves to retained lab evidence or an explicit `not_required` rationale.
  3. Two consecutive green `lab-reference-integrity` runs.
- **Validator / CI / evidence / disclosure requirements**
  - extend authored scenario registry
  - add integrity validator
  - emit release closure report
  - expose any unresolved gap in residual ledger and HarnessCard
- **Claim-honesty effect if unresolved**
  - future release claim becomes vulnerable because proof and support-universe assertions can overstate reality.

## CC-02 — Host projection authority purity

- **Current repo paths**
  - `/.github/workflows/**`
  - `/.octon/framework/engine/runtime/adapters/host/**`
  - `/.octon/state/control/execution/{approvals,exceptions,revocations}/**`
  - `/.octon/state/evidence/control/execution/**`
- **Affected canonical target-state artifacts**
  - host adapter contracts
  - authority lineage receipts
  - release closure reports
- **Issue type**: claim-critical hardening
- **Action class**: harden
- **Execution mode**: targeted cutover
- **Why this judgment is correct**
  - The authority model is already correct.
  - The remaining risk is workflow or host-side recreation of authority semantics.
- **Acceptance criteria**
  1. No workflow step can approve or unblock based on label/comment/check alone.
  2. All host projections cite canonical DecisionArtifact and, where relevant, ApprovalGrant / ExceptionLease / Revocation.
  3. Two consecutive green `host-authority-purity` runs.
- **Validator / CI / evidence / disclosure requirements**
  - add workflow scan + adapter parity validator
  - emit purity receipt and release closure report
  - fail release closeout if host-only authority is detected
- **Claim-honesty effect if unresolved**
  - future canonical-authority claim is directly threatened.

## CC-03 — Runtime artifact-depth validator gap

- **Current repo paths**
  - `/.octon/framework/constitution/contracts/runtime/**`
  - `/.octon/state/control/execution/runs/**`
  - `/.octon/state/continuity/**`
  - `/.octon/state/evidence/runs/**`
- **Affected canonical target-state artifacts**
  - stage-attempts
  - checkpoints
  - continuity artifacts
  - contamination records
  - retry records
- **Issue type**: claim-critical hardening / validator depth
- **Action class**: harden
- **Execution mode**: staged hardening
- **Why this judgment is correct**
  - Families exist and are in use.
  - The residual weakness is deterministic completeness and disclosure depth rather than missing runtime design.
- **Acceptance criteria**
  1. Every admitted run class validates required family presence or explicit non-applicability.
  2. `runtime-state.yml` points only to resolvable stage/checkpoint refs.
  3. RunCards expose artifact-depth summaries.
  4. Two consecutive green runtime-family depth runs.
- **Validator / CI / evidence / disclosure requirements**
  - add runtime-family validators
  - add continuity-linkage validator
  - add contamination/retry depth validator
  - add release closure reports
- **Claim-honesty effect if unresolved**
  - future durable-run and resumability claims become weakly evidenced.

## CC-04 — Disclosure and HarnessCard calibration

- **Current repo paths**
  - `/.octon/instance/governance/disclosure/**`
  - `/.octon/instance/governance/closure/**`
  - `/.octon/state/evidence/disclosure/releases/**`
  - `/.octon/generated/effective/closure/**`
- **Affected canonical target-state artifacts**
  - authored HarnessCard source
  - release HarnessCard
  - residual ledger
  - claim-status / recertification projections
- **Issue type**: disclosure calibration
- **Action class**: recalibrate
- **Execution mode**: targeted cutover
- **Why this judgment is correct**
  - The release claim is currently supportable.
  - The disclosure surface slightly understates remaining hardening caveats.
- **Acceptance criteria**
  1. `known_limits` is derived from a residual ledger, not handwritten optimism.
  2. Residual ledger exists in the release closure bundle.
  3. Generated/effective projections remain in parity with authored closure/disclosure.
- **Validator / CI / evidence / disclosure requirements**
  - add release-known-limits validator
  - add residual-ledger artifact
  - update parity checks
- **Claim-honesty effect if unresolved**
  - future release could overstate perfection or hide residual risks.


## CC-05 — Retirement / retain-rationale discipline

- **Current repo paths**
  - `/.octon/instance/governance/retirement-register.yml`
  - `/.octon/instance/governance/contracts/closeout-reviews.yml`
  - `/.octon/state/evidence/validation/publication/build-to-delete/**`
  - release closure / disclosure roots
- **Affected canonical target-state artifacts**
  - retirement register
  - release closeout reviews
  - residual ledger / disclosure known-limits surfaces
  - claim-bearing closure bundles
- **Issue type**: claim-critical hardening / retirement discipline
- **Action class**: harden / normalize
- **Execution mode**: targeted cutover
- **Why this judgment is correct**
  - The repo already has a retirement mechanism.
  - The remaining weakness is that transitional, shim, mirror, and scaffold surfaces can still survive release close without explicit retain-vs-retire rationale strong enough for recertification.
- **Acceptance criteria**
  1. Every transitional / shim / mirror surface that remains in-tree at release close is recorded in the retirement register.
  2. Every such surface is marked `retired`, `demoted`, or `retained_with_rationale` with an owning review artifact.
  3. Claim-adjacent transitional surfaces cannot survive without explicit closure-bundle rationale.
  4. Two consecutive green `retirement-rationale` runs.
- **Validator / CI / evidence / disclosure requirements**
  - add release closeout validator for retain-vs-retire completeness
  - emit retirement-rationale report in the closure bundle
  - require residual-ledger parity with retirement-register entries where applicable
- **Claim-honesty effect if unresolved**
  - future release claim becomes vulnerable because ambiguous transitional surfaces can silently survive as de facto authority or undeclared caveats.

## CS-01 — Support-universe empirical depth

- **Issue type**: empirical evidence depth
- **Action class**: harden
- **Execution mode**: ongoing evidence deepening
- **Acceptance criteria**
  - at least one refreshed exemplar or explicit carry-forward rationale per admitted tuple per recertification window
  - boundary-sensitive tuples get extra recovery/behavioral depth
- **Claim-honesty effect**
  - strengthens future claim; not required to keep current active claim honest

## CS-02 — Evaluator and hidden-check breadth

- **Issue type**: empirical evidence depth
- **Action class**: harden
- **Execution mode**: ongoing evidence deepening
- **Acceptance criteria**
  - evaluator coverage summary in release bundle
  - at least one strengthened evaluator or hidden-check execution for boundary-sensitive tuples
- **Claim-honesty effect**
  - strengthens anti-overfitting credibility; not a current blocker

## SR-01 — Agency-kernel persona residue

- **Issue type**: simplification
- **Action class**: simplify / demote
- **Execution mode**: staged hardening
- **Acceptance criteria**
  - ingress and agency overlays explicitly label identity/persona content as non-authoritative
  - at least one persona-heavy retained surface is demoted or retired in the next release
- **Claim-honesty effect**
  - interpretive clarity; not current claim invalidating

## SR-02 — Retirement-register operational depth

- **Issue type**: retirement
- **Action class**: harden / normalize
- **Execution mode**: staged hardening
- **Acceptance criteria**
  - each release records retained vs retired surfaces and rationale
  - at least one reviewed candidate for deletion or demotion per release
- **Claim-honesty effect**
  - long-run entropy control and build-to-delete integrity

## SR-03 / SR-04 — Residual surface rationale and projection clarity

- **Issue type**: simplification / retirement
- **Action class**: normalize / harden
- **Execution mode**: targeted cutover
- **Acceptance criteria**
  - residual ledger records disposition for each retained shim/projection/mirror
  - generated/effective parity and operator-facing projection-only messaging are green
- **Claim-honesty effect**
  - reduces operator confusion; keeps claim interpretation clean
