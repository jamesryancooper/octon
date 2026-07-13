# Implementation Plan

This plan becomes executable only after proposal acceptance and the entry
gates above. It does not authorize a candidate launch.

## Workstream 0 — Freeze Interfaces and Mechanisms

1. Bind RP-00 exit evidence and an exact repository baseline.
2. Apply ED-001 to a pinned macOS floor, native sandbox profile mechanism,
   provider client, and non-exportable or short-lived session form.
3. Record module/symbol ownership: RP-01 owns guard semantics and immediate
   launch; RP-02 owns isolation preparation/execution/cleanup; RP-11 owns the
   generic adapter interface.
4. Use sentinel credentials and disposable provider/project targets only.

## Workstream 1 — Independent Candidate Repository

1. Create a new repository and object database in a candidate-only root.
2. Materialize the exact source baseline and allowed inputs without linking
   canonical common-directory, refs, objects, config, index, hooks, or
   attributes.
3. Enforce candidate-only ownership and permissions for worktree and object
   state.
4. Define exact commit identity and a non-executing export envelope.

## Workstream 2 — Fresh Environment and Native Sandbox

1. Construct a fresh HOME and explicit environment allowlist.
2. Close inherited descriptors and create a controlled process group.
3. Apply the pinned macOS profile for read/write roots, process execution,
   signals, IPC, and network destinations.
4. Deny canonical repository, Keychain, SSH agent, credential helpers,
   privileged sockets, sibling workspaces, and undeclared temporary paths.

## Workstream 3 — Useful Provider Session

1. Attach a provider-native session that is useful to the model process but
   does not expose durable credential material.
2. Bind the session to candidate identity, expiry, allowed provider endpoint,
   and the exact run.
3. Run a representative positive task and capture provider usage and terminal
   observation without retaining secret material.
4. Refuse durable token fallback or a dependency on the future effect broker.

## Workstream 4 — Export, Cancellation, and Cleanup

1. Produce the exact candidate commit and content digest.
2. Export objects/metadata without trusted execution or canonical mutation.
3. Exercise timeout, cancellation, process-tree termination, partial export,
   and cleanup failure.
4. Retire or quarantine workspace, HOME, session, and temporary identity; no
   later run reuses them.

## Workstream 5 — Integration and Proof

1. Bind the isolation runner behind RP-01's guard-owning launch API after that
   interface freezes, without changing its semantics.
2. Expose the isolation binding through the existing adapter seam without
   defining RP-11 generic semantics.
3. Run the positive and adversarial suites and retain UE-003 evidence.
4. Complete conformance, drift/churn, rollback, and packet handoff receipts.

## Parallelization Constraints

- RP-02 may implement alongside RP-01 after RP-00, but the same launcher
  module/symbol may not be edited concurrently.
- RP-02 tests never use real production credentials or effect targets.
- RP-02 does not wait on or create an RP-04 broker dependency.
- Provider session, sandbox, export, and cleanup reviewers must be independent
  where trust-sensitive proof is assessed.

## Dependency Discipline

The plan prefers existing Rust launcher, macOS, Git, and provider-native
primitives. If a new library is required for sandbox or session integration,
implementation must add its exact Cargo targets to the packet, retain a
Dependency Receipt, and re-run completeness review before coding. A dependency
cannot silently broaden the promotion targets.
