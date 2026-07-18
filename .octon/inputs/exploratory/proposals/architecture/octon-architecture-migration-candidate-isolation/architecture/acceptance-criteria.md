# Acceptance Criteria

AC-01 and AC-02 are proposal-design gates. AC-00 is an implementation-entry
gate. AC-03 through AC-15 are future exact-implementation gates; this revision
satisfies none of their runtime or provider proof conditions.

## Entry and Ownership

- **AC-00:** `octon-architecture-migration-containment` reaches its contained
  exit state and candidate-head privileged effects remain disabled.
- **AC-01:** ED-001 selects arm64 macOS 26/Darwin 25, root-owned exact-digest
  `/usr/bin/sandbox-exec`, a digest-bound default-deny SBPL profile generated
  from `macos-candidate.yml`, an absolute exact-digest/version OpenAI Codex
  CLI, and `loopback-capability-relay-v1`. Independent review and proposal
  acceptance pass before implementation authorization.
- **AC-02:** Source ownership proves RP-02 edits only isolation-owned
  modules/symbols; RP-01 guard semantics and RP-11 generic adapter semantics
  remain untouched or are consumed through frozen interfaces.

## Useful Positive Path

- **AC-03:** After the exact implementation is authorized and AC-00 passes, a
  representative primary-supported-provider task completes in the
  isolated candidate, produces the expected bounded result, and records exact
  provider, client, sandbox, source, and workspace identities.
- **AC-04:** The candidate result becomes an exact commit in an independent
  disposable repository and can be exported as an exact route-neutral
  candidate without executing candidate hooks, filters, helpers, drivers, or
  checkout code under trusted identity.

## Credential and Host Negatives

- **AC-05:** Sentinel environment, Keychain, SSH agent, Git credential helper,
  provider token, parent descriptor, and host configuration probes all fail.
- **AC-06:** The candidate cannot read or mutate canonical refs, objects,
  index, config, hooks, attributes, worktrees, or repository common-directory
  state.
- **AC-07:** Filesystem traversal, symlink, hardlink, case, temporary-directory,
  parent-process, sibling-process, signal, and undeclared executable probes
  deny outside the declared envelope.
- **AC-08:** Candidate network access is limited to the exact one-run relay
  listener. Direct provider access, every other loopback listener, metadata
  endpoints, arbitrary egress, and broker IPC deny. The relay admits only the
  run/model/budget-bound inference protocol and no effect operation.

## Lifecycle and Recovery

- **AC-09:** Inherited FDs are closed except the explicit standard and control
  channels, process-group cancellation terminates descendants, and no orphan
  survives timeout or cancellation.
- **AC-10:** Successful and failed runs retire or quarantine session, guard,
  workspace, and temporary HOME state without identity reuse; cleanup proof is
  retained.
- **AC-11:** Disabling automated launch preserves/exports the exact candidate
  commit when available without granting credentials, canonical Git access, or
  a publication-route decision; protected PR requires a later fresh valid
  RP-06 review predicate.

## Proof and Closeout

- **AC-12:** Against the exact authorized implementation commit, PO-FD-008
  passes PG-02-MACOS-ISOLATION and UE-003 records one useful positive result
  plus the full negative matrix before conformance, completion, cutover,
  support claim, or promotion.
- **AC-13:** The candidate-side portion of PO-FD-006 is directly proved and
  cross-referenced to RP-04; RP-02 does not claim the broker/IPC half or
  PG-04 closure.
- **AC-14:** RF-004 and RF-023 resolve for RP-02; RF-025 remains cross-owned by
  RP-04 until the shared provider-session evidence is complete.
- **AC-15:** Implementation conformance and post-implementation drift/churn
  receipts pass before `implemented` or implemented archival is claimed.
