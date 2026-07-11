# Performance, Usability, and Representative Workflows

## Decision Summary

Octon's safety controls are acceptable only when ordinary engineering remains
fast and interruption-free. Restriction alone is not success.

The default solo-developer outcome is:

- zero blocking approvals for Class A and policy-eligible Class B work;
- zero manually authored governance artifacts for ordinary changes;
- one consolidated operator activation for a default Class C transition;
- subsecond warm harness compilation;
- local edit/build/test/commit loops without broker round trips;
- automatic durable transitions when policy and evidence permit;
- failures that preserve work and block only the unavailable consequential
  transition.

The targets in this document are initial acceptance targets. They require
baseline instrumentation before becoming release gates; they are not claims
about current measured performance.

## Measurement Definitions

### Operator Interruption

A blocking request that requires operator input before the run can continue.
Asynchronous notifications, end-of-run summaries, and optional review views do
not count.

### Manual Approval

An operator decision that authorizes a consequential transition. Supplying the
initial objective or answering a genuine product question is not counted as a
governance approval, but it is counted separately as operator input.

### Octon-Added Latency

Elapsed time added by:

- project/profile selection and freshness checks;
- harness compilation;
- authority evaluation;
- sandbox launch;
- broker verification, receipt, and reconciliation;
- Octon-specific CI checks.

It excludes:

- model inference;
- project build/test execution;
- provider queueing and provider-native processing;
- deployment execution;
- deliberate policy hold periods.

### End-to-End Merge Latency

Elapsed wall time from an exact candidate head with all project-native required
checks and Octon provenance inputs available to the broker's reconciled
observation that the expected target ref contains that head. It includes Octon
verification, broker work, provider queueing/native merge processing, and
reconciliation. Human review wait and deliberate policy holds are reported
separately. The Octon-added slice and total merge latency are both retained.

### False Denial

A denied request later proven valid without changing its intent, effect, scope,
bound source SHA, governing policy, or required evidence. Fixing missing or
incorrect evidence does not make the original denial false.

### False Approval

Any performed effect that violates the effective scope, policy, revocation,
credential, exact-SHA, target, expiry, or effect-class constraints that should
have denied it. The numerator is confirmed violating effects. The denominator
is every performed Class B/C effect plus every mutation/fault-injection
admission trial in the supported release corpus. Production and adversarial
denominators are reported separately and together; denied trials are not
discarded.

### Autonomous Completion

The requested terminal outcome is reached without blocking operator input after
the initial objective, excluding a predeclared Class C activation.

### Automatically Authorized Consequential Effect

A policy-eligible Class B effect for which the authority engine issued a grant
and the broker completed or safely reconciled the effect without operator
approval.

## Representative Workflow Matrix

Notifications are non-blocking and are not included in the interruption count.

| Workflow | Actions performed without interruption | Automatically brokered effects | Automatic non-broker gates | Actions requiring operator approval | Expected blocking interruptions | Initial Octon-added latency target | Failure and recovery behavior |
|---|---|---|---|---|---:|---|---|
| 1. Small bug fix | Project selection, code search, edit, local build/test/lint, local commits, diff self-review, candidate evidence | Promote exact candidate commit; push governed ref; open/update the PR; publish retained evidence; policy-eligible exact-SHA merge; cleanup | Required CI, policy/freshness evaluation, and independent provenance verification | None | 0 | Warm start to productive work ≤15 s; local Octon overhead ≤3 s total; durable transition overhead ≤60 s beyond native CI/provider | Failed local validation stays in Class A loop. Failed CI leaves candidate/branch intact. Broker/provider outage preserves the candidate and blocks only publish/merge. Reconcile exact SHA before retry. |
| 2. Multi-file refactor | Full refactor and test loop, code generation, local commits, rollback rehearsal, local dependency graph analysis | Branch promotion/push; PR creation/update; retained-evidence publication; eligible merge; cleanup | Impact/scope classification, exact-SHA CI, independent verifier, and rollback validation | None unless scope enters a Class C or unresolved cross-project boundary | 0 | Local Octon overhead ≤5 s; durable transition overhead ≤60 s beyond CI | Scope expansion triggers harness recompile, not loss of work. An overlap or stale profile blocks only affected paths/transition. Preserve all commits and provide the shortest repair route. |
| 3. New feature | Design within the supplied objective, implementation, tests, documentation, local commits, candidate preview | Governed branch/PR mutation; reversible preview publication; retained evidence; policy-eligible merge | Product acceptance tests, CI, policy evaluation, and independent provenance verification | Genuine unresolved product decision, new consequential credential/egress, or Class C activation only | 0 normally; at most 1 when a material product or Class C decision is genuinely missing | Local Octon overhead ≤10 s; durable transition overhead ≤90 s beyond CI/provider | Emit one consolidated decision request rather than repeated prompts. Candidate work remains resumable. Missing external service blocks only integration/activation; mocks and local tests continue. |
| 4. Long-running mission | Slice planning inside mission bounds, implementation, builds/tests, local checkpoints, bounded child agents, local commits, recovery rehearsal | Exact-SHA branch checkpoints; signed-head anchor publication; mission-state publication; policy-eligible PR updates/merges | Per-slice harness compilation, validation, policy/revocation checks, and independent provenance verification | Envelope renewal after declared expiry, material scope change, or Class C transition | 0 per ordinary slice; no more than 1 per declared renewal period | Warm harness compile ≤1 s per slice; Octon overhead ≤2% of mission wall time excluding model/build/provider time | Broker/provider outage does not stop safe local slices. Revocation stops affected executor/children and preserves candidate state. Failed slice retries from last trusted checkpoint; no blind replay of unknown external effects. |
| 5. Low-risk autonomous pull-request completion | Inspect PR/review context, implement fixes, run tests, create local commits, self-review diff/policy/rollback | Push exact head; update PR/review evidence; mark ready; request/perform exact-SHA merge; post-merge containment and cleanup | Required CI, review-state observation, policy/revocation evaluation, and independent App verification | None when all policy, exact-SHA, review, and verifier conditions pass | 0 | Octon overhead ≤60 s beyond provider/check latency | Red checks return to candidate correction loop. Unresolved human objection remains open and blocks only ready/merge. Stale head forces rebind/revalidate. Unknown merge result is reconciled against provider state before retry. |
| 6. Production change | Plan, build, test, simulate, stage candidate, rollback/compensation rehearsal, inactive artifact creation | Reversible staging upload; approved exact-artifact activation/deployment; observation; evidence anchoring; authorized automatic rollback/compensation | Independent verification, environment/precondition checks, policy evaluation, and post-activation health gates | One consolidated production activation in default profile; higher-assurance policy may require a second human | 1 default | Pre-activation Octon overhead ≤2 min, excluding deployment/provider and deliberate hold | Any missing verification or uncertain target blocks activation only. Previous release remains active. Failure triggers automatic rollback or declared compensation; outcome-unknown state is reconciled before any retry. |
| 7. Ordinary Octon self-development | Edit non-trust-root Octon surfaces in disposable workspace, run tests/validators/fault scenarios, local commits, candidate package | Governed branch/PR; eligible exact-SHA merge; inactive staging/install; ordinary evidence publication | Previous-trusted-version classification, candidate tests, exact-SHA CI, and independent App verification | None when classification proves no trust-root or governance-activation impact | 0 | Octon overhead ≤90 s beyond CI/provider | Installed trusted runtime remains active. Misclassification or protected-surface discovery reclassifies the durable transition without discarding candidate work. Failed staged install rolls back automatically. |
| 8. Octon trust-root modification | Candidate implementation, adversarial and fault-injection tests, migration/rollback rehearsal, inactive build | Governed branch/PR; inert exact-SHA merge; inactive artifact publication; evidence anchoring; approved activation and automatic rollback | Previous-trusted/base verifier, reproducible build, independent App, prohibited-combination gate, shadow/canary, and health checks | One explicit operator activation after independent verification; stricter profile may add second-human approval | 1 default | Pre-activation Octon overhead ≤5 min, excluding CI and deliberate delay | The same change cannot control the only verifier or gate. Failed verification or missing anchor prevents activation. Previous trusted version remains installed; activation failure automatically restores it and retains incident evidence. |

## Workflow Details

### 1. Small Bug Fix

Expected path:

~~~text
launch candidate envelope
-> inspect/edit/test/commit repeatedly
-> exact-SHA validation
-> automatically broker selected durable route
-> merge when policy allows
-> concise notification
~~~

No approval is required for an ordinary low-risk bug. Revision 2 routes the
durable transition through an automatically opened PR so the trusted
provenance/check/invalidation protocol applies. Direct-main/no-PR is not an
admitted target route; the model receives no push credential.

### 2. Multi-File Refactor

Refactor size does not automatically create manual governance. Escalation occurs
only when actual effects cross:

- project boundaries not already in the Run Contract;
- protected/trust-root surfaces;
- new credentials or egress;
- irreversible migration;
- insufficient rollback or validation.

An affected boundary can pause promotion while local refactoring and tests
continue within the original envelope.

### 3. New Feature

Normal feature development remains zero-approval after the objective and
acceptance criteria are supplied. Octon should consolidate missing product,
security, data, or external-service decisions into one operator request rather
than interrupting at each downstream action.

### 4. Long-Running Mission

The mission identity scopes and records continuity; it authorizes nothing.
Each slice receives a fresh run/harness binding. Local checkpoint frequency
should be cheap; external branch
checkpoints and evidence anchors are automatically brokered and batched.

Mission interruption budget:

- zero blocking governance prompts per ordinary slice;
- at most one consolidated renewal request per declared renewal period;
- immediate notification, not approval, for automatic Class B checkpoints;
- Class C transition remains a distinct activation.

### 5. Low-Risk Autonomous Pull-Request Completion

The agent may autonomously:

- address actionable review findings;
- commit and push exact-head corrections through the broker;
- reply with evidence;
- move draft to ready;
- request or execute the protected merge route;
- verify origin containment and clean up.

This is eligible only when the trusted verifier binds the exact head and all
policy conditions. GitHub ruleset satisfaction alone does not prove Octon
lifecycle provenance.

### 6. Production Change

Implementation and staging are separated from activation:

~~~text
candidate implementation
-> independent validation
-> inactive staging
-> one consolidated operator activation
-> observation
-> automatic rollback/compensation if required
~~~

The approval packet should fit one concise view: artifact, environment, exact
source, validations, risk, rollback, evidence anchor, and expiry.

### 7. Ordinary Octon Self-Development

Ordinary self-development includes changes that do not modify or activate the
authority engine, effect broker, signer, verifier, sandbox/launcher, CI trust
gate, support admission logic, installer/update trust, or equivalent
trust-root semantics.

It remains eligible for zero-interruption autonomous completion when a
previously trusted verifier confirms classification and validation.

### 8. Octon Trust-Root Modification

Trust-root modification uses two phases:

1. Implement, validate, merge, and publish an inactive candidate.
2. Independently verify and explicitly activate that exact artifact.

One consolidated operator activation is the default solo profile. Independent
software identities, keys, previously trusted verifier releases, and staged
activation provide the other authority. A high-assurance profile may require a
second human.

## Initial Solo-Developer Acceptance Targets

| Metric | Initial target | Measurement scope |
|---|---:|---|
| Time to productive work, warm supported repository | p95 ≤15 s | Invocation to writable candidate workspace and first executor action |
| Time to productive work, first supported-repository adoption | p95 ≤5 min | Excludes dependency/tool installation and explicit trust-root enrollment |
| Blocking interruptions per ordinary run | median 0; p95 ≤1 | Class A and policy-eligible Class B workflows |
| Manual approvals per ordinary change | 0 | Bug, refactor, normal feature, low-risk PR, ordinary Octon self-development |
| Manual approvals per default Class C activation | 1 consolidated | Excludes optional second-human profile |
| Warm harness compilation | p50 ≤250 ms; p95 ≤1 s | Complete cached-input compilation and digest |
| Cold harness compilation | p95 ≤5 s | Excludes model inference and dependency download |
| Sandbox/candidate launch | p95 ≤1 s | Workspace ready through contained process start |
| Local broker decision and receipt | p95 ≤25 ms | Excludes performed effect |
| Local durable-effect wrapper overhead | p95 ≤250 ms | Excludes Git/provider execution |
| Remote broker wrapper overhead | p95 ≤750 ms | Excludes provider-native processing |
| Octon-specific CI critical-path addition | p95 ≤60 s and ≤10% of total CI time | Exact-SHA verifier and Octon policy checks |
| Eligible low-risk merge and reconciliation latency | p95 ≤5 min under nominal provider availability | Exact head/check inputs ready through reconciled target ref; includes provider-native time |
| False-denial rate | ≤2% | Otherwise valid supported ordinary transitions |
| False-approval rate | 0 observed (0% sample rate); one-sided 95% upper confidence bound ≤0.1% after at least 3,000 mutation/fault trials; any confirmed event blocks release | Includes policy, scope, target, expiry, revocation, credential, and exact-SHA errors |
| Broker revocation enforcement | p95 ≤1 s | Canonical revocation commit to denial of every new broker/launch request |
| Executor termination after applicable revocation | p95 ≤5 s | Canonical revocation commit to launch-broker process-tree termination and credential withdrawal |
| Candidate recovery time | p95 ≤60 s | Resume from preserved candidate after process/broker/provider failure |
| Unknown external-effect reconciliation | p95 ≤5 min | Determine actual state or exact safe operator route |
| Class B automatic rollback where claimed | p95 ≤10 min | Detection to restored postcondition |
| Trust-root rollback | p95 ≤15 min | Activation failure to previous trusted active version |
| Ordinary Octon control-context tokens | p95 ≤12,000 | Governance/context overhead, excluding task source code chosen on demand |
| Long-mission control-context tokens | p95 ≤25,000 per slice | Includes mission/run/harness context |
| Trust-root control-context tokens | p95 ≤40,000 | Includes independent verification packet |
| Manual artifacts required | 0 manually authored artifacts for ordinary work and default Class C | Receipts, manifests, activation packets, and summaries are generated; the separate approval-action metric still permits one planned Class C activation decision |
| Ordinary evidence-review burden | p95 ≤2 min | Operator can understand effect, status, and rollback |
| Class C evidence-review burden | p95 ≤10 min | Consolidated activation packet |
| Ordinary autonomous-completion rate | ≥85% | Supported bug/refactor/feature/PR/self-development tasks |
| Long-mission slice autonomous-completion rate | ≥75% | Slices reaching requested terminal state without blocking input |
| Eligible Class B effects automatically authorized | ≥90% | Policy-eligible denominator only |
| Task correctness | ≥90% acceptance-test success and no reduction versus baseline | Matched task suites with/without Octon controls |
| Post-merge regression rate | <3% | Supported ordinary autonomous merges |
| Scope violations | 0 | Any read/write/process/network effect beyond envelope |
| Credential exposure or unmediated credential use | 0 | Includes environment, files, sockets, metadata, logs |
| Operator comprehension | ≥90% within 2 min | Identify what changed, why, current state, and rollback |

Targets should be recalibrated only with retained measurements and an explicit
decision. A security control that misses the latency or interruption target must
show the meaningful risk reduction that justifies its cost.

## Instrumentation Requirements

### Harness Factory

Record:

- project/profile discovery and freshness duration;
- each compilation stage duration;
- cache hit/miss;
- input and output digest;
- sandbox installation and executor-launch duration;
- invalidation reason.

### Authority Engine and Broker

Record:

- decision latency;
- allow/deny reason;
- queue duration;
- capability verification/consumption latency;
- effect execution latency;
- external reconciliation latency;
- exact-head-ready, verifier-complete, merge-request, provider-response, and
  reconciled-target timestamps;
- revocation commit, broker observation, credential withdrawal, and process
  termination timestamps;
- retry and idempotency outcome;
- rollback/compensation duration.

### Run and Mission Journal

Record:

- blocking interruption count and reason;
- operator approval count and class;
- automatic Class B effect count;
- denied effect and shortest recovery route;
- candidate preservation/recovery events;
- child launches and rework;
- final requested versus actual outcome.

### Context and Evidence

Extend the token ledger or an adjacent non-authoritative measurement artifact to
record:

- actual provider usage when available;
- model-visible governance/context tokens;
- repeated-source ratio;
- evidence generated and retained;
- operator summary length;
- compaction and raw-retention tier.

### Quality and Usability

Record:

- acceptance-test result;
- post-merge regression/rollback;
- scope or credential incident;
- autonomous-completion result;
- operator comprehension time;
- manual artifacts and manual repair steps;
- evidence-review time.

## Denominators and Anti-Gaming Rules

- Report median, p95, sample size, support profile, host, and workflow class.
- Do not hide denied or abandoned runs from the false-denial denominator.
- Do not count ineligible Class C effects against Class B automatic
  authorization.
- Do not count a notification as an interruption.
- Do count repeated requests for the same missing decision as repeated
  interruptions.
- Do not report a staged, pushed, open-PR, or ready state as autonomous terminal
  completion when the requested outcome was landed or activated.
- Do not count model/build/provider latency as Octon overhead, but report total
  wall time alongside it.
- A false approval or scope/credential violation is release-blocking regardless
  of average latency or completion rate.
- Token reduction may not remove required authority or safety inputs.

## Failure and Recovery Acceptance Scenarios

The workflow benchmark must include:

1. local candidate process crash;
2. stale Project Profile during a run;
3. sandbox launch failure;
4. local broker outage;
5. broker recovery with a queued exact-SHA request;
6. network/GitHub outage;
7. effect attempted with outcome unknown;
8. receipt missing after externally successful effect;
9. revocation during a long-running executor and child process;
10. failed CI after automatic branch publication;
11. production activation failure and rollback;
12. trust-root verifier or signer outage.

For each scenario verify:

- completed candidate work is preserved;
- unrelated Class A work continues where safe;
- only the unavailable consequential transition blocks;
- no blind retry occurs after an unknown outcome;
- the denial names reason, policy, evidence, and shortest safe recovery route;
- recovery meets its time target.

## Release Gate and Solo-Administrator Test

The default profile is not ready for general solo-developer use unless a
representative benchmark demonstrates:

- zero ordinary manual approvals;
- zero ordinary manual governance artifacts;
- median zero blocking interruptions;
- warm harness compilation and broker targets;
- safe offline/degraded Class A continuation;
- automatic handling of at least 90% of eligible Class B transitions;
- no false approvals, scope violations, or credential exposure;
- operator summaries understandable within two minutes.

If those conditions fail, the mechanism must be simplified, automated, narrowed,
or removed unless retained evidence demonstrates that its risk reduction
justifies the operational cost.

The product question is therefore answered conditionally:

> One developer can operate Octon without becoming Octon's full-time governance
> administrator only when governance artifacts are generated, ordinary work is
> zero-approval, durable reversible effects are automatically brokered, and
> strong controls remain concentrated at irreversible and trust-root
> boundaries.
