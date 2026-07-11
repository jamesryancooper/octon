# Independently Approvable Architecture Decisions

Each record can be approved, rejected, or returned for revision independently.
Dependencies are explicit; approval of one record does not silently approve
another.

## AD-01 — Canonical Authorization Unification

- **Recommended option:** `authorize_execution` is the only component allowed
  to produce an authorization decision and `GrantBundle`. A Run Contract,
  Workspace Project, Project Profile, effective harness, delegation contract,
  evidence gate, and provider check are inputs or narrowing gates only. From an
  allow grant, the authority issuer signs an exact typed capability request;
  ledger `register_issue` atomically activates one lineage/generation and only
  then exposes the registered `AuthorizedEffect<T>` reference. An effect broker
  submits that reference for ledger verification/reservation, validates the
  lease, and requests irreversible consume intent plus outbox. The evidence
  store imports it, validates fresh liveness/preconditions, and commits
  `attempt_started`; the ledger independently re-verifies the
  `AttemptLivenessBundle` and records one `AttemptLinkAck`; the broker
  consumes the resulting invocation guard, performs the effect, and supplies
  observed facts.
- **Rejected alternatives:** keep lifecycle authorization as a peer; let a Run
  Contract or harness mint authority; treat `GrantBundle` as a consumable
  capability; verify a token before it has been issued; use ambient grant
  access at material APIs.
- **Rationale:** one vocabulary and one decision owner remove contradictory
  allow semantics while preserving typed least-authority effects.
- **Security effect:** eliminates self-described or competing authorization
  paths; compromise of the authority engine remains high impact.
- **Development-velocity effect:** one envelope decision replaces repeated
  policy ceremonies; downstream components cache immutable decision inputs.
- **Implementation cost:** high.
- **Migration impact:** rename lifecycle “authorization” outputs to
  precondition receipts; convert `ProgramApprovalGrant` to non-authorizing
  `ProgramApprovalInput` evaluated only by `authorize_execution`; add
  grant/harness digests to all typed effects; replace public
  `verify_authorized_effect` consumption with ledger
  `verify_and_reserve`/`commit_consume_intent` plus evidence-store
  `import_and_begin_attempt`; retire duplicate allow/deny terms and validators.
- **Residual risk:** incorrect canonical policy or authority-engine code can
  still overgrant.
- **Acceptance test:** a repository-wide negative-control inventory proves no
  component other than the canonical engine can emit an allow grant, and every
  ordinary Class B/C effect fails without a matching current grant and typed
  capability. The bounded Phase 1B first-epoch activation and separate
  break-glass stop/revoke/restore-last-trusted paths are externally rooted,
  independently recorded exceptions; negative controls prove neither can
  authorize ordinary effects, arbitrary candidates, widening, or continued
  bootstrap activation after retirement.
  A lifecycle-program approval cannot reach an adapter except as canonical
  authority input; crash/concurrent-issuer tests expose no capability before
  `register_issue` and activate at most one version; no consumed capability or
  pre-attempt guard is reused.

## AD-02 — Lifecycle-Executor Launch Authority

- **Recommended option:** every real lifecycle or child-agent process launch
  requires a distinct, single-use `AuthorizedEffect<ExecutorLaunch>` bound to
  run, grant, effective-harness digest, executable/image digest, normalized
  command, working root, sandbox profile, environment digest, network and
  credential projection, descendant limit, delegation depth, expiry, and
  revocation state. A delegated child agent first receives a fresh
  child-scoped GrantBundle from canonical `authorize_execution`; the issuer
  signs launch/later-effect requests only against that child grant and ledger
  `register_issue` exposes only child-bound references. The launch broker, not the
  lifecycle executor, submits the token to the capability ledger for atomic
  verification/reservation, validates the authenticated lease, installs
  controls, requests irreversible consume intent plus outbox, causes
  evidence-store import and durable `attempt_started`, validates the returned
  receipt, obtains the sole ledger `AttemptLinkAck` after independent liveness
  re-verification, constructs a non-cloneable
  `AttemptInvocationGuard<ExecutorLaunch>`,
  and consumes it to launch. Crash recovery before attempt-start requires one
  exclusive `RecoveryLease`, fresh liveness/preconditions, and the same
  evidence-store CAS/guard; after attempt-start it reconciles unknown outcome.
- **Rejected alternatives:** delegation proof alone; generic service token;
  caller-supplied `mode: unattended` or `authority_ref`; passing the parent
  grant or durable credential into a child.
- **Rationale:** process launch creates the isolation envelope and therefore is
  the correct point for one typed capability, not per-file authorization.
- **Security effect:** prevents an untrusted caller from widening child scope
  or launching without canonical authority.
- **Development-velocity effect:** one launch decision unlocks uninterrupted
  Class A work.
- **Implementation cost:** medium-high.
- **Migration impact:** replace `LifecycleInvocationAuthority` with immutable
  grant/token references; rename `authorize_before_dispatch`; route
  `Command::spawn` through the broker.
- **Residual risk:** sandbox or host-adapter escape.
- **Acceptance test:** direct lifecycle spawn, changed command/environment,
  widened write path, excess child count, expired token, and revoked token all
  fail before process creation; consume/outbox/import/`attempt_started` crash
  tests prove no reuse or unrecorded spawn; a valid launch has no extra
  approval.

## AD-03 — Candidate Versus Durable Effect Boundary

- **Recommended option:** Class A effects may occur inside a disposable,
  project-scoped, credentialless sandbox after launch. Class B and Class C
  effects that mutate canonical roots, remote state, external systems,
  secrets, production, publication, or trust activation are broker-only.
- **Rejected alternatives:** broker every file write; trust all local writes;
  classify only by command name or path without environment/provenance; expose
  remote credentials to make the safe path convenient.
- **Rationale:** durability, escape, and consequence—not “a write happened”—are
  the risk boundary.
- **Security effect:** preserves mediation where consequences survive while
  reducing pressure to bypass controls during normal editing.
- **Development-velocity effect:** local edit/build/test/commit loops have no
  broker round trip or operator approval.
- **Implementation cost:** medium.
- **Migration impact:** revise the material-side-effect inventory and coverage
  validators; introduce sandbox-local candidate roots and export/quarantine
  rules.
- **Residual risk:** misclassification or a sandbox path alias that reaches a
  durable root.
- **Acceptance test:** mount/path/symlink, Git-ref, network, secret, and
  external-API negative controls prove that Class A cannot reach a durable
  target; representative local loops meet the latency target.

## AD-04 — Default Solo-Developer Sandbox and Broker Topology

- **Recommended option:** hybrid local and remote enforcement: disposable
  working copy, rootless OCI sandbox (native namespaces on Linux and
  VM-backed on macOS/Windows), per-user local broker outside the sandbox,
  platform keystore, separate verifier/effect GitHub Apps, and remote evidence
  anchor. Higher assurance uses a dedicated lightweight VM plus privileged
  sidecar or remote broker and stronger key custody.
- **Rejected alternatives:** in-process wrappers or hooks as the sole boundary;
  container without broker; local broker without isolation; remote-only broker;
  GitHub App as a local filesystem boundary.
- **Rationale:** no single topology covers local process/filesystem effects,
  credentials, offline work, and provider mutation.
- **Security effect:** separates the agent from credentials and durable effect
  adapters.
- **Development-velocity effect:** Class A remains local/offline; only durable
  transitions pay broker/provider latency.
- **Implementation cost:** high, with host-specific adapters.
- **Migration impact:** shadow broker first; admit host adapters separately;
  keep hooks temporarily for telemetry; remove direct provider credentials
  after coverage.
- **Residual risk:** OS/container implementation defects and local broker
  compromise.
- **Acceptance test:** an adversarial sandbox cannot read broker credentials,
  write host/canonical paths, reach denied network endpoints, or impersonate a
  provider effect on each admitted host.

## AD-05 — Identity and Credential Separation

- **Recommended option:** the proposer identity (model/child or human proposal
  session) has no unmediated consequential credential. Every privileged
  layered-TCB transition has a distinct revocable principal and credential
  scope: proposal versus operator approval/activation; run/mission/harness and
  lifecycle executor; authority/capability issuer versus ledger; canonical
  governing-input and Workspace Project stores; launch/effect brokers,
  per-target adapters, vault/JIT issuer; evidence store, signer, anchor writer,
  and retention; credentialless validation worker versus non-candidate-
  executing attestor; verifier App versus effect App; build/release,
  installer/bootstrap, and recovery/backup identities. Solo default is
  two-authority or two-identity control; two-person control is configurable.
- **Rejected alternatives:** shared operator PAT in the agent or PR runner;
  one runtime key for authorization, effects, and evidence; mandatory second
  human for ordinary work; model-owned approval.
- **Rationale:** independent software identities provide meaningful separation
  without making a solo user recruit an approver for routine work.
- **Security effect:** compromise of the model does not immediately yield the
  credential needed for its proposed effect.
- **Development-velocity effect:** policy can authorize Class B automatically
  because credential use remains mediated.
- **Implementation cost:** medium-high.
- **Migration impact:** inventory and remove ambient credentials; issue
  least-privilege broker/App identities and rotation/revocation controls.
- **Residual risk:** host/operator compromise may cross identities.
- **Acceptance test:** credential scans and live negative controls prove the
  model/proposal sandbox and candidate-executing validation worker cannot
  obtain or directly use Class B/C, check-write, signing, release, or
  activation credentials; a principal-to-TCB-transition matrix has no shared
  credential shortcut, and revoking each principal blocks only its owned
  transition.

## AD-06 — Evidence Signer and External Anchor

- **Recommended option:** effect and launch brokers append observed facts to a
  dedicated transactional evidence sequence/receipt store. The separate
  capability ledger owns nonce and operation-lineage/generation uniqueness,
  issue/supersede/reserve/release/consume/expiry/revocation state, the
  immutable consume outbox, evidence-attempt linkage, and capability recovery.
  It never owns attempt or outcome truth.
  Broker/reconciler/ledger fact envelopes carry end-to-end producer
  authentication that the store preserves but cannot forge; a
  hardware/keystore-backed signer independently re-verifies those envelopes
  and signs normalized evidence-store records,
  and a separate append-only anchor writer externally anchors Class B/C heads.
  Each originating B/C capability registers a fixed signed-head-only
  finalization obligation, so the external append is authorized without an
  unconstrained or recursively anchored second effect.
  Raw bodies live in a content-addressed evidence store, with compact signed
  indexes and retention tiers.
- **Rejected alternatives:** model-supplied receipts signed verbatim;
  re-chainable local hash journal as adversarial proof; signer key in the
  repository or sandbox; all raw evidence committed to Git; unsigned summaries
  replacing raw facts.
- **Rationale:** integrity, authenticity, completeness, and truthfulness require
  different mechanisms and claims.
- **Security effect:** makes undetected after-the-fact rewrite and receipt
  impersonation substantially harder.
- **Development-velocity effect:** compact indexes lower context and repository
  churn; signing/anchoring is batched at consequential transitions.
- **Implementation cost:** high.
- **Migration impact:** add the transactional evidence sequence/receipt store,
  broker/launch append protocol, signer protocol, key registry/rotation,
  append-only anchor writer, legacy unsigned evidence classification, and
  compaction jobs. Capability reservation remains in the separately owned
  capability ledger from AD-01/AD-02.
- **Residual risk:** the broker may record an incorrect observation that the
  signer can authenticate but cannot independently prove truthful; external
  anchor availability.
- **Acceptance test:** tamper, re-chain, replay, signer impersonation, key
  rotation, offline queue, crash, compaction, and old-verifier tests produce
  the defined narrow outcomes.

## AD-07 — Trusted Merge Verifier

- **Recommended option:** require a verifier GitHub App check from an integration
  identity a pull request cannot impersonate. It verifies the exact repository,
  PR identity/lifecycle/head repository, head SHA, base target/SHA, provider
  controls, and full signed Octon provenance tuple. The verifier/attestor emits
  only a committed signed verdict and `ControlPlaneEmissionRequest`; the
  canonical authority issuer signs and the ledger registers/reserves/commits
  consume for a typed `ProviderCheckEmission`, and the checks-write App adapter
  consumes only the resulting invocation guard to create a non-successful
  check.
  Registration also stores a dormant one-shot, failure-only invalidation
  template with a distinct finalization obligation; authenticated provider
  response binds it to check ID/emission lineage/attempt link before success.
  While available, the App later consumes that `CheckInvalidationObligation`
  on bounded expiry, revocation, or tuple/config drift. A separate effect
  App/broker holds the only ordinary
  automation merge credential and rechecks the full tuple immediately before
  the expected-SHA merge. The Revision 2 target admits PR-backed durable merges
  only. Direct-main/no-PR updates remain unsupported unless a later independent
  decision defines an equally protected non-PR tuple, trigger, verdict,
  invalidation, liveness, expected-old/new-ref update, and provider gate.
- **Rejected alternatives:** current required GitHub Actions contexts alone;
  executing PR-head broker/runtime code with a write token; a released binary
  selected by a PR-modifiable workflow; a protected reusable workflow or
  base-version check as the sole verifier; ruleset satisfaction as proof of
  Octon provenance; carrying forward direct-main/no-PR as an undefined bypass.
- **Rationale:** provider enforcement must bind an independent verifier
  identity, not only a check name or code stored in the candidate change.
- **Security effect:** prevents candidate code from self-issuing the required
  lifecycle-provenance verdict, replaying a same-SHA verdict across PR/base
  contexts, or racing a different head into the automatic merge lane.
- **Development-velocity effect:** verification is automatic and adds no
  operator interruption.
- **Implementation cost:** high.
- **Migration impact:** deploy App in report-only mode, add the required App
  check, dormant-template binding, one-shot invalidator, and distinct
  publication/invalidation finalization; remove provider write credentials
  from PR-head jobs and generic automation, then retire the old merge path in a
  separate repo-local Change.
- **Residual risk:** App or provider compromise/configuration drift; during
  verifier outage an already-green check may remain green, and a solo-owner
  account may remain technically capable of a policy-violating manual merge
  unless an admitted provider actor restriction is available.
- **Acceptance test:** modified workflow/verifier, forged check name, stale
  head, same-head cross-PR/base reuse, revoked grant, scheduled expiry, provider
  config change, missing evidence anchor, and cross-repository replay cannot
  drive the effect-App merge; success before authenticated invalidation binding
  fails; invalidation uses one obligation and `failure`, never
  `neutral`/`skipped`/retarget/restore, and both outcomes are separately
  signed/anchored; direct-main/no-PR mutation is denied; verifier outage blocks automatic merge and manual-owner
  capability/actor restrictions are explicitly documented and tested.

## AD-08 — Self-Development Activation Policy

- **Recommended option:** classify ordinary workspace work, ordinary Octon
  self-development, governance modification, and runtime/trust-root
  modification separately. Trust changes are verified by the previously
  trusted release and independent App and installed inactive. In steady state,
  sealed tagged `ActivationApprovalInput`—either `OperatorApprovalInput` or a
  separately issued `HighAssurancePolicyApprovalInput`—is only a governing
  input to `authorize_execution(TrustActivationRequest)`; the issuer signs a typed
  request, ledger `register_issue` exposes the activation reference, and
  broker/installer consumes its invocation guard. That capability registers a
  fixed one-shot old-slot health rollback obligation. Direct operator-signature
  activation exists only in the bounded first-epoch bootstrap; separate
  break-glass can stop/revoke/restore last-trusted but cannot activate a new
  candidate.
- **Rejected alternatives:** prohibit self-development; let a change alter its
  only verifier or activation gate; require a second person for every Octon
  change; immediately replace the active runtime after merge; allow same-change
  rollback removal.
- **Rationale:** two-phase activation creates solo-operator separation without
  freezing Octon's ability to improve itself.
- **Security effect:** blocks same-change self-certification and preserves a
  last-known-good trust epoch.
- **Development-velocity effect:** ordinary non-trust Octon work remains
  autonomous; human attention is concentrated at trust activation.
- **Implementation cost:** high.
- **Migration impact:** define trust-root path inventory, active/candidate
  epochs, old-verifier runner, inactive slots, activation receipts, and rollback
  controller.
- **Residual risk:** latent defect accepted by both old verifier and operator;
  rollback-incompatible data migration.
- **Acceptance test:** a change that controls the sole verifier, signer,
  provider gate, active selector, or rollback path is denied; operator approval
  cannot mutate the steady-state pointer or replace grant/capability;
  activation passes `register_issue`/attempt guard; failed health can consume
  only the exact one-shot old-slot rollback obligation, while arbitrary restore
  and break-glass candidate activation fail.

## AD-09 — Workspace Project Authority Boundary

- **Recommended option:** Workspace Project is an authored locality identity
  and maximum-boundary declaration under `instance/locality`. It may narrow or
  block a request but cannot approve, grant, admit support, issue credentials,
  or authorize. Project Profile remains evidence-backed observed state linked
  to that durable identity.
- **Rejected alternatives:** use absolute `repo_root` as identity; make each
  monorepo package a mandatory project; let Project Profile authorize; infer
  cross-project writes from dependency graphs; select ambiguous nested projects
  silently.
- **Rationale:** stable identity and explicit maximum scope solve project drift
  without duplicating runtime authority.
- **Security effect:** prevents stale/local discovery facts from widening
  effect scope.
- **Development-velocity effect:** one project per repository is the default;
  nested declarations appear only where boundaries materially differ.
- **Implementation cost:** medium.
- **Migration impact:** add project schema/registry, link current Project
  Profile, automatic discovery/repair, and composite-envelope handling.
- **Residual risk:** wrong authored boundary or ambiguous filesystem identity.
- **Acceptance test:** move/clone, monorepo, nested, stale profile, retired ID,
  ambiguous root, and cross-project dependency fixtures select or block
  deterministically without issuing authority.

## AD-10 — Harness Factory Authority-Binding Boundary

- **Recommended option:** the Governed Harness Factory first emits a
  deterministic structural Harness Input Lock. The Policy Compiler alone
  classifies effect/risk and emits an exact Harness Compilation Plan. The
  Factory deterministically compiles that plan, without policy discretion, into
  a non-authorizing effective-harness manifest. The Policy Compiler verifies
  conformance; the authority engine binds all digests into the grant. A typed
  launch capability allows the launch broker to install only trusted host
  controls and launch the sandbox. Descendant harnesses can only narrow.
- **Rejected alternatives:** factory-issued grants; generated harness as policy
  authority; repo-supplied host-install script; authorize first and compile
  later; reuse stale harness by timestamp alone.
- **Rationale:** compilation is valuable preparation but must not become a
  second authority or privileged installer.
- **Security effect:** exact digest/freshness binding prevents harness swapping
  and child widening.
- **Development-velocity effect:** cached deterministic compilation makes safe
  launch the default one-command path.
- **Implementation cost:** medium-high.
- **Migration impact:** extend Task-Specific Execution Harness v1, add factory
  stages/receipts, source locks, host-adapter plans, grant field, and
  retirement/cleanup.
- **Residual risk:** compiler bug within the declared maxima or compromised host
  template.
- **Acceptance test:** deterministic rebuild, source drift, swapped manifest,
  untrusted host control, revoked grant, descendant widening, and retirement
  tests behave as specified.

## AD-11 — Safe Degraded-Operation Policy

- **Recommended option:** fail closed at the narrowest unavailable transition.
  Preserve and allow safe Class A candidate work during broker, signer,
  verifier, network, or provider outage; queue no ambiguous consequential
  business effect; quarantine unknown outcomes for broker reconciliation.
  During signer/anchor outage, pre-registered strictly narrowing obligations
  (check failure, exact rollback to a bound prior production/deployment or
  trust slot, strictly exposure-reducing bounded compensation, stop/revoke)
  may still execute
  through healthy ledger/evidence attempt-link gates, with origin-authenticated
  facts queued for later signature/anchor; new ordinary B/C effects remain
  blocked. Every denial
  names reason, policy, missing evidence, affected transition, preserved work,
  and shortest safe recovery route.
- **Rejected alternatives:** stop the entire run for any dependency outage;
  fail open; retry unknown non-idempotent effects blindly; discard the
  sandbox; return “manual intervention” without a concrete route.
- **Rationale:** narrow failure improves both safety and throughput.
- **Security effect:** unavailable enforcement cannot be bypassed, and unknown
  outcomes cannot be duplicated.
- **Development-velocity effect:** unrelated local work and evidence
  preparation continue.
- **Implementation cost:** medium-high.
- **Migration impact:** typed denial/recovery schema, effect state machine,
  preservation/quarantine, reconciliation adapters, and fault-injection suite.
- **Residual risk:** long outage delays merge/deployment and accumulates
  preserved candidates.
- **Acceptance test:** all twelve specified fault points and dependency outages
  block only the affected transition and retain a deterministic recovery
  receipt.

## AD-12 — Governance-Latency and Operator-Interruption Targets

- **Recommended option:** zero manual approvals and zero expected
  interruptions for ordinary Class A/B changes; at most one approval for
  production activation and trust-root activation; warm productive start p95
  at most 15 seconds, warm harness compile p95 at most 1 second, local broker
  decision/receipt p95 at most 25 ms and durable-wrapper overhead p95 at most
  250 ms, Octon-specific CI addition p95 at most 60 seconds and 10% of total CI
  critical-path time, eligible merge/reconciliation p95 at most 5 minutes,
  revocation denial/termination p95 at most 1/5 seconds, ordinary false-denial
  rate at most 2%, and zero observed scope violations or false approvals with
  the required statistical bound in the adversarial acceptance suite. Full
  targets live in `performance-and-workflows.md`.
- **Rejected alternatives:** unmeasured “secure by default”; per-command
  approval; periodic mission approval without scope change; latency targets
  that include provider/CI time but hide Octon overhead; accepting lower task
  correctness for stricter governance.
- **Rationale:** a solo developer must be able to prove Octon is not becoming a
  governance job.
- **Security effect:** measures false approvals, scope violations, regression,
  and recovery alongside speed.
- **Development-velocity effect:** makes interruption and latency budgets
  release-gating quality attributes.
- **Implementation cost:** medium.
- **Migration impact:** add telemetry, representative workload corpus,
  baseline comparisons, operator comprehension tests, and release SLO gates.
- **Residual risk:** benchmark gaming or workloads outside the corpus.
- **Acceptance test:** the representative workflow suite meets all safety,
  correctness, latency, interruption, evidence-review, and autonomous
  completion targets for two consecutive release candidates.

## Dependency Map

| Decision | Depends on |
| --- | --- |
| AD-02 | AD-01 |
| AD-03 | AD-01, AD-02 |
| AD-04 | AD-03 |
| AD-05 | AD-04 |
| AD-06 | AD-04, AD-05 |
| AD-07 | AD-05, AD-06 |
| AD-08 | AD-05, AD-06, AD-07 |
| AD-09 | AD-01 |
| AD-10 | AD-02, AD-09 |
| AD-11 | AD-01, AD-04, AD-06, AD-07, AD-08 |
| AD-12 | All preceding decisions |
