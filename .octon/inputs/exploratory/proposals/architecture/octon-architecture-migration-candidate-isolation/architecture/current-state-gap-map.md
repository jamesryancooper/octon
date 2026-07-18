# Current-State Gap Map

## Bound Baseline

The reconciled baseline is clean `main` at
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. The proposal-creation commit is
`d78ee8b42cb3a39557bbe39b66cb5d156946172a`; no RP-02 runtime, adapter,
contract, assurance, or provider-launch source changed between them.
Implementation still requires a fresh exact baseline and proof against the
selected ED-001 tuple. At revision time, the observed host is arm64 macOS
26.5.2 build 25F84/Darwin 25; `/usr/bin/sandbox-exec` is present, but the shell
Codex wrapper does not resolve its native executable. That observed client
failure is an implementation-entry denial, not evidence that provider work or
native enforcement succeeded.

## Repository-Grounded Gaps

| Gap | Current evidence | Required RP-02 correction | Adjacent owner |
| --- | --- | --- | --- |
| Candidate runs in canonical repo | `lifecycle_executor/src/codex.rs` sets current directory and `--cd` to the repository root. | Build and launch from a separate disposable repository with its own common directory, refs, objects, config, and worktree. | RP-05 later owns trusted candidate-object import for privileged Git. |
| Host credential capability is shared | Current launcher reads the operator HOME and can access the host context; the reconciliation proves exposure capability, not any named secret use. | Construct a fresh allowed HOME/environment, close inherited descriptors, deny Keychain/SSH/canonical-host probes, and attach only a candidate-safe provider session. | RP-04 owns privileged credential custody. |
| Current sandbox is not the accepted boundary | Codex is launched with `workspace-write`, but the canonical checkout remains the workspace and no repo-owned macOS candidate profile proves the full boundary. | For the initial arm64 macOS 26/Darwin 25 envelope, render a default-deny SBPL profile from `macos-candidate.yml`, bind its digest and root-owned `/usr/bin/sandbox-exec` digest, and apply it before the exact client exec. | RP-11 owns generic adapter conformance, not this host boundary. |
| Provider session mechanism is unproved | No live safe experiment establishes useful work without durable candidate-readable provider authentication. | Use `loopback-capability-relay-v1`: a trusted launcher-owned inference-only relay outside the sandbox holds the pre-existing upstream transport; the candidate receives one random 256-bit run/deadline/budget-bound bearer and can reach only the exact relay listener. Prove one useful task and every durable-credential/direct-egress/loopback negative. | UE-003 remains shared with RP-04; the relay exposes no RP-04 effect operation. |
| Linked worktree can share Git authority | Git worktrees share a common directory and object/ref/config state. | Prohibit linked-worktree-only isolation; initialize or materialize a truly independent repository/object database. | RF-023 primary. |
| Candidate artifact transfer is not a bounded contract | Current candidate work happens directly in the target repository. | Export the exact candidate commit through a content-addressed, non-executing boundary that preserves work without mutating canonical Git. | RP-05 consumes candidate objects later; RP-02 owns export mechanics only. |
| Launcher ownership overlaps were implicit | RP-01 now freezes `consume_candidate_launch_guard`, while RP-11 later normalizes generic adapters. | RP-02 owns `CandidateIsolationRunner` and its preparation/relay/native-spawn/export/retirement methods, plus only the named integration slices in `execute_real`, `resolve_executor`, `run_with_timeout`, `execute_claude`, and `LifecycleRouteExecutionRequest`. | RP-01 and RP-11 remain exclusive owners of their contracts. |

## Preserved Primitives

- Existing lifecycle request, timeout, cancellation, process-group, and
  terminal-observation behavior.
- Current provider launch binaries behind a stricter host boundary.
- Run Contract, exact guard, Harness, and adapter contracts as consumed inputs,
  never authority invented by RP-02.
- Route-neutral exact-candidate preservation while privileged publication
  remains disabled; protected PR is possible only after a later fresh RP-06
  review-required selection.
