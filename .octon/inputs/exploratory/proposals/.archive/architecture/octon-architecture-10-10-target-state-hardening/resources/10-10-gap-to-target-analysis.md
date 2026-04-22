# 10/10 Gap-to-Target Analysis

## What prevents 10/10 today

A true 10/10 architecture would require little meaningful improvement under a
strict review. Octon is not there because several claims are architecturally
correct but not yet mechanically complete.

## Limiting factors and closures

### 1. Universal authorization coverage

**Current blocker:** The authorization boundary is correctly specified and partly
implemented, but every material path must be proven coverage-bound.

**Required change:** Expand material inventory and authorization coverage maps,
then add blocking validators and negative controls.

**Closure:** Missing coverage fails with FCR-023; no material action proceeds
without GrantBundle and receipt.

### 2. Runtime-effective publication freshness

**Current blocker:** Freshness and receipts are declared but need hard runtime
rejection proof.

**Required change:** Add publication freshness gates and runtime/validator checks.

**Closure:** Stale generated/effective outputs deny with FCR-007/FCR-022 evidence.

### 3. Support claim partitioning

**Current blocker:** `support-targets.yml` is bounded, but admissions/dossiers are
not physically partitioned by claim state.

**Required change:** Partition live/stage-only/unadmitted/retired support artifacts.

**Closure:** Support claim state is visible by path and validated by route.

### 4. Support-pack-admission invariant graph

**Current blocker:** Pack admission, support targets, runtime routes, and
disclosure claims can drift.

**Required change:** Add invariant contract and validator.

**Closure:** Live tuple cannot reference unadmitted pack/adapter or missing proof.

### 5. Proof-plane closure maturity

**Current blocker:** Proof-plane architecture is strong but not every live claim
has compact, retained, inspectable proof.

**Required change:** Require proof bundles, negative controls, RunCards,
HarnessCards, SupportCards, replay/recovery artifacts.

**Closure:** Every live claim has proof-plane coverage and retained evidence.

### 6. Operator boot complexity

**Current blocker:** Ingress/boot surfaces mix orientation and closeout logic.

**Required change:** Split boot manifest from closeout workflows and add doctor path.

**Closure:** Boot path is concise and closeout is separately validated.

### 7. Pack/extension maintainability

**Current blocker:** Pack and extension lifecycle is structurally sound but too
manual and metadata-heavy.

**Required change:** Generate projections, normalize dependency locks, reduce
manual duplicate registries.

**Closure:** Pack/extension validators prove no drift and no authority leakage.

### 8. Root manifest load

**Current blocker:** Root manifest correctly anchors portability but carries too
much execution detail.

**Required change:** Keep manifest as anchor; delegate bulky operational policy to
versioned referenced contracts.

**Closure:** Manifest remains stable, lower-churn, and validator-resolved.

### 9. Compatibility retirement

**Current blocker:** Compatibility shims are mostly labeled but too visible.

**Required change:** Require owner, successor, review cadence, retirement trigger.

**Closure:** Ownerless or triggerless shims fail architecture health.

### 10. Deployment practicality

**Current blocker:** Runtime workspace exists, but first-run install/doctor/closeout
path is not target-state productized.

**Required change:** Provide executable/fixture-backed doctor, run, inspect,
disclose, close, replay path.

**Closure:** A fresh operator can complete canonical first-run lifecycle.

## How this packet closes the gaps

| Gap | Packet artifact |
| --- | --- |
| Authorization coverage | `architecture/runtime-enforcement-hardening-plan.md`, `architecture/validation-plan.md` |
| Publication freshness | `architecture/pack-extension-publication-plan.md`, `architecture/file-change-map.md` |
| Support partitioning | `architecture/support-claim-partition-plan.md` |
| Support-pack graph | `architecture/support-claim-partition-plan.md`, `resources/coverage-traceability-matrix.md` |
| Proof maturity | `resources/evidence-plan.md`, `resources/proof-maturity-analysis.md` |
| Boot simplification | `architecture/operator-boot-simplification-plan.md` |
| Pack/extension lifecycle | `architecture/pack-extension-publication-plan.md` |
| Root manifest load | `architecture/file-change-map.md` |
| Shim retirement | `architecture/closure-certification-plan.md`, `resources/rejection-ledger.md` |
| Deployment practicality | `architecture/implementation-plan.md`, `architecture/cutover-checklist.md` |
