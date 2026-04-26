# Runtime Enforcement Map

## Material path families

Each material path must have an effect class, verifier, consumer, receipt, and
negative bypass proof.

| Path family | Effect class | Required consumer posture |
| --- | --- | --- |
| Repository mutation | `RepoMutation` | Require `VerifiedEffect<RepoMutation>` |
| Generated/effective publication | `GeneratedEffectivePublication` | Require `VerifiedEffect<GeneratedEffectivePublication>` |
| State/control mutation | `StateControlMutation` | Require `VerifiedEffect<StateControlMutation>` |
| State/evidence mutation | `EvidenceMutation` | Require `VerifiedEffect<EvidenceMutation>` or validator-specific evidence authority |
| Executor launch | `ExecutorLaunch` | Require `VerifiedEffect<ExecutorLaunch>` |
| Service invocation | `ServiceInvocation` | Require `VerifiedEffect<ServiceInvocation>` |
| Protected CI check | `ProtectedCiCheck` | Require `VerifiedEffect<ProtectedCiCheck>` |
| Extension activation | `ExtensionActivation` | Require `VerifiedEffect<ExtensionActivation>` |
| Capability-pack activation | `CapabilityPackActivation` | Require `VerifiedEffect<CapabilityPackActivation>` |

## Verification checks

Before a token becomes a verified effect, the verifier must check:

- token record exists
- token digest matches
- decision and grant references exist
- run root and lifecycle state match
- route id matches
- support-target tuple matches
- capability-pack scope allows the requested effect
- effect class matches the consumer
- token is not expired
- token is not revoked
- token is not already consumed when single-use
- approvals/exceptions are present when required
- rollback posture is sufficient
- budget and egress constraints allow the action
- support-envelope reconciler permits the route/support posture

## Receipt requirements

Every successful consumption writes:

- token consumption receipt
- run journal event
- evidence pointer
- material effect class
- consumer path
- verifier version
- source token digest
- denial/approval trace where applicable

Every denied consumption writes a denial record unless the denial occurs before a
run/evidence root exists; in that case the caller must return a deterministic
denial code.
