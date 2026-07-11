# Identity, Evidence, Merge Provenance, and Safe Self-Development

## Decision Summary

Octon should separate the identity that proposes work from the identities that
authorize, perform, attest, verify, merge, and activate it. The default solo
profile uses one human with several non-interchangeable software identities and
keys. It does not require a second person for ordinary development.

The target model has four linked rules:

1. the model and delegated children possess no unmediated consequential
   credential;
2. the authority engine can issue grants but cannot perform effects;
3. the broker can perform a typed effect but cannot authorize it or sign the
   final evidence attesting to it; and
4. a trust-changing candidate cannot control the only verifier or activation
   gate that accepts the change.

This concentrates strong separation at durable and trust-root boundaries while
leaving candidate edit/build/test/commit loops uninterrupted.

## Current-State Facts and Qualifications

### Current identity and credential facts

- Constitutional ownership currently defines human, harness, and model role
  classes. It states that the model must not approve, revoke, grant exceptions,
  widen support, authorize irreversible actions, or perform final consequential
  acceptance
  (`.octon/framework/constitution/ownership/roles.yml:3-78`).
- Connector credential policy declares `none`, `read_only`, and
  `write_scoped` credential classes. Credentialed classes are
  `externally_managed`, require retained evidence, and do not authorize
  execution
  (`.octon/instance/governance/policies/connector-credentials.yml:1-35`).
- These are role and policy declarations. The repository does not yet define
  independently authenticated process identities and key custody for the run,
  mission, effective harness, executor, authority engine, effect broker,
  evidence signer, CI verifier, and child agent.
- `AcpAttestation.signature` is an optional string. The policy engine counts
  non-empty values and checks required roles; it does not perform a
  cryptographic signature verification in that path
  (`.octon/framework/engine/runtime/crates/policy_engine/src/lib.rs:658-672,2586-2609`).
- The retained self-evolution approval grant identifies its issuer with the
  string `operator://octon-governance`; the current gate checks issuer presence,
  not cryptographic proof of control
  (`.octon/state/control/execution/approvals/grants/grant-evolution-promotion-v5-validation.yml:1-9`;
  `.octon/framework/engine/runtime/crates/kernel/src/commands/evolution.rs:852-925`).

These facts support the intended authority separation but do not prove that the
separation is currently enforced by different OS identities, services,
credentials, or keys.

### Current evidence facts

- The canonical Run Journal is sequence ordered and SHA-256 hash linked. The
  writer validates prior sequence and hashes before append
  (`.octon/framework/engine/runtime/spec/run-journal-v1.md:45-63`;
  `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs:505-538`).
- The event hash is unkeyed. The writer appends the event and then rewrites the
  manifest; no separate evidence signer or external head anchor participates in
  that write path
  (`.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs:384-427,1658-1687,1778-1823`).
- The evidence-store contract correctly separates control truth, retained
  evidence, transport artifacts, private raw evidence, compact views, and
  generated read models
  (`.octon/framework/engine/runtime/spec/evidence-store-v1.md:30-64,106-170`).
- The `external-replay-index-v1` schema requires a digest and locator, but no
  signature, signer identity, anchor sequence, witness, conditional-create
  proof, or retrieval proof
  (`.octon/framework/constitution/contracts/retention/external-replay-index-v1.schema.json:35-102`).
- The authority-engine writer records `immutable://` locators but hashes the
  local replay manifest and trace-pointer files; it does not upload the named
  `bundle.jsonl` or `trace.jsonl` in that path
  (`.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs:4831-4913`).
- A second run writer records values such as `sha256:$run_id` and
  `sha256:$run_id-trace`, which are identifiers rather than content digests
  (`.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh:1079-1127`).

The qualified current claim is therefore: the journal and manifests provide
useful corruption, ordering, and internal-consistency detection when compared
with a trusted expected head. They do not, by themselves, prove adversarial
tamper resistance, authenticity, non-repudiation, completeness, or the truth of
the recorded effect.

### Provider facts

A live read-only query on July 10, 2026 captured selected fields from ruleset
`12881449`. The response digest and exact command are retained in the Required
Evidence Appendix.

| Field | Live observed value |
| --- | --- |
| Repository | `jamesryancooper/octon` |
| Ruleset ID | `12881449` |
| Name | `Main Branch Guardrails (Change Route + CI)` |
| Target | `branch` |
| Enforcement | `active` |
| Included ref | `~DEFAULT_BRANCH` |
| Deletion rule | present |
| Non-fast-forward rule | present |
| Required linear history | present |
| Required status policy | `strict_required_status_checks_policy: true` |
| Enforce on create | `do_not_enforce_on_create: false` |
| Required context | `route_neutral_closeout_validation`, integration ID `15368` |
| Required context | `branch_naming_validation`, integration ID `15368` |
| Required context | `route_aware_autonomy_validation`, integration ID `15368` |
| Required context | `exact_source_sha_validation`, integration ID `15368` |
| Bypass actors | `[]` |
| Current queried user bypass | `never` |

The selected live response contains no `pull_request` rule and no fields
proving required reviews, CODEOWNERS review, resolved conversations, signed
commits, deployments, merge queue, environment approval, required reusable
workflows, or the human-readable owner/name of integration ID `15368`.
Revision 2 makes no claim about controls absent from the response. It also does
not infer that integration ID `15368` is an independently deployed Octon
verifier merely because the checks are integration-bound.

The May 4, 2026 retained export at
`.octon/state/evidence/control/execution/github-rulesets/2026-05-04-route-neutral-main-migration/post-migration-main-ruleset.json`
provides a historical comparison. Provider state remains mutable after the live
capture, so admission must re-query and retain the relevant configuration at
the consequential transition.

### Current merge-provenance limitation

The required status contexts are useful provider gates, but their current
implementations do not establish full Octon provenance:

- `exact_source_sha_validation` verifies a 40-character commit and, when no
  receipt is supplied, reports success after confirming that the commit exists
  (`.github/workflows/change-route-projection.yml:124-165`).
- It does not require or bind the Run Contract digest, grant, typed effect,
  effective harness, policy/runtime versions, support tuple, capability
  envelope, validation bundle, rollback posture, signed evidence root, expiry,
  or revocation state.

This is not evidence that GitHub's ruleset was bypassed. It is evidence that a
change can satisfy the currently observed ruleset without the ruleset proving
Octon lifecycle provenance.

### PR-head credential hazard

The current automatic merge path has a trust-root defect that must be corrected
before it becomes a target-state boundary:

1. The workflow exposes `AUTONOMY_PAT || GITHUB_TOKEN` to the auto-merge step
   (`.github/workflows/pr-auto-merge.yml:117-120`).
2. It fetches and checks out the pull-request head
   (`.github/workflows/pr-auto-merge.yml:274-288`).
3. It then executes the checked-out
   `.octon/framework/assurance/runtime/_ops/scripts/protected-ci-auto-merge.sh`,
   whose wrapper builds and runs the checked-out kernel
   (`.github/workflows/pr-auto-merge.yml:324-330`;
   `.octon/framework/assurance/runtime/_ops/scripts/publication-wrapper-common.sh:163-188`).
4. The kernel's approval projection contains only optional approval request and
   grant refs plus `approval_granted`
   (`.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:1374-1382`).
5. It checks that referenced approval files exist, then constructs a new
   request bound to repository/PR but not the PR head SHA
   (`.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:1429-1516`).
6. The merge invocation does not include an expected-head SHA precondition
   (`.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:1576-1592`).

Forks are excluded, but a model-controlled same-repository branch remains
candidate code. Candidate code must never execute under a provider write,
grant-signing, evidence-signing, release-signing, vault, or activation
credential.

### Current self-development facts

- The self-evolution program forbids autonomous constitutional amendment,
  support widening, connector admission, AI-only quorum, and
  `self_modifying_runtime`; it requires human or quorum approval
  (`.octon/instance/governance/evolution/programs/octon-self-evolution/program.yml:15-36`).
- The promotion runtime is intentionally a readiness gate. `promote apply`
  reports `already_applied`, `ready_to_apply`, or blocked and says a governed
  run is still required for material change
  (`.octon/framework/engine/runtime/spec/promotion-runtime-v1.md:3-11`;
  `.octon/framework/engine/runtime/crates/kernel/src/commands/evolution.rs:425-468`).
- The current implementation reads `proposal_status` directly from the
  promotion record rather than resolving an independently protected proposal
  status source
  (`.octon/framework/engine/runtime/crates/kernel/src/commands/evolution.rs:1057-1063`).
- The retained validation promotion declares as targets the evolution kernel,
  its validator and tests, quorum policy, approval request/grant, evolution
  control/evidence, recertification, and promotion receipt families
  (`.octon/state/control/evolution/promotions/evolution-promotion-v5-validation.yml:40-73`).

The current concepts are valuable, but a file-backed readiness gate and
self-described approvals/recertification do not yet create an independently
installed old-verifier/new-candidate activation boundary.

## Target Identity and Credential Matrix

The governing invariant is:

> The entity proposing an effect must not possess an unmediated credential
> capable of performing that effect.

“Entity” means the authenticated principal and credential context, not merely
the natural person. One solo operator therefore uses a credentialless
proposal/session principal and a distinct approval principal. The
approval context may approve only an immutable digest-bound request prepared
before that context opens; it cannot originate, edit, rebuild, or substitute
the payload. Closing the approval context destroys its short-lived session and
returns the person to the proposal context. A third independently revocable
break-glass context can only stop/revoke/isolate or restore a predeclared
last-trusted state; it cannot approve normal activation.

| Identity | May propose | May authorize | May perform | Credentials possessed | Evidence it may write | What it may modify | Revocation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Human proposal/session identity | Any candidate, effect request, exception request, policy/trust-root candidate, activation request, or rollback proposal. | Nothing. | Ordinary operator navigation/review and credentialless candidate work; it cannot perform the proposed durable effect. | Human login/session identity only; no activation, break-glass, release, provider-effect, or production credential in this context. | Untrusted proposal rationale, annotations, and requested target/digest. | Candidate/proposal artifacts only. | Close session, disable account, or revoke session identity. |
| Operator approval identity | Nothing; it accepts only a sealed request digest from the proposal context and cannot originate or alter payloads. | Supplies exact-digest `OperatorApprovalInput` for Class C, exception, or activation policy; it does not emit Octon authorization, grant, capability, or steady-state pointer mutation. | Signs approve/deny/revoke input. Only the bounded first-epoch bootstrap may directly verify that signature; steady-state installer/broker requires a ledger-registered typed capability from `authorize_execution`. | Separate approval key, preferably hardware-backed, exposed only in the isolated approval context; no break-glass/effect credential. | Signed approval/denial/revocation/risk input bound to request/payload digest and expiry. | No candidate payload or steady-state pointer; first-epoch bootstrap applies only its exact prevalidated digest. | Revoke/rotate key, close approval context, disable identity. |
| Break-glass recovery identity | Nothing and cannot approve ordinary activation/feature effects. | Emergency stop/revoke/isolate/restore-last-trusted directive only; it is the explicit bounded emergency authority, not the normal canonical path. | Directly stops services, revokes keys/Apps/grants, isolates targets, or restores an already retained last-trusted slot under incident policy. | Separate hardware recovery key/context, never loaded with proposal or ordinary approval sessions. | Signed emergency directive, exact recovery target, reason, expiry, actions, and exit receipt. | Revocation/safe-mode/service pointer only to a predeclared last-trusted target; no new candidate activation. | Rotate/revoke key, exercise independent recovery, and require incident exit review. |
| Model process | Plans, patches, candidate commands, effect requests, tests, summaries, and recovery suggestions. | Nothing. | Class A work inside the sandbox. | No consequential credential, provider token, signing key, vault socket, SSH agent, cloud metadata, or host keychain access. | Candidate logs, reports, patches, and claimed results, all classified as untrusted source material. | Run-owned disposable filesystem/Git database only. | Kill process/session and revoke its executor identity. |
| Run identity | The run's bounded action sequence and effect proposals through its executor. | Nothing. | Nothing independently; it scopes calls made by the executor/broker. | Signed/leased run identity and correlation secret or OS credential only. | Namespaces journal, capability, measurement, intervention, and disclosure records. | No authored authority; run-owned candidate/control state through owning services. | Close, expire, or revoke run; deny all new capabilities. |
| Mission identity | Long-horizon objectives, queue items, continuation proposals, and child run candidates. | Nothing. Mission continuity never substitutes for execution authorization. | Nothing independently. | Mission identity/lease; no effect credential. | Continuity, queue, budget, handoff, and mission-to-run lineage. | Mission control/continuity through canonical runtime only. | Revoke/expire mission lease; cancel queued runs. |
| Effective harness identity | A compiled tool, context, validation, rollback, and sandbox manifest. | Nothing. | Nothing. The launch broker installs it after binding. | Content digest and compiler identity only. | Harness manifest, compiler receipt, freshness, and source digest map. | Nothing after issuance; it is immutable and disposable. | Revoke digest/compiler release or compile a successor. |
| Lifecycle executor | Child/run execution proposals and broker requests within the bound harness. | Nothing. | Validates request-owned preconditions, coordinates Class A execution, and submits child requests; only the launch broker creates a process after a new or narrower `ExecutorLaunch`. | Executor process identity and sandbox lease; no process-launch or durable-effect credential. | Candidate execution telemetry; trusted launch/termination facts come from the launch broker. | Candidate worktree and temporary/cache roots only. | Revoke its lease and launch capability; the launch broker terminates the process tree. |
| Launch broker | Nothing; it accepts an immutable lifecycle request and canonical capability reference. | Nothing; it may narrow or deny but cannot issue grants/capabilities. | Request verification/reservation of `ExecutorLaunch`, install controls, request consume/outbox/attempt/link, consume invocation guard, create/terminate child, and observe outcome. | Launch-broker service/origin-authentication identity and host process/isolation privilege; no provider-effect, grant, or final evidence-signing credential. | End-to-end origin-authenticated launch intent, control-install, process identity, termination, and revocation fact envelopes to the evidence store. | Run-owned sandbox/process state only. | Stop service, revoke identity/capability/origin key, terminate descendants, activate previous trusted launcher release. |
| Canonical authority engine | Decision and grant records derived from governing inputs plus exact typed capability issuance requests. | Sole issuer of canonical authorization decisions and `GrantBundle`; signs typed issuance requests but cannot make them usable without ledger `register_issue`. | No privileged effect. | Grant/capability-issuer key; policy/control read identity; no provider/effect/signing-of-evidence key. | Signed authority decision, grant, issuance request, denial reasons, missing evidence, and shortest safe recovery route. | Authority decision records only through its service. | Revoke issuer/policy version, enter deny/safe mode, activate previous release. |
| Transactional capability ledger | Nothing. | Nothing; it cannot decide policy or grant and cannot widen an issuer-signed payload. | Atomically register/expose issuance, own active lineage/generation, reserve/consume/recover, and independently verify `AttemptLivenessBundle` plus attempt receipt before one evidence-attempt link; no external effect. | Ledger service/origin-authentication identity and protected authority/broker IPC; no grant, effect, provider, or final evidence-signing credential. | Origin-authenticated canonical capability/outbox/recovery/link envelopes; attempt/outcome truth remains in evidence store. | Protected capability database only. | Stop service, revoke IPC/origin identity, restore verified snapshot/previous release, and deny new registration/reservations during recovery. |
| Effect broker | Nothing beyond observed reconciliation/recovery suggestions. | Nothing; it may narrow or deny an invalid capability. | Class B and Class C effects exactly as encoded by invocation guard. | Broker service/origin-authentication identity and just-in-time effect credentials from vault; no grant or final evidence-signing key. | End-to-end origin-authenticated intent, observed result, reconciliation-request, and rollback-handle fact envelopes. | Exact canonical/provider/external target allowed by capability. | Stop broker, revoke JIT credential/App/origin key, revoke capability, roll back service version. |
| Evidence store | Nothing. | Nothing. | Verify producer origin envelopes; atomically append canonical facts, sequences, signature state, and anchor state through typed APIs. | Store service identity and protected database access; producer public verification keys; no producer private, effect, grant, final-signing, or anchor credential. | Canonical unsigned append-only records retaining producer signatures/nonces/digests and recovery lineage. | Its transactional evidence database only. | Stop writes, activate previous store release/snapshot, revoke service identity, run recovery verification. |
| Attempt-liveness attestors/assembler | Fresh operation-bound liveness bundle only; no effect proposal. | Nothing. | Read and attest governing/revocation/clock, credential-handle metadata, and exact target preconditions; assemble/verify without performing the effect. | Separate origin-authentication keys; target observer read-only credential where needed; no effect/grant/final-evidence key or secret handle. | Origin-authenticated sub-attestations and `AttemptLivenessBundle`. | Attestation output only. | Revoke source/assembler identities, expire bundles, activate prior trusted versions. |
| Evidence signer | Nothing. | Nothing. | No underlying effect. | Dedicated final evidence-signing key, producer public verification keys, and authenticated read channel to committed evidence-store facts/envelopes. | Signed effect/recovery receipt, compaction manifest, and journal-head envelope after end-to-end origin verification. | Signed-envelope/head output only; it has no anchor-store credential. | Revoke/rotate signer key; freeze affected evidence interval; activate old signer. |
| External anchor writer | Nothing. | Nothing. | Append an already signed head under the originating fixed finalization obligation to the configured conditional-create/WORM or transparency-log target. | Consequential append-only anchor credential with no delete/update; no underlying business-effect/provider-mutation, grant, or signer key. | External anchor object/log entry and provider response returned to evidence store. | New bound anchor entries only. | Revoke writer credential, rotate anchor generation/provider, preserve and cross-anchor the old generation. |
| Independent provenance verifier | A digest-bound `ControlPlaneEmissionRequest` derived from the full mandatory provenance tuple and signed verdict. | Nothing; its verdict does not itself authorize provider mutation or merge. | Read/verify provider metadata, signed evidence/anchors/revocations, and produce the signed verdict without executing candidate code. | Verifier signing/service identity and read-only metadata/evidence access; no checks-write, merge, content-write, or candidate-execution credential. | Signed full-tuple verdict, expiry, invalidation sources, and emission request. | Evidence output only. | Revoke verifier release/key, invalidate dependent emission capabilities/checks, activate previous verifier. |
| Verifier GitHub App | Nothing beyond the already authorized bound emission/obligation request. | Nothing. | Publish only after consuming `ProviderCheckEmission` through ledger/attempt guard; later write `failure` only after exclusively claiming `CheckInvalidationObligation` through the same gate. | Short-lived contents/read and checks/write installation token; no merge/contents-write token. | Provider check/response plus source-verdict, emission-capability or invalidation-obligation, attempt-link, and finalization locators. | Its bound check run only; cannot restore success or target another check. | Uninstall/disable App, revoke key/token/capability/obligation, remove check only through operator-controlled ruleset recovery. |
| Effect GitHub App | Nothing. | Nothing. | Push governed branch, open/update PR, exact-SHA merge, and governed ref cleanup through broker. | Separate short-lived contents/PR write installation token. | Provider operation facts returned to broker; it does not author the final signed receipt. | Provider refs/PRs within admitted installation and capability. | Uninstall/disable App, revoke token, remove installation permission. |
| Credentialless validation worker | Nothing. | Nothing. | Execute admitted validation against exact candidate source in isolated compute. | No provider-write, signing, merge, release, or external-effect credential. | Content-addressed raw output only; it cannot publish a claim-bearing check. | Disposable validation workspace only. | Revoke worker release/lease and discard workspace. |
| Validation result attestor | A signed validation result derived from an observed worker result; it does not formulate a provider check-emission request. | Nothing in Octon; attests an observed worker result. | Verify worker/source/input/output bindings without executing candidate code; it cannot publish provider state directly. | Attestor signing identity only; no checks-write, merge, content-write, or candidate-execution credential. | Signed validation result with source, input, output, worker, and attestor digests. | Evidence output only. | Revoke attestor release/key; invalidate dependent verifier verdicts and emission capabilities/checks. |
| Delegated or child agent | Sub-scoped plan, patch, test, and effect request. | Nothing; delegation proof cannot mint authority. | Class A work within a same-or-narrower sandbox. | Child identity/lease; no durable credential. | Candidate child output and delegation lineage. | Delegated disposable subtree/worktree only. | Terminate child; revoke child lease/delegation/capabilities. |

## Two-Authority Versus Two-Person Control

### Default solo profile: two-authority or two-identity control

One human may operate Octon without becoming a standing approval committee.
Meaningful separation comes from non-interchangeable software identities,
permissions, keys, binaries, and activation epochs:

- proposer/model: candidate scope, no consequential credential;
- authority engine: grant key, no effect credential;
- broker: effect credential, no grant or evidence-signing key;
- evidence signer: evidence key, no effect or grant credential;
- verifier App: read/check identity, no merge credential;
- effect App: provider write identity, no verifier key;
- previous trusted release: approves candidate trust-root release;
- operator activation key: changes the active trust epoch.

This is two-authority control because no single ordinary software identity can
propose, authorize, perform, and certify the same consequential transition.
One human may own and recover all identities, but routine model compromise does
not collapse them automatically.

### Higher-assurance profile: two-person control

A second human is appropriate when selected by profile or external obligation,
for example:

- production or destructive infrastructure activation above a threshold;
- high-sensitivity secret release;
- release/trust-key rotation;
- break-glass exit after a trust-root incident;
- regulated publication or an explicitly configured quorum.

Two-person control is not the default for bug fixes, refactors, feature work,
ordinary PR creation, low-risk verified merge, or ordinary non-trust-root Octon
self-development.

## Evidence Trust Model

### Required distinctions

| Property | Meaning | What provides it | What does not provide it alone |
| --- | --- | --- | --- |
| Corruption detection | Detects accidental byte change, truncation, reordering, or mismatch against a trusted expected digest/head. | Content hashes, sequence validation, manifests, redundant copies. | An untrusted digest stored beside the changed bytes. |
| Tamper evidence | Makes malicious rewrite detectable to a verifier that trusts an independent key, witness, or anchor. | Signatures plus protected key custody and externally retained signed heads. | A re-chainable unanchored hash journal controlled by the same writer. |
| Authenticity | Binds exact canonical bytes to an identified signer/key. | Verified digital signature, key identity, canonicalization, key validity/revocation. | Actor strings, filenames, role labels, non-empty `signature` fields, or hashes. |
| Non-repudiation | Strong claim that an actor cannot plausibly deny an action, including key custody and legal/organizational context. | Potentially hardware-held identity, independent timestamp/witness, policy and legal controls. | Ordinary local signatures under one solo operator. Revision 2 does not claim legal non-repudiation. |
| Completeness | Establishes that all required events for the declared envelope are present and ordered, or that a gap is explicit. | Transactional monotonic sequence, required-event schema, terminal reconciliation, external head anchors, gap records. | A valid chain that may have been rebuilt after deleting events. |
| Truthfulness | Establishes that the claimed effect matches what a trustworthy component attempted and what the target state shows. | Broker/observer-owned intent/result facts plus external-state reconciliation and independent verifier. | A correctly signed model-supplied receipt or a self-reported success string. |

Evidence claims must name which property they establish. “Integrity” is not a
substitute for all six.

### Signer and broker relationship

The ledger, evidence store, broker, reconciler, and signer are separate
services:

1. The broker asks the capability ledger to commit consume intent and its
   immutable outbox; the ledger is the sole committer.
2. Independent attestors supply an `AttemptLivenessBundle`; the broker asks the
   evidence store to import the outbox and CAS `attempt_started`. It validates
   the returned receipt, obtains the capability ledger's one-time
   `AttemptLinkAck`, and constructs the one invocation guard.
3. The broker consumes that guard while performing the effect with a
   just-in-time credential unavailable to the model.
4. Broker, reconciler, and ledger each wrap their facts in end-to-end
   origin-authenticated envelopes binding producer identity, nonce, operation,
   payload digest, and time. The store verifies, sequences, and preserves those
   envelopes; it cannot forge a producer signature.
5. The signer authenticates the evidence-store channel, reads only committed
   normalized facts plus retained origin envelopes, independently re-verifies
   every producer signature/nonce/binding, recomputes canonical digests,
   evaluates capability validity at the recorded
   consume-intent time, and signs a normalized envelope including later
   revocation, failure, dispute, and recovery facts.
6. The signer rejects caller-supplied free-form receipts, missing intent,
   mismatched target, invalid sequence, and unreconciled success claims. A
   capability stale or revoked before consume intent produces a signed
   invalid/denied record rather than a success. Revocation after consume intent
   never suppresses factual attempt/outcome evidence.

The broker/reconciler/ledger origin signatures authenticate source facts but
are not final evidence signatures or authority to make an audit claim. The
Evidence Signer alone signs the canonical receipt/head after verification. No
producer may forward a model-authored receipt for final signature.

### Signed receipt and journal-head envelope

At minimum, a signed Class B/C receipt binds:

- project and immutable repository identity;
- run, mission when present, executor, broker, adapter, and signer identities;
- monotonic per-run and per-effect sequence;
- prior signed journal head;
- request ID/digest;
- Run Contract identity/digest;
- grant identity/digest;
- typed capability identity/digest/nonce, operation-lineage ID, attempt
  generation, and idempotency key;
- `AttemptLivenessBundle` digest, source identities/signatures, evaluated
  policy/revocation/clock/credential/target epochs, issued/expiry times;
- `AttemptStartReceipt` digest plus `AttemptLinkAck` digest, capability-ledger
  identity, and one-link sequence;
- effective-harness identity/digest;
- policy, authority engine, runtime, broker, signer, and adapter versions;
- support tuple and capability envelope;
- exact target and expected precondition/version/SHA;
- explicit non-idempotent posture when applicable;
- attempted, observed, and reconciled outcome;
- rollback/compensation handle and residual consequence;
- expiry and revocation epoch evaluated;
- resulting evidence root/head;
- signer key ID, canonicalization version, signature, and time source.

The journal hash chain remains useful inside this envelope. The signed external
head, not the local unkeyed chain alone, supplies the stronger tamper-evidence
claim.

### External anchoring

Default solo profile:

- anchor the signed head automatically at each Class B/C terminal transition;
- store only compact, non-sensitive digest material externally;
- use conditional-create or WORM/version-locked storage under an append-only
  anchor identity;
- retain `(project_id, run_id, sequence, head_digest, previous_anchor_digest,
  signer_key_id, signature, recorded_at)`;
- allow sound existing Class A work to continue during signer/anchor outage;
- block ordinary new Class B/C effect starts while required finalization is
  unavailable, but allow a pre-registered, strictly narrowing one-shot
  obligation for check failure, exact rollback to a capability-bound prior
  production/deployment or trust slot, strictly exposure-reducing bounded
  compensation, stop, or revocation to start through healthy
  capability-ledger and evidence gates; queue its
  origin-authenticated outcome for later signing/anchoring;
- for an effect already past consume intent when the outage begins, retain and
  queue a digest-bound pending signature/anchor without retrying the underlying
  effect or claiming completion.

The originating Class B/C capability explicitly includes one constrained
evidence-finalization obligation. At consume time the ledger records its fixed
anchor target/namespace, admitted signer/store identities, signed-head-only
schema, conditional-create/idempotency key, expiry, and retry posture. The
anchor writer verifies that obligation plus the committed signed head; it
cannot accept a model-selected target or arbitrary external payload. This is a
subordinate terminal part of the already authorized effect, not a second
general external-effect capability. The anchor provider receipt is appended as
canonical evidence, but the anchor append is the recursion base case: that
receipt does not require an immediate anchor of itself. A later periodic head
may cover it. Administrative backfill/repair outside the originating
obligation requires a separately typed `EvidenceAnchorRepair` capability.

A GitHub check may mirror the anchor for operator visibility, but a mutable
check run is not the external immutable anchor. The higher-assurance profile
uses a transparency log or two independent anchors.

### Trusted control-plane emissions

Provider validation/provenance checks are durable external writes and do not
bypass canonical authority. A committed attestor/verifier result causes an
automatic `authorize_execution(ControlPlaneEmissionRequest)` evaluation. On
allow, the issuer signs the exact typed request; the capability ledger
registers, reserves, and commits consume intent; the evidence-store/ledger
attempt gate returns the one invocation guard that the App adapter consumes.
The `ProviderCheckEmission` binding covers repository, PR/head/base/config
tuple, App installation/check namespace, exact source-result digest,
conclusion, expiry/invalidation rules, idempotency key, and its own fixed
evidence-finalization obligation. Registration also stores a dormant finite
one-shot `CheckInvalidationObligationTemplate` bound to that same
repository/SHA/check namespace, authenticated expiry/revocation/config event
sources, a `failure`-only update, deadline, idempotency key, and its own
distinct evidence-finalization obligation.
The credentialless
attestor/verifier proposes only the committed result; a dedicated App adapter
holds checks-write and can emit only that schema. Publication is a bounded
two-phase provider effect: create the check as non-successful/in-progress,
authenticate the provider response, atomically bind/activate the invalidation
template to the observed check ID plus exact emission lineage,
`AttemptLinkAck`, and context, then update that same check to the authorized
success conclusion. Failure to bind leaves the check non-successful and blocks
completion.

A later invalidation does not
reuse the spent publication capability or rely on standing discretion: the App
claims the ledger-recorded one-shot obligation, passes the normal
evidence-store begin-attempt guard, and may only change that check to
`failure`. The first successful invalidation consumes the obligation and its
distinct finalization sequence; it can never restore success, target another
check, or reuse publication finalization.

The check-emission outcome is submitted to the evidence store, signed, and
anchored under that capability's finalization obligation, but it does not
require a second provider check about the check response. The anchor append
uses the originating effect's fixed obligation because it closes the evidence
chain. Only the anchor-provider response is the no-immediate-self-anchor
recursion base; a later periodic head may cover it. No standing App credential
accepts an arbitrary caller-selected payload, target, or conclusion.

### Sequence control, replay protection, and crash recovery

Use one logical operation protocol across two separately owned transactional
stores, joined by a durable capability-ledger outbox and idempotent
evidence-store import:

~~~text
capability ledger:
  signed-issuance-request -> register-issue -> issued
  issued -> reservation-committed -> consume-intent-committed + outbox
  consumed + no-attempt -> recovery-reserved | recovery-denied
  consumed/recovery-reserved -> evidence-attempt-link

evidence sequence/receipt store:
  outbox-imported -> abandoned-before-attempt
  outbox-imported -> attempt-started
  attempt-started -> observed-success | observed-failure | outcome-unknown
  -> reconciled -> signed -> anchored

broker typestate:
  ReservationLease -> VerifiedEffect<T> -> ConsumeOutboxRef
  ConsumeOutboxRef | RecoveryLease -> AttemptStartReceipt
  -> AttemptLinkAck -> AttemptInvocationGuard<T> -> adapter consumes guard
~~~

Required properties:

- uniqueness on capability nonce and `(run_id, sequence)`;
- global uniqueness on operation lineage/generation/idempotency across
  predecessor and successor capability IDs;
- `register_issue` atomically activates one capability version/supersedes an
  eligible predecessor before any registered reference is exposed;
- compare-and-swap reservation so exactly one consumer wins;
- a dead reservation may release only when the ledger proves no consume intent;
- consume-intent commit is the irreversible single-use spend and persists
  with a minimal outbox before effect attempt;
- evidence-store import is idempotent; both normal and recovered begin-attempt
  require the same fresh revocation/expiry/approval/credential/policy/target
  receipt; the broker cannot invoke before `attempt-started` is durable and it
  holds the one non-cloneable `AttemptInvocationGuard<T>`;
- consumed-before-attempt may continue the same operation once only after one
  exclusive, expiring `RecoveryLease` plus evidence-store CAS and
  rechecking revocation, expiry, approval/credential availability, policy
  epoch, and exact target/SHA/preconditions; otherwise it becomes terminal
  `abandoned-before-attempt`; a later generation requires fresh authorization;
- non-idempotent unknown outcomes are never blindly retried;
- recovery queries exact target/version/SHA or provider operation ID;
- an effect that succeeded without a final receipt receives an append-only
  recovery receipt after reconciliation;
- disagreement between receipt and external state becomes `disputed`, blocks
  dependent transitions, and invokes compensation/incident policy;
- recovery adds records and anchors; it never rewrites the original fact.

Required fault injections are defined in `authority-and-failure-model.md` and
must include concurrent consumption, concurrent journal append, partial
persistence at every boundary, signer/anchor outage, provider outage, and
revocation during execution.

### Verification after upgrades

Historical evidence remains verifiable after an upgrade by retaining:

- the verifier release or reproducible image and its signed digest;
- schema and canonicalization versions;
- public signing keys, validity intervals, rotation, and revocations;
- policy/runtime/support versions referenced by the receipt;
- raw signed envelope and anchor;
- migration mappings for derived indexes.

An upgrade may append a new signed verification or compaction record. It must
not rewrite the historical signed envelope to fit a new schema.

### Evidence economics and retention

The current dirty worktree observation is approximately:

| Root | Current bytes | Current files | Git-tracked files | Qualification |
| --- | ---: | ---: | ---: | --- |
| `.octon/state/evidence` | `1.4G` | `119086` | `17793` | Includes substantial untracked local run residue; not clean-checkout size. |
| `.octon/state/control` | `332M` | `31659` | `21201` | Includes substantial untracked local run state; not clean-checkout size. |

The target avoids converting ordinary autonomy into repository churn:

| Evidence class | Raw default | Durable compact record | Git posture | External anchor |
| --- | --- | --- | --- | --- |
| Class A successful candidate work | Detailed local telemetry for 7 days after closeout. | Candidate tree/commit digest, validation summary, notable denial/failure summary through Change closeout. | No per-action Git evidence; one compact closeout record when required. | None unless promoted to B/C. |
| Class A failed/diagnostic work | Raw local evidence for 30 days by default, longer on explicit hold. | Failure slice, source digests, recovery status, and retained locator. | Compact failure receipt only when claim-bearing. | Anchor only if it supports a B/C incident or decision. |
| Class B | Large raw logs externally for 90 days by default. | Signed broker receipt, exact target/SHA, validation manifest, rollback, evidence root, and anchor retained for repository lifetime. | One concise digest-bound Change/effect receipt; raw bodies stay out of Git. | Required at terminal transition. |
| Class C and trust-root | Policy-selected encrypted raw retention; default at least one year for operational raw evidence. | Signed decision, effect/activation receipt, verifier release/digest, evidence root, anchors, rollback/incident evidence retained indefinitely unless stricter obligation applies. | Compact signed/index records only. | Required; dual/public anchor in higher-assurance profile. |

Initial growth budgets are proposed product SLOs, not proof that every workload
fits them:

| Class | Raw soft trigger | Raw hard quota | Compact/index ceiling |
| --- | --- | --- | --- |
| Class A per run | `25 MiB` or `5,000` files | `100 MiB` or `20,000` files | One closeout/failure view up to `64 KiB` and `4,000` estimated model-visible tokens |
| Class B per effect | `100 MiB` or `10,000` objects externally | `1 GiB` or `50,000` objects | Content-addressed signed/index/rollback set up to `256 KiB` externally; Git receives only its entry in the consolidated Change index |
| Class C/trust-root per effect | `1 GiB` or `50,000` objects externally | `10 GiB` or `250,000` objects unless an approved profile sets a stricter/lower ceiling | Content-addressed signed decision/activation/incident index up to `1 MiB` externally; Git receives only its entry in the consolidated Change index |
| Per-project rolling retained raw | `5 GiB` or `250,000` objects | `20 GiB` or `1,000,000` objects | New B/C reservations must fit both effect and project remaining quota before consume |
| Global rolling retained raw for `N` active projects | `max(20 GiB, 5 GiB × N)` or `max(1,000,000, 250,000 × N)` objects | `max(100 GiB, 20 GiB × N)` or `max(5,000,000, 1,000,000 × N)` objects | A profile may set a stricter ceiling only when the largest admitted effect reservation still fits; exhaustion blocks only new affected transitions |
| Aggregate Git-visible compact evidence per Change | compaction starts at `256 KiB` | `512 KiB` and `4` files total | One consolidated Change index plus at most three required lifecycle receipts, regardless of effect count; exceeding the hard ceiling requires an explicit retained-evidence exception |

At a soft trigger or 80 percent of a hard quota, deterministic compaction,
deduplication, compression, and raw externalization start automatically.
Each run reserves quota before accepting raw evidence; every B/C effect body is
content-addressed externally and aggregated into the one Change index, so
ordinary multi-effect automation does not consume a per-effect Git-file
allowance.
Class A telemetry may sample/drop only low-value success detail after recording
the gap and preserving candidate work, failures, validation summary, and
closeout digest. At a Class B/C hard quota, the evidence store preserves the
current consumed/attempted facts but blocks the next consequential transition
with an exact quota denial and a generated retention-extension/compaction
route; it never truncates evidence or repeats the effect. Quota accounting is
per project/run/effect plus global store, reserves capacity before B/C consume,
and index entries expose bytes,
objects, age, retention hold, compaction ratio, and projected exhaustion.

Index evidence by project, run, grant, capability nonce, target, exact SHA,
effect class, outcome, and signer key. Default readers load compact indexes and
failure slices, not raw transcripts.

Compaction is additive and deterministic:

~~~text
raw evidence
-> source digest and stable locator
-> deterministic summary/failing slices
-> signed compaction manifest
-> retained raw policy or signed tombstone after expiry
~~~

Compaction never deletes the last signed receipt, external anchor, historical
verifier, current rollback proof, legal hold, or raw source still required for a
live claim. A model may propose a summary or deletion, but the trusted
retention service performs it only under policy and a typed capability.

## Target Merge-Provenance Model

### Canonical verifier flow

~~~text
pull request opens, head synchronizes, base target changes, or same-head PR identity changes
-> independent provenance verifier fetches head/base as untrusted data and loads signed Octon evidence
-> pinned released/base-version verifier verifies the full repository/PR/head-repository/head-SHA/base/provider-control provenance tuple
-> checks current expiry and revocation state
-> emits signed verdict and ControlPlaneEmissionRequest bound to the full tuple, verdict identity, and expiry
-> authorize_execution(ControlPlaneEmissionRequest)
-> issuer signs ProviderCheckEmission request; ledger register_issue
-> ledger reserves/commits consume; store/ledger attempt gate returns guard; Verifier GitHub App consumes guard and creates non-successful/in-progress check
-> authenticate provider response; ledger binds dormant invalidation template to check ID, emission lineage, AttemptLinkAck, and context
-> App updates same check to authorized success only after binding
-> App schedules expiry and subscribes to authenticated revocation/config invalidation
-> effect broker re-fetches exact head; ledger and attempt gates admit the merge
-> effect App consumes the merge invocation guard and merges only expected head SHA
-> broker reconciles target ref; signer signs receipt; anchor writer anchors it
~~~

A new commit, PR identity, base target/SHA, ruleset snapshot, grant revocation,
or relevant policy/config epoch invalidates the verdict and capability. The
App must actively replace a successful check with a definitive `failure`
conclusion on the earlier of those events or its scheduled bounded
expiry; a green check cannot be treated as live merely because the head SHA is
unchanged. `neutral` and `skipped` are forbidden invalidation conclusions
because GitHub treats them as successful for required checks. The provider
check's expiry cannot exceed the
grant/capability/evidence freshness bound.

The automatic lane restricts merge-capable automation credentials to the
effect App/broker: model, workflow, PAT, and generic service tokens have no
ordinary merge credential. The solo owner's provider account may remain
technically capable of a manual merge on provider profiles that cannot enforce
actor restriction; Octon classifies that action as an explicit Class C
break-glass route requiring independent liveness verification and incident
evidence. A higher-assurance profile may admit a verified provider actor
restriction that also blocks the owner. If the verifier App is down, an
already-green check may remain green; the effect App still fails closed, but
manual owner misuse remains a declared residual risk. Because provider check
state is primarily SHA-scoped, the broker and App always verify the signed
`(repository, PR identity, head SHA, base target/SHA)` tuple immediately before
merge.

### Required provenance tuple

The verifier must bind at least:

| Field | Verification requirement |
| --- | --- |
| Repository identity | Immutable provider repository ID plus expected owner/name and installation scope. |
| Pull-request identity and lifecycle | Immutable provider PR/node identity, number, open/mergeable lifecycle state, head repository identity, fork/same-repository posture, and head ref. A same SHA in another PR is not equivalent. |
| Base target | Expected branch, base SHA/version, and applicable ruleset/config snapshot. |
| Exact head SHA | Exact pull-request head; re-read immediately before merge. |
| Provider control/verdict | Ruleset/config snapshot digest, Verifier App installation/context identity, signed verdict identity/digest/conclusion/expiry, and Effect App installation identity. |
| Run identity | Canonical run ID and signed run identity/lease. |
| Run Contract | Digest and schema; scope contains the merge target and source. |
| Grant | Grant ID, digest, issuer, decision, expiry, revocation epoch, governing-input digests. |
| Typed capability | Merge effect kind, nonce, operation-lineage ID, attempt generation, idempotency key, expected head/base, target, single-use state, expiry, and predecessor/supersession state. |
| Attempt gate | `AttemptLivenessBundle` digest/source identities/epochs/freshness, `AttemptStartReceipt` digest/store identity, and `AttemptLinkAck` digest/ledger identity prove the one invocation guard followed both liveness verifiers and the one-link gate. |
| Effective harness | Manifest digest, compiler identity/version, source/freshness digests. |
| Runtime/policy | Authority engine, verifier, broker, policy bundle, support resolver, and adapter versions/digests. |
| Support tuple | Exact admitted model/workload/language/locale/host tuple and claim state. |
| Capability envelope | Requested and granted operations, paths/refs, network/credential projection, and no-widening proof. |
| Validation | Required validators, input SHA, results, verifier identities/digests, and freshness. |
| Recovery | Rollback/revert/compensation handle, recovery window, and current feasibility. |
| Evidence | Signed evidence root/head, signer key, external anchor, required raw/compact locators. |
| Liveness | Current expiry, revocation, App installation, ruleset, and external-state agreement. |

The pull request may carry a locator or candidate manifest, but it cannot be the
sole source of the grant, verdict, signer key, verifier binary, or active
provider configuration.

### Verifier option evaluation

| Option | Independence from PR | Exact-SHA binding | Credential separation | Update/self-development safety | Operational cost | Revision 2 disposition |
| --- | --- | --- | --- | --- | --- | --- |
| Independent GitHub App | High when deployed outside repository and limited to read/check. | High; webhook/check is bound to repository and head SHA. | High with a separate effect App. | High when App pins a signed verifier release and activation is external. | Moderate one-time deployment/installation plus small service operation. | **Recommended enforcement identity.** |
| Protected reusable workflow | Medium to high only if provider guarantees workflow source from protected base/release and the PR cannot select/modify caller or verifier. | High when all inputs and checkout refs are explicit. | Medium; remains in Actions and must not receive merge credential while executing candidate code. | Medium; workflow/provider administrators and base branch remain TCB. | Low to moderate. | **Migration/fallback option, not sole long-term identity unless provider guarantees are proven.** |
| Released verifier binary | Depends on where it runs. A binary alone is not a provider boundary. | High if invoked with immutable repository/head inputs. | Depends on host identity and token. | High when signature-pinned and retained across versions. | Moderate build/release cost; low runtime cost. | **Required verifier core, hosted by App or protected base workflow.** |
| Protected base-version verification | High against the current PR because verifier comes from base/previous trusted release. | High when PR tree is treated as data. | Medium to high if run without provider write credential. | High for trust-root/self-development because the changed verifier cannot approve itself. | Low incremental cost; must manage old-version compatibility. | **Mandatory self-development safeguard and practical local/CI fallback.** |
| PR-owned workflow or PR-built verifier | Low. | May check a SHA but candidate controls semantics. | Low if any write credential is present. | Low; same change may weaken its gate. | Low apparent cost. | **Rejected as the sole provenance gate; defense in depth only.** |
| Ruleset contexts without Octon verifier | Provider-enforced context identity only. | Provider SHA association, but not the Octon provenance tuple. | Varies. | Low for lifecycle provenance. | Low. | **Necessary provider control, insufficient alone.** |

### Immediate migration constraints

Before enabling trusted automatic merge:

1. stop executing PR-head scripts, Actions, build scripts, or binaries in any
   step that holds a provider write credential;
2. replace the shared PAT path with short-lived App installation tokens held by
   the broker;
3. run the verifier and merge adapter from a signed release or protected base,
   not the PR head;
4. treat PR files and receipts as untrusted input;
5. add the full exact-SHA provenance tuple and current revocation check;
6. require the independent verifier-App check in a separately activated
   ruleset;
7. use a separate effect App for merge;
8. re-read the provider head/base before capability consumption and pass the
   expected head to the merge operation;
9. reconcile the resulting target ref and anchor the signed broker receipt; and
10. keep existing CI/status checks as defense in depth rather than describing
    them as lifecycle provenance.

## Safe Self-Development for a Solo Operator

Octon remains able to modify itself. The decisive boundaries are whether the
change affects ordinary product behavior, governance meaning, or the active
trust root, and whether activation is separate from candidate implementation.

### Mode matrix

| Mode | Sandbox and worktree | Credentials | Permitted candidate and durable effects | Validator source | Merge requirements | Activation procedure | Rollback | Autonomous-completion eligibility |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ordinary workspace-project work | Run-owned disposable clone/copy-on-write checkout with separate Git database and project sandbox. Canonical checkout and installed Octon are outside write set. | Model/executor has none; broker receives JIT project/provider handles for B effects. | Class A read/edit/build/test/local commit is uninterrupted. Policy-allowed Class B branch push, PR, evidence publication, and low-risk merge are automatic. | Installed signed Octon release and project effective harness; candidate validators may add evidence but cannot redefine authority. | Exact-SHA verifier verdict, required ordinary CI, policy-allowed Class B capability, rollback handle. | No Octon activation. Project deploy/release follows its own B/C class. | Discard candidate, revert exact commit/merge, restore broker snapshot. | **Yes** for ordinary low-risk work; expected manual approvals `0`. |
| Ordinary Octon self-development | Disposable Octon candidate clone with installed active Octon runtime, broker, signer, verifier, vault, and provider credentials outside sandbox. | No trust/effect credential in candidate. | Non-trust-root docs, product behavior, workflows not used as active gates, tests, adapters not yet admitted, and ordinary runtime features may be prepared as Class A and merged as Class B after old-verifier classification. | Previously trusted installed Octon release plus candidate tests. The old classifier decides whether the change remains ordinary. | Full exact-SHA provenance, old-verifier no-trust-impact classification, ordinary CI, independent verifier App. | Signed release may be installed automatically only when it does not replace an active trust-root component; otherwise route to trust-root mode. | Revert Change; previous installed release remains active and retained. | **Yes** for low-risk non-trust-root changes; expected approvals `0`. |
| Governance modification | Isolated candidate clone; policy compiler and active governance source are mounted/read separately from previous release. | Candidate has no operator approval, grant, signer, provider write, or activation key. | Candidate policy/schema/charter/support/exclusion/ownership change, simulations, proof refresh, and inactive release build. Merge of a proven-inert bundle is Class B; governance activation is Class C when meaning changes. | Previously trusted policy compiler/verifier and independent provider verifier. New compiler runs in shadow only. | Exact-SHA provenance, no-silent-widening proof, independent old-version validation, retained rollback policy, and proof that the merged bundle remains inactive; no operator approval for the inert merge. | Land inactive policy bundle; compare old/new decisions; explicit operator activation or deliberately configured high-assurance governance policy. | Atomic restore of previous policy bundle and revocation of new epoch. | Candidate preparation and inert merge may be autonomous; **activation is not unattended by default**. Expected operator interruptions: `1` activation decision. |
| Runtime or trust-root modification | Isolated build environment and candidate clone; active authority engine, broker, ledger, launcher, sandbox, signer, verifier, App deployment, trust store, installer, release keys, and activation pointer are not writable. | Candidate has no production/runtime/App/vault/signing/release/activation credential. | Candidate implementation, adversarial tests, fault injection, inactive signed release, shadow/canary. It cannot activate or replace the active component. | Previously trusted released verifier/runtime, protected base-version checks, independent verifier App, and fixed external negative-control suite. | Old-version verification, exact-SHA provenance, reproducible build/signature, no same-change sole-verifier/gate control, rollback drill, and proof that the candidate remains inactive; no operator approval for the inert merge/publication. | Two phase: land/build inactive candidate, then separate explicit activation after shadow/canary/delay and health gate. | Atomic pointer/service rollback to previous trusted release; revoke new epoch; preserve incident evidence. | Candidate work and inert merge/publication may be autonomous; **trust-root activation is not**. Expected operator interruptions: `1` activation decision, plus incident-only recovery. |

### Trust-root classification

The old verifier owns classification. Every active component, configuration,
credential/identity binding, admission rule, schema, and update path in the
five layered TCB inventories is trust-root scope, including indirect shared
dependencies. At minimum, runtime/trust-root mode covers changes to:

- authorization decision/grant semantics;
- typed effect issuance, verification, reservation, consumption, revocation,
  and replay protection;
- lifecycle launch enforcement and sandbox boundaries;
- host isolation substrate, launch/effect broker, local or external effect
  adapter, broker IPC, credential vault/JIT issuer, or their admission profile;
- identity/lease registry, trusted clock/revocation cache, canonical governing
  input store, Workspace Project revision/pointer store, or capability ledger;
- evidence store, signer, anchor writer, canonicalization, retention/compaction,
  historical verifier, or backup/external retention;
- provider verifier, required gate, merge adapter, App identity/permissions, or
  provider-control contract;
- credentialless validation worker, validation attestor/publisher, or admitted
  CI validation source;
- policy compiler/evaluator or authoritative policy precedence;
- support admission/claim semantics;
- build/release signer, trust store, installer, updater, active-version
  selector, first-epoch bootstrap controller, rollback/compensation adapter,
  reconciliation controller, previous-release/snapshot store, recovery
  verifier, or break-glass plane.

A path list is necessary but insufficient. Semantic impact and dependency
analysis must catch indirect changes to shared libraries, build inputs,
generated runtime bundles, or schemas consumed by these components.

### Prohibited same-change combinations

A candidate may add new implementation tests, but those tests cannot be the
only approving authority. One activation unit must not both:

- modify authority, grant, or capability semantics and modify/control the only
  verifier of those semantics;
- modify broker mediation and modify/control the only complete-mediation test
  or activation gate;
- modify policy meaning and modify/control the only policy compiler/evaluator
  approving the new meaning;
- modify evidence format, signer, anchor, canonicalization, or retention proof
  and modify/control the only historical evidence verifier;
- modify the GitHub provenance gate or App and modify/control the required
  ruleset/App identity approving that change;
- modify installer/updater/active-slot selection and modify the only release
  signature trust store or rollback gate;
- rotate an authority, signer, release, App, or operator key and modify the only
  verifier/trust store that accepts the new key without old-key or break-glass
  authorization;
- change trust-impact/risk classification and use the changed classifier as the
  sole basis for classifying itself as ordinary/low risk;
- modify rollback/recovery semantics and delete, invalidate, or make
  incompatible the last previously trusted version;
- modify support admission/claim semantics and generate the only no-widening
  evidence under the changed semantics; or
- modify a trust mechanism and the only verifier or activation gate approving
  that trust-mechanism change.

Splitting files across two commits does not satisfy this rule if the same
untrusted release or activation unit controls both sides. Separation must be by
previously trusted authority, identity, release, and activation epoch.

### Two-phase trust-root activation

~~~text
Phase 1: candidate implementation and inactive release
  old trusted classifier identifies trust impact
  -> model prepares candidate without credentials
  -> old verifier + independent App validate exact SHA
  -> hermetic build produces signed inactive release
  -> candidate release is installed in inactive slot

Phase 2: separate activation
  shadow old/new decisions and negative controls
  -> run fault, migration, and rollback drills
  -> wait configured delay/canary health window
  -> operator emits OperatorApprovalInput OR configured policy emits HighAssurancePolicyApprovalInput
  -> form sealed ActivationApprovalInput tagged with its distinct issuer/profile/quorum semantics
  -> authorize_execution(TrustActivationRequest + ActivationApprovalInput)
  -> authority issuer signs typed TrustActivation request
  -> capability ledger register_issue returns registered activation reference
  -> broker/installer consumes activation guard and atomically changes active pointer
  -> activation registers one-shot exact rollback obligation for old/new slots and health trigger
  -> old trusted health monitor confirms or consumes rollback obligation through broker/installer
  -> signer signs activation/rollback evidence
  -> anchor writer anchors the signed head
~~~

Requirements:

- the Phase 2 authorization binds the exact signed candidate release digest,
  old release digest, migration, health gate, rollback slot, and expiry;
- `ActivationApprovalInput` is a tagged union of `OperatorApprovalInput` and
  `HighAssurancePolicyApprovalInput`. Each binds a distinct issuer/key,
  selected profile/quorum, request digest, scope, expiry, and evidence; policy
  can never impersonate the operator branch and the grant binds the exact
  chosen input digest;
- the registered activation capability binds the approval-input digest and a
  finite rollback obligation with old/new slot digests, trusted health-monitor
  identity/predicate, trigger window, expiry, idempotency key, and its own
  evidence-finalization obligation; it cannot select an arbitrary restore;
- authorization or completion of the Phase 1 merge does not authorize Phase 2
  activation;
- the candidate cannot read the activation credential or mutate the active
  pointer;
- failure blocks only activation; the landed candidate, evidence, and ordinary
  Class A work remain available;
- post-activation failure rolls back before wider effects only when the old
  trusted monitor's exact trigger permits it by exclusively claiming that
  obligation and passing the normal attempt guard;
- rollback does not erase the failed activation or incident record.

### Previously trusted verifier and protected-base roles

- **Previously trusted verifier release:** authoritative for trust-impact
  classification, historical evidence verification, negative controls, release
  signature verification, and activation eligibility.
- **Protected base-version validation:** evaluates the PR with verifier/policy
  code from the target base or installed old release; PR content is data.
- **Independent verifier App:** prevents the PR from impersonating the provider
  verdict and binds it to exact head SHA.
- **Two-phase activation:** prevents a successfully merged trust candidate from
  becoming active merely because it landed.
- **Delayed promotion/canary:** exposes divergence before full activation.
- **Explicit operator activation:** default solo control for governance and
  trust-root meaning changes.
- **Automatic rollback:** restores the previously trusted release when
  configured health/fault gates fail.

No single mechanism is sufficient alone; together they provide solo-compatible
two-authority separation.

## Degraded Operation and Recovery

Identity, evidence, provider, and self-development failures must fail narrowly:

| Failure | Work that continues | Transition that blocks | Recovery |
| --- | --- | --- | --- |
| Authority engine unavailable | Existing Class A candidate work under an already valid sandbox lease, subject to local expiry policy. | New grants/capabilities and any widening. | Preserve candidate; restore old authority release; retry authorization against fresh inputs. |
| Capability ledger unavailable | Existing sound sandboxes within their installed envelope. | Registration, reservation, consume, recovery lease, new ExecutorLaunch, and B/C start. | Preserve requests/candidate work; restore ledger from verified state; revalidate identity, grant, liveness, and lineage before retry. |
| Identity/lease registry unavailable | Existing sandbox Class A work within a locally verifiable unexpired lease. | New/renewed run, mission, executor, child, delegation, and fresh identity-dependent transition. | Restore registry/cache, reject stale identity, then issue a new bounded lease without repeating work. |
| Governing-input store, trusted clock, or revocation cache unavailable/stale | Existing sandbox Class A work within the declared offline envelope/TTL. | New authorization/issuance and any begin-attempt lacking a fresh policy/approval/revocation/time receipt. | Restore and authenticate current pointers/epoch/time; re-evaluate the pending exact request. |
| Broker unavailable | Read/edit/build/test/local candidate commits. | Canonical, provider, credentialed, or external effect. | Queue digest-bound request; reauthorize/revalidate before sending. |
| Credential vault/JIT issuer unavailable | Class A and unaffected adapters using a separate healthy credential partition. | Only the exact credentialed adapter/target. | Preserve pending request; restore/rotate vault partition; rerun liveness/target checks before JIT issuance. |
| Evidence store unavailable | Existing already launched sound sandboxes and bounded Class A telemetry buffering. | Every new ExecutorLaunch/B/C begin-attempt and terminal claim whose facts cannot be persisted. | Restore store/import outbox idempotently; reconcile already attempted operations; never relaunch/repeat because evidence was unavailable. |
| Signer unavailable | Class A, preservation of committed facts, and pre-registered strictly narrowing obligations (check failure, exact rollback to a bound prior production/deployment or trust slot, strictly exposure-reducing bounded compensation, stop/revoke) through healthy ledger/evidence gates. | New ordinary B/C business effects, success claims, merge, activation, widening, or unbounded/non-reducing compensation. | Queue origin-authenticated obligation facts; recover signer/old release, sign and anchor without repeating the narrowing effect. |
| Anchor unavailable | Class A, pending facts, and the same pre-registered narrowing obligations through healthy ledger/evidence gates. | New ordinary B/C business effects and terminal success/merge/activation claims requiring an anchor. | Queue signed or origin-authenticated facts; retry anchor only, never the underlying effect. |
| GitHub/verifier/network unavailable | All local Class A work and candidate preservation. | Push/PR/check/merge only. | Re-fetch head/config/revocation and rerun verifier when available. |
| Verifier rejects after head update | Candidate remains intact. | Merge of stale verdict/capability. | Issue a new run/grant/capability or revalidate updated SHA within existing policy. |
| Signer key compromised | Class A in safe mode; read-only forensic verification. | New trusted evidence and dependent B/C effects. | Revoke key, freeze affected interval, reconcile against external anchors/provider, rotate under old/break-glass authority, append recovery records. |
| Effect App compromised | Local Class A and non-provider broker operations. | Provider mutations. | Revoke installation, disable merge lane, inspect provider audit, reconcile SHAs, revert safe unauthorized changes. |
| Candidate trust-root health failure | Ordinary old-release operation and candidate analysis. | New-version activation/continued use. | Automatic old-slot rollback, revoke candidate epoch, preserve incident/evidence. |

Every denial or pause identifies the reason, governing policy/version, missing
or stale evidence, exact blocked transition, and shortest safe recovery route.

## Acceptance Criteria

Identity, evidence, merge provenance, and self-development are accepted only
when all of the following pass:

1. credential-exfiltration tests prove model, executor, and child processes
   cannot obtain or directly use Class B/C credentials;
2. authority engine cannot perform an effect, broker cannot mint a grant, and
   signer cannot perform the effect it attests;
3. revoking each identity blocks only its owned transition;
4. signer rejects altered, missing, caller-supplied, stale, or unreconciled
   broker facts;
5. journal re-chaining or deletion fails verification against the external
   signed anchor;
6. concurrent consume/append and every crash boundary produce one recoverable,
   non-replayable state;
7. historical signed evidence verifies after runtime/signer/verifier upgrades;
8. evidence retention and compaction meet storage/context targets without
   deleting the last claim/recovery proof;
9. a PR that modifies its workflow, verifier, receipt, policy, or runtime cannot
   impersonate the independent verifier App;
10. a head update, expired/revoked grant, changed harness, missing anchor, or
    unsupported tuple invalidates the merge verdict;
11. no candidate code executes while a provider write or trust-root credential
    is present;
12. the merge adapter proves the exact expected head was merged and reconciles
    the resulting target ref;
13. the old verifier rejects every prohibited same-change combination;
14. a trust-root candidate cannot activate itself or remove the last previous
    trusted release;
15. failed canary/health injection automatically restores the old release and
    preserves signed incident evidence; and
16. ordinary bug fixes, refactors, features, and non-trust-root Octon work
    require zero manual approvals while meeting the packet's latency and
    autonomous-completion targets.

The governing usability test is practical: one developer should review concise
Class B notifications and make deliberate Class C activation decisions, not
manually author routine grants, signatures, receipts, provider checks, evidence
indexes, or rollback records.
