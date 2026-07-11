# Target Architecture: Trustworthy Autonomy Without Solo-Developer Bureaucracy

## Decision Status

Revision 2 is an in-review target architecture. It is complete enough for the
twelve decisions in `decisions.md` to be approved independently, but it is not
an implementation authorization. The required pre-integration architecture
review and proposal acceptance remain pending.

## Review Charter

| Item | Revision 2 position |
| --- | --- |
| Decision | Where autonomy should be broad, where enforcement must be unavoidable, and which identity owns each consequential transition |
| Product stakeholder | One developer delegating substantial engineering work |
| Operational stakeholders | Operator, model/child agents, runtime maintainer, provider, incident responder |
| Time horizon | Next clean-break pre-1.0 runtime architecture, with a migration that preserves candidate work |
| Risk tolerance | Very low for unauthorized durable effects; ordinary for disposable candidate iteration |
| Non-negotiables | One canonical authority path, proposer/credential separation, narrow fail-closed behavior, retained recovery, proposal non-authority |
| Out of scope | Universal external-system support, mandatory two-person control, remote-only execution, and implementation patches |

## System Job

Octon must let an agent work quickly and independently inside a focused,
reversible project envelope while making durable and consequential transitions
authorized, attributable, recoverable, and understandable to a solo operator.

The essential outcomes are:

1. productive work starts without an approval ceremony;
2. the agent cannot escape project, process, network, or credential boundaries;
3. durable effects are exact-operation and exact-version bound;
4. failures preserve candidate work and block only the unavailable transition;
5. evidence describes effects observed by a trustworthy component;
6. ordinary changes complete with no manual approval;
7. production and trust-root activation remain under operator control; and
8. Octon can improve itself without allowing the changed mechanism to certify
   its own trustworthiness.

## Selected Architecture

### Execution envelope

One canonical authorization establishes an execution envelope. A brokered
`AuthorizedEffect<ExecutorLaunch>` starts a credentialless, disposable project
sandbox. Inside that sandbox, Class A reads, writes, local commits, tests,
builds, patches, and evidence preparation proceed without per-action tokens or
operator interruption.

Class B and Class C transitions leave the sandbox only through typed broker
operations. The agent submits an effect proposal; it never receives the
credential that can perform the effect. The authority engine intersects the
request with the Workspace Project boundary, current Project Profile, effective
harness digest, support posture, policy, approvals, revocations, budget,
rollback, and external state. The broker submits the resulting capability to
the capability ledger only after the authority issuer's request was atomically
registered/exposed. The ledger verifies/reserves; broker validates the lease
and requests irreversible consume/outbox. Independent sources produce
`AttemptLivenessBundle`; evidence store commits attempt-start; ledger
independently re-verifies liveness and returns the sole `AttemptLinkAck`. Only
then can the broker construct/consume the invocation guard, perform or
reconcile the exact operation, and submit origin-authenticated observed facts
for independent final signing.

### Enforcement

The solo-developer default is a hybrid:

- disposable working copy plus a rootless OCI sandbox (native namespaces on
  Linux and a VM-backed container runtime on macOS and Windows);
- a per-user local effect broker outside the agent sandbox;
- credentials held by the broker or platform keystore, never by the model
  process;
- a verifier GitHub App with read/check permission and a separate effect
  GitHub App with narrowly scoped provider-write permission;
- externally anchored broker attestations for Class B and Class C effects.

A dedicated lightweight VM plus privileged sidecar or remote broker replaces
the rootless OCI boundary in the higher-assurance profile. A native host
sandbox may replace OCI only after its host-specific conformance suite is
admitted. Hooks and in-process wrappers remain telemetry and defense-in-depth
only.

### Project and harness

Workspace Project supplies durable identity and maximum locality boundaries.
Project Profile supplies evidence-backed, refreshable observations about the
current checkout. The Governed Harness Factory first emits a deterministic
structural Harness Input Lock without classifying authority. The Policy
Compiler alone classifies effect/risk and emits an exact Harness Compilation
Plan after intersecting project, policy, support, budget, credential, and host
limits. The Factory then deterministically compiles that plan with workflow,
context, validation, and rollback details into the Effective Harness Manifest;
it cannot reinterpret the plan.

Neither artifact authorizes execution. The authority engine binds the exact
effective-harness digest into the grant, and the launch broker verifies that
digest when it installs host controls and starts the executor.

### Trust and evidence

The broker records requests it accepted, operations it attempted, external
state it observed, and reconciliation outcomes as origin-authenticated fact
envelopes. The evidence store verifies and preserves those producer envelopes
inside canonical records. A separate evidence signer signs only normalized
committed records after independently re-verifying every producer signature,
nonce, and digest end to end; an authenticated store channel alone is not
sufficient. The capability ledger alone owns nonce uniqueness,
exclusive reservation, irreversible consume intent, expiry, and revocation
state. The evidence sequence/receipt store alone owns monotonic fact sequence,
attempt/outcome/reconciliation, signature, and anchor state. Brokers perform
and observe effects; neither ledger authorizes or performs them. A separate
anchor writer appends signed heads outside the writable project, and raw
evidence is retained outside Git by default.

Hash chaining remains useful for corruption and internal consistency
detection. Without an independently protected signature and anchor it does not
prove adversarial tamper resistance, authenticity, non-repudiation,
completeness, or truthfulness.

### Merge and self-development

Repository rules and ordinary CI remain necessary, but they do not establish
Octon lifecycle provenance. A required verifier GitHub App check, issued by an
identity the pull request cannot impersonate, verifies exact-head provenance
from externally signed evidence. That verifier identity has no merge
credential. A separate effect App, invoked only by the broker, performs merge
with the expected head SHA.

Ordinary Octon development may complete autonomously only when the previously
trusted classifier proves there is no direct or indirect governance/trust-root
impact; path lists are necessary but insufficient. Governance and trust-root
candidates are built and validated with the previously trusted verifier,
installed into an inactive slot, and
activated separately. A trust-changing change cannot modify or control the only
verifier or activation gate that approves it.

## Revision 1 Corrections

Because the Revision 1 artifact was not available for review, this table preserves or
corrects only propositions represented in the assignment and verified in the
live checkout.

| Proposition | Revision 2 disposition |
| --- | --- |
| `authorize_execution` is the intended engine-owned boundary | Preserve |
| A Run Contract participates in authority | Clarify: it is a governing scope/input artifact; it neither decides nor mints a grant or capability |
| `GrantBundle` is a side-effect token | Correct: it is the authorization decision product; the issuer signs a typed request and ledger `register_issue` separately exposes the capability reference |
| Token verification happens before issuance | Correct: allow decision → grant → signed issuance request → ledger registration/reference exposure → verification/reservation/consumption → effect |
| Lifecycle pre-dispatch proves canonical authority | Correct: current code validates self-described fields and writes a proof; it does not verify a canonical grant or launch token |
| Every file write needs a privileged broker | Reject: disposable Class A writes stay inside the sandbox |
| Hooks can enforce complete mediation | Reject as a sole boundary; retain for telemetry and defense-in-depth |
| The TCB has exactly seven components | Replace with five layered, profile-dependent inventories |
| A local hash chain is adversarially tamper-evident | Qualify: it detects corruption and inconsistent edits; independent signing and anchoring are required for stronger claims |
| Satisfying a GitHub ruleset proves Octon provenance | Correct: ruleset satisfaction and lifecycle provenance are separate facts |
| Provider rules were bypassed | Use only when bypass evidence exists; current observation instead shows an active ruleset with no bypass actors and four required checks |
| Self-development must be prohibited or require a second human | Reject: default solo separation is two-authority/two-identity plus staged activation; a second human is profile-dependent |
| Project and harness compilation can authorize | Reject: both prepare and narrow inputs to canonical authorization |

## Retained Current Strengths

- one declared engine authorization boundary;
- a typed `AuthorizedEffect<T>` / `VerifiedEffect<T>` model;
- run contracts, context packs, rollback posture, support admissions, and
  revocation inputs;
- fail-closed reason codes and retained run evidence;
- a canonical Run Journal with sequence and hash validation;
- a non-authorizing Project Profile preparation layer;
- a non-authorizing task-specific execution harness contract;
- a live provider ruleset requiring exact-SHA-oriented checks;
- self-evolution promotion, approval, and recertification concepts.

Revision 2 integrates these strengths instead of replacing the entire runtime.

## Architecture Boundaries

| Boundary | Inside | Crossing rule |
| --- | --- | --- |
| Candidate sandbox | Class A project work, local Git, local build/test artifacts | One brokered launch; no consequential credential |
| Local durable state | Canonical refs, active control state, retained signed evidence | Class B or C typed capability through local broker |
| Provider | Push, PR, checks, merge, remote refs | GitHub App or provider broker, exact SHA and provenance bound |
| External service | API mutations, publications, deployments | Typed broker adapter; Class B auto-policy or Class C activation |
| Trust epoch | Authority engine, broker, signer, verifier, policy, updater | Previously trusted verification plus separate staged activation |

## Why This Remains Inside the Kernel

The design preserves explicit authority routing before material side effects,
fail-closed handling, evidence obligations, support boundedness, and authored
authority placement. It narrows the definition of *material side effect* by
distinguishing disposable candidate effects from durable effects; it does not
exempt any durable effect from authorization.

The product requirement that safety and throughput are coequal is applied when
choosing among kernel-conformant mechanisms. If a throughput optimization would
violate the constitutional fail-closed floor, it is not an eligible trade.
Conversely, a more restrictive mechanism is not accepted merely for being
restrictive; it must reduce meaningful risk at an acceptable measured cost.

No current decision requires changing constitutional precedence. Any later
implementation that changes the execution-authorization boundary,
fail-closed obligations, evidence obligations, or self-evolution approval
rules must stop and use the constitutional-challenge route.

## Detailed Design

- Canonical authority and failure semantics:
  `authority-and-failure-model.md`
- Effect classes and enforcement topology:
  `governance-and-enforcement.md`
- Layered TCB: `trusted-computing-base.md`
- Identities, evidence, merge provenance, and self-development:
  `identity-evidence-merge-self-development.md`
- Workspace Project and Governed Harness Factory:
  `workspace-project-and-harness-factory.md`
- Workflow and usability targets: `performance-and-workflows.md`
- Independently approvable records: `decisions.md`

## Final Verdict

**Proceed to independent decision review.** Unresolved architecture questions:
zero. Formal acceptance blockers: operator disposition of the twelve decisions
and a passing strict pre-integration architecture review.
