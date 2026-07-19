# File Change Map

All entries are planned, not implemented. `Octon runtime` owns launcher and
isolation code, `Octon contracts` owns schemas, and `Octon assurance` owns
adversarial validation. The trusted integrator must enforce the RP-01/RP-02,
RP-02/RP-11, and RP-02/RP-04 symbol boundaries before any edit begins.

| Durable promotion target | Current assumption | Required RP-02 change | Ownership and rationale |
| --- | --- | --- | --- |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/lib.rs` | The crate exports lifecycle execution without a candidate-isolation surface. | Register and expose only the reviewed RP-02 isolation types needed by the frozen RP-01 launch seam. | RP-02; no authority or generic-adapter semantics. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs` | `execute_real` dispatches from the canonical repository after authorization. | At the allocated call site, consume `CandidateIsolationRunner` after RP-01's frozen guard and route observation/cancellation/retirement without altering guard or generic adapter semantics. | Shared integration seam; RP-02 owns only this named call slice. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/auto.rs` | `resolve_executor` selects an installed provider binary from ambient `PATH`. | Resolve only an absolute non-candidate-writable OpenAI Codex CLI whose exact digest and reported version match the admitted run tuple; reject missing, broken, relative, PATH-only, or changed clients. | RP-02 slice in `resolve_executor`; RP-11 later owns generic resolution semantics. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs` | `run_with_timeout` runs Codex with canonical `repo_root` and inherited context. | Replace only its ambient final spawn with `CandidateIsolationRunner::apply_native_policy_and_spawn` inside the independent root, after the RP-01 guard and with the one-run relay binding. | RP-02 allocated launcher-mechanics slice; RP-01 guard and RP-11 generic semantics remain separate. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/claude.rs` | `execute_claude` delegates to an ambient secondary provider. | Deny the candidate-isolation route because ED-001 admits no secondary-provider tuple; do not claim or silently inherit primary-provider support. | RP-02 narrow denial slice in `execute_claude`; no second-provider proof. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs` | `LifecycleRouteExecutionRequest` has no exact isolation binding. | Carry the minimum versioned profile/client/relay/repository binding while leaving authority fields owned by RP-01 and generic adapter fields owned by RP-11. Never carry durable credential material. | Shared schema-first slice in the named request type. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/candidate_isolation.rs` | No dedicated isolation module exists. | Add `CandidateIsolationSpec`, `CandidateIsolationRunner`, `PreparedCandidate`, `CandidateProviderRelay`, `ExactCommitExport`, and `RetirementReceipt`; implement `prepare`, `start_relay`, `apply_native_policy_and_spawn`, `export_exact_commit`, and `retire`. | Primary RP-02 source owner with exact state-machine symbols. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs` | Tests cover lifecycle dispatch and descendant termination, not the full credentialless boundary. | Add positive useful-task binding tests and negative integration fixtures without real credentials or production targets. | RP-02 tests at the existing integration seam. |
| `.octon/framework/engine/runtime/adapters/host/macos-candidate.yml` | No candidate-specific native macOS host adapter declaration exists. | Declare arm64 macOS 26/Darwin 25, root-owned `/usr/bin/sandbox-exec`, default-deny SBPL rendering, exact client identity, exact one-run relay listener, denials, evidence bindings, and unsupported remainder. | RP-02 host binding; it is not a new control plane. |
| `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md` | The harness binds capability and authority routes but does not state the candidate-isolation envelope. | Define the candidate isolation binding and its non-authority, non-credential, independent-Git invariants. | Contract owner with RP-02 content; no grant semantics. |
| `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.schema.json` | The runtime schema cannot validate the planned isolation binding. | Validate exact profile, workspace, repository, provider-session, allowlist, export, and cleanup references. | Runtime contract owner; versioning reviewed before implementation. |
| `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-v1.schema.json` | The constitutional mirror does not encode the candidate-isolation boundary. | Apply the same governed contract change through the owning constitutional route and parity checks. | Contract owner; RP-02 cannot independently redefine constitutional authority. |
| `.octon/framework/constitution/contracts/adapters/host-adapter-v1.schema.json` | Host adapters have no validated native-candidate isolation capability envelope. | Admit the minimal macOS candidate profile fields and fail unknown or privilege-widening declarations. | Adapter contract owner; generic adapter semantics remain RP-11-owned. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-candidate-isolation.sh` | No packet-specific structural and retained-evidence validator exists. | Add deterministic checks for exact host/client/executable/profile/relay identity, state-machine/spawn dominance, inference-only protocol, repository independence, FD/env/network/process/filesystem denials, export, and cleanup evidence. | RP-02 assurance owner; planned new target. |
| `.octon/framework/assurance/runtime/_ops/tests/test-candidate-isolation.sh` | No adversarial isolation test driver exists. | Execute the positive task, credential/host/Git canaries, fault matrix, exact export, and cleanup/reuse checks. | RP-02 assurance owner; never uses durable production credentials. |
| `.octon/framework/assurance/runtime/_ops/fixtures/candidate-isolation/` | No hostile candidate fixture family exists. | Add sentinel credentials, malicious Git configuration, filesystem escapes, process/FD probes, network probes, and deterministic positive-task fixtures. | RP-02 fixture owner; disposable targets only. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-candidate-isolation/` | No RP-02 implementation evidence exists at packet creation. | Retain redacted profile/session identity, UE-003, positive task, negative matrices, export, cleanup, rollback, conformance, and drift receipts. | Evidence-only target; never authority or secret storage. |

## Affected but Excluded Surfaces

- The pre-existing upstream provider transport is observed deployment state,
  not a promoted repository target. RP-02 reads no durable credential value
  into candidate state and retains none.
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
