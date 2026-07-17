# Target Architecture

## Decision

Add one first-class `owner-lane execute` operation beneath the existing
`protected-ci` kernel surface. The operation is an authority consumer, not an
authority source. It requires a run-bound grant plus a single-use
`AuthorizedEffect<ProviderRepositoryMutation>` whose scope binds the accepted
review, run, repository, base SHA, candidate SHA/tree, manifest digest,
principal, credential tuple, and evidence root.

## Boundary flow

1. Validate strict lifecycle JSON artifacts and canonical digests before secret
   capture.
2. Verify the authority grant and consume the provider-mutation effect token.
3. Read exactly one fine-grained PAT through an inherited file descriptor,
   close the descriptor, bind a nonce-salted opaque handle digest, and scrub all
   ambient credential variables from child processes.
4. Run admission-only identity/capability reads against fixed GitHub.com HTTPS
   origins. No mutation is eligible until admission passes.
5. Execute only the manifest's closed, ordered operation enum. Append a
   pre-send record before every request and an observed response record after
   it. A missing terminal response becomes `outcome-unknown`; the request is
   never resent. Canonical artifact and request digests use RFC 8785 JSON
   Canonicalization; the accepted value domain excludes floating-point numbers
   and duplicate object keys.
6. Supply the PAT to `curl` only through stdin configuration and to Git only
   through a one-use named pipe consumed by a fixed askpass helper. Token bytes
   never enter argv, environment, durable files, evidence, or `gh`.
7. After the authoritative post-read, submit the same token once to the
   unauthenticated credential-revocation endpoint, poll `/user` without resend
   of revocation, require `401`, zero local buffers, remove the FIFO, run the
   scoped secret census, and write terminalization and retirement receipts.

All external executable paths (`curl`, `git`, `mkfifo`, and the fixed askpass
helper) are resolved before credential capture, constrained to the manifest's
canonical paths and SHA-256 digests, and reverified immediately before launch.
`PATH` and credential-bearing environment variables are not trusted inputs.

## Bootstrap and support posture

The current GitHub repo-consequential tuple is a valid authority route only for
its documented protected-CI merge claim. This packet may expand that same tuple
to one additional operation id, `rp00-owner-lane-cutover`, only after the built
runtime completes a retained end-to-end run against the hermetic GitHub/Git
fixture plus every negative and recovery case. The admission, dossier, and
proof bundle must bind that exact evidence and continue to exclude a general
API client, connector operation, arbitrary repository, or recurring provider
automation. The implementation remains inert until this evidence-backed source
update is complete and a separate exact provider authorization is materialized
through the existing authority engine.

## Lifecycle correction

When a program child reports that all local implementation evidence is present
but a separately authorized provider cutover is required, the controller emits
an exact `approval-required` blocker rather than the generic
`missing-evidence` class. `lifecycle program approve` may consume only that
current blocker and binds its grant to child id, route id, run id, candidate,
and provider-operation digest. Ordinary missing evidence remains unchanged.
