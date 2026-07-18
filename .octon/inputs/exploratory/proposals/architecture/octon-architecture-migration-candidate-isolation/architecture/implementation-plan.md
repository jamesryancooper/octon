# Implementation Plan

This plan becomes executable only after proposal acceptance and a separately
generated exact implementation prompt. RP-00 verification and the host/client/
upstream preflight gate execution, not design acceptance. This document does
not authorize a candidate launch.

## Workstream 0 — Freeze Interfaces and Mechanisms

1. Bind RP-00 verification evidence and an exact repository baseline before
   any candidate execution.
2. Materialize the selected ED-001 default from
   `resources/engineering-disposition-ed001.yml`: arm64 macOS 26/Darwin 25,
   root-owned exact-digest `/usr/bin/sandbox-exec`, digest-bound default-deny
   SBPL, exact-digest/version OpenAI Codex CLI, and
   `loopback-capability-relay-v1`.
3. Preflight a working absolute client and authenticated upstream transport.
   Missing/broken client or unavailable transport denies without credential
   acquisition, direct provider access, or RP-04 fallback.
4. Consume RP-01's frozen `consume_candidate_launch_guard`. RP-02 owns the
   `CandidateIsolationRunner::{prepare,start_relay,apply_native_policy_and_spawn,
   export_exact_commit,retire}` slice; RP-11 owns the generic adapter interface.
5. Use sentinel credentials and disposable provider/project targets only.

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
3. Render the default-deny SBPL profile from `macos-candidate.yml`, bind its
   digest and the root-owned `/usr/bin/sandbox-exec` digest, allow only exact
   read/write roots, executables, owned processes, IPC, and the relay listener,
   then apply it before the primary-provider exec.
4. Deny canonical repository, Keychain, SSH agent, credential helpers,
   privileged sockets, sibling workspaces, and undeclared temporary paths.

## Workstream 3 — Useful Provider Session

1. Start `CandidateProviderRelay` outside the candidate sandbox/process group
   using a pre-existing authenticated upstream primary-provider transport;
   never copy, persist, log, or return its durable authentication.
2. Mint one random 256-bit candidate-readable bearer bound to the run, process
   group, provider/model, request/token budgets, exact 127.0.0.1 listener, and
   deadline, with concurrency one and no reuse.
3. Configure the exact Codex CLI to reach only that inference relay; direct
   provider egress and every other loopback target deny.
4. Run a representative positive task and capture redacted usage/terminal
   observation, then atomically revoke the bearer and stop the relay at every
   terminal path.
5. Refuse ambient/durable token fallback, provider administration, privileged
   effects, or a dependency on the future RP-04 effect broker.

## Workstream 4 — Export, Cancellation, and Cleanup

1. Produce the exact candidate commit and content digest.
2. Export objects/metadata without trusted execution or canonical mutation.
3. Exercise timeout, cancellation, process-tree termination, partial export,
   and cleanup failure.
4. Retire or quarantine workspace, HOME, session, and temporary identity; no
   later run reuses them.

## Workstream 5 — Integration and Proof

1. Bind the isolation runner immediately after RP-01's accepted frozen
   `consume_candidate_launch_guard` invocation, without changing its semantics.
2. Expose the isolation binding through the existing adapter seam without
   defining RP-11 generic semantics.
3. Only after the exact implementation exists, run the positive and
   adversarial suites and retain UE-003 evidence against its exact commit.
4. Complete conformance, drift/churn, rollback, and packet handoff receipts.

## Parallelization Constraints

- RP-02 may implement alongside RP-01 after RP-00, but the same launcher
  module/symbol may not be edited concurrently.
- RP-02 tests never use real production credentials or effect targets.
- RP-02 does not wait on or create an RP-04 broker dependency.
- Provider session, sandbox, export, and cleanup reviewers must be independent
  where trust-sensitive proof is assessed.

## Dependency Discipline

The plan prefers existing Rust launcher, macOS, Git, and HTTP primitives. If a
new library is required for SBPL rendering or the inference relay,
implementation must add its exact Cargo targets to the packet, retain a
Dependency Receipt, and re-run completeness review before coding. A dependency
cannot silently broaden the promotion targets.
