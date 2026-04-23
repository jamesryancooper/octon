# Cutover Checklist

## Pre-cutover

- [ ] Proposal packet reviewed against current repo state.
- [ ] Promotion targets remain `.octon/**` only.
- [ ] No support-target expansion bundled.
- [ ] v2 schemas added and validated.
- [ ] Runtime docs updated.
- [ ] Runtime bus append path implemented.
- [ ] Replay store reconstruction implemented.
- [ ] Evidence snapshot writer implemented.
- [ ] Operator read-model source/freshness requirements implemented.

## Validation

- [ ] `validate-proposal-standard.sh` passes for this packet before promotion.
- [ ] `validate-architecture-proposal.sh` passes for this packet before promotion.
- [ ] `validate-run-journal-contracts.sh` passes.
- [ ] `validate-architecture-conformance.sh` invokes Run Journal checks.
- [ ] Runtime docs consistency validation passes.
- [ ] Support-target admission validation requires Run Journal proof.

## Fixture Runs

- [ ] Denied authorization fixture passes.
- [ ] Observe/read fixture passes.
- [ ] Repo-consequential staged fixture passes.
- [ ] Checkpoint/resume fixture passes.
- [ ] Rollback/recovery fixture passes.
- [ ] Operator intervention fixture passes.

## Negative tests

- [ ] Missing event fails closed.
- [ ] Event reorder fails closed.
- [ ] Hash mismatch fails closed.
- [ ] Runtime-state conflict triggers drift.
- [ ] Generated read model as authority fails closed.
- [ ] Side effect without grant/journal refs fails closed.
- [ ] Replay live side effect without fresh grant fails closed.

## Evidence

- [ ] Evidence roots captured under `state/evidence/validation/**`.
- [ ] Closeout evidence includes journal snapshot and manifest hash match.
- [ ] Operator disclosure cites canonical roots.
- [ ] Redactions, if any, include lineage.

## Post-cutover

- [ ] Generated projections rebuilt from canonical roots.
- [ ] Proposal closure certification complete.
- [ ] Migration exceptions recorded.
- [ ] Stage-only surfaces remain stage-only unless separately admitted.
