# Staged Implementation Plan

## Plan Status

This is an architecture implementation sequence, not an executable
implementation prompt. It becomes actionable only after:

1. the relevant AD-01 through AD-12 dispositions are accepted;
2. the strict Pre-Integration Architecture Review passes;
3. a Change route is selected for each coherent implementation unit; and
4. the repo-local/provider projection is split from Octon-internal promotion.

The repository is pre-1.0 and the Profile Selection Receipt selects the
`atomic` change profile. Implementation should make a clean break at each
activated contract boundary. Temporary shadow observation is permitted;
indefinite dual authority, dual token semantics, or compatibility shims are
not.

## Sequencing Principles

- Settle names, ownership, and effect classes before adding adapters.
- Make typed launch and atomic consumption correct before increasing autonomy.
- Build the credentialless candidate lane before moving ordinary writes out of
  privileged mediation.
- Add signer and reconciliation semantics before claiming trustworthy
  evidence.
- Introduce the provider verifier in shadow mode, then make it required; never
  execute PR-head trust code with write credentials during migration.
- Keep the previously trusted runtime and verifier usable until the new trust
  epoch is activated and rollback-tested.
- Before a first broker/signer/verifier release exists, use the Phase 1B
  externally pinned bootstrap verifier, inactive slots, operator activation,
  and automatic restoration of the legacy runtime; never pretend the new
  component can certify its own first installation.
- Preserve completed candidate work during every migration and outage.
- Do not generate an executable implementation prompt from this packet until
  proposal review explicitly authorizes one.

## Target Implementation Units

| Unit | Octon-internal owner | Responsibility | Privilege boundary |
|---|---|---|---|
| Policy compiler | new isolated `policy_compiler` crate/service extracted from the authority policy-input layer | Consume the Harness Input Lock, classify effect/risk/profile, emit the exact Harness Compilation Plan, then verify manifest conformance and seal CompiledAuthorizationInput | Credentialless process identity; no grant/effect key, with authority independently enforcing hard ceilings |
| Canonical authority | `authority_engine` | Produce decision and `GrantBundle`; sign only typed, narrowed capability issuance requests for ledger `register_issue` | Grant/capability-issuer identity; no capability-state or effect credential |
| Capability model | `authorized_effects` | Define sealed typed effects including `ExecutorLaunch` and durable-effect variants | Pure contract/verification logic |
| Transactional capability ledger | new `capability_ledger` crate | Atomic nonce/operation-lineage uniqueness, reservation, supersession, consume-intent plus minimal evidence outbox, revocation, idempotency, and recovery states | Local protected state; no provider credential |
| Lifecycle dispatch adapter | `lifecycle_executor` | Validate request-owned non-authorizing preconditions and submit the immutable request plus capability reference to the launch broker | No process-launch or durable-effect privilege |
| Launch broker | new `launch_broker` crate plus host adapters | Request ledger verification/reservation, install controls, request consume/outbox, supply AttemptLivenessBundle, obtain evidence-store attempt receipt plus ledger attempt-link ack, consume invocation guard, launch exact child, and observe termination | Process-launch and host-control privilege; no provider-effect credential |
| Local effect broker | new `effect_broker` crate plus narrow adapters | Perform canonical filesystem, Git, control-root, evidence-root, secret-lease, and external effects | Target-specific JIT credentials |
| Candidate sandbox adapter | `launch_broker` host adapters | Create disposable project worktree/mount/process/network boundary | Host sandbox privilege; no consequential credential |
| Evidence sequence and receipt store | new `evidence_store` crate replacing nontransactional journal writes | Verify/preserve producer origin envelopes, idempotently import ledger outbox, and atomically sequence attempt-start, outcome, reconciliation, signature, and anchor state | Protected transactional state and producer public keys; no producer private/effect/final-signing credential |
| Evidence signer | new `evidence_signer` service | Re-verify end-to-end broker/reconciler/ledger origin envelopes from committed store facts, then sign normalized receipts/heads | Dedicated final evidence key and producer public keys; no effect credential |
| External anchor writer | narrow `evidence_anchor` adapter | Append signed heads under the originating fixed finalization obligation to conditional-create/WORM or transparency-log storage | Consequential append-only anchor credential; no underlying business-effect/provider-mutation, grant, or signing key |
| Attempt-liveness services | governing-input/revocation/clock attestor, credential-projection attestor (empty-credential profile in Phase 2; vault-metadata-backed in Phase 4), read-only target observer, effect-profile sources, and credentialless assembler | Produce origin-authenticated, short-lived `AttemptLivenessBundle` bound to capability/outbox/operation/target/broker; evidence store re-verifies every required source | Read-only source credentials and distinct origin keys; no effect/grant/final-evidence key |
| Workspace Project registry | constitution/locality contracts plus instance projection | Durable project identity, authenticated-store/digest/predecessor-bound maximum boundary, lifecycle, discovery, dependencies, and typed transition-receipt/pointer recovery | Security-relevant canonical input; non-authorizing and no effect credential |
| Governed Harness Factory | existing task-harness compilation family | Emit the structural Harness Input Lock, then deterministically compile the exact policy plan into an effective-harness manifest/digest without reclassification | Non-authorizing compilation |
| Self-development release gate | kernel/evolution, installer, release contracts | Old-version classification, inert candidate release, staged activation, rollback | Installation/activation identity |
| Credentialless validation worker | isolated CI worker release | Execute admitted candidate validation and emit content-addressed raw result only | Candidate-executing; no signing/check/provider-write credential |
| Validation result attestor | non-candidate-executing attestor service | Verify worker/source/input/output binding and sign validation result | Attestor key; no candidate execution, checks-write, or merge credential |
| Independent provenance verifier | released/protected-base verifier service | Verify the complete PR/head/base/config/Octon tuple and sign `ControlPlaneEmissionRequest` | Read-only metadata/evidence and verifier key; no candidate execution, checks-write, or merge credential |
| Provider check-emission adapter | schema-constrained Verifier GitHub App called through the canonical ledger/broker path | Consume typed `ProviderCheckEmission` and publish/invalidate only the bound App check; return non-recursive provider facts for signed/anchored finalization | Checks-write installation token only; no merge/content-write credential |
| Provider effect projection | separate App identity called by broker | Push/merge/provider mutation bound to typed capability | Short-lived installation write token |
| External effect adapter set | effect-broker admitted adapters | Typed secret use, deployment/infrastructure, package publication, and external API effects with per-target reconciliation/compensation | Per-adapter operation-scoped JIT credential |

`capability_ledger` is a standalone crate so its transactional state machine,
concurrency guarantees, and migration logic can be tested without broker,
signer, lifecycle, or policy side effects.

## Layered-TCB Implementation Coverage

Every component named in `trusted-computing-base.md` has an implementation,
external-dependency, or retained-service disposition:

| TCB component | Implementation unit or disposition | Phase | Validation/activation owner |
| --- | --- | --- | --- |
| Host isolation substrate | Admitted OS/rootless-OCI/VM dependency; host-profile manifest | 1B, 3 | Host conformance owner; signed platform admission |
| Sandbox adapter | `launch_broker` host adapter | 3 | Launch/sandbox owner; escape suite |
| Launch broker | `launch_broker` | 2 | Launch owner; AC-A03/A06/P06 and crash tests |
| Policy Compiler | isolated `policy_compiler` service | 1, 2 | Compiler owner; classification/conformance vectors |
| Workspace Project revision store and active pointer | locality registry/store | 1 | Locality owner; AC-P01/P02 |
| Canonical governing-input store | versioned `governing_input_store` service | 0, 2 | Governance/input owner; pointer/signature/precedence tests |
| Canonical authority engine | `authority_engine` | 2 | Authority owner; AC-A01/A02/A07 |
| Capability issuer inside authority engine | issuer module/key service | 2 | Authority issuer owner; AC-A09 |
| Transactional capability ledger | `capability_ledger` | 2 | Ledger owner; registration/reserve/consume/link/recovery concurrency |
| Local effect broker core | `effect_broker` | 4 shadow, 5 cutover | Broker owner; direct-path and idempotency suite |
| Local filesystem/Git adapter | admitted local adapter | 4, 5 | Adapter owner; path/ref/race/rollback tests |
| Admitted external-effect adapter set | per-provider broker adapters | 4, 5 | Adapter/credential owner; provider sandbox and compensation tests |
| Broker IPC endpoint and policy | installed broker IPC service | 2, 4 | Host IPC owner; peer/replay/confused-deputy tests |
| Identity and lease registry | `identity_lease_registry` service | 2 | Identity owner; AC-E05 and lease/delegation tests |
| Credential vault and JIT issuer | platform vault adapter/JIT service | 4 | Credential owner; leakage/scope/rotation/outage tests |
| Evidence signer | `evidence_signer` | 5 | Signer owner; AC-V01/V02/V05 |
| Evidence sequence and receipt store | `evidence_store` core/full service | 2 core, 5 full | Store owner; attempt/link, origin, crash, sequence tests |
| Trusted clock and revocation cache | `liveness_time_revocation` service | 2 | Revocation/time owner; AC-A10 |
| Attempt-liveness attestation set and assembler | base attestors plus effect-profile sources and assembler | 2 empty-credential launch profile; 4 vault-backed effect profiles; 5 finalization readiness; 6 provider-control liveness | Liveness owners; AC-A10 mutation/outage suite |
| External journal-head anchor | `evidence_anchor` adapter | 5 | Anchor owner; AC-V04/V09 |
| Evidence retention and compaction service | `evidence_retention` | 5, 8 | Retention owner; AC-V07/V08 and quota SLOs |
| Credentialless validation worker | isolated CI worker | 6 | Validation worker owner; credential absence/reproducibility |
| Validation result attestor | non-candidate attestor | 6 | Attestor owner; source/result substitution tests |
| Independent provenance verifier | released verifier service | 6 | Verifier owner; AC-M01/M03/M07 |
| Verifier GitHub App identity | check-emission App adapter | 6 | App/control-plane owner; AC-M02/M06/V09 |
| Provider effect App/broker adapter | separate effect App | 6 | Provider broker owner; AC-M02/M05/M06 |
| Provider ruleset and branch controls | repo-local/provider configuration Change | 6 | Provider-control owner; live drift/actor tests |
| Provider platform | external admitted dependency | 6, 8 | Provider observer; contract/outage/reconciliation tests |
| Hermetic build pipeline | protected build service | 1B, 7 | Build owner; reproducibility/secret-absence tests |
| Release signer | isolated release-signing service/context | 1B, 7 | Release owner; key/substitution/rotation tests |
| Release registry and trust store | protected trust store | 1B, 7 | Trust-store owner; downgrade/epoch tests |
| Installer/updater | inactive-slot installer service | 1B, 7 | Installer owner; power-loss/activation tests |
| First-epoch bootstrap controller | externally pinned bootstrap installer/watchdog | 1B, retire in 7 | Bootstrap/operator owner; first-install/retirement tests |
| Dependency/toolchain trust set | signed lock/image/action/toolchain manifests | 1B, 7 | Supply-chain owner; substitution/reproducibility tests |
| Reconciliation controller | `reconciliation_controller` | 2 launch, 5 general | Recovery owner; AC-F04/V06 |
| Rollback/compensation adapter set | typed broker recovery adapters | 4, 5, 7 | Recovery adapter owner; stale/intervening/partial rollback tests |
| Previous trusted release slots and snapshots | installer slots plus protected snapshot store | 1B, 7 | Installer/recovery owner; restore drills |
| Break-glass and global revocation plane | separate hardware recovery context/service controls | 1B, 7 | Recovery identity owner; stop/restore-only exercises |
| Recovery evidence verifier | prior released verifier mode | 1B, 7, 8 | Recovery-verifier owner; receipt/target/anchor tests |
| Backup and external retention service | external versioned encrypted store | 5, 7, 8 | Backup owner; deletion/key-loss/restore drills |

No row is satisfied merely by documentation. External dependencies require a
live admission receipt; retained platform services require an explicit
conformance test and update owner.

## Impact Map

| Current assumption or surface | Required change | Owning surface | Priority | Rationale |
|---|---|---|---|---|
| `authorize_execution` produces a canonical grant, while lifecycle dispatch separately accepts self-described authority fields | Make the canonical grant/capability chain the only launch authority; rename lifecycle authorization to precondition validation | Authority engine, authorized effects, lifecycle executor | P0 | Removes the competing authorization plane |
| `ExecutorLaunch` exists but is not required by child-process dispatch | Bind child, adapter, worktree, sandbox, harness, delegation, expiry, and budget into a single-use launch token | Authorized effects, capability ledger, and launch broker | P0 | Prevents self-declared unattended launch |
| Consumption writes are sequential but not proven atomic under concurrency/crash | Introduce transactional nonce/sequence storage and explicit attempt states | Capability ledger and runtime bus | P0 | Prevents replay, double consumption, and ambiguous retry |
| Material-effect inventory treats ordinary candidate writes as privileged | Replace with Class A/B/C inventory and canonical/disposable target classification | Constitution contracts, policy inputs, effect adapters | P0 | Preserves throughput without weakening durable mediation |
| Candidate process may reach ambient host paths, network, or credentials | Install project-scoped sandbox controls before child start | Lifecycle host adapters | P0 | Makes autonomous Class A work safe by construction |
| Git and provider helper paths can call durable effects directly | Route canonical FS, remote Git, provider, secret, deployment, and publication effects through broker adapters | Effect broker, execution roles, helper retirement | P0 | Completes durable-effect mediation |
| Journal is an unsigned local hash chain | Add broker-observed canonical records, signer identity, external head anchor, and historical verifier | Evidence signer, runtime bus, retention contracts | P0 | Adds authenticity and qualified tamper evidence |
| Provider checks can be emitted by mutable repository workflows | Require independent App-bound exact-SHA provenance verification | Separate repo-local/provider Change | P0 | Distinguishes ruleset satisfaction from lifecycle provenance |
| PR-head code can execute while a provider write credential is present | Remove write credentials from PR-head execution and separate verifier/effect Apps | GitHub workflow/App projection | P0 | Enforces proposal/credential separation |
| Current Project Profile is mutable observed state rather than stable identity | Add Workspace Project identity/registry and make Project Profile a freshness-checked projection | Locality contracts and instance locality | P1 | Stabilizes project-scoped boundaries |
| Task-specific harness is non-authorizing but lacks one canonical compiled manifest | Extend it into the Governed Harness Factory with deterministic digest/freshness | Product contracts, execution roles, authority binding | P1 | Avoids a parallel harness authority plane |
| Self-evolution readiness can include trust mechanism and approving surfaces together | Add base-version classification, prohibited-combination gate, inert release, separate activation, prior-version rollback | Evolution/runtime/release/install | P0 | Prevents same-change self-certification |
| Evidence is stored at high volume in Git and local state | Add class-tiered retention, compact summaries, external raw payloads, and indexed roots | Evidence/retention contracts and signer | P1 | Controls storage, churn, review, and context cost |
| Denial can block too broadly or lack recovery guidance | Standardize narrow denial and recovery payload | Authority, broker, lifecycle, provider adapters | P1 | Keeps unrelated safe work available |

## Phase 0 — Ratify Contracts and Vocabulary

### Deliverables

1. Add or revise canonical specifications for:
   - authority decision, grant, typed capability, atomic reservation,
     consumption, attempt, reconciliation, receipt, and anchor;
   - `ExecutorLaunch` fields and child-delegation derivation;
   - Class A/B/C effect classification and candidate/durable boundary;
   - denial/recovery result;
   - identity, credential, signer, verifier, and trust-epoch separation.
2. Replace ambiguous language that says a Run Contract, Project Profile, or
   harness “authorizes” or “mints” authority.
3. Publish the exhaustive effect inventory with direct-path owners.
4. Add schemas and fixtures before runtime code changes.

### Validation

- schema validators accept canonical fixtures and reject field widening;
- terminology lint finds no secondary “authorization proof” accepted as a
  grant;
- every current effect adapter maps to Class A, B, or C and a target class;
- architecture decision and contract registries resolve the new versions.

### Rollback

This phase changes declarations only. Revert the contract Change before runtime
adoption if review finds ambiguity. Do not ship runtime code against an
unaccepted contract.

## Phase 1 — Add Workspace Project and the Governed Harness Factory

### Deliverables

1. Add the Workspace Project schema, immutable revision store, stable
   ID/adoption protocol, registry, lifecycle, maximum boundary,
   nested/monorepo rules, and dependency edges.
2. Convert Project Profile into a freshness-checked observed-state projection
   and provide deterministic repair/selection.
3. Extend the existing task-specific harness contract into the canonical
   effective-harness manifest.
4. Implement normalized compilation, acyclic deterministic digesting,
   freshness inputs, per-project requested scope maps, concrete launch
   bindings, revocation, retirement, and child narrowing through the sole-owner
   Factory-input-lock -> Policy-Compiler-plan -> Factory-manifest ->
   Policy-Compiler-conformance pipeline.
5. Emit only non-authorizing manifests and compilation receipts; Phase 2 adds
   the canonical authority binding.

### Validation

- AC-P01 through AC-P04;
- schema and discovery fixtures across supported repository shapes;
- same-host move, normal clone, same-host raw-copy collision, cross-host
  unclaimed-ID/transfer, fork, and provider-transfer identity tests;
- reproducible acyclic digest tests across hosts;
- multi-project no-union and per-target mapping tests;
- stale profile/harness/support/runtime negative tests;
- compilation and context-latency targets.

### Migration and Rollback

Generate a Workspace Project candidate from the existing profile, require
operator selection only for genuine ambiguity, then atomically switch the
profile’s source reference. Rollback restores the old profile projection but
does not let either project or profile authorize effects. Retain every
project revision still pinned by a run or receipt.

## Phase 1B — Bootstrap the First Trust Epoch

This phase exists because the current repository does not yet have a distinct
trusted launch/effect broker, evidence signer, or independent provider
verifier. “The previous broker verifies the new broker” is valid only after
the first trusted epoch.

### Deliverables

1. Install a minimal bootstrap controller outside candidate/repository write
   scope with:
   - a fixed, signed verifier release and digest pinned by the operator;
   - inactive versioned slots and an atomic active pointer;
   - a health watchdog that can restore a bounded legacy authority/launcher
     runtime with autonomous mutation disabled or moved to the admitted
     higher-assurance containment profile;
   - a deny-by-default list of trust-root files, binaries, identities, and
     provider projections;
   - no authority to approve ordinary engineering content.
2. Require the bootstrap verifier to classify and validate every Phase 2–7
   trust-root candidate as data, including the Phase 7 steady-state verifier,
   installer, activation gate, trust store, and rollback monitor that will
   replace it, using protected-base source and negative-control fixtures.
3. Require one explicit operator activation for each first-installed trust
   family. A credentialless proposal/session principal seals the request; a
   separate approval/activation principal can approve only that immutable
   digest and cannot originate, alter, rebuild, or substitute the payload.
   Bind the exact candidate digest, legacy runtime digest/path, migration,
   canary, rollback command, expiry, and both principal identities.
4. Write a signed bootstrap activation/rollback receipt with the operator's
   activation key and place its head in an external conditional-create
   location outside the repository. This bootstrap receipt is not represented
   as broker/signer evidence.
5. After the full evidence signer, verifier, activation gate, and rollback
   monitor pass Phase 7, retire the bootstrap controller's activation
   authority; retain its verifier and receipts for historical verification.

### Validation and Rollback

- candidate code cannot modify/select the bootstrap verifier, inactive slots,
  active pointer, watchdog, operator key, or external receipt location;
- first-install fixtures intentionally corrupt each new component, migration,
  and health result and must preserve the legacy runtime;
- power loss before/after active-pointer change yields either the old or fully
  admitted new slot, never a mixed installation;
- rollback may restore only the bounded legacy authority/launcher runtime and
  revokes candidate leases and credentials without deleting candidate work;
  after any durable-effect family cutover, rollback fails that family closed
  and never restores its retired direct credential/path;
- no Phase 2–7 trust-root activation or Phase 7 bootstrap retirement may
  proceed without a valid bootstrap receipt over the exact replacement gate
  and cutover until Phase 7 records bootstrap retirement.

## Phase 2 — Unify Authority and Make Launch Typed

### Deliverables

1. Extend the canonical issuance path to issue `ExecutorLaunch` from an allowed
   `GrantBundle`.
2. Bind:
   - repository and Workspace Project identity;
   - run, mission, parent executor, and child identity;
   - adapter and executable digest;
   - disposable worktree and maximum path boundary;
   - sandbox/network/process/environment profile digest;
   - effective-harness digest;
   - delegation parent and narrowed envelope;
   - operation-lineage ID, attempt generation, idempotency key, budget, expiry,
     revocation epoch, and single-use nonce.
3. Bind Harness Input Lock, Harness Compilation Plan, Effective Harness
   Manifest, and per-project narrowed envelope digests in the decision, grant,
   and capability.
4. Replace `authorize_before_dispatch` with a clearly named non-authorizing
   precondition check.
5. Add atomic `register_issue` before a capability reference is exposed, plus
   transactional reserve/consume states with global predecessor/successor
   lineage uniqueness and a minimal consume-intent evidence outbox. The external launch broker is the
   only process-launch caller: it asks the capability ledger to atomically
   verify/reserve, validates the authenticated lease, installs host controls,
   requests irreversible consume/outbox commit, asks the evidence store to
   import the outbox and commit `attempt_started`, obtains the sole ledger
   `AttemptLinkAck`, constructs/consumes the invocation guard, and only then
   creates the child process; lifecycle executor only submits the request.
6. Require delegated child agents to receive a fresh child-scoped
   `GrantBundle` from `authorize_execution(ChildExecutionRequest)`; issue their
   launch/effect capabilities only from that child grant.
7. Retire `ProgramApprovalGrant` as authority: migrate retained records through
   a `STAGE_ONLY` reader into `ProgramApprovalInput` and prove only
   `authorize_execution` can evaluate that input before grant issuance.
8. Remove the free-standing authority meaning of `mode: unattended` and
   `authority_ref`; they may be descriptive projections only.
9. Implement the minimum transactional evidence-store core needed by launch:
   idempotent consume-outbox import, exclusive pre-attempt recovery claim,
   `attempt_started`/`abandoned_before_attempt` CAS, ledger one-time
   `evidence_attempt_link` acknowledgement before any invocation guard, launch
   `observed_created`/`observed_failed`/`observed_terminated` and
   `outcome_unknown`/reconciliation records, plus restart recovery. It carries
   no signing/anchor credential; Phase 5 extends the same store with general
   Class B/C outcome schemas, signing, anchoring, indexing, and retention.
10. Implement the base independent liveness attestors plus credentialless
    assembler and require the evidence store to verify every signature, nonce,
    freshness window, operation/outbox/broker binding, and target observation
    on normal and recovered begin-attempt. Phase 2's launch profile binds an
    explicit empty credential projection from a minimal credential attestor;
    Phase 4 extends the same signed schema with vault-handle
    availability/scope without changing launch semantics.

### Validation

- all AC-A01 through AC-A10 tests;
- AC-P05 plus the child-grant lineage portions of AC-P07;
- concurrent launch-token consumption;
- concurrent predecessor/successor capability consumption in one operation
  lineage and outbox-import recovery;
- malicious-store duplicate AttemptStartReceipt, concurrent
  `link_attempt_start`, and one-ack/one-guard tests;
- every `AttemptLivenessBundle` source signature/freshness/epoch/binding
  mutation plus attestor/assembler outage;
- crash at every reserve/consume/process-spawn boundary;
- parent/child narrowing matrix;
- process-tree proof that no child starts on denial.

### Activation and Rollback

Phase 2 activates the authority/issuer/ledger/evidence protocol only in shadow
and for hermetic no-op/read-only fixture executors inside a Phase 1B-admitted
test containment profile. It must not launch an ordinary mutating candidate:
typed launch authority without an admitted isolation adapter is insufficient.
Phase 3 performs the one clean production cutover, simultaneously activating
the admitted sandbox adapter and new launch path and retiring the legacy
ambient launch route. Keep the previous release only as an inactive rollback
artifact; never allow both launch-authority protocols in one active runtime.

## Phase 3 — Establish the Credentialless Candidate Lane

### Deliverables

1. Create a disposable project clone or copy-on-write snapshot with a separate
   Git database.
2. Enforce path, mount, process, network, device, environment, and secret
   controls before process launch.
3. Permit Class A read/edit/build/test/lint/generation/local-commit operations
   without broker round trips.
4. Exclude canonical Octon control/evidence roots, provider credentials,
   activation keys, and external write endpoints.
5. Add deterministic cleanup, preservation, and recovery commands.

### Validation

- macOS, Linux, and Windows host-profile conformance fixtures;
- symlink, traversal, mount, subprocess, socket, metadata-service, environment,
  and credential-exfiltration tests;
- local development performance targets;
- candidate work survives lifecycle/broker/provider failure.
- AC-P06 and the active launch/revocation/retirement portions of AC-P07.

### Activation and Rollback

Roll out per host profile after escape tests pass. A host without a supported
boundary may continue read-only analysis or use the higher-assurance VM
profile; it must not silently degrade into ambient Class A mutation.
First activation of each host adapter uses the Phase 1B inactive-slot and
rollback receipt and atomically enables the Phase 2 typed launch path while
hard-disabling the legacy ambient launcher. Phase 2 fixture-only launch remains
the sole permitted pre-Phase-3 use.

## Phase 4 — Broker Every Durable Effect

### Deliverables

1. Implement narrow broker adapters for:
   - canonical filesystem and control/evidence-root writes;
   - governed Git push, protected ref mutation, merge, and release tags;
   - external APIs;
   - secret leases;
   - deployment and infrastructure mutation;
   - package/artifact publication;
   - policy and trust-root activation.
2. Give the broker JIT, target-scoped credentials only after capability
   verification/reservation.
   Extend the Phase 2 credential-projection attestor from the explicit empty
   launch profile to vault-handle availability/scope for each admitted adapter;
   no secret value enters the liveness bundle.
3. Inventory and prepare atomic retirement/hard-disable changes for every
   direct durable helper path; do not activate a target broker family yet.
4. Add idempotency and external-state reconciliation per adapter.
5. Emit concise non-blocking operator notifications for completed Class B
   effects.

### Validation

- direct-path scan plus adversarial bypass suite;
- broker cannot mint or widen capability;
- authority and model processes cannot use effect credentials;
- exact-target, exact-SHA, expiry, revocation, and idempotency tests;
- Class A loop measurements show no broker latency.

### Activation and Rollback

Phase 4 is report-only/shadow and gives the candidate-facing runtime no broker
effect credential. No Class B/C route is activated because the target evidence
store, signer, and anchor are not ready yet. Existing routes remain explicitly
classified as legacy current-state paths, not target conformance. Phase 5
performs each atomic family cutover only after trustworthy evidence readiness.
Rollback here removes the shadow adapter without changing effect authority.

## Phase 5 — Make Evidence Authentic, Reconciled, and Economical

### Deliverables

1. Extend the Phase 2 transactional evidence-store core with canonical outcome,
   reconciliation, signature/anchor state, sequence allocation, indexes, and
   retention; retain idempotent capability-ledger outbox import and the durable
   `attempt_started` boundary before every adapter call.
2. Introduce authenticated broker-to-evidence-store append and
   evidence-store-to-signer read channels plus a separate signer identity.
   The signer never accepts a direct broker/caller receipt body.
3. Give broker, reconciler, and ledger distinct origin-authentication keys;
   preserve producer identity/nonce/operation/payload digest/time envelopes
   through the store; require signer end-to-end verification so a malicious
   store cannot fabricate a signable outcome.
4. Sign canonical intent, attempt, observed result, reconciliation, and terminal
   head facts read from trusted state.
5. Anchor Class B/C terminal heads externally with conditional-create/WORM
   semantics.
6. Retain historical producer/signer keys, schemas, canonicalizers, and verifier releases.
7. Add compaction and retention tiers:
   - Class A raw success telemetry 7 days and failure telemetry 30 days;
   - Class B signed root/receipt for repository lifetime and large raw logs 90
     days by default;
   - Class C/trust-root decision, activation, rollback, verifier, roots, and
     anchors indefinitely unless a stronger approved policy applies.
8. Keep large raw evidence outside Git and publish compact indexed summaries.

### Validation

- signature known-answer and key-rotation tests;
- local journal re-chain fails against the external anchor;
- crash/concurrent append suite;
- signer rejects caller/provider/ledger disagreement;
- malicious store fabrication/substitution/replay/omission cannot pass producer
  origin-envelope verification at store or signer; producer-key compromise is
  separately injected and attributed;
- upgrade-time historical verification;
- retention sweep preserves roots and summary-to-raw lineage;
- context and review-burden targets.

### Migration and Rollback

Retain existing hash journals as `legacy-unanchored` evidence with honest
qualification. Establish a first signed checkpoint referencing their final
digest; do not rewrite history. Signer/anchor outage blocks only new Class B/C
transitions and leaves Class A available.

After evidence-store, signer, anchor, crash, and historical-verifier tests
pass, activate one broker effect family and remove/hard-disable all of that
family's direct credentialed paths in the same atomic cutover. Rollback disables
the family transition and preserves the candidate; it never restores an
unmediated credential path. Repeat only after the prior family has retained
signed/anchored conformance evidence. The first store/signer/broker-family
activation is admitted by Phase 1B; only subsequent versions may rely on the
previous trusted versions of those new components.

## Phase 6 — Install Trusted Merge Provenance

This phase is a separate repo-local/provider Change because it modifies
`.github/**`, provider rules, and deployed App identities.

### Deliverables

1. Release a reproducible, signed verifier binary.
2. Deploy four separated principals: credentialless validation worker
   (executes candidate, raw result only), non-candidate-executing validation
   result attestor (signs worker/source/input/output result), independent
   provenance verifier (verifies/signs full tuple and emission request), and
   schema-constrained Verifier GitHub App adapter (checks-write only).
3. Verify every field in the normative Required Provenance Tuple table and
   AC-M07 mutation gate, commit/sign the verdict, automatically
   run `authorize_execution(ControlPlaneEmissionRequest)`; have the issuer sign
   and ledger register/reserve/commit consume for a typed
   `ProviderCheckEmission`; pass the resulting attempt invocation guard to the
   App adapter, and only then emit the App-bound check for exact head SHA, PR
   identity, base target/SHA, and
   provider-control snapshot. Registration stores a dormant
   `CheckInvalidationObligationTemplate` with authenticated event sources,
   failure-only conclusion, deadline, idempotency, and a distinct finalization
   obligation. The App creates a non-successful check, authenticates its
   provider response, atomically binds/activates the template to the observed
   check ID plus emission lineage/`AttemptLinkAck`/context, and only then sets
   the authorized success conclusion. Bind failure leaves it non-successful.
4. Deploy a separate effect App for push/merge credentials used only by the
   broker.
5. Bind the provider merge request to the expected head SHA.
6. Remove write credentials from every PR-head execution context.
7. Run the new check in shadow, compare results, then make it required in the
   ruleset.
8. Actively invalidate successful checks on expiry, revocation, base/config
   change, or same-head PR mismatch only by claiming/consuming that one-shot
   obligation through the normal attempt-link/guard path; restrict ordinary merge credentials to
   the effect App/broker, test stale-green workflow/PAT/service-token denial,
   and explicitly record whether the solo owner remains technically capable of
   Class C manual break-glass merge.
9. Sign/anchor publication and invalidation outcomes under their distinct
   finalization obligations; treat only each anchor-provider response as the
   no-immediate-self-anchor base case.
10. Retire mutable repository workflows as provenance authorities; they may
    remain validation inputs.
11. Disable direct-main/no-PR automation. Every durable target-branch merge in
    this revision must carry the PR-bound tuple and App verdict; a future no-PR
    lane requires a separate approved architecture decision and provider gate.

### Validation

- live provider configuration receipt identifies ruleset, required App/check
  identity, permissions, bypass posture, and exact SHA;
- adversarial PR changes workflow, verifier source, check name, and evidence
  payload but cannot satisfy the App;
- head update, expiry, revocation, harness drift, support drift, and evidence
  mismatch fail;
- eligible low-risk PR completes with zero operator interruption;
- effect App cannot publish a verifier check and verifier App cannot merge.
- attestor/verifier cannot write a check directly; missing/wrong
  `ProviderCheckEmission`, tuple, namespace, conclusion, expiry, or source
  verdict denies before provider mutation;
- publication capability cannot be reused for invalidation; missing/wrong
  template/provider ID/response/emission lineage/attempt link/context,
  invalidation obligation/event, or distinct finalization denies; bind failure
  cannot expose success; concurrent claims yield one failure; no obligation
  can restore success, retarget, or reuse publication finalization;
- publication/invalidation outcomes are separately signed/anchored, no second
  check is emitted for either response, and anchor responses do not recurse.
- direct-main/no-PR provider mutation and any unbound target-ref update fail.

### Activation and Rollback

Do not remove the existing required checks during shadowing. After the new App
is required, rollback disables autonomous merge and preserves the branch/PR;
it revokes pending check-emission/merge capabilities and does not fall back to
direct App writes or the mutable check as lifecycle provenance.

## Phase 7 — Separate Self-Development from Trust Activation

### Deliverables

1. Publish a protected base-version classifier for the four self-development
   modes.
2. Add prohibited same-change combination validation.
3. Build/sign/install candidates as inactive releases.
4. Validate trust-root candidates with the previous trusted verifier and
   independent App result.
5. Add shadow/canary comparison and optional delay; seal a tagged
   `ActivationApprovalInput` from distinct `OperatorApprovalInput` or
   `HighAssurancePolicyApprovalInput` issuer/profile/quorum paths; run canonical
   `authorize_execution`; have the issuer sign and ledger
   register/reserve/commit consume for typed `TrustActivation`; pass the
   resulting attempt invocation guard to the installer, which atomically changes the
   pointer and registers a one-shot rollback obligation bound to exact old/new
   slots, old-monitor health predicate, window, expiry, idempotency, and its
   own evidence-finalization obligation.
6. Preserve autonomous completion for ordinary non-trust-root Octon changes.
7. Let the external bootstrap verifier/controller—not any Phase 7 candidate—
   validate and admit the exact steady-state verifier/installer/activation/
   rollback family and its cutover. Retire bootstrap activation authority only
   after the new family has completed its observation window and the bootstrap
   controller has signed the retirement receipt.

### Validation

- AC-S01 through AC-S06;
- candidate cannot modify its own classification outcome or activate itself;
- operator approval cannot mutate the steady-state pointer or substitute for
  grant/capability; activation without canonical registration/guard fails;
- every prohibited combination fixture fails under the old verifier;
- the Phase 7 candidate cannot approve its own admission or bootstrap
  retirement; corrupt replacement-gate and early-retirement fixtures retain
  bootstrap authority and the prior active slot;
- corrupt release, stale signature, missing anchor, canary disagreement,
  wrong rollback slot/monitor/trigger, concurrent rollback, and rollback
  failure stop activation or fail the affected new epoch closed;
- ordinary Octon self-development meets zero-interruption targets.

### Activation and Rollback

Trust-root activation is always a second unit after the candidate lands inert.
The previous release, keys, verifier, and rollback pointer remain retained
until the new epoch passes its declared observation window.

## Phase 8 — Prove Failure Semantics and Solo-Developer Performance

### Deliverables

1. Implement the twelve mandatory fault injections.
2. Add outage matrices for broker, signer, anchor, verifier, network, GitHub,
   key compromise, and App compromise.
3. Instrument the metrics defined in `performance-and-workflows.md`.
4. Run matched task suites with and without Octon controls.
5. Retain compact conformance, performance, recovery, and drift receipts.

### Release Gate

Release only when:

- forbidden fault outcomes are zero;
- false approval, scope violation, and credential exposure are zero in the
  acceptance corpus;
- ordinary manual approvals and manually authored governance artifacts are
  zero;
- ordinary interruption, latency, false-denial, autonomous-completion,
  correctness, regression, evidence-review, and comprehension targets pass;
- each denial demonstrates narrow blocking and a shortest safe recovery route;
- all host profiles either pass their isolation suite or are explicitly
  unsupported for candidate mutation.

## Generated Outputs

Implementation will generate or update:

- Rust/schema fixtures for decisions, grants, typed capabilities, launch
  manifests, ledger states, signed receipts, anchors, Workspace Projects, and
  effective harnesses;
- contract and architecture registries;
- effect inventory and risk-classification indexes;
- host-control projections;
- provider App/ruleset configuration receipts;
- historical verifier/key registries;
- fault-injection reports;
- performance/usability reports;
- implementation conformance and post-implementation drift/churn reviews.

Generated runtime state and retained evidence must live under their canonical
control/evidence authorities, not under this proposal packet.

## Downstream Reference Repair

Each Change must search and repair:

- calls and prose using `authorize_before_dispatch` as authorization;
- `unattended` or `authority_ref` as authority-bearing inputs;
- direct `git`, `gh`, deployment, publication, secret, and canonical-root
  mutation helpers;
- project-profile singleton assumptions and absolute-root consumers;
- task-harness consumers that bypass the effective manifest digest;
- claims that the local journal is authentic, complete, non-repudiable, or
  adversarially tamper-evident;
- provider claims not supported by a live retained configuration receipt;
- self-evolution paths that accept same-change verification or activation.

The proposal path must not appear in durable runtime, policy, validation,
registry, or provider configuration after promotion.

## Validation Floor by Change

Every implementation Change must run:

1. relevant Rust unit, property, concurrency, crash, and adapter integration
   tests;
2. applicable contract/schema validators;
3. proposal-selected impact/alignment validation;
4. direct-path and stale-reference sweeps;
5. the phase-specific acceptance tests above;
6. implementation conformance review;
7. post-implementation drift/churn review; and
8. route-selected closeout validation.

Provider changes additionally require live read-only configuration capture
before mutation and a retained post-change configuration receipt. Trust-root
changes additionally require the strict post-integration architecture review
and activation/rollback evidence.

## Implementation Completion Definition

Revision 2 is implemented only when:

- the canonical authority path is singular in code and terminology;
- every child launch follows ledger consume/attempt-link gating and consumes
  only the resulting typed `ExecutorLaunch` invocation guard;
- Class A is autonomous inside a disposable credentialless boundary;
- every Class B/C effect is broker-mediated;
- evidence is broker-observed, signed, reconciled, externally anchored, and
  economically retained;
- provider merge eligibility uses the independent exact-SHA verifier;
- trust-root candidates cannot self-verify or self-activate;
- Workspace Project and effective harness compile into, but never replace, the
  authority path;
- narrow degradation and all fault injections pass;
- the solo-developer performance gate passes;
- accepted content has been promoted to durable authority and no durable
  back-reference to this packet remains.
