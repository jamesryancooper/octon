# Implementation-Grade Completeness Review

- verdict: fail
- unresolved_questions_count: 9
- clarification_required: yes
- reviewed_at: 2026-07-10
- review_scope: Revision 2 architecture packet after adversarial review and before external architect disposition

## Blockers

Nine material findings block implementation-grade completeness. Their complete
handoff contract, required dispositions, and affected architecture questions
are recorded in `support/external-architect-handoff.md` as EXT-01 through
EXT-09:

- crash-safe evidence-capacity lease release, allocation, downsizing, and
  protected recovery capacity;
- bounded evidence completeness and producer high-watermark semantics;
- removal of privileged PR-head execution before new TCB candidate PRs;
- rollback-obligation registration before trust activation;
- honest TCB accounting for canonical durable writers;
- consistent issuer/ledger/attempt-gate/adapter and attestor/verifier ownership;
- check invalidation when publication finalization or anchoring misses its
  deadline;
- privileged Git execution with every executable repository-controlled
  extension disabled; and
- secure first-install/enrollment and recurring solo-maintenance targets.

The following additional lifecycle gates remain after those defects are
resolved:

- operator disposition of the twelve decisions;
- strict Pre-Integration Architecture Review at a stable packet digest;
- proposal review and advancement from `in-review` to `accepted`;
- Change routing and implementation authorization;
- a separate repo-local/provider Change for `.github/**`, GitHub Apps, and the
  live ruleset.

No executable implementation prompt exists. Implementation remains blocked
until the external review is dispositioned, the required revisions are made,
the completeness receipt is rebound to the final artifact set, and all gates
pass.

## Assumptions

1. The target operator is one developer using the default solo profile; a
   second human is optional except where a selected higher-assurance profile
   requires one.
2. The default product posture is broad autonomy inside a disposable,
   credentialless project envelope, with controls concentrated at Class B/C
   boundaries.
3. Octon remains pre-1.0, so the selected `atomic` change profile may replace
   competing authority semantics cleanly rather than preserve indefinite
   compatibility.
4. The provider, OS key store, host sandbox primitives, and external anchor are
   dependencies with explicit compromise and outage handling, not assumed
   infallible.
5. The supplied Revision 1 artifact was not found in the searched exploratory
   proposal tree. The operator assignment is the available correction ledger;
   current repository/provider evidence supports the retained and corrected
   findings.
6. Existing unrelated dirty-worktree changes remain outside this packet and
   must be partitioned before any implementation closeout.

## Promotion Target Coverage

| Promotion target | Planned durable content | Packet owner |
|---|---|---|
| `.octon/framework/engine/runtime/spec/` | Canonical authority, capability/attempt, effect-class, denial/recovery, evidence, project-profile, and harness contracts | Authority, governance, evidence, project/harness designs |
| `.octon/framework/engine/runtime/crates/` | Authority unification, transactional ledger, launch gate, sandbox/broker adapters, signer, reconciliation, self-development runtime | Implementation plan phases 1–8 |
| `.octon/framework/capabilities/_ops/scripts/` | Retire or non-authoritatively rename the legacy policy grant broker | Authorization semantic migration |
| `.octon/framework/orchestration/runtime/_ops/scripts/` | Replace legacy replay/evidence pointer writing with canonical broker/evidence-store paths | Evidence migration |
| `.octon/framework/constitution/contracts/` | Identity, credential, evidence, Workspace Project, trust-root activation, and retention schemas | TCB, identity/evidence, project/harness designs |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Registration of accepted versioned contracts | Implementation plan generated outputs |
| `.octon/framework/product/contracts/` | User-facing project/harness/governance and operator-notification contracts | Governance, workflow, and factory designs |
| `.octon/framework/execution-roles/` | Broker, signer, verifier, launcher, child-agent, and recovery role bindings | Identity matrix and TCB |
| `.octon/framework/assurance/runtime/` | Direct-path, fault-injection, provider, self-development, and performance validators | Acceptance criteria and validation floor |
| `.octon/instance/governance/` | Default profile policy, identity/credential bindings, effect classes, activation and retention posture | Governance, identity, and self-development designs |
| `.octon/instance/locality/` | Workspace Project registry and Project Profile projection | Workspace Project design |

The target family is coherently Octon-internal. Provider workflows,
rulesets, and Apps are deliberately excluded and assigned to a linked
repo-local/provider Change.

## Affected Artifact Coverage

The packet accounts for:

- declared authority contracts and the implemented `GrantBundle`,
  `AuthorizedEffect<T>`, `VerifiedEffect<T>`, issuance, verification, and
  consumption path;
- lifecycle request, delegation, pre-dispatch proof, Codex/Claude/workflow
  child-process launch, and request-supplied mode/scope/evidence fields;
- material-effect inventory, local/canonical filesystem, local/remote Git,
  tests, generated artifacts, control/evidence roots, external APIs,
  deployments, publications, secrets, and trust activation;
- sandbox, local broker, sidecar/VM, remote broker, GitHub App, and hybrid
  topology options on macOS, Linux, and Windows;
- five-layer TCB, full identity matrix, credential custody, signer, sequence,
  replay, anchor, retention, build/update, and recovery surfaces;
- live provider ruleset fields, mutable workflow checks, PR-head credential
  exposure, expected-SHA merge binding, and independent App projection;
- ordinary and trust-root Octon self-development, prohibited same-change
  combinations, inert installation, old-version verification, activation, and
  rollback;
- all twelve required fault cases and narrow degraded operation;
- Workspace Project schema/lifecycle/boundary/discovery/nesting/dependencies
  and Project Profile repair;
- governed harness inputs, stages, manifest schema, freshness/digest binding,
  launch installation, revocation, retirement, child narrowing, and evidence;
- all eight representative workflows and every requested performance,
  correctness, safety, context, artifact, review, and comprehension metric.

Downstream reference repair and proposal-back-reference removal are explicit in
the implementation plan.

## Validator Coverage

The proposed validation floor covers:

- YAML/JSON schema parsing and negative fixtures;
- Rust unit and integration tests;
- multi-process concurrency and crash injection;
- path-component, symlink, mount, process, network, environment, and credential
  escape tests;
- direct durable-effect and process-spawn call-graph scans;
- grant/capability field mutation, expiry, revocation, replay, and child
  narrowing;
- broker idempotency and external-state reconciliation;
- signature, key rotation, journal re-chain, external anchor, historical
  verifier, compaction, and retention;
- live provider configuration, App permissions, exact-head synchronization,
  check impersonation, and PR-modified verifier/workflow attacks;
- base-version self-development classification, prohibited combination,
  inactive install, canary, activation, and rollback;
- Workspace Project and effective-harness determinism/freshness fixtures;
- all fault/degraded-operation scenarios;
- representative workflow latency, interruption, correctness, regression,
  scope, credential, context, autonomous-completion, evidence-review, and
  comprehension measurements;
- implementation conformance and post-implementation drift/churn review.

Current dynamic evidence remains deliberately narrower: 153 focused existing
tests passed, but concurrency, crash, provider reconciliation, and outage
correctness are implementation acceptance work rather than present proof.

## Implementation Prompt Readiness

The architecture is detailed enough to generate phased implementation prompts
after decision acceptance and strict pre-integration review. Each prompt must
correspond to one coherent Change unit and carry:

- accepted decision IDs and exact promotion targets;
- the relevant phase deliverables and negative controls;
- required validators and retained receipts;
- rollback and narrow-degradation expectations;
- implementation-conformance and drift/churn review requirements;
- refusal to close out while any direct durable path, same-change trust
  violation, failed acceptance target, or proposal back-reference remains.

Prompt generation is currently **not ready and not authorized**. The packet
remains `in-review`, has nine unresolved implementation-readiness findings, has
no proposal-review acceptance receipt, and correctly omits
`support/executable-implementation-prompt.md`.

## Exclusions

- No implementation source, runtime state, provider configuration, credential,
  branch, PR, merge, deployment, release, or activation is changed.
- No claim is made that a broker, signer, external anchor, independent
  verifier App, Workspace Project registry, or two-phase trust-root installer
  is currently deployed.
- No claim is made that the local journal proves authenticity,
  non-repudiation, completeness, or truthfulness.
- No bypass of the live ruleset is claimed; the merge finding concerns
  provenance sufficiency and credential isolation.
- No undocumented provider review, CODEOWNERS, signed-commit, deployment,
  merge-queue, environment, or reusable-workflow field is inferred.
- No concurrency or fault behavior is described as dynamically proven.
- No deleted-history, remote-branch, or external Revision 1 artifact is
  reconstructed.
- No generated proposal registry is refreshed in the materially dirty
  worktree; validation uses the documented packet-only skip for that unrelated
  projection.

## Final Route Recommendation

1. Send `support/external-architect-handoff.md` and the packet to the external
   architect.
2. Record dispositions for AD-01 through AD-12 and EXT-01 through EXT-09.
3. Revise the packet, rerun adversarial review, and bind the completeness
   receipt to the stable artifact-set digest.
4. Run packet validators and strict Pre-Integration Architecture Review on the
   stable packet digest.
5. Record proposal review, advance to `accepted` only on an accepted verdict,
   and then generate route-scoped implementation prompts.
6. Implement Octon-internal phases as coherent Changes; implement provider and
   `.github/**` projections as a separate linked repo-local Change.
7. Retain conformance, fault, performance, provider, activation, rollback, and
   drift receipts.
8. Promote accepted content into durable authorities and archive this packet
   only after proving no durable back-reference remains.
