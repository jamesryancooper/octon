# Current-State Gap Map

## Bound Baseline

The reconciled baseline is clean `main` at
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. The proposal-creation commit is
`d78ee8b42cb3a39557bbe39b66cb5d156946172a`; no RP-02 runtime, adapter,
contract, assurance, or provider-launch source changed between them.
Implementation still requires a fresh exact baseline and pinned macOS and
provider versions.

## Repository-Grounded Gaps

| Gap | Current evidence | Required RP-02 correction | Adjacent owner |
| --- | --- | --- | --- |
| Candidate runs in canonical repo | `lifecycle_executor/src/codex.rs` sets current directory and `--cd` to the repository root. | Build and launch from a separate disposable repository with its own common directory, refs, objects, config, and worktree. | RP-05 later owns trusted candidate-object import for privileged Git. |
| Host credential capability is shared | Current launcher reads the operator HOME and can access the host context; the reconciliation proves exposure capability, not any named secret use. | Construct a fresh allowed HOME/environment, close inherited descriptors, deny Keychain/SSH/canonical-host probes, and attach only a candidate-safe provider session. | RP-04 owns privileged credential custody. |
| Current sandbox is not the accepted boundary | Codex is launched with `workspace-write`, but the canonical checkout remains the workspace and no repo-owned macOS candidate profile proves the full boundary. | Apply a pinned native macOS profile with explicit filesystem, process, network, and descriptor posture around the independent workspace. | RP-11 owns generic adapter conformance, not this host boundary. |
| Provider session mechanism is unproved | No live safe experiment selects a non-exportable or short-lived primary-provider session. | Apply ED-001 and prove one useful primary-provider task while durable credential probes fail. | UE-003 remains shared with RP-04. |
| Linked worktree can share Git authority | Git worktrees share a common directory and object/ref/config state. | Prohibit linked-worktree-only isolation; initialize or materialize a truly independent repository/object database. | RF-023 primary. |
| Candidate artifact transfer is not a bounded contract | Current candidate work happens directly in the target repository. | Export the exact candidate commit through a content-addressed, non-executing boundary that preserves work without mutating canonical Git. | RP-05 consumes candidate objects later; RP-02 owns export mechanics only. |
| Launcher ownership overlaps are implicit | RP-01 must route all launches through one guard API, while RP-11 later normalizes generic adapters. | Limit RP-02 edits to isolation-owned module/symbols and documented integration seams. | RP-01 and RP-11 remain exclusive owners of their contracts. |

## Preserved Primitives

- Existing lifecycle request, timeout, cancellation, process-group, and
  terminal-observation behavior.
- Current provider launch binaries behind a stricter host boundary.
- Run Contract, exact guard, Harness, and adapter contracts as consumed inputs,
  never authority invented by RP-02.
- Protected PR as the safe candidate-preservation route while privileged
  publication remains disabled.

