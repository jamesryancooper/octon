# Architectural Pressure Ledger

## Review Objective

Resolve the narrowest architecture that combines substantial autonomous
engineering throughput with strong control of durable and consequential
effects for one operator.

## Fundamental Job

The system is not a per-command approval engine. Its job is to create a
reversible work envelope, keep the agent inside it, and mediate only the
transitions whose consequences survive, escape, or redefine that envelope.

## Pressures

| ID | Pressure | Current insufficiency | Required outcome | Kernel route |
| --- | --- | --- | --- | --- |
| P-01 | Competing launch authorization | Lifecycle pre-dispatch uses self-described authority fields and its own proof | One grant/capability path for child launch | Ordinary revision |
| P-02 | Candidate-work overmediation | Repo mutation is modeled broadly as high/material | Disposable writes, commits, and tests run without per-action approval | Ordinary revision |
| P-03 | Bypassable durable effects | Host scripts and provider workflows can execute effects with ambient credentials | Credentialless agent plus unavoidable local/provider broker | Ordinary revision |
| P-04 | Evidence overclaim | Hash integrity is not independent authenticity or anchoring | Broker observation, signer separation, transactional sequence, external anchor | Ordinary revision |
| P-05 | Merge provenance gap | Required checks can be satisfied without proving the full Octon lifecycle tuple | Unforgeable exact-SHA provider verifier | Ordinary revision |
| P-06 | Same-change self-certification | Existing self-evolution gates do not fully separate verifier and activation versions | Previous-verifier, inactive install, separate activation, automatic rollback | Ordinary revision |
| P-07 | Project identity drift | Singleton mutable Project Profile carries a machine path but not durable multi-project identity | Workspace Project identity plus refreshable Project Profile | Ordinary revision |
| P-08 | Harness ambiguity | Task harness is non-authorizing but lacks the complete factory/install/retirement path | Deterministic effective harness bound at authorization | Ordinary revision |
| P-09 | Crash and concurrency ambiguity | Filesystem token/journal paths do not define atomic reservation and unknown outcomes | Transactional capability-ledger/evidence-store protocol and required fault injection | Ordinary revision |
| P-10 | Governance cost | Existing posture can make routine local iteration look consequential | Zero ordinary approvals and measured latency/error budgets | Ordinary revision |

## Stakeholders and Tolerances

- solo operator: minimal interruption, clear notification, simple recovery;
- model and child agents: broad candidate freedom, explicit boundaries;
- runtime maintainer: one vocabulary, small privileged core, deterministic
  tests;
- provider: exact operation and identity binding;
- incident responder: signed, reconcilable facts and last-known-good rollback.

Unauthorized Class B or C effects have near-zero tolerance. Loss of a
disposable sandbox is tolerable only after candidate work is exported or
quarantined. Small, bounded Class A telemetry loss may be tolerated when it
cannot conceal a durable effect.

## First-Principles Decomposition

1. propose work;
2. constrain the project and execution envelope;
3. authorize the envelope or a durable transition;
4. sign a narrow typed request and register its capability;
5. enforce isolation continuously;
6. reserve and perform the exact effect;
7. observe and attest to the outcome;
8. reconcile uncertainty;
9. notify the operator at the appropriate level; and
10. recover or roll back without discarding useful candidate work.

The decomposition deliberately retains Octon's existing authority, typed
effects, lifecycle, support, and evidence concepts. A clean-sheet agent
platform is unnecessary.

## Constitutional Challenge Screen

No immediate kernel amendment is required. Revision 2 preserves explicit
authority routing for durable material effects and reclassifies disposable
candidate work as non-material within an authorized sandbox. A future proposal
must escalate if it attempts to let Workspace Project, Project Profile, a Run
Contract, a harness compiler, a host adapter, generated output, or provider
check mint authority.
