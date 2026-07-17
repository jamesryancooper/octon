# Owner-Lane Execution v1

## Status and scope

This contract defines the only executable Octon boundary for the exact
`rp00-owner-lane-cutover` operation against `jamesryancooper/octon`. It is an
authority consumer, never an authority source. It does not admit a general
GitHub API client, another repository, a connector, a new support tuple, or
recurring provider automation.

The kernel action is `rp00_owner_lane_cutover`. Every material provider or Git
mutation consumes one single-use
`AuthorizedEffect<ProviderRepositoryMutation>` whose scope binds the accepted
review digest, run, authorization id, base commit, candidate commit/tree,
manifest digest, operation digest, principal, and fixed repository.

## Acyclic artifact graph

Artifacts are strict JSON with unknown members denied. Their digest graph is
acyclic and independently constructible:

1. attestation binds repository, candidate, principal, and accepted review;
2. manifest binds the attestation and the closed ordered operations;
3. admission authorization binds the manifest and operation digest;
4. issuance outcome binds the authorization and opaque secret digests;
5. lifecycle envelope binds authorization, issuance, manifest, and attestation;
6. admission receipt binds the lifecycle;
7. construction and completed-prefix receipts bind the preceding immutable
   graph and the append-only journal;
8. retirement receipt binds the lifecycle and terminal observations.

Canonical artifact and request digests use the RFC 8785 object-member ordering
and JSON scalar representation supported by the interoperable JSON domain.
Duplicate keys, floating-point values, integers outside ±(2^53−1), digest
cycles, and self-references are denied.

## Closed execution protocol

Before credential capture the runtime validates every artifact, digest edge,
principal/repository/candidate binding, operation sequence, fixed URL/method,
probe and revoke budget, and the canonical path plus SHA-256 digest of `curl`,
`git`, `mkfifo`, and the fixed owner-lane askpass helper. Each tool is rehashed
immediately before launch.

The credential is one fine-grained PAT read once from an inherited descriptor
of 3 or greater. The descriptor is closed immediately. Ambient GitHub, Git,
SSH, credential-helper, and `PATH` authority is not inherited by children. The
secret is never permitted in argv, environment, URL, a durable configuration
file, journal, log, receipt, or evidence artifact.

Authenticated HTTP uses the canonical `curl` binary with a configuration sent
through stdin. Git HTTPS push uses the canonical `git` binary, an empty
credential helper, `GIT_TERMINAL_PROMPT=0`, and a one-use FIFO read by the
fixed askpass helper. `gh` and SSH are outside the protocol.

Every request is append-and-fsync journaled before send. Its response status
and response digest are appended and fsynced afterward. A pre-send event with
no response is `outcome-unknown` and permanently denies resend of that request
digest. Mutations require a prior observation digest. The first two operations
are identity and repository probes; the last two are credential revocation and
the terminal same-token identity probe.

## Credential retirement

Revocation is exactly one unauthenticated `POST` to
`https://api.github.com/credentials/revoke` carrying the same credential. A
`202` is acceptance only. After the envelope wait interval, the runtime uses
the finite remaining `/user` probe budget and requires a genuine same-token
`401`. Retirement additionally requires prior authenticated `200` evidence,
local buffer destruction, FIFO removal, an empty scoped secret census, and a
strict retirement receipt.

## Failure and recovery

Manifest, binding, tool, token, admission, or secret failures deny before the
first provider mutation. An unknown send outcome is never retried. Provider
authority is represented by the exact `provider-authority-required` program
blocker and an approval grant bound to child, route, run, candidate, and
operation digest. Generic missing evidence is not converted.

This implementation is inert until retained hermetic positive, denial,
replay, interruption, and leak-census evidence expands the existing
`github-repo-consequential-en` support tuple by exactly the
`rp00-owner-lane-cutover` operation. Live credential issuance and provider
execution always require a separate current authorization.
