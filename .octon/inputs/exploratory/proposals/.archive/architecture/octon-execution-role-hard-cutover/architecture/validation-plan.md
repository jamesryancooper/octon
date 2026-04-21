# Validation Plan

## Deterministic checks

- YAML/JSON schema validation for all new manifests and schemas.
- Proposal standard validation.
- Architecture proposal subtype validation.
- Execution-role registry validation.
- Overlay registry/instance manifest alignment.
- Support-target schema validation.
- Root manifest validation.
- Workflow manifest reduction validation.

## Hard-cut checks

- `framework/agency/**` absent.
- No active `agents`, `assistants`, `teams`, or `subagents` registries.
- No `actor_ref` in runtime schemas.
- No `agent-augmented` runtime mode.
- No persona or identity authority.
- No mission-only execution path.
- No unsupported browser/API live claims.

## Runtime proofs

- material action without grant denied;
- grant emits receipt obligations;
- execution receipt links context pack, support target, capability packs, adapter tuple, rollback plan, evidence root;
- runtime event ledger emits lifecycle events;
- replay pointer generated;
- rollback drill executed.

## Browser/API proof expectations

Browser/API support is accepted only with:

- service manifest entry;
- support tuple;
- egress lease;
- action record;
- event ledger;
- redaction metadata;
- replay manifest;
- support dossier;
- scenario/shadow evidence.

## Scenario and shadow tests

- repo-local reversible run;
- repo-consequential run;
- boundary-sensitive denied run;
- specialist delegated work;
- verifier-mediated closeout;
- browser/API staged denial;
- rollback recovery;
- intervention revoke/resume.

## Baseline comparisons

Each claimed agency-runtime improvement must be benchmarked against:

1. raw frontier model with same objective and context;
2. thin tool wrapper;
3. Octon-governed run;
4. Octon-governed run with verifier when applicable.

## Failure-mode tests

- missing context pack;
- missing support target tuple;
- generated-only authority attempt;
- specialist capability widening;
- composition profile attempts to execute;
- browser/API capability without service;
- stale generated context;
- hidden human intervention.
