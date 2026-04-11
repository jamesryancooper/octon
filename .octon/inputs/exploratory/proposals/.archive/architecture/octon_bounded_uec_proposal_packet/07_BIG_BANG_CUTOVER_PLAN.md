# 07. Big-bang cutover plan

## 7.1 Cutover objective

This packet supports a **single atomic clean-break constitutional cutover** for packet-scope target-state changes.

No dual-live constitutional regime is allowed. At promotion time there is exactly one active bounded hardened release.

## 7.2 Preconditions

The cutover may begin only when all of the following are true:

1. support-target universe is frozen for the duration of the cutover;
2. no new adapter or capability-pack admissions are pending;
3. the fresh build-to-delete packet is complete;
4. the current-audit crosswalk is complete;
5. all in-scope dossier depth / evaluator / hidden-check minima are met;
6. all required validator scripts exist and pass in dry-run mode;
7. the new release bundle has been staged but not promoted.

## 7.3 Exact cutover steps

### Step 1 — freeze the branch

- create a cutover branch/tag
- record the support-target digest
- record the active release-lineage digest
- record the validator suite digest

### Step 2 — land active authority changes

Land modifications to:

- support-target wording / enum calibration
- claim-truth conditions
- registry and family README normalization
- retirement register v3
- ingress manifest + ingress file updates
- closeout-reviews latest packet pointer

### Step 3 — land new evidence / review artifacts

Land:

- fresh build-to-delete packet
- fresh bounded hardening audit bundle
- additional retained runs and upgraded support dossiers
- depth/diversity/hidden-check reports

### Step 4 — generate the new bounded hardened release bundle

Generate the full release bundle under the new `<CUTOVER_DATE>-uec-bounded-hardening-closure` directory.

### Step 5 — validation pass 1

Run the full validator suite on the cutover branch.

If any claim-critical failure occurs, stop. Do **not** promote.

### Step 6 — validation pass 2 from clean checkout

Clone or clean-checkout the branch and rerun the entire validator suite.

If pass 2 fails, stop. Do **not** promote.

### Step 7 — certification issuance

Issue the new closure certificate and residual ledger.

### Step 8 — active promotion

Update:

- `instance/governance/disclosure/release-lineage.yml`
- `generated/effective/closure/claim-status.yml`
- any active effective projections that point to the old release

Mark the previous active release as superseded historical evidence.

## 7.4 Fail-closed conditions

Promotion must fail closed if any of the following occurs:

- any claim-critical matrix row remains open;
- any admitted tuple lacks required evidence-depth sufficiency;
- evaluator diversity or hidden-check breadth minima are not met;
- any active artifact still uses overbroad claim wording;
- the fresh review packet is not referenced everywhere active lineage requires it;
- any generated/effective/operator surface lacks non-authority labeling;
- any ingress parity failure occurs;
- pass 1 or pass 2 fails.

## 7.5 Rollback posture

Because this is a clean-break, rollback is simple:

1. revert `release-lineage.yml` active pointer to the previous active release;
2. revert generated/effective active pointers;
3. leave the new release bundle on disk as unpromoted evidence;
4. record the failed cutover reason in governance state.

No partial promotion is allowed.

## 7.6 Post-cutover immediate checks

After promotion, run a final post-promotion verification sweep:

- active release-lineage points to the new release;
- claim-status projection matches the new release;
- support-universe coverage and dossiers still align;
- non-authority register and retirement register validate;
- build-to-delete freshness report is green;
- closure certificate and residual ledger are published.
