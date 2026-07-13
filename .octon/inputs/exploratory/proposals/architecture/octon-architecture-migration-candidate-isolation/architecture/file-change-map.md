# File Change Map

All entries are planned, not implemented. `Octon runtime` owns launcher and
isolation code, `Octon contracts` owns schemas, and `Octon assurance` owns
adversarial validation. The trusted integrator must enforce the RP-01/RP-02,
RP-02/RP-11, and RP-02/RP-04 symbol boundaries before any edit begins.

| Durable promotion target | Current assumption | Required RP-02 change | Ownership and rationale |
| --- | --- | --- | --- |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/lib.rs` | The crate exports lifecycle execution without a candidate-isolation surface. | Register and expose only the reviewed RP-02 isolation types needed by the frozen RP-01 launch seam. | RP-02; no authority or generic-adapter semantics. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs` | Real executors dispatch from the canonical repository after authorization. | Bind the selected primary-provider path to isolation preparation, observation, cancellation, and retirement through frozen interfaces. | Shared integration seam; RP-02 edits only an allocated call site and does not alter RP-01 authorization. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/auto.rs` | Executor discovery selects an installed provider binary from ambient `PATH`. | Resolve only the admitted provider/client tuple supplied by the isolation contract and reject undeclared fallback. | RP-02 provider binding; RP-11 later owns generic resolution semantics. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs` | Codex runs with `--cd` and `current_dir` set to canonical `repo_root`, can add repository-local runtime state, and inherits the parent environment. | Launch the primary-provider client only inside the independent candidate root with fresh HOME/env, explicit descriptors, pinned sandbox profile, bounded network, and isolated result observation. | RP-02 allocated launcher mechanics; RP-01 guard checks remain outside and before this launch. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/claude.rs` | The secondary provider delegates to the same ambient launcher. | Refuse the new isolation route unless a separately admitted provider tuple exists; do not claim or silently inherit primary-provider support. | RP-02 narrow denial/parity edit only; no second-provider proof in this packet. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs` | Requests bind lifecycle execution but not an exact candidate isolation profile, repository identity, or provider session class. | Add the minimum versioned isolation binding consumed by RP-02 while leaving authority fields owned by RP-01 and generic adapter fields owned by RP-11. | Shared contract surface; schema-first allocation required. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/candidate_isolation.rs` | No dedicated isolation module exists. | Add preparation, independent-repository materialization, fresh environment, FD closure, native-policy launch, exact commit export, cancellation, and cleanup state machines. | Primary RP-02 source owner. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs` | Tests cover lifecycle dispatch and descendant termination, not the full credentialless boundary. | Add positive useful-task binding tests and negative integration fixtures without real credentials or production targets. | RP-02 tests at the existing integration seam. |
| `.octon/framework/engine/runtime/adapters/host/macos-candidate.yml` | No candidate-specific native macOS host adapter declaration exists. | Declare the pinned native isolation capabilities, denials, evidence bindings, version floor, and unsupported remainder. | RP-02 host binding; it is not a new control plane. |
| `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md` | The harness binds capability and authority routes but does not state the candidate-isolation envelope. | Define the candidate isolation binding and its non-authority, non-credential, independent-Git invariants. | Contract owner with RP-02 content; no grant semantics. |
| `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.schema.json` | The runtime schema cannot validate the planned isolation binding. | Validate exact profile, workspace, repository, provider-session, allowlist, export, and cleanup references. | Runtime contract owner; versioning reviewed before implementation. |
| `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-v1.schema.json` | The constitutional mirror does not encode the candidate-isolation boundary. | Apply the same governed contract change through the owning constitutional route and parity checks. | Contract owner; RP-02 cannot independently redefine constitutional authority. |
| `.octon/framework/constitution/contracts/adapters/host-adapter-v1.schema.json` | Host adapters have no validated native-candidate isolation capability envelope. | Admit the minimal macOS candidate profile fields and fail unknown or privilege-widening declarations. | Adapter contract owner; generic adapter semantics remain RP-11-owned. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-candidate-isolation.sh` | No packet-specific structural and retained-evidence validator exists. | Add deterministic checks for profile/session identity, repository independence, FD/env/network/process/filesystem denials, export, and cleanup evidence. | RP-02 assurance owner; planned new target. |
| `.octon/framework/assurance/runtime/_ops/tests/test-candidate-isolation.sh` | No adversarial isolation test driver exists. | Execute the positive task, credential/host/Git canaries, fault matrix, exact export, and cleanup/reuse checks. | RP-02 assurance owner; never uses durable production credentials. |
| `.octon/framework/assurance/runtime/_ops/fixtures/candidate-isolation/` | No hostile candidate fixture family exists. | Add sentinel credentials, malicious Git configuration, filesystem escapes, process/FD probes, network probes, and deterministic positive-task fixtures. | RP-02 fixture owner; disposable targets only. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-candidate-isolation/` | No RP-02 implementation evidence exists at packet creation. | Retain redacted profile/session identity, UE-003, positive task, negative matrices, export, cleanup, rollback, conformance, and drift receipts. | Evidence-only target; never authority or secret storage. |

## Affected but Excluded Surfaces

- Provider-native session and account state is observed deployment state, not a
  promoted repository target. No durable credential value is read or retained.
- Disposable candidate workspaces, HOME directories, repositories, object
  databases, process groups, and native sandbox instances are ephemeral host
  state and cannot become authority.
- `.octon/framework/engine/runtime/adapters/model/**` is affected conceptually,
  but RP-02 does not author a generic or multi-provider model-adapter contract.
  RP-11 owns that adapter family.
- Canonical Git, `.github/**`, provider effects, broker IPC, Keychain custody,
  VM infrastructure, Linux production support, and generated proposal views
  are not RP-02 promotion targets.

## Collision Rule

If review cannot allocate exact non-overlapping symbols in `adapter.rs`,
`request.rs`, `codex.rs`, the harness contracts, or the host-adapter schema,
implementation stops and the packet is revised. A shared file path is not
permission to co-own the same semantic interface.
