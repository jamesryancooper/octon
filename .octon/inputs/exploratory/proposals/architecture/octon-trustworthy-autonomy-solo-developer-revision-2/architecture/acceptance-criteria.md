# Architecture Acceptance Criteria

## Acceptance Rule

Revision 2 is architecture-decision-ready when every criterion in the
decision, contract, evidence, and usability groups below is either:

1. demonstrated by retained evidence; or
2. assigned as an implementation acceptance test with an unambiguous expected
   result and owner.

Passing this document does not authorize implementation. Proposal acceptance,
the strict Pre-Integration Architecture Review, a route-selected Change, and
the applicable implementation receipts remain separate gates.

## Decision Completeness

| ID | Criterion | Evidence at proposal review |
|---|---|---|
| AC-D01 | Each of AD-01 through AD-12 can be accepted, rejected, or revised independently without changing the meaning of another decision. | Decision record and dependency map. |
| AC-D02 | The architecture uses one authorization vocabulary: decision, grant, typed capability, verification/reservation/consumption, effect, observed receipt. | Authority-flow review; no Run Contract or harness authority-minting language. |
| AC-D03 | Candidate, durable-reversible, and irreversible/trust-root effects have explicit default postures and boundary examples. | Effect-class and inventory review. |
| AC-D04 | Safety and throughput effects are recorded for every decision, including implementation cost, migration impact, residual risk, and an acceptance test. | Decision-table inspection. |
| AC-D05 | Current repository facts, deployment-local facts, observed behavior, provider configuration, and architectural inference are not conflated. | Evidence appendix classification audit. |

## Canonical Authorization and Launch

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-A01 | `authorize_execution` is the sole source of grants for material execution. | Search and call-graph tests find no downstream grant or allow decision created by lifecycle, sandbox, broker, workflow, or harness code. |
| AC-A02 | A Run Contract, Project Profile, Workspace Project, effective harness, delegation proof, mode string, evidence-gate result, or request field can constrain or inform a request but cannot mint or widen authority. | Mutation tests alter each input after decision; issuance or verification fails closed. |
| AC-A03 | Lifecycle dispatch requires a canonical, typed, target-bound, single-use `ExecutorLaunch` capability. | Launch without a capability, with the wrong run/child/adapter/worktree/harness/sandbox digest, after expiry, after revocation, or after prior consumption is denied before process creation. |
| AC-A04 | `lifecycle_executor::authorize_before_dispatch` no longer represents an authorization plane. | The function is removed or renamed to a non-authorizing precondition validator; its output is not accepted as a grant or launch capability. |
| AC-A05 | Delegation invokes canonical authorization to create a fresh child-scoped `GrantBundle`; issuer signs requests only against it and ledger registers/exposes child-bound references. | Passing a parent grant/capability to a child is denied; broader path, tool, budget, network, duration, project, or effect class is denied; parent revocation cascades and child revocation remains independent. |
| AC-A06 | Reservation is exclusive but releasable only when no consume intent exists; consume-intent commit is irreversible. Invocation requires evidence-store CAS plus the sole ledger `AttemptLinkAck`; consumed-before-attempt recovery additionally requires an exclusive recovery lease. | Concurrent predecessor/successor consumers and 64 recovery/malicious-store duplicate-receipt claimants produce one spend, one recovery lease, one liveness-valid `AttemptLinkAck`, one invocation guard/call; crash never reconstructs the dead guard; every loser is denied and a spent capability is never reused. |
| AC-A07 | A broker cannot mint a grant, and the authority engine cannot directly perform a brokered effect. | Credential and interface tests demonstrate the separation in both directions. |
| AC-A08 | Every denial reports reason code, policy and version, missing or stale evidence, affected transition, and shortest safe recovery route. | Golden denial-contract tests cover policy denial, stale digest, revocation, outage, conflict, and incomplete evidence. |
| AC-A09 | Capability issuance is not externally usable until authenticated ledger `register_issue` atomically activates exactly one lineage/generation and supersedes any eligible predecessor. | Crash before/after signing, registration, predecessor supersession, and reference return exposes either no capability or one registered capability; synchronized concurrent issuers never create two active/reservable versions. |
| AC-A10 | Every normal/recovered begin-attempt uses an independently origin-authenticated, short-lived `AttemptLivenessBundle` covering governing-input/policy/approval/revocation/clock, credential-handle availability/scope, and exact target/SHA/version. Evidence store and capability ledger independently verify it; the broker cannot self-attest. | Mutate/omit/replay each source signature, identity, nonce, epoch, timestamp/skew, operation/outbox/broker binding, credential scope, target observer/version/SHA, assembler/receipt/bundle digest, and expiry; both store and ledger reject before guard. Source/assembler outage blocks only the affected new attempt while sound existing Class A continues. |

## Candidate and Durable Effect Boundary

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-B01 | Class A work occurs in a disposable project-scoped filesystem with no consequential credential and no canonical control/evidence-root write access. | Escape, symlink, mount, environment, process, and credential-exfiltration tests fail; the worktree remains discardable. |
| AC-B02 | Reads, candidate edits, local build/test/lint, generated candidate artifacts, local commits, and Class A actions inside an already launched child require no per-action approval or broker round trip. Each delegated child-agent launch still uses one typed `ExecutorLaunch` broker transition; enumerated ordinary subprocesses may be pre-admitted by the parent envelope. | Representative ordinary workflows complete candidate iteration with zero approval prompts and no durable-effect credential; child launch has exactly one broker transition and its internal admitted Class A loop has none. |
| AC-B03 | Canonical filesystem mutation, canonical control/evidence-root publication, remote Git mutation, provider mutation, external API write, secret lease, deployment, package publication, and policy/trust-root activation are broker-only. | Direct-path inventory and negative tests prove every durable adapter fails without broker IPC and a verified typed capability. |
| AC-B04 | Local commits remain candidate effects; push, merge, protected-ref change, and release-tag publication are durable effects. | Git integration tests exercise the boundary without treating local commit creation as privileged. |
| AC-B05 | Test execution is Class A unless the test can reach durable targets, consequential secrets, privileged devices, or external write APIs. | Test harness classification fixtures correctly elevate only consequential variants. |
| AC-B06 | Generated artifacts remain candidate data until promoted to a canonical root or external store. | Identical artifact generation is autonomous; publication requires a target-bound capability and provenance digest. |
| AC-B07 | The safe path is the default path and requires no more operator steps than an available bypass. | Usability test demonstrates one command/run path from candidate work through an automatically allowed Class B effect. |

## Enforcement and Identity

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-E01 | Default profile combines an OS- or OCI-backed project sandbox, a local effect broker, OS key custody/JIT credentials, and independent provider Apps. | End-to-end test on supported hosts; unsupported isolation features fail only the affected durable transition. |
| AC-E02 | Higher-assurance profile supports VM or privileged sidecar isolation, remote/WORM anchoring, and stronger key custody without changing authority semantics. | Cross-profile conformance suite produces identical allow/deny decisions for the same governing inputs. |
| AC-E03 | Hooks and in-process wrappers are defense in depth, telemetry, or compatibility aids, never the sole boundary. | Removing or bypassing a hook does not permit a durable effect. |
| AC-E04 | The model, executor, harness, run, mission, and child agent possess no unmediated consequential credential. | Runtime environment and process-tree scans find none; a malicious candidate cannot use provider or activation credentials. |
| AC-E05 | All credential/high-impact principals are distinct and revocable: proposal versus operator activation, identity registry, compiler/authority/issuer, ledger, launch/effect brokers and adapters, vault/JIT issuer, evidence store/signer/anchor/retention, validation worker/attestor, verifier/effect Apps, release signer/trust store/installer/bootstrap, recovery/backup, and break-glass. | Principal-to-transition inventory and cross-use tests deny every credential substitution; candidate-executing identities hold none; revoking each principal blocks only its owned transition and leaves unrelated sound Class A work available. |
| AC-E06 | The layered TCB inventories cover local enforcement; identity, credential, and evidence; merge/provider; build/release/update; and recovery/rollback. | Threat-model review traces every durable effect and trust decision to a documented TCB property and update path. |

## Evidence Trust and Economics

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-V01 | Documentation distinguishes corruption detection, qualified tamper evidence, authenticity, non-repudiation, completeness, and truthfulness. | Terminology lint and architecture review reject stronger claims than retained proof supports. |
| AC-V02 | The signer attests only to normalized committed evidence-store facts after end-to-end verification of broker/reconciler/ledger origin envelopes, identities, nonces, and payload digests—not an arbitrary model, direct producer, or store-fabricated receipt. | Altering caller fields cannot alter the signed outcome; a malicious store fabricates, substitutes, replays, omits, or reorders outcome/reconciliation facts and the signer rejects every fact lacking valid origin/linkage. Independent target queries remain the broker/reconciler/verifier's responsibility. |
| AC-V03 | Per-run sequence and capability nonce uniqueness are transactional, crash-recoverable, and replay-safe. | Concurrent append, crash-at-each-transition, restart, and replay tests retain one monotonic history. |
| AC-V04 | Every Class B/C terminal head is signed and externally anchored under the fixed finalization obligation registered with its originating capability; the anchor append is a terminal recursion base. | A local writer re-chains the journal and verification fails; missing/wrong originating obligation, signer/store, target, payload schema, or idempotency key denies; duplicate append is idempotent; arbitrary anchor calls and recursive immediate self-anchoring fail; typed repair is required for backfill. |
| AC-V05 | Historical evidence remains verifiable after schema, runtime, signer-key, or verifier upgrades. | Old public keys, canonicalizers, schemas, and released verifier digests reproduce the prior verdict after upgrade. |
| AC-V06 | Provider or external state is reconciled with receipts; disagreement creates a disputed append-only record and blocks only dependent transitions. | Inject a forged/synthetic success receipt and verify reconciliation prevents dependent publication. |
| AC-V07 | Evidence retention, quotas, aggregation, and compaction obey effect-class tiers without per-action Git churn. | Tests cross the 80-percent/soft triggers; reserve and exhaust per-run, per-effect, per-project, derived `N`-project global, and Change-index quotas; reject a profile ceiling smaller than its largest admitted effect; prove Class A sampling preserves required facts/work; prove B/C hard quota blocks only the next transition; aggregate many B/C effects into one Change index within `512 KiB`/`4` files; preserve roots/anchors, remove expired raw, and prove summary-to-raw lineage. |
| AC-V08 | Ordinary review loads a compact summary rather than raw event streams. | Median ordinary-run evidence summary is at most 4,000 context tokens and identifies links to externally retained raw evidence. |
| AC-V09 | Durable check/control-plane emissions are schema-constrained and brokered. `ProviderCheckEmission` creates a non-successful check, then atomically binds a dormant invalidation template to the authenticated provider check ID/emission lineage/attempt link before success. Later failure consumes the one-shot `CheckInvalidationObligation`. Publication and invalidation use attempt/link guards and distinct finalization obligations; only anchor responses are no-immediate-self-anchor bases. | Missing/wrong source, tuple, App/namespace, conclusion, expiry, idempotency, emission capability, provider response/ID, lineage/attempt link/context, template/bound invalidation event, or either finalization denies; bind failure leaves check non-successful; premature success/direct discretion fails; concurrent invalidators yield one failure; invalidation cannot restore/retarget/reuse publication finalization; both outcomes get distinct signed anchors; anchor responses do not recurse. |

## Merge Provenance

The normative minimum tuple is the complete “Required provenance tuple” table
in `identity-evidence-merge-self-development.md`, incorporated here by
reference. Every field and verification subfield in that table is mandatory;
no shortened routing list, check payload, or pull-request manifest may replace
it.

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-M01 | A required, App-bound check is emitted by an independent GitHub App using a pinned released or protected-base verifier. | A PR that modifies repository workflows, verifier source, or check-name strings cannot impersonate or satisfy the App check. |
| AC-M02 | The verifier and provider-effect identities are separate; verifier has read/check permission and no merge credential. | GitHub installation permission inspection and attempted cross-use prove least privilege. |
| AC-M03 | The check/verdict is bound to repository identity, PR identity, exact current head SHA, base target/SHA, and provider-control snapshot. | Head update, same-head cross-PR reuse, PR recreation, base-target/base-SHA change, or ruleset/config change invalidates the old verdict/check and capability; merge of a different tuple is rejected. |
| AC-M04 | Ruleset satisfaction alone is not treated as lifecycle provenance. | A synthetic green non-Octon check does not satisfy the App-bound provenance requirement. |
| AC-M05 | A low-risk, fully validated, unrevoked change may be merged automatically without operator interruption through the PR-backed route; direct-main/no-PR target-branch mutation is unsupported in Revision 2. | End-to-end Class B PR completion passes exact-SHA validation and retains signed merge/reconciliation evidence; direct-main/no-PR and unbound ref-update attempts fail before provider mutation. |
| AC-M06 | A green provider check has bounded liveness: while available, the verifier App changes it to definitive `failure` on expiry or revocation, never `neutral`/`skipped`; only the effect App/broker has ordinary automation merge credentials, and verifier outage blocks that App. A solo-owner manual merge is Class C break-glass unless an admitted higher-assurance provider actor restriction technically blocks it. | Live-provider scheduled-expiry and revocation tests turn an unchanged-head green check to failure and prove neutral/skipped would still satisfy the required-check rule; workflow/PAT/generic-service merge credentials are absent or denied; App outage blocks automatic merge; the effect App rechecks the full tuple. Manual-owner capability and any admitted actor restriction are explicitly tested/documented rather than assumed. |
| AC-M07 | The verifier rejects omission, mutation, stale value, or inconsistent cross-binding for every mandatory field/subfield in the normative Required provenance tuple table. | Schema-generated mutation coverage deletes and alters each leaf—including signed run lease, Run Contract schema/scope, grant issuer/decision/governing digests, capability kind/target/single-use/predecessor, compiler/freshness, component digests, validation input/verifier/freshness, recovery feasibility, signer/anchor/raw/compact locators, and full liveness—and every case fails before check emission/merge. |

## Safe Self-Development

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-S01 | Workspace-project work, ordinary Octon self-development, governance modification, and runtime/trust-root modification are classified before candidate code runs with authority. | Previously trusted classifier maps path/effect fixtures to the four modes; candidate classifier output is advisory for its own change. |
| AC-S02 | Ordinary non-trust-root Octon changes can complete autonomously when base-version policy and the independent verifier classify them as low risk. | Representative documentation, nonprivileged runtime, and test-only changes complete with zero activation prompt. |
| AC-S03 | Governance and trust-root candidates land inert and cannot activate themselves. Operator approval is a sealed input, not authority. | Candidate release/policy remains inactive until `authorize_execution` evaluates `OperatorApprovalInput`, ledger `register_issue` exposes typed `TrustActivation`, and broker/installer consumes its invocation guard; direct operator/installer pointer mutation fails outside first-epoch bootstrap. |
| AC-S04 | A single activation unit cannot modify a trust mechanism and control its only verifier or activation gate. | Negative fixtures cover authority/broker, policy/compiler, evidence/signer, merge/ruleset, installer/trust store, key rotation/verifier, classifier/self-classification, and rollback/previous-version combinations. |
| AC-S05 | Trust-root activation uses the previously trusted verifier, protected base facts, independent App result, shadow/canary evidence, and a tagged `OperatorApprovalInput` or separately keyed/quorate `HighAssurancePolicyApprovalInput` that flows through `authorize_execution` into a typed `TrustActivation` capability. Activation atomically registers an exact-old-slot one-shot rollback obligation. Direct operator-signature activation is permitted only for the bounded Phase 1B bootstrap. | Corrupt candidate, failed canary, stale verifier, missing prior release, forged/wrong-profile approval input, direct steady-state activation, and absent rollback obligation each prevent activation; a health failure claims the registered obligation through the ledger/broker/installer path and restores only the exact prior slot. |
| AC-S06 | A second human is profile-dependent; two-authority and two-identity control is the solo default. | Default profile operates with one human while cryptographically and operationally separating proposal, authorization, effect, evidence, verification, and activation identities. |

## Fault Injection and Narrow Degradation

The fault suite must inject and retain results for all twelve cases:

1. grant issued, no effect capability issued;
2. capability issued, not consumed;
3. consumption begun, persistence incomplete;
4. capability consumed, effect not attempted;
5. effect attempted, outcome unknown;
6. effect succeeded, final receipt missing;
7. receipt exists but external state disagrees;
8. concurrent token consumption;
9. concurrent journal append;
10. concurrent run start;
11. revocation during a running executor; and
12. broker, signer, verifier, network, or GitHub outage, independently.

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-F01 | No injection produces silent capability reuse, duplicate non-idempotent effect, false success, or lost candidate work. | Fault matrix reports zero forbidden outcomes. |
| AC-F02 | Class A work continues during a broker, signer, anchor, verifier, network, or provider outage whenever its sandbox remains trustworthy. | Outage tests continue local edit/build/test/commit and preserve the ready durable transition. |
| AC-F03 | Only the unavailable or disputed consequential transition blocks. | Independent runs and unrelated targets continue; denial names the narrow scope. |
| AC-F04 | Unknown effects reconcile before retry and non-idempotent effects are never blindly replayed. | Provider target/version/idempotency fixtures prove safe recovery. |
| AC-F05 | Overlapping durable scopes serialize while independent candidate work and disjoint durable targets can coexist. | Lease tests cover same project/target and disjoint worktrees/projects. |
| AC-F06 | Concurrent starts for the same run key create exactly one run identity, evidence root, and `run-created` event; later starters attach idempotently or receive a deterministic conflict. | Threaded and multi-process tests assert one canonical run reference and no duplicate root/event. |

## Workspace Project and Harness Factory

| ID | Required result | Implementation acceptance test |
|---|---|---|
| AC-P01 | Workspace Project has a durable ID/adoption protocol, path-safe storage key, immutable project/profile revision stores, an atomic active pointer pairing their independent revisions, lifecycle, maximum boundary, canonical locator, monorepo/nested rules, dependency edges, and discovery rules. | Schema and discovery fixtures cover same-host move without project/boundary revision churn, normal clone, same-host raw-copy collision, cross-host unclaimed-ID/transfer, fork/provider transfer, single-root, monorepo, nested ownership, detached worktree, exact pointer-epoch historical lookup, and multiple candidates. |
| AC-P02 | Project Profile is a separately revisioned, repairable observed-state projection of a Workspace Project, not a source of authority. | Stale path, moved root, changed VCS identity, and machine-fact drift publish/select a new profile revision while retaining the project revision when its authored boundary is unchanged; boundary drift requires a new project revision; a run never silently follows either pointer. |
| AC-P03 | Cross-project dependencies do not silently union authority. | Manifest maps every requested path/effect/target to one project scope; the canonical decision records separately narrowed project envelopes; each broker capability binds one envelope/target unless an explicitly typed atomic multi-project effect names all of them. |
| AC-P04 | The governed factory compiles the existing non-authorizing task-harness inputs into a canonical effective-harness manifest; the isolated Policy Compiler is the sole semantic effect/risk/self-development classifier. | Same normalized inputs produce the same digest/class; golden/mutation vectors cover classification; untrusted content cannot inject authority/host controls; no peer classifier silently changes the class. |
| AC-P05 | Canonical authority binds the effective-harness/compiler output when deciding, applies live policy plus the small versioned structural monotonic invariant lattice, and signs issuance requests without reclassifying. | Manifest/compiler-version/class change, stale input, or support change invalidates; lattice rejects scope/type/protected-root widening but cannot upgrade/downgrade the compiler class; compiler compromise is reported as authorization-TCB risk. |
| AC-P06 | Host controls are installed only by the launch broker after `ExecutorLaunch` verification/reservation; consume intent, outbox import, and `attempt_started` are durable before spawn. | Harness output alone cannot change controls; mutation of parent/child identity, parent grant ref/digest, Run Contract ref/digest, delegation depth limits, argv, working-directory scope/path, environment allowlist/value digest, timeout/cancellation, descendants, resources, budget, operation lineage, attempt generation, idempotency key, sandbox, mount, network, process, or credential binding denies before spawn; crash injection proves the pre-spawn persistence order. |
| AC-P07 | Revocation, retirement, and child-agent narrowing are explicit and auditable. | Revoked digest stops new launches, active child loses new durable transitions, and retired manifests remain historically verifiable. |

## Performance and Usability Gate

The quantitative targets in `performance-and-workflows.md` are normative
initial targets. At minimum:

- ordinary bug fixes, refactors, features, and low-risk PR completion require
  zero manual approvals and zero routine operator interruptions;
- production and trust-root activation require no more than one planned
  interruption in the default solo profile;
- warm productive start p95 is at most 15 seconds;
- warm harness compilation p95 is at most 1 second and cold p95 at most 5
  seconds;
- local broker overhead p95 is under 250 milliseconds per Class B
  transition, excluding provider latency;
- Octon-specific CI adds at most 60 seconds at p95 and at most 10 percent of
  total CI critical-path time;
- eligible low-risk merge and target-ref reconciliation completes within 5
  minutes at p95 under nominal provider availability;
- ordinary false-denial rate is at most 2 percent after stabilization;
- adversarial suites observe zero false approvals, with a one-sided 95 percent
  upper confidence bound at most 0.1 percent after at least 3,000 trials, and
  zero scope violations;
- new broker/launch requests deny within 1 second at p95 after revocation and
  affected executor process trees terminate within 5 seconds at p95;
- ordinary changes require zero manually authored governance artifacts;
- compact ordinary evidence review takes under 2 minutes;
- Class A recovery after a consequential-service outage is under 60 seconds;
- task correctness and regression rate are no worse than the ungoverned
  baseline, with scope-violation rate strictly improved.

An architecture implementation fails the usability gate if it meets security
tests by increasing ordinary manual approvals, artifacts, or interruptions
beyond these limits without a separately approved risk-based exception.

## Workflow Gate

The measured workflow table must cover:

1. small bug fix;
2. multi-file refactor;
3. new feature;
4. long-running mission;
5. low-risk autonomous pull-request completion;
6. production change;
7. ordinary Octon self-development; and
8. Octon trust-root modification.

For each workflow, retained results must record autonomous actions, brokered
actions, approval points, interruption count, Octon-added latency, failure
behavior, recovery behavior, autonomous-completion result, correctness,
regressions, and scope violations.

## Acceptance-Test Ownership

The lead owner retains the test receipt. A named co-owner supplies the boundary
fixture or observation. The assurance runner executes negative/fault suites
from the previously trusted release; a component under test cannot be its own
sole certifier.

| Criteria | Lead owner | Required co-owner or independent observer |
|---|---|---|
| AC-D01–AC-D05 | Proposal architecture reviewer | Evidence appendix/schema validator |
| AC-A01, AC-A02 | Canonical authority engine | Policy compiler and authority-boundary scanner |
| AC-A03 | Launch broker | Capability ledger and lifecycle executor |
| AC-A04 | Lifecycle executor | Authority-boundary scanner |
| AC-A05 | Canonical authority engine | Identity registry, capability issuer, and launch broker |
| AC-A06 | Capability ledger | Effect/launch broker concurrency harness |
| AC-A09 | Capability issuer and ledger | Crash/concurrent-issuer registration harness |
| AC-A10 | Liveness attestor/assembler owners | Evidence-store signature/freshness mutation and outage harness |
| AC-A07 | Credential/identity integration owner | Authority engine and effect broker negative-control runner |
| AC-A08 | Authority/denial-contract owner | Lifecycle, launch broker, effect broker, and provider adapters |
| AC-B01 | Launch broker and sandbox adapter | Host-specific escape-suite runner |
| AC-B02 | Governed Harness Factory | Performance suite and sandbox adapter |
| AC-B03, AC-B04, AC-B05, AC-B06 | Material-effect inventory owner | Effect broker and direct-path scanner |
| AC-B07 | Solo-developer workflow owner | Usability/performance suite |
| AC-E01 | Default-profile release integrator | Host sandbox, broker, vault, and provider-App owners |
| AC-E02 | Higher-assurance profile owner | Cross-profile conformance runner |
| AC-E03 | Authority-boundary scanner | Hook/wrapper owners |
| AC-E04 | Credential vault and launch-broker owners | Credential-exfiltration runner |
| AC-E05 | Identity/credential architecture owner | Every layered-TCB principal/credential owner and cross-use/revocation harness |
| AC-E06 | TCB architecture reviewer | Threat-model and update-path reviewers |
| AC-V01 | Evidence-contract owner | Architecture terminology reviewer |
| AC-V02 | Evidence signer | Evidence store and broker observer |
| AC-V03 | Evidence store | Capability ledger and crash/concurrency harness |
| AC-V04 | External anchor writer | Evidence signer and independent retriever |
| AC-V05 | Historical verifier registry | Release/key/schema owners |
| AC-V06 | Reconciliation controller | Provider/local adapter and evidence signer |
| AC-V07 | Retention/compaction service | Evidence signer, anchor, and restore runner |
| AC-V08 | Evidence-view/context owner | Operator-comprehension suite |
| AC-V09 | Control-plane emission broker/App and anchor writer | Authority/ledger, attestor/verifier, evidence store, and recursion/idempotency suite |
| AC-M01, AC-M03, AC-M04 | Verifier GitHub App | Pinned verifier and live provider observer |
| AC-M02 | Provider identity/credential owner | Verifier-App/effect-App cross-use test |
| AC-M05 | Effect GitHub App and provider broker | Verifier App, signer, and merge-reconciliation runner |
| AC-M06 | Verifier GitHub App and provider credential owner | Effect-App liveness/revocation and stale-green negative-control runner |
| AC-M07 | Independent provenance verifier | Generated full-tuple schema/mutation and cross-binding suite |
| AC-S01, AC-S02, AC-S04 | Previously trusted self-development verifier | Independent verifier App |
| AC-S03, AC-S05 | Capability ledger, broker, installer/activation controller, and health monitor | Previous trusted release/verifier, operator-approval or high-assurance-policy identity, separate break-glass identity, and exact-old-slot rollback obligation |
| AC-S06 | Identity/profile owner | Solo-operator usability runner |
| AC-F01, AC-F03, AC-F04 | Recovery/reconciliation controller | Capability ledger, evidence store, and fault-injection runner |
| AC-F02 | Launch/sandbox owner | Dependency-outage runner |
| AC-F05 | Durable-scope lease owner | Multi-process concurrency runner |
| AC-F06 | Run identity/evidence-root owner | Multi-process unique-run-key runner |
| AC-P01, AC-P02, AC-P03 | Workspace Project/locality owner | Discovery, identity-adoption, and authority no-union fixtures |
| AC-P04 | Governed Harness Factory | Policy Compiler and deterministic-build runner |
| AC-P05 | Policy Compiler and canonical authority engine | Harness Factory and capability issuer |
| AC-P06 | Launch broker | Harness Factory and host-control conformance runner |
| AC-P07 | Identity/revocation and harness-retirement owners | Authority engine and launch broker |
| Performance and Workflow Gates | Assurance performance/usability owner | Every workflow/component owner supplies timestamped measurements |

## Final Architecture Acceptance Gate

The packet may advance from `in-review` only when:

1. all twelve decision dispositions are recorded;
2. the Required Evidence Appendix is complete and its limitations remain
   visible;
3. the implementation-grade completeness review passes;
4. the strict Pre-Integration Architecture Review passes against the stable
   packet digest;
5. promotion targets and the separate repo-local/provider Change boundary are
   accepted; and
6. no unsupported claim is used as an implementation premise.
