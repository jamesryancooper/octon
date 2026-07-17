# Target Architecture

## Decision

Replace the monolithic all-artifacts-as-input owner lane with one staged
`protected-ci owner-lane execute` state machine. It remains an authority
consumer and one exact RP-00 operation, but creates observation-dependent
artifacts only after their observations exist.

## Immutable stage graph

1. **Preauthorize.** Validate an independently sealable admission
   authorization and operation plan before credential capture. Authorization
   binds accepted review, run, repository, base/candidate/tree, plan digest,
   principal, complete intended credential tuple, one issuance attempt,
   evidence root, probe/revoke budgets, no-resend posture, and replacement lock.
2. **Capture and envelope.** Read exactly one `github_pat_` line from inherited
   FD 3 or greater and close it. Validate separately supplied nonsecret capture
   metadata against authorization. Derive the nonce-salted handle,
   Authorization-header, and canonical revocation-body digests. Durably write
   the issuance outcome and lifecycle envelope before any authenticated request.
3. **Admit.** Execute only the plan's exact identity, repository, and declared
   capability reads. Journal before every request. Compare live login/id,
   repository, API version, and endpoint evidence with sealed intent and trusted
   capture metadata. Durably write the admission receipt only after all reads
   pass. Failure enters terminalization-only execution.
4. **Seal admitted authority.** Construct the operation manifest from the
   operation plan plus authorization, issuance, lifecycle, and admission
   digests. The manifest commits strict exact requests or typed templates and an
   attestation template; it does not contain its own digest or the realized
   attestation digest. Its domain-separated digest realizes the attestation.
5. **Execute prefix and bind PR.** Execute safing, exact HTTPS push, PR create,
   and one authoritative PR reconcile read. The reconcile response must identify
   exactly one PR matching repository/base/head/tree/branch and the create
   response. Seal a completed-prefix receipt containing that canonical PR
   number and prefix request/response digests.
6. **Construct suffix and terminalize.** Resolve only declared typed bindings
   from manifest digest, attestation digest, completed-prefix digest, and
   canonical PR number. Normalize every resolved request to the committed
   template and emit an append-only construction receipt before send. Execute
   marker, ruleset, safe-check, conditional merge, post-read, one revocation,
   wait, and terminal probe. Require genuine same-token `401`, local zeroization,
   FIFO removal, empty secret census, and retirement receipt.

The graph is temporally and digest acyclic:

`plan -> authorization -> capture -> issuance -> lifecycle -> admission reads
-> admission receipt -> manifest -> attestation -> prefix -> completed prefix
-> suffix construction -> retirement`.

## Complete credential tuple

Preauthorization and capture metadata jointly bind:

- fine-grained personal access token, `github_pat_`, GitHub.com issuer;
- resource owner and operator `jamesryancooper` / provider id `800837`;
- sole selected/write-capable repository `jamesryancooper/octon`;
- anonymous-equivalent public-read boundary;
- ordered permissions: Administration, Actions, Variables, Contents, and Pull
  requests `write`; Checks and Commit statuses `read`; Metadata implicit read;
- REST version `2026-03-10`;
- trusted capture source, exactly one issuance attempt, local issued-at time,
  one-calendar-day provider expiry, and issued-at-plus-60-minute local deadline;
- allowed admission probes, one preprobe/revoke/wait/postprobe budget, no-resend
  posture, and replacement/bootstrap lock.

Facts unavailable from GitHub token introspection are explicitly classified as
trusted issuance-capture evidence and never inferred from endpoint success.
Live endpoint reads prove only the facts they directly expose.

## Typed template model

The operation plan represents every request as either exact or a strict
template. Templates use explicit typed binding nodes; arbitrary interpolation,
wildcards, recursive values, unknown bindings, duplicate bindings, and binding
inside executable paths other than the declared numeric PR segment are denied.
The only binding sources are:

- `manifest_digest`;
- `attestation_digest`;
- `completed_prefix_digest`; and
- `canonical_pr_number`.

The runtime resolves nodes structurally, canonicalizes the resolved request,
normalizes the declared nodes back to their typed placeholders, and requires
the original template digest before launch.

## Secret and process boundary

The PAT is never present in argv, environment, URL, durable configuration,
journal, receipt, log, `gh`, SSH, or Git credential helper. Authenticated HTTP
uses canonical curl with configuration on stdin. Git HTTPS uses canonical Git,
an empty helper, `GIT_TERMINAL_PROMPT=0`, and one-use FIFO askpass. Canonical
paths and SHA-256 digests for curl, git, mkfifo, and askpass are verified before
capture and immediately before launch.

## Recovery and authority

Every phase is run-bound and digest-linked under one evidence root. Existing
conflicting or later-phase artifacts deny. A matching prior phase may resume
only with the same authorization, plan, capture metadata, credential handle,
and no-resend journal. A pre-send record without response is outcome-unknown
and permanently blocks resend. The provider-repository mutation effect remains
single-use and exact; admission failure permits only lifecycle-envelope-owned
terminalization.

## Bootstrap and support posture

The existing GitHub repo-consequential tuple may name only
`rp00-owner-lane-cutover` after retained hermetic staged execution and all
negative controls pass. No connector, general API client, arbitrary repository,
new support tuple, daemon, database, credential proxy, or recurring automation
is admitted.
