# Validation Plan

## Structural gates

- proposal standard, architecture proposal, strict architecture receipt,
  accepted review, implementation readiness, reviewed digest, contract
  registry, schema syntax, exact target coverage, and `git diff --check`;
- verify no durable edit outside the revised promotion targets and route-owned
  evidence/support receipts.

## Runtime gates

- `cargo fmt --check` and targeted tests for authorized effects, authority
  engine, kernel owner lane, and lifecycle program;
- material side-effect inventory and authorization-boundary coverage;
- support proof, live claim, admission/dossier parity, and evidence depth;
- hermetic process test with fake curl, git, mkfifo, clock, filesystem, and
  provider-assigned PR identity.

## Stage and artifact negatives

- preauthorization containing manifest/admission/attestation backreferences;
- missing, forged, stale, wrong-run, wrong-candidate, wrong-plan, conflicting,
  or preexisting later-phase artifact;
- capture metadata with wrong owner, repository selection, permission order,
  issuance count/source/time, provider expiry, local deadline, or API version;
- lifecycle or admission artifact written before its direct inputs;
- crash after capture, envelope, either admission probe, manifest, PR create,
  PR reconcile, prefix receipt, template construction, merge, or revocation;
- resume with a different credential, nonce, capture metadata, plan, evidence
  root, request budget, or replacement-lock state.

## Operation and construction negatives

- noncanonical, self-referential, reordered, duplicated, skipped, or
  allowlist-escaping plan/manifest;
- duplicate JSON key, float, integer outside interoperable range, unknown typed
  binding, wildcard, recursive binding, or arbitrary interpolation;
- zero/multiple/mismatched PR reconciliation, create/reconcile disagreement,
  predicted PR number, or unknown PR-create outcome resend;
- normalized template mismatch, completed-prefix substitution, final-body
  feedback into an upstream digest, or request launched before construction
  receipt durability;
- tool path/digest drift, symlink substitution, or PATH poisoning.

## Secret, replay, and retirement negatives

- ambient GH/GitHub tokens, helpers, SSH, `gh`, or token bytes in argv,
  environment, URL, files, logs, receipts, evidence, or child census;
- provider timeout before send, after send, or after mutation; request replay
  after unknown outcome;
- double askpass, FIFO reuse/residue, authenticated or duplicate revocation,
  false terminal `401`, missing prior `200`, local destruction failure, or
  nonempty census;
- wrong lifecycle approval child, route, run, candidate, or operation-plan
  digest and ordinary missing-evidence misclassification.

## Evidence

Retain exact commands, commit/tree, stage transitions, canonical artifact and
request digests, timestamps, exit codes, redacted fixtures, journal lineage,
secret census, rollback result, and direct references. Planned or historical
tests are never labeled current execution.
