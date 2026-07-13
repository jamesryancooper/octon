# Acceptance Criteria

These are future implementation gates. Packet creation satisfies none of the
runtime or provider proof conditions.

## Entry and Ownership

- **AC-00:** `octon-architecture-migration-containment` reaches its contained
  exit state and candidate-head privileged effects remain disabled.
- **AC-01:** ED-001 is resolved to exact pinned macOS, sandbox, provider-client,
  and provider-session mechanisms; independent review and proposal acceptance
  pass.
- **AC-02:** Source ownership proves RP-02 edits only isolation-owned
  modules/symbols; RP-01 guard semantics and RP-11 generic adapter semantics
  remain untouched or are consumed through frozen interfaces.

## Useful Positive Path

- **AC-03:** A representative primary-supported-provider task completes in the
  isolated candidate, produces the expected bounded result, and records exact
  provider, client, sandbox, source, and workspace identities.
- **AC-04:** The candidate result becomes an exact commit in an independent
  disposable repository and can be exported for protected PR without
  executing candidate hooks, filters, helpers, drivers, or checkout code under
  trusted identity.

## Credential and Host Negatives

- **AC-05:** Sentinel environment, Keychain, SSH agent, Git credential helper,
  provider token, parent descriptor, and host configuration probes all fail.
- **AC-06:** The candidate cannot read or mutate canonical refs, objects,
  index, config, hooks, attributes, worktrees, or repository common-directory
  state.
- **AC-07:** Filesystem traversal, symlink, hardlink, case, temporary-directory,
  parent-process, sibling-process, signal, and undeclared executable probes
  deny outside the declared envelope.
- **AC-08:** Network access is limited to the pinned provider/session and
  explicitly declared task destinations; loopback privilege services,
  metadata endpoints, arbitrary egress, and broker IPC deny.

## Lifecycle and Recovery

- **AC-09:** Inherited FDs are closed except the explicit standard and control
  channels, process-group cancellation terminates descendants, and no orphan
  survives timeout or cancellation.
- **AC-10:** Successful and failed runs retire or quarantine session, guard,
  workspace, and temporary HOME state without identity reuse; cleanup proof is
  retained.
- **AC-11:** Disabling automated launch preserves/exports the exact candidate
  commit when available and routes it to manual/protected PR without granting
  credentials or canonical Git access.

## Proof and Closeout

- **AC-12:** PO-FD-008 passes PG-02-MACOS-ISOLATION and UE-003 records one
  useful positive result plus the full negative matrix.
- **AC-13:** The candidate-side portion of PO-FD-006 is directly proved and
  cross-referenced to RP-04; RP-02 does not claim the broker/IPC half or
  PG-04 closure.
- **AC-14:** RF-004 and RF-023 resolve for RP-02; RF-025 remains cross-owned by
  RP-04 until the shared provider-session evidence is complete.
- **AC-15:** Implementation conformance and post-implementation drift/churn
  receipts pass before `implemented` or implemented archival is claimed.

