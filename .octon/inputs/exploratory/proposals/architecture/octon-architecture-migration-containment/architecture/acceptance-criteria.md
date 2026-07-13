# Acceptance Criteria

These are future implementation-exit conditions. None is satisfied by packet
creation.

## Entry Gates

- **AC-00:** The implementation binds an exact clean repository commit, commit
  time, branch, staged/unstaged/untracked state, and a redacted read-only
  provider observation with freshness status.
- **AC-01:** The proposal is accepted only after the accepted ROD-006
  no-Octon-direct-main posture is bound, the Implementation-Grade Completeness
  Gate passes, and a valid pre-integration architecture review receipt passes.

## Containment Gates

- **AC-02:** Every candidate-head privileged provider writer identified by the
  physical inventory is disabled or placed behind a candidate-immutable
  boundary; a negative fixture proves candidate edits cannot write.
- **AC-03:** No Octon route, agent or human, can select direct-main. Ordinary
  human Git remains outside Octon. Current autonomous no-PR and local landing
  effect entrypoints are unreachable while their classification and candidate
  remain intact.
- **AC-04:** Protected PR is available only for independently review-selected
  work after its candidate-code/credential boundary is proved safe. No current
  PR workflow is presumed safe and invalid/raced authority never becomes PR.

## Inventory Gates

- **AC-05:** Physical writer, launcher, credential, policy-input, trust-root,
  and provider-workflow inventories cover every discovered runtime, shell,
  workflow, and provider entrypoint and assign one authenticated role,
  interface, owner, and later packet disposition.
- **AC-06:** An intentionally unregistered writer and launcher fail the
  material-side-effect and authorization-boundary validators.
- **AC-07:** Inventory generation is deterministic at the bound commit and
  records source refs and digests without treating generated output as
  authority.

## Claim and Product Gates

- **AC-08:** All live support and HarnessCard source claims match admitted
  tuples and direct retained evidence. No stage-only, unadmitted, unsupported,
  referenced-only, unsigned, or stale surface is described as live proof.
- **AC-09:** A negative fixture proves a referenced-only test cannot receive
  `DYNAMICALLY_EXECUTED` classification.
- **AC-10:** A reproducible baseline records tracked state file count, bytes,
  inodes, workflow count, visible command concepts, prompt behavior, and
  operator effort without asserting that every measured surface is obsolete.

## Safety and Closeout Gates

- **AC-11:** Rollback testing proves non-safety wording and inventory changes
  can be reverted while unsafe routes remain disabled and candidate work stays
  preserved without requiring a route change.
- **AC-12:** No `.github/**` path appears as an `octon-internal` promotion
  target, and any required host-projection change is traceable to a durable
  `.octon/**` owner plus projection validation.
- **AC-13:** PO-FD-015 passes and PG-00-WRITER-INVENTORY records direct proof;
  RF-007, RF-013, RF-018, and RF-032 are resolved for RP-00 scope, while
  cross-packet findings remain assigned to their owners.
- **AC-14:** Implementation conformance and post-implementation drift/churn
  receipts pass before this packet may claim implementation or archive-ready
  status.

- **AC-15:** Direct invocation of the current hosted no-PR helper, local landing
  helper, and destructive cleanup helper denies during containment.
- **AC-16:** A closed-unmerged or otherwise unlanded candidate is never deleted;
  outage, rejection, and collision each retain a recoverable exact SHA.
- **AC-17:** Eligible Class B remains reported as no-PR-but-blocked until the
  RP-05–RP-08 safety spine exits; no universal PR requirement is introduced.
