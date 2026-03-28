# Target Architecture

- proposal: `execution-constitution-completion-closeout`

## Goal

Finish the remaining implementation work so Octon can accurately and defensibly
claim the target state described by the archived fully unified execution
constitution proposal.

This completion is intentionally **atomic and clean-break**:

- one coordinated landing branch
- no compatibility window between the old and final models
- no mixed steady state where helper-authored acceptance bundles, legacy
  decision evidence, or placeholder governance overlays remain live alongside
  the final constitutional model
- no final completion claim unless the old path is removed or provably
  unreachable in the same cutover

This closeout proposal does not reopen the constitutional direction. It closes
the gaps surfaced by the implementation audit:

1. canonical authority artifacts exist in schema and code, but not as the
   dominant live retained model
2. the showcase Wave 3 and Wave 4 runs were helper-script fixtures rather than
   proof that the live engine authority path produced the final-state artifacts
3. run-first execution is not yet proven as the universal consequential path,
   and no supported run-only example exists
4. proof, disclosure, retention, and replay are only partially normalized
5. lab depth, observability depth, and retirement governance remain thin

## Closeout Thesis

The completion architecture must make three things true at the same time:

1. **Canonical authority is the only live authority.**
   Every consequential run must be created and routed by the engine authority
   path, not by helper scripts that can synthesize run bundles without the
   canonical decision, approval, exception, revocation, and grant-bundle
   artifacts.

2. **Run-first execution is the universal consequential model.**
   Every consequential run must bind a run root before side effects, retain
   canonical runtime-state, checkpoints, rollback posture, and replay pointers,
   and prove that mission continuity now consumes those artifacts instead of
   standing in for them.

3. **Closeout evidence is release-grade, not migration-grade.**
   The final acceptance claim must be backed by retained live artifacts under
   the canonical control, evidence, lab, disclosure, and retirement surfaces,
   including one mission-backed supported run and one run-only supported run.

## Required Architectural Deltas

### 1. Canonical authority artifacts become mandatory live outputs

Required state:

- `state/control/execution/approvals/**` contains real `ApprovalRequest` and
  `ApprovalGrant` artifacts when policy requires them
- `state/control/execution/exceptions/**` contains per-run `ExceptionLease`
  artifacts rather than only empty aggregate sets
- `state/control/execution/revocations/**` contains real revocation records when
  exercised
- `state/evidence/control/execution/**` contains canonical authority-decision
  and authority-grant-bundle artifacts emitted by the engine runtime
- `state/evidence/decisions/**` is retired from the live authority path or
  clearly demoted to historical lineage in the same cutover

Constraints:

- helper writers may not create a consequential acceptance bundle at all; any
  surviving helper tooling must consume engine-emitted authority artifacts and
  remain explicitly outside the live acceptance path
- support-tier routing, approval requirements, and reversibility posture must be
  reflected in the canonical decision artifact rather than only in prose or
  migration evidence

### 2. Sample and acceptance runs must execute through the real authority path

Required state:

- the showcase mission-backed run is created via the engine authorization path
- a supported run-only example is created via the same path with no mission
  authority bound
- no final acceptance example may be produced by `write-run.sh` plus
  `write-decision.sh` as an authority bypass

Constraints:

- helper-authored synthetic bundles must be excluded from the final model in the
  same branch, either by deletion, by explicit historical quarantine, or by
  validator-enforced non-acceptance status
- validators and closeout docs must reject any acceptance claim that relies on
  synthetic backfill bundles

### 3. Run continuity becomes first-class

Required state:

- `state/continuity/runs/**` exists and records resumability and handoff state
  for bound runs
- mission continuity and generated mission read models reference run continuity
  alongside run evidence
- run-only execution can be resumed from run continuity and run evidence without
  mission dependency

Constraints:

- `state/evidence/runs/**` remains retained evidence, not continuity truth
- generated mission/operator views stay derived-only and subordinate to control
  and evidence roots

### 4. Proof and disclosure move from sample completeness to release completeness

Required state:

- every consequential acceptance run retains artifacts for structural,
  governance, functional, behavioral, maintainability, recovery, and evaluator
  proof handling
- structural and governance proof become retained run-local or release-local
  artifacts rather than only script references in RunCards
- one canonical disclosure retention family exists after cutover; if that family
  is not `state/evidence/disclosure/{runs,releases}/**`, the authoritative docs
  and validators must state the replacement unambiguously in the same branch
- a current-release HarnessCard exists for the live support posture, not only
  benchmark-specific lab cards

Constraints:

- RunCards and HarnessCards must remain subordinate disclosures, never
  authority
- disclosure must cite the actual compatibility tuple, adapters, proof bundle,
  intervention status, and known limits used for the claim

### 5. Retention and replay are formalized end to end

Required state:

- `framework/constitution/contracts/retention/**` exists and is active
- `state/evidence/external-index/**` exists for external replay payload pointers
  when high-volume telemetry is externalized
- replay retention classes distinguish Git-inline evidence, pointered evidence,
  and external immutable payloads

Constraints:

- the cutover may not claim replay completeness while the retention family
  remains reserved-only
- external replay must be content-addressed and referenced from canonical run
  evidence

### 6. `framework/lab/**` and `framework/observability/**` become real authored domains

Required state:

- `framework/lab/` contains authored scenario, replay, shadow, fault, and
  adversarial surfaces with explicit contracts
- `framework/observability/` contains authored measurement, intervention,
  failure-taxonomy, and reporting surfaces beyond a minimal README-plus-schema
  shell

Constraints:

- lab remains distinct from assurance: it explores unknown failure modes rather
  than merely restating proof gates
- observability remains subordinate to the constitutional kernel and run roots

### 7. Build-to-delete becomes enforceable governance

Required state:

- `instance/governance/contracts/**` is populated with repo-owned overlays that
  matter to the final model, including retirement policy
- the atomic cutover retains drift review, support-target review, adapter
  review, and deletion review evidence
- legacy transitional helpers and legacy authority surfaces have explicit
  retirement status, owners, and removal criteria in the same cutover branch

Constraints:

- the repo may not declare the archived unified-execution proposal “fully
  complete” while retirement governance remains placeholder-only

## Durable Completion Claim

The archived unified-execution proposal is complete only when the current repo
can prove, from durable authored and retained surfaces alone, that:

- the engine authority path is the only live consequential authority path
- canonical authority artifacts are populated and retained
- run-first execution is universal for consequential work
- both mission-backed and run-only supported runs exist under the new pipeline
- disclosure, replay, and retirement evidence are release-grade
- no helper-script fixture can be mistaken for final acceptance evidence
- no coexistence shim remains required for steady-state operation
