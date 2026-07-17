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
operation-plan digest, principal, and fixed repository. The independently
sealed plan is the complete pre-effect operation commitment; no future
observation digest appears in the authority scope.

## Acyclic artifact graph

Artifacts are strict JSON with unknown members denied. Their digest graph is
temporally acyclic and independently constructible:

1. the operation plan seals tools, candidate, exact requests, typed templates,
   and the attestation template without a credential or provider observation;
2. admission authorization binds that plan digest and the complete intended
   credential tuple;
3. nonsecret capture metadata binds authorization, plan, trusted issuance
   provenance, the one-day provider expiry, and the 60-minute local deadline;
4. the runtime-generated issuance outcome and lifecycle envelope bind the
   captured credential through opaque domain-separated digests before network;
5. journaled identity and repository reads generate the admission receipt;
6. the manifest binds plan plus authorization/capture/issuance/lifecycle/
   admission digests, but neither its own digest nor a realized attestation;
7. the manifest digest realizes the attestation, then the mutation prefix and
   one authoritative PR reconcile read generate the completed-prefix receipt;
8. typed suffix construction binds manifest, attestation, completed prefix,
   and canonical PR number before send; retirement binds terminal observations.

Canonical artifact and request digests use the RFC 8785 object-member ordering
and JSON scalar representation supported by the interoperable JSON domain.
Duplicate keys, floating-point values, integers outside ±(2^53−1), digest
cycles, and self-references are denied.

## Closed execution protocol

Before credential capture the runtime accepts only authorization, nonsecret
capture metadata, operation plan, evidence root, and one inherited descriptor.
It validates every available digest edge, the complete owner/repository/
permission/lifetime tuple, operation sequence and stage, exact URL/method or
typed template, finite budgets and locks, and the canonical path plus SHA-256
digest of `curl`, `git`, `mkfifo`, and the fixed owner-lane askpass helper. Each
tool is rehashed immediately before launch.

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
and response digest are appended and fsynced afterward. Before that terminal
journal event, the runtime durably writes strict response evidence containing
the exact realized operation, safe response bytes and headers, status, digest,
and observation time. A pre-send event with no response is `outcome-unknown`
and permanently denies resend of that request digest. A completed journal event
may be resumed only by loading matching durable response evidence; it is never
sent again. The first two operations are identity and repository admission reads.
The prefix then safes workflows, pushes the exact candidate, creates a PR, and
performs exactly one authoritative reconcile read. Zero, multiple, substituted,
or create/reconcile-mismatched PR identities deny the suffix.

The completed-prefix receipt records the canonical provider-assigned PR number
and exact create/reconcile request/response digests. Suffix operations resolve
only `manifest_digest`, `attestation_digest`, `completed_prefix_digest`, and
`canonical_pr_number` typed nodes. The runtime re-normalizes each resolved
request to its sealed template digest and durably writes a construction receipt
before send. Arbitrary interpolation, prediction, recursive bindings, and
binding in any executable path other than the declared numeric PR segment are
denied. The last two operations remain credential revocation and the terminal
same-token identity probe.

## Credential retirement

Revocation is exactly one unauthenticated `POST` to
`https://api.github.com/credentials/revoke` carrying the same credential. A
`202` is acceptance only. After the envelope wait interval, the runtime uses
the finite remaining `/user` probe budget and requires a genuine same-token
`401`. Retirement additionally requires prior authenticated `200` evidence,
local buffer destruction, FIFO removal, an empty scoped secret census, and a
strict retirement receipt.

## Failure and recovery

Plan, authorization, capture, binding, tool, token, admission, or secret
failures deny before the first repository mutation. Admission or later failure
enters terminalization-only execution. Matching create-only artifacts may be
reused only as exact bytes; conflicting bytes deny. Matching completed requests
resume from their exact durable response evidence, while an unknown send
outcome is never retried. An expired local deadline denies new admission,
prefix, or suffix sends but still permits the fixed revocation and terminal
probe sequence. Provider authority is represented by the exact
`provider-authority-required` program blocker and an approval grant bound to
child, route, run, candidate, and operation-plan digest. Generic missing
evidence is not converted.

This implementation is inert until retained hermetic positive, denial,
replay, interruption, and leak-census evidence expands the existing
`github-repo-consequential-en` support tuple by exactly the
`rp00-owner-lane-cutover` operation. Live credential issuance and provider
execution always require a separate current authorization.
