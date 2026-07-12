# Reconciled Migration Architecture

## Design rule

Adopt the least complex design that satisfies accepted trust properties: one installed candidate-immutable authority, one authoritative local store, one supervised local broker, one independent verifier identity, provider-native components behind Octon contracts, and no fallback that restores candidate credentials, dual authority, or dual writers.

## Current-to-target sequence

```text
clean normalized baseline
→ remove candidate-controlled provider writes and autonomous direct-main
→ make canonical authority and its decision inputs candidate-immutable
→ consume exact one-shot guards on every supported agent/child launch
→ run useful candidates credentialless in native macOS isolation and independent Git state
→ migrate all runtime authority state into one SQLite/WAL transaction model
→ introduce one supervised local broker with authenticated IPC and credential custody
→ place a closed sanitized Git adapter inside the broker
→ produce candidate-immutable exact-SHA verdicts with a separate identity
→ route eligible Class B through expected-old fast-forward publication; escalate deterministically to PR
→ sign direct observations/checkpoints and enforce capacity, retention, pins, and compaction
→ reconcile unknown outcomes before retry and converge without duplicate authorized attempts
→ prove a complete Class A/B vertical with narrow degraded operation
→ land self-changes inert and prove previous-version trust-root activation/rollback
→ add minimal Workspace Projects and the full digest-bound Harness Factory
→ add private signed extensions and bounded credentialless child agents
→ prove setup, recovery, two-project continuity, burden budgets, and fresh support claims
→ complete authoritative promotion prerequisites
```

This preserves the intake's safety and promotion spine with two explicit dependency refinements. First, the signed-evidence identity/capacity foundation closes before integrated recovery proof because outcome attribution and terminal recovery records must already be authentic and physically writable; no autonomous Class B route is enabled at that point. Second, the non-authoritative Projects/Harness branch may begin after canonical authority and isolation, in parallel with the broker/trust spine, because it cannot authorize, publish, activate trust, or promote a claim. That shortens calendar time without weakening the linear proof gates. Operational setup/doctor/repair also ships with the components it diagnoses.

## Components

### Preserved

- `authority_engine` typed grants/effects, expiry/revocation vocabulary, and `ExecutorLaunch` types.
- Run Contract, context packing, support targets, route resolution, task-harness schemas, and exact-ref validation concepts.
- Provider adapter contracts and ruleset non-bypass/non-fast-forward/strict-check protections.
- Hash-linked journals, evidence classifications, extension publication/quarantine, project profiles, child scheduling/budgets, and promotion blocker readers.

### Modified

- Authorization becomes an installed/base-certified decision function; project policy can narrow but never widen the trusted floor.
- Every agent/child launch converges on one structural guard-owning launch API.
- Candidate execution moves to a disposable independent repository/object database, fresh environment, native sandbox, and bounded provider session.
- Runtime files become migrations, projections, exports, or bounded payload pointers from one SQLite source.
- No-PR validation becomes a broker-owned expected-old, fast-forward-only effect with durable attempt state.
- External effects use a local `T1` reserve/consume/`ATTEMPTING` commit, the provider call outside SQLite, and a `T2` result-or-`UNKNOWN` commit; unknown attempts reconcile before retry and may terminate honestly as `manual_intervention`.
- Required checks become authenticated verifier verdicts rather than context-name trust.
- Promotion scaffolding becomes enforced inert installation and a separate exact-version activation state machine.

### Added

- One supervised local broker process with authenticated IPC, credential custody, sole SQLite writer, effect adapters, enrollment, status, doctor, repair, and automatic restart/reconciliation.
- One candidate-immutable verifier identity, preferably provider-native when conformant.
- Minimal Workspace Project identity and a full per-run deterministic Harness Factory compiler.
- One generic executor-adapter interface and strict conformance suite consumed by the Harness Factory; verifier/publication and child-agent specializations remain with their owning packets.
- Private signed extension import and bounded mission-child enforcement.

### Demoted or retired

- Lifecycle-local `DelegationProof` as execution authority.
- Raw model-launch sites outside the guard-owning API.
- Autonomous direct-main and ambient credentialed Git.
- Candidate-head effect/verifier workflows and ambiguous required-check identity.
- Loose files as runtime authority after store cutover.
- Repository-tracked raw/detailed run payloads by default.
- Unsupported distributed federation, enterprise administration, broad certification, and persistent-agent surfaces from the supported solo path.

## Prohibited compatibility bridges

- Log-only guards on a privileged route.
- YAML/file read-through as authority after the first transactional effect.
- Ambient/unsanitized Git or candidate-held provider credentials.
- Candidate-head verifier or effect code.
- Dual authority, dual runtime writer, second broker, or second control plane.
- Unsigned evidence fallback while retaining autonomous-success claims.
- Linked-worktree-only isolation.
- Generic force/lease behavior that permits a non-fast-forward update.
- PR escalation that launders forged, stale, revoked, wrong-SHA, or wrong-scope authority; those cases deny and require fresh authorization.

## Safe rollback rule

Before a packet performs its first trust-sensitive effect, rollback may restore immutable pre-cutover state. After cutover, rollback must restore the last independently certified implementation behind the same boundary, disable the affected route, preserve candidate work for manual/protected PR, or repair the single transactional state forward and reconcile. It must never restore the retired hazard.

## Dependency rationale

Authority/guard semantics freeze before store persistence migration so two packets never mutate the same trusted guard source concurrently. Isolation may proceed in parallel with authority; broker integration waits for authority, isolation, and store. Sanitized Git waits for broker custody. Verification/publication owns immutable classification policy and waits for Git plus authority/store. Evidence and recovery wait for stable attempt/verdict identities; recovery integrates rather than redefines store transitions and classification. Trust activation waits for the complete Class B vertical. Projects and the cross-project mission inbox wait only for canonical authority and may proceed alongside the trust path; Harness Factory waits for authority, Projects, and isolation. Extensions wait for signed evidence and Harness Factory; children additionally wait for the shared recovery path. Core and optional support claims promote only after their own proof, while full program closeout waits for every packet.
