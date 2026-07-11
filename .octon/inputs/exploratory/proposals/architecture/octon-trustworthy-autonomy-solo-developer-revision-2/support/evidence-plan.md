# Evidence Plan

## Current-State Claims

Each material current-state claim must appear in
`resources/evidence-appendix.yml` with repository commit, baseline worktree
state, environment, evidence class, commands, bounded outputs, paths, digests,
limitations, and confidence.

## Implementation Evidence

Accepted implementation must retain:

- authorization and typed-capability issuance/consumption state-machine tests;
- sandbox escape and credential-isolation negative controls;
- broker crash, retry, reconciliation, and idempotency fault injections;
- concurrent token, journal, and run-start tests;
- signer-signed canonical receipt over end-to-end origin-authenticated
  broker/reconciler/ledger fact envelopes, plus external-anchor verification;
- GitHub App exact-head and unforgeable-check negative controls;
- self-development previous-verifier and two-phase activation tests;
- Workspace Project discovery, nesting, dependency, and stale-repair tests;
- harness compilation determinism, freshness, installation, revocation, and
  retirement tests;
- representative workflow latency, interruption, false-denial, correctness,
  regression, scope, and comprehension measurements.

No implementation claim may be upgraded from static or inferred to dynamic or
adversarial without the corresponding retained test result.
