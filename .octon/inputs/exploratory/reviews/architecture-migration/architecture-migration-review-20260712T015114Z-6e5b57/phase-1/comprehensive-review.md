# Phase 1 — Independent Comprehensive Review

Repository commit: c5b1f5760c78ff521cca6b054e4e8fef5300505b

This phase reconstructs the current implementation independently from the
intake. The intake decisions are treated as operator direction, not evidence
that the repository implements them.

## Executive finding

Octon already contains valuable authorization, lifecycle, route, extension,
and evidence primitives, but the material execution architecture is not yet
the accepted solo-builder architecture. Four boundary breaks dominate:

1. lifecycle dispatch self-produces a delegation proof and launches Codex,
   Claude, or workflow leaves without consuming a canonical ExecutorLaunch;
2. child processes share the canonical checkout and inherited host
   environment, including credential-capable user state;
3. privileged GitHub automation checks out and executes candidate-controlled
   code while a write-capable token is present; and
4. single-use effects and journal state are persisted through unlocked,
   non-transactional files.

These are architectural blockers to privileged autonomous Class B
publication. They do not invalidate all existing work: the typed-effect
model, fail-closed validation rules, exact-source/target concepts, ruleset
guardrails, extension publication boundary, and lifecycle records are useful
assets to migrate.

## A. Product and scope alignment

The declared product is frequently solo-first, CLI-first, and progressive,
but the implementation surface has accumulated materially broader concerns.
The framework contains federation/trust-domain machinery, connectors,
portable proof exchange, stewardship roles, multiple publication projections,
and a very large generated and retained-state footprint. Static file inventory
found more than 32,000 files under framework/engine alone and over 1,000 under
framework/capabilities. File count is not itself a defect, but it correlates
with operator-visible concepts and validation burden that the one-operator
target does not need.

Current route policy is also inconsistent with the target. The normal solo
selection order still considers direct-main before branch-no-pr:

- .octon/framework/product/contracts/default-work-unit.md:54-63@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/product/contracts/default-work-unit.yml:295-317@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The repository has good progressive-disclosure patterns for skills and
effective manifests, but setup, broker health, project inference, concise
mission status, and repair are not yet one coherent product path. The current
Codex launcher can even fail local deployment preflight if the user-state
database is not writable, exposing implementation mechanics rather than an
operator-grade repair path.

Conclusion: PARTIALLY_SATISFIED for solo scope and usability, with direct-main
explicitly CONTRADICTED.

## B. Canonical authorization

### Implemented strength

The authority engine is a serious reusable core. AuthorizedEffect and
VerifiedEffect are sealed typed wrappers, and ExecutorLaunch is a defined
effect class:

- .octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs:1-180@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs:390-394@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Effect verification validates the canonical token record, digest, grant,
scope, route, support posture, expiry, revocation, approvals, rollback,
budget, egress, lifecycle, and prior consumption:

- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs:210-667@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The full authority-engine library suite passed 75 tests. Its sequential
single-use, expiry, wrong-scope, wrong-class, forged-digest, revocation, and
missing-token negative controls passed. These results prove those tested code
paths at this commit; they do not prove concurrency, crash atomicity, or
complete mediation.

### Competing authority

Lifecycle dispatch does not consume that primitive. LifecycleExecutionPolicy
contains string fields for invocation mode and provenance, with an optional
authority reference:

- .octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs:97-110@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The lifecycle authorizer creates its own DelegationProof from request
metadata. It accepts unattended or grant-consumption mode without loading and
consuming a canonical typed launch token:

- .octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs:39-150@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs:399-409@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The kernel normally supplies unattended and leaves authority_ref unset:

- .octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs:4412-4629@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/kernel/src/main.rs:1268-1270@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The active chain is therefore:

intent/request → lifecycle-local checks → lifecycle-produced proof →
direct process dispatch.

The accepted chain is:

intent/request → authorize_execution → typed one-shot launch issuance →
atomic consumption → isolated process dispatch → broker/evidence transaction.

Conclusion: the canonical authority decision is PARTIALLY_SATISFIED, while
complete launch mediation is ABSENT.

## C. Invocation guards and lifecycle launch

ExecutorLaunch exists and can be issued and verified. It is not structurally
required by the lifecycle adapter. The studio command demonstrates the
problem: it verifies ExecutorLaunch, but the verified value only gates
creation of a directory; the cargo process launch follows outside the
guard-consuming helper:

- .octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:685-757@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:114-120@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The minimum repair is an unforgeable launch API whose process-spawn method
requires ownership of a fresh VerifiedEffect<ExecutorLaunch>, atomically
consumes it with operation reservation, and cannot be reached through a raw
Command path. Descriptive lifecycle fields may remain temporarily for
observability but must no longer authorize.

## D. Candidate isolation

Current lifecycle candidates are not disposable or Git-isolated. The Codex
command uses the repository root, workspace-write, and the canonical checkout;
Claude is invoked without a sandbox flag. No env_clear or credential scrub is
applied:

- .octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs:224-256@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs:416-451@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Codex preflight explicitly requires writable state under the user's home:

- .octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs:31-73@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Deployment-local inspection found Codex configured for workspace-write with
network access enabled and Claude configured for accept-edits without a
separate sandbox configuration. The current process environment included a
keychain-backed GitHub session, osxkeychain Git helper, and SSH agent socket
even though that agent held no identities at inspection time. This establishes
ambient exposure potential, not proof that a child exfiltrated or used a
credential.

Required target: a short-lived native macOS seatbelt/container-equivalent
boundary with a minimal environment, no host keychain/session access, isolated
HOME, isolated Git object/ref/index/config state, explicit network policy, and
cleanup/reconciliation by operation ID.

## E. Broker and credentials

No built-in separate transactional durable-effect broker was found. The file
named policy-grant-broker.sh is an ephemeral policy-grant helper; it is not a
credential-custody process, Git effect worker, or SQLite authority store:

- .octon/framework/capabilities/_ops/scripts/policy-grant-broker.sh:1-300@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Current provider writes are performed by shell, gh, and Git processes running
in repository context. Git may consult user/global/system configuration,
credential helpers, hooks, filters, attributes, includes, URL rewrites,
submodule protocols, and transport environment. The hosted no-PR authorization
script emits its own approval JSON rather than consuming broker authority:

- .octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh:160-239@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The landing script validates JSON fields and executes Git push directly:

- .octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh:79-126@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh:208-234@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Provider metadata showed repository secrets named for OpenAI, Anthropic, and
autonomy access, plus a write-capable active automation path. Secret values
were neither requested nor retained.

## F. Git and publication

There are strong concepts worth preserving: route separation, fast-forward
only hosted landing, exact source SHA and target pre-SHA, required-check
enumeration, target revalidation, rollback handles, and provider ruleset
guardrails. The hosted no-PR validation suite passed 29 tests.

Those tests validate receipts and declared safety properties; they do not
establish a trusted effect boundary. The authorization JSON is locally
self-issued, Git uses ambient configuration and credentials, and provider
verification is candidate-controlled.

The live GitHub ruleset is active, applies to the default branch, prevents
deletion and non-fast-forward updates, requires linear history and four
checks, and exposes no bypass actor to the current user. It does not require a
PR, matching the intended adaptive route capability.

However, the required checks execute workflows and scripts from the candidate
repository. More critically, pr-auto-merge uses pull_request_target with
contents and pull-requests write, checks out the PR head, and then executes the
candidate version of protected-ci-auto-merge.sh and the Rust kernel while
AUTONOMY_PAT or GITHUB_TOKEN remains in scope:

- .github/workflows/pr-auto-merge.yml:3-25@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .github/workflows/pr-auto-merge.yml:257-330@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Required-check workflows similarly checkout candidate code and execute
repository-owned validators:

- .github/workflows/change-route-projection.yml:31-166@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The trusted integration lane must therefore be moved to immutable
base-branch/provider-managed code, or a separately pinned protected worker,
before privileged autonomous use.

## G. Runtime correctness

Token records are read, validated, evented, receipted, and only then rewritten
as consumed. No lock or transaction spans that sequence:

- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs:294-658@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/policy.rs:81-96@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Two concurrent consumers can both observe minted state. A crash can leave the
event, receipt, and consumed record inconsistent. The existing sequential
single-use test does not exercise this race.

The runtime bus has the same crash/concurrency class: it derives sequence and
hash from the current ledger, appends without fsync or an interprocess lock,
then rewrites the manifest with fs::write:

- .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs:384-435@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs:1778-1823@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The runtime-bus library suite passed 17 tests, including hash tamper and
lifecycle-state denials. This supports the transition and integrity logic but
not atomic durability. No SQLite/WAL authoritative runtime store or integrated
evidence-capacity reservation was found.

## H. Evidence

Current evidence provides useful traceability, structural linkage, lifecycle
records, and hash-chain corruption detection. It does not provide authenticity
against a writer that can rewrite and rechain files. No production signing
implementation for broker/verifier receipts was identified in the runtime
crate dependencies. Evidence-store contracts describe many retained surfaces,
but no measured automatic compaction and bounded-retention mechanism was
verified:

- .octon/framework/engine/runtime/spec/evidence-store-v1.md:1-260@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs:128-154@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Claims must be bounded as follows:

- integrity: supported for tested chain format;
- corruption detection: supported for tested tampering;
- tamper resistance/authenticity/non-repudiation: not established;
- completeness/truthfulness: not established by chaining;
- exact-effect binding: partial in typed effect records, absent end to end for
  lifecycle/provider effects;
- bounded retention/compaction: declared direction, not dynamically proved.

## I. Self-development

The promotion contracts correctly deny quiet authority and require decisions,
receipts, rollback posture, support proof, and recertification. This is a
valuable declared boundary:

- .octon/framework/engine/runtime/spec/promotion-activation-v1.md:1-75@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The current promote apply implementation does not perform installation or
activation. It evaluates blockers and returns ready_to_apply with
requires_authorized_run_for_material_change:

- .octon/framework/engine/runtime/crates/kernel/src/commands/evolution.rs:425-468@c5b1f5760c78ff521cca6b054e4e8fef5300505b

The repository therefore has governance scaffolding, not an independently
verified exact-version staged activation state machine. Because validators and
privileged workflow code are candidate-mutable today, same-change
self-certification remains possible on the provider path. Trust-root changes
must land inert, with activation owned by an immutable older/base verifier and
a separately preauthorized exact-version rollback-capable state machine.

## J. Workspace Projects and Harness Factory

Current reusable foundations include:

- a descriptive instance project profile;
- project-profile and task-specific-harness schemas;
- runtime resolver/effective manifest machinery;
- extension fragments and generated effective extension catalog;
- harness-card disclosure and compile-receipt concepts.

Representative refs:

- .octon/instance/locality/project-profile.yml:1-160@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/spec/project-profile-v1.schema.json:1-220@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md:1-220@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/generated/effective/extensions/catalog.effective.yml:1-120@c5b1f5760c78ff521cca6b054e4e8fef5300505b

What is absent is one minimal durable Workspace Project identity contract and
one clearly non-authoritative deterministic Harness Factory that compiles
project/profile/mission/extension inputs to a digest-bound manifest. Current
project and harness concepts are spread across instance, runtime specs,
generated projections, inputs, and host integrations.

## K. Extensions and multi-agent operation

Extension packaging, manifests, skills, validators, and publication into
generated effective surfaces are mature relative strengths. They should be
preserved but narrowed to a personal/private signed catalog with pinning,
revocation, rollback, and mission selection. The current catalog is not a
trusted signature boundary by itself.

Lifecycle machinery supports child work, retries, workflows, and retained
state, but child launch is neither credentialless nor canonically guarded.
The target should retain mission-scoped orchestration and provider-native
execution while removing ambient authority, persistent organization concepts,
and lifecycle-local authority.

## L. Solo-builder experience

The accepted budgets are credible only after consolidation:

- one guided trust enrollment that stores broker credentials in the OS
  keychain without copying secrets into agents;
- broker auto-start and self-diagnosis;
- automatic project inference and one default profile;
- automatic branch-no-pr versus PR selection;
- zero routine Class A prompts and zero admitted routine Class B prompts;
- concise outcome first, with expandable evidence;
- operation-ID recovery and reconciliation;
- bounded local retention and automatic compaction.

The current implementation cannot yet demonstrate the setup, onboarding,
prompt, evidence-volume, or monthly-administration budgets. These are
REQUIRES_DYNAMIC_PROOF, not failures inferred from missing benchmark records.

## Phase 1 conclusion

The intake's central findings remain valid and are sharpened by current
evidence. The largest correction is that Octon has more useful typed-effect and
route-validation structure than a greenfield migration would imply. The
smallest safe path is to reuse those contracts while replacing their
file-backed consumption and direct/candidate-controlled effect execution with
one transactional store, one credentialed broker, one structural launch gate,
and one independent verifier.
