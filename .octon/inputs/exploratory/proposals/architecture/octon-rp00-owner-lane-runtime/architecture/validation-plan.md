# Validation Plan

## Structural gates

- proposal standard, architecture proposal, implementation-readiness, review
  digest, contract registry, JSON Schema syntax, and `git diff --check`;
- exact promotion-target coverage and no undeclared durable edit.

## Runtime gates

- `cargo fmt --check` and targeted `cargo test` for authorized effects,
  authority engine, kernel owner lane, and lifecycle program;
- material side-effect inventory and authorization-boundary coverage validators;
- support-target proofing, live-claim, admission/dossier parity, and evidence-
  depth validators;
- shell integration test with fake `curl`, `git`, `mkfifo`, clock, and filesystem
  boundaries in a disposable root.

## Required negative controls

- missing/forged/stale/wrong-run/wrong-scope/consumed effect token;
- noncanonical, self-referential, stale, reordered, duplicated, skipped, or
  allowlist-escaping manifest;
- RFC 8785 independent-constructor mismatch, duplicate JSON key, float, or
  integer outside the interoperable exact range;
- external tool path/digest drift, symlink substitution, or `PATH` poisoning;
- ambient `GH_TOKEN`, `GITHUB_TOKEN`, credential helper, SSH, or `gh` use;
- token bytes in argv, environment, durable files, logs, receipts, or child
  process census;
- wrong login/id/repository/API version, incomplete pagination, unexpected
  accepted-permissions header, or failed capability probe;
- provider timeout before send, after send, or after mutation; no resend after
  unknown outcome;
- Git askpass called twice for the password, FIFO reuse, or residual FIFO;
- authenticated revocation, second revocation request, false `401`, missing
  prior `200` in admitted phases, local-destruction failure, or nonempty secret
  census;
- ordinary `missing-evidence` incorrectly converted to approval-required;
- provider approval with wrong child, route, run, candidate, or operation digest.

## Evidence

Retain commands, exact commit/tree, timestamps, exit codes, full-log digests,
redacted fixtures, token-leak census, journal transitions, rollback result, and
direct references. Planned tests are never labeled executed.
