# Atomic Cutover Plan

## Cutover Rule
The cutover is performed **once**, **atomically**, on a dedicated remediation branch. No partial merge is permitted. If any cutover gate fails, the branch does not merge and the active release claim must not remain unqualifiedly complete.

## Preconditions
1. Freeze claim-bearing path changes while the remediation branch is open:
   - `/.octon/framework/constitution/**`
   - `/.octon/instance/governance/**`
   - `/.octon/state/control/execution/**`
   - `/.octon/state/evidence/**`
   - `/.github/workflows/**`
2. Snapshot the current active release bundle and its digests.
3. Declare blocker classes A–E in authored governance.
4. Prepare all validator changes before flipping any claim-bearing surface.
5. Identify every active claim-bearing run in the current release bundle; every one must either be migrated or explicitly retired from the active claim before cutover completes.

## Ordered Migration Stages
### Stage 0 — Freeze and Snapshot
- create remediation branch
- capture current active release bundle
- generate baseline blocker ledger
- confirm that no concurrent support-target or authority-family edits are pending

### Stage 1 — Support-Target Canonicalization
- rewrite `support-targets.yml` to remove authored duplicate tuple-semantics
- preserve tuple inventory and admission refs only
- normalize all admission files as the sole canonical tuple-semantic source
- ensure dossiers contain evidence only
- regenerate effective support-target matrix
- update affected run contracts / run cards to bind canonical tuple IDs and mission semantics

### Stage 2 — Authority-Family Purity
- rewrite any lingering refs to flat compatibility aggregate files
- delete `exceptions/leases.yml` and `revocations/grants.yml` from live roots
- add generated aggregate mirrors only if required for non-authority consumers
- update READMEs and registry classification

### Stage 3 — Runtime / Stage-Attempt Normalization
- enumerate all stage-attempt artifacts under the active claim-bearing run set
- migrate any non-v2 artifact to v2 or retire the containing run from the active claim set
- remove claim-envelope language from stage-attempts and evidence classifications
- ensure run manifests and run contracts point only to canonical runtime artifacts

### Stage 4 — Disclosure Normalization
- regenerate all affected RunCards
- regenerate active HarnessCard and governance mirror
- populate `known_limits` from blocker ledger until ledger reaches zero
- regenerate claim-status and recertification-status from closure evidence

### Stage 5 — Validator / Workflow Hardening
- land strengthened validators and new negative-control sufficiency workflow
- wire blocker-ledger gating into closure-certification and completion workflows
- add weekly drift watch that re-opens claim status automatically on semantic drift

### Stage 6 — Certification Pass 1
- generate release bundle
- generate closure projections
- run all strengthened validators
- produce blocker ledger
- fail if blocker ledger is non-zero
- fail if any generated artifact differs from committed canonical disclosure bundle

### Stage 7 — Certification Pass 2
- rerun bundle/projection generation from the now-generated state
- rerun parity and freshness validators
- require byte-stable outputs and zero blocker ledger again

### Stage 8 — Claim Flip
- only after both passes are clean:
  - keep `release-lineage.yml` active release as current
  - publish `claim_status: complete`
  - publish HarnessCard with truthful `known_limits`
  - publish certified closure certificate

## Cutover Gates
- **Gate A:** support-target semantic parity proven
- **Gate B:** authority-family purity proven
- **Gate C:** no stale claim-envelope wording in active claim-bearing artifacts
- **Gate D:** stage-attempt family canonicality proven across active run set
- **Gate E:** validator sufficiency proven against seeded negative controls
- **Gate F:** pass 1 clean
- **Gate G:** pass 2 clean and byte-stable

## Rollback Conditions
### Pre-merge rollback
If any gate fails before merge, abandon the remediation branch. The active release may not be reasserted as unqualifiedly complete.

### Post-merge recertification rollback
If later drift reintroduces any blocker class, the recertification regime must:
- mark the blocker ledger non-zero,
- invalidate unqualified completion,
- and force a fresh certification cycle before `claim_status: complete` can stand again.

## No-Partial-State Guarantees
- No compatibility aggregate is deleted before all refs are rewritten in the same cutover set.
- No claim-bearing disclosure is regenerated before runtime/evidence normalization is complete.
- No claim-status is published as complete before blocker ledger is zero and pass 2 is clean.
- No support-target semantic duplication remains in authored live canonical surfaces after cutover.
