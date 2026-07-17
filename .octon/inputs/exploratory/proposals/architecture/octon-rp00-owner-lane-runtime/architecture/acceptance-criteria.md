# Acceptance Criteria

- **AC-01:** Pre-issuance authorization is sealable without issuance,
  admission, manifest, attestation, completed-prefix, or provider response
  artifacts and binds the exact plan digest, candidate, principal, credential
  tuple, budgets, evidence root, one-attempt lock, and replacement lock.
- **AC-02:** The runtime accepts only authorization, nonsecret capture metadata,
  operation plan, evidence root, and one inherited credential FD as live-run
  inputs. It generates observation-dependent artifacts in stage order.
- **AC-03:** The complete intended and observed credential tuple covers class,
  issuer, resource owner, sole selected repository, public-read boundary,
  ordered permissions, API version, capture source/time, provider expiry, local
  deadline, probe/revoke budgets, and replacement posture. Missing, widened,
  reordered, expired, or unavailable facts fail closed.
- **AC-04:** Token bytes remain absent from argv, environment, URL, disk, logs,
  evidence, child process state, `gh`, SSH, and ambient helpers. Only inherited
  FD intake, stdin curl configuration, and one-use FIFO askpass are eligible.
- **AC-05:** Issuance outcome and lifecycle envelope are durably written before
  the first authenticated request and bind the exact token-derived handle,
  header, and revocation-body digests.
- **AC-06:** Admission receipt is generated only after journaled identity,
  repository, and declared capability reads pass. It records direct live facts
  separately from trusted issuance-capture facts. No repository mutation occurs
  before admission, manifest, and attestation pass.
- **AC-07:** The final manifest binds authorization, capture, issuance,
  lifecycle, admission, plan, candidate, tools, and operation templates without
  self-reference or realized attestation digest. Its digest realizes the
  attestation before the first cutover mutation.
- **AC-08:** Every provider request has a durable pre-send event and response
  digest. Missing terminal response becomes outcome-unknown and permanently
  denies resend of that request digest.
- **AC-09:** PR creation is followed by one authoritative reconciliation read.
  Exactly one PR must match create response, repository, base, head, tree, and
  branch before the completed-prefix receipt records canonical PR identity.
- **AC-10:** Post-PR operations resolve only the four declared typed bindings.
  Normalization reproduces the sealed template digest and a construction
  receipt is durable before send. Prediction, arbitrary interpolation,
  substitution, unresolved binding, or upstream mutation fails closed.
- **AC-11:** The same token is revoked at most once through the unauthenticated
  endpoint; genuine provider `401`, prior authenticated `200`, local
  zeroization, FIFO removal, empty census, and retirement receipt are all
  required. Failure blocks replacement, SI-00, closeout, and DAG continuation.
- **AC-12:** Existing fixed-origin allowlisting, canonical tool binding,
  single-use provider-mutation effect, no-resend semantics, lifecycle approval
  scoping, and narrow support tuple remain enforced.
- **AC-13:** Hermetic tests cover temporal-order forgery, incomplete credential
  tuple, capture/lifetime mismatch, crash/resume boundaries, PR zero/multiple/
  substitution, typed-template mutation, every send boundary, secret leakage,
  terminalization, and replay.
- **AC-14:** All proposal, architecture, schema, registry, Rust, shell,
  inventory, authorization, support, conformance, drift, rollback, and diff
  gates pass with current direct evidence and no provider effect.
