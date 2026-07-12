# Subagent Report — Authority, Runtime, Trust

Agent: /root/authority_runtime_trust

Assignments: A, D, F. No mutation or provider observation. Sibling review tree
was not listed, searched, read, or cited.

## Accepted findings

- ADF-A-001: lifecycle, pipeline, and workflow launches bypass canonical
  ExecutorLaunch.
- ADF-A-002: scope_matches accepts reverse/non-boundary prefix widening.
- ADF-A-003: sequential single-use tokens are not unique exact operation
  reservations and default grants lack mandatory bounded expiry.
- ADF-D-001: accepted SQLite/WAL store and evidence outbox are absent.
- ADF-D-002: token consume and journal append are concurrency/crash unsafe.
- ADF-F-001: self-evolution governance is declared but candidate-immutable
  verifier ownership is not enforced.
- ADF-F-002: exact staged activation and executable automatic rollback are
  absent.

## Accepted strengths

Typed effect separation, restricted minting, broad effect verification,
hash-linked journal validation, fresh-authority replay posture, and currently
inert material promotion.

## Primary inspected paths

authorized_effects; authority_engine api/effects/execution/policy/tests;
kernel lifecycle/pipeline/workflow/evolution; lifecycle_executor request,
authorization, adapter, Codex/workflow leaf; runtime_bus; replay_store;
material inventory, boundary coverage, journal/evidence/promotion specs; and
evolution control/evidence/validators.

## Rejected or narrowed

No finding was rejected. The primary reviewer narrowed absence claims to the
bounded inspected scopes and did not adopt any dynamic safety claim because
the subagent ran no implementation tests.

## Disagreements

None. The primary reviewer additionally executed current Rust suites and
retained their sequential strengths without treating them as crash/concurrency
proof.

