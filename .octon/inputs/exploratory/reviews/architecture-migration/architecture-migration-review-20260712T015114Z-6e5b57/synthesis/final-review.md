# Final Independent Architecture Migration Review

Repository commit: c5b1f5760c78ff521cca6b054e4e8fef5300505b

## What is true about current Octon

Octon is a mature contract-rich system with a partially implemented trustworthy
execution architecture. authority_engine is not decorative: it has typed,
sealed effects and broad validation of grants, scope, route, support, expiry,
revocation, approval, rollback, budget, egress, and lifecycle. Its 75 library
tests passed. Runtime-bus transition/hash validation, lifecycle tests, hosted
no-PR receipt checks, context packs, extension publication, and main ruleset
guardrails also provide real value.

Those strengths do not dominate all material effects. Lifecycle authorization
self-produces proof from request metadata and directly dispatches Codex,
Claude, and workflows. Pipeline/workflow launches and studio spawn are not
structurally guarded. Candidates use the canonical checkout with inherited
host user/environment context. Publication scripts call ambient Git, and the
active GitHub auto-merge lane executes candidate code after obtaining a
write-capable token. Required exact-SHA checks are produced by candidate-owned
workflow code.

Runtime state is persisted through separate unlocked files. Sequential tests
pass, but the consume and journal sequences permit concurrent double
observation, partial crash persistence, and unresolved external outcomes.
Hash-linked evidence detects tested corruption but is not signed against a
writer or old-snapshot rollback. Some proof aggregation/materialization is
stronger than its executed evidence.

## Inherited findings

### Remain valid

- lifecycle is a competing launch authority;
- credentialless native isolation and isolated Git are absent;
- no separate durable-effect broker or SQLite/WAL authority store exists;
- direct-main and ambient Git conflict with accepted publication direction;
- provider verification/effects are candidate-controlled;
- evidence authenticity, capacity reservation, bounded retention, and
  reconciliation are incomplete;
- safe trust-root activation is not implemented;
- Workspace Projects, deterministic Harness Factory, signed private catalog,
  and operator-grade golden path require migration.

### Corrected or sharpened

- The authority engine and typed effects are stronger and more reusable than a
  greenfield framing suggests; migration should preserve them.
- ExecutorLaunch exists, but current use gates setup rather than structural
  process creation.
- No-PR tooling has useful exact source/target/check/post-land invariants, but
  its authorization is self-minted and effect is ambient.
- The live provider ruleset has valuable no-bypass and fast-forward controls,
  but required check implementation is not independent.
- Self-evolution promotion is currently inert; present safety is non-activation,
  not a proven activation state machine.
- Support dossiers disclose some external gaps; the issue is proof-depth and
  promotion wording, not hidden limitations.
- New review evidence identified reverse-prefix scope widening and a validator
  that reports referenced tests as executed without invoking them.

### Superseded positions that stay rejected

VMs, enterprise IAM/RBAC/SSO, distributed consensus, multi-writer ledgers,
universal PR ceremony, public marketplace infrastructure, persistent agent
organizations, autonomous direct-main, and a second broker/control plane are
not revived. The migration consolidates the intake's larger workgroup set into
14 bounded packets without changing the accepted decisions.

## Decision alignment

None of the 24 accepted directions is fully proven end to end. Existing
partial foundations are strongest for canonical authorization semantics,
typed guards, proportional route vocabulary, degraded/fail-closed concepts,
self-development governance, project/profile inputs, harness/context
primitives, extension publication, mission lifecycle, and provider delegation.

The clearest contradictions are FD-003, FD-006 through FD-011, and current
direct-main behavior. FD-005, FD-013, and FD-018 are absent. FD-024 requires
fresh dogfood proof. The complete per-decision assessment is in
phase-1/final-decision-to-repository-crosswalk.yml.

## Smallest safe migration

### Control and data plane

Keep authority_engine as sole semantic issuer. Add exact operation and launch
reservations in one SQLite/WAL store. Use one local broker as the only
credentialed durable-effect performer. Broker and verifier are different
identities. GitHub may later execute an exact preauthorized request, but never
own authority, policy, state, or reconciliation.

### Candidate plane

Every model/workflow/child launch consumes a one-shot exact guard immediately
before spawn. Candidates run in a disposable native macOS boundary with fresh
HOME/config/environment, explicit network/process/filesystem policy, and an
independent Git database. They have no durable credentials.

### Publication plane

Move the current exact-ref checks into a broker-owned sanitized Git adapter.
Bind source SHA, target pre-SHA, route, validation, expiry, revocation,
rollback, and evidence reservation. Perform fast-forward compare-and-swap.
Accept a signed verdict only from immutable verifier code. Default admitted
Class B to no-PR; automatically select PR for provider policy, review, preview,
uncertainty, higher consequence, or trust root. Never select autonomous
direct-main.

### Evidence and recovery

Commit attempt/evidence outbox state transactionally. Broker and verifier sign
their direct observations. Reconcile unknown outcomes before retry. Project
human-readable journals from the store and retain hash validation. Compact raw
evidence only after signed checkpoints and pin decisions. Reserve terminal
evidence capacity with the operation.

### Product plane

Add minimal Workspace Project identity, reuse Project Profile as descriptive
input, compile one digest-bound harness manifest, extend current extension
publication with signed private import/pinning/revocation/rollback, and make
setup/project/run/status/inbox/doctor/repair the default operator path.

## What must be removed before privileged implementation

- active candidate-controlled provider-write execution;
- autonomous direct-main/provider-write lanes;
- reverse-prefix scope widening;
- support claims asserting complete mediation/executed proof;
- any design that permits legacy lifecycle metadata to authorize;
- any privileged Git plan that retains ambient configuration/credentials.

This is GATE-0 and WG-00/WG-01. It precedes broker or publication implementation.

## Proof before autonomous Class B publication

The minimum proof must dynamically demonstrate:

- credentialless isolated candidate with independent Git;
- exact one-shot launch and effect consumption under concurrency;
- one transactional store and evidence reservation;
- broker-only keychain credential custody;
- sanitized Git against every executable extension class;
- exact target compare-and-swap and source binding;
- immutable signed verifier identity and duplicate-context denial;
- race, replay, expiry, revocation, crash, timeout, delayed provider,
  unknown-outcome, low-space, and recovery behavior;
- signed direct-observer terminal evidence;
- zero routine prompts and preserved work on failure.

## Proof before autonomous trust-root activation

Class B publication proof is a prerequisite. Then prove a minimal trust-root
inventory, immutable inert version, previous-version exact verification,
preauthorized staged health window, atomic active pointer, immutable rollback
version, automatic rollback, signed receipts, and denial of every candidate
attempt to alter verifier, activation, rollback, signer, inventory, or
authority-expansion rules.

## Complexity to remove or defer

Federation, trust-domain administration, delegated leases, broad certification,
continuous stewardship, and broad connector UX are not part of the supported
solo golden path. Mature internals may remain hidden/feature-gated where cheap;
unsupported breadth must not drive setup, claims, or routine maintenance.

The optional GitHub effect worker, broad external effects, Linux production
support, and advanced Studio behavior are later/optional. They are excluded
from the proof of architecture.

## Operator decisions

Provider credential form, signing-key custody, trust-root inventory, remote
worker timing, evidence window/quota, and advanced CLI disposition remain.
Recommended defaults are recorded in synthesis/remaining-operator-decisions.yml.
None requires a decision before the proposal program is created.

## Proposal program

Create the non-authoritative 14-packet program described in
phase-2/proposal-program-packet-map.yml:

WG-00 containment; WG-01 authority/guards; WG-02 isolation; WG-03 store;
WG-04 broker/credentials; WG-05 Git; WG-06 verifier/routes; WG-07
recovery/evidence; WG-08 Class B proof; WG-09 trust activation; WG-10 projects;
WG-11 harness; WG-12 extensions/children/UX; WG-13 claims/promotion.

The dependency graph deliberately allows WG-01, WG-02, and WG-03 to proceed in
parallel after containment. It forbids privileged integration until their
proofs converge.

## Readiness verdict

The current architecture has serious repair needs, but they are now bounded,
evidence-backed, and sequenced. Fresh repository and provider evidence is
available; the accepted product direction is coherent; safe bridges and
prohibited intermediate states are explicit; operator decisions can be closed
inside packets. A formal proposal program is the correct vehicle for repair.
Privileged implementation remains blocked by GATE-0.

READY_FOR_PROPOSAL_PROGRAM

