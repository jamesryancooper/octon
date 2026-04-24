---
title: Octon
description: Root overview for the Octon Constitutional Engineering Harness repository.
---

# Octon

Octon helps AI agents build software more safely and work reliably for longer
stretches. It gives agents clear goals and rules, keeps a durable record of
what happened and why, and makes it easier for people to pause, review, resume,
or stop work when something needs closer attention.

Octon exists because powerful coding agents can drift from the plan, lose
context, make changes they should not make, stop before the job is done, or
break something before anyone notices. Octon is designed to reduce those risks
by giving agents room to work inside checked, reviewable boundaries.

Octon is not reckless autonomy. It is **controlled autonomy**.

It does not give agents unlimited freedom. It gives them carefully governed
freedom inside areas that have been admitted, checked, and made reviewable.
Unsupported or insufficiently proven work is kept in review, staged, denied, or
stopped instead of silently treated as safe. Octon is trustworthy because it
knows its limits.

Technically, Octon is a **Constitutional Engineering Harness** for
consequential software work, with a **Governed Agent Runtime** at its core. It
binds consequential runs to explicit objectives, run contracts, scoped
capabilities, authorization decisions, retained evidence, rollback posture,
continuity state, and review or disclosure surfaces.

Octon is not a prompt library, coding bot, generic agent framework,
unconstrained autonomy layer, or dashboard over agent logs. It is a governed
harness for people who want long-running AI help without handing unchecked
control to important software work.

## Current State

Octon is pre-1.0. This repository supports bounded, admitted repo-local work;
it does not claim universal support for every future-facing design already
represented in the repository.

Current live support is declared in
[`.octon/instance/governance/support-targets.yml`](.octon/instance/governance/support-targets.yml).
At the time of this README, the admitted live universe is repo-local governed
work in English over the supported repo shell, CI control-plane read/observe,
and GitHub control-plane consequential routes, with the admitted `repo`, `git`,
`shell`, and `telemetry` capability packs. Stage-only, unadmitted, unsupported,
stale, or insufficiently proven surfaces remain outside the live claim.

The constitutional purpose lives in
[`.octon/framework/constitution/CHARTER.md`](.octon/framework/constitution/CHARTER.md).
Runtime behavior, support status, evidence obligations, and generated artifact
authority are owned by their canonical contracts and registries under
[`.octon/`](.octon/), not by this overview.

## Capabilities

| Capability | What it means | Why it matters | Current support boundary | Canonical detail |
| --- | --- | --- | --- | --- |
| Clear goals and run contracts | Consequential work is bound to explicit objectives and run contracts instead of loose chat intent. | Agents are less likely to wander from the job or close out without the required context. | The live consequential path is bounded to admitted repo-local work. | [Charter](.octon/framework/constitution/CHARTER.md), [orchestrator role](.octon/framework/execution-roles/runtime/orchestrator/ROLE.md), [run lifecycle](.octon/framework/engine/runtime/spec/run-lifecycle-v1.md) |
| Controlled autonomy inside admitted boundaries | Agents can work where the repository has declared, checked, and evidenced support. | Limits become a trust feature: unsupported work is reviewed or stopped rather than assumed safe. | Live support is finite and declared in the support-target matrix; non-live surfaces are stage-only, unadmitted, or unsupported. | [Support targets](.octon/instance/governance/support-targets.yml), [fail-closed obligations](.octon/framework/constitution/obligations/fail-closed.yml) |
| Authorization before material effects | Material side effects require engine-owned authorization before they proceed. | Important changes should not happen just because a model decided to act. | Material routes must stay inside the admitted support envelope and declared capability packs. | [Execution authorization](.octon/framework/engine/runtime/spec/execution-authorization-v1.md), [authorization coverage](.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md) |
| Durable evidence of what happened | Runs, approvals, receipts, disclosure artifacts, and validation evidence are retained in canonical evidence roots. | People can inspect, replay, debug, and disclose consequential work from durable records instead of memory or chat summaries. | Evidence obligations apply to supported consequential runs and support claims. | [Evidence obligations](.octon/framework/constitution/obligations/evidence.yml), [evidence store](.octon/framework/engine/runtime/spec/evidence-store-v1.md) |
| Pause, review, resume, rollback, and closeout surfaces | Live control state, continuity state, rollback posture, and disclosure records are separated and reviewable. | Long-running work can be interrupted or resumed without pretending the model's current context is the source of truth. | Mission-backed or long-horizon autonomy must satisfy the runtime and evidence contracts before it can claim support. | [Orchestrator role](.octon/framework/execution-roles/runtime/orchestrator/ROLE.md), [evidence store](.octon/framework/engine/runtime/spec/evidence-store-v1.md) |
| Separation of authority, state, evidence, and summaries | Authored authority, mutable control truth, retained evidence, continuity, generated runtime handles, and operator read models live in distinct roots. | Summaries can help people operate the system without becoming hidden permission or policy. | Generated outputs remain derived-only and may not widen authority or support claims. | [`.octon/README.md`](.octon/README.md), [architecture specification](.octon/framework/cognition/_meta/architecture/specification.md), [contract registry](.octon/framework/cognition/_meta/architecture/contract-registry.yml) |
| Operator visibility into long-running work | Octon keeps review and disclosure surfaces near the runtime path. | Serious solo operators can delegate more work while preserving inspection points and stop conditions. | Visibility surfaces summarize canonical control and evidence; they do not replace them. | [Evidence store](.octon/framework/engine/runtime/spec/evidence-store-v1.md), [runtime resolution](.octon/instance/governance/runtime-resolution.yml) |

## What Octon Does Not Claim Yet

Octon does not claim that all agent work is safe, that all external systems are
supported, or that future-facing designs in the repository are live capability.
It does not treat raw inputs, archived proposals, generated summaries, host UI
state, labels, comments, or chat transcripts as runtime authority.

When support is missing, stale, or unproven, the intended behavior is to stop,
stage, deny, revoke, or escalate rather than keep going as if the work were
safe by default.

## Core Layout

- [`.octon/framework/`](.octon/framework/) contains portable authored Octon core.
- [`.octon/instance/`](.octon/instance/) contains repo-specific durable authored authority.
- [`.octon/inputs/`](.octon/inputs/) contains additive packs and exploratory material.
- [`.octon/state/`](.octon/state/) contains continuity, evidence, and control truth.
- [`.octon/generated/`](.octon/generated/) contains rebuildable effective views and registries.

Committed generated projections may be retained for durability, but they remain
derived outputs rather than authoritative control surfaces.

## Start Here

- [`.octon/AGENTS.md`](.octon/AGENTS.md)
- [`.octon/instance/ingress/AGENTS.md`](.octon/instance/ingress/AGENTS.md)
- [`.octon/instance/bootstrap/START.md`](.octon/instance/bootstrap/START.md)
- [`.octon/framework/cognition/_meta/architecture/specification.md`](.octon/framework/cognition/_meta/architecture/specification.md)
- [`.octon/framework/cognition/_meta/terminology/glossary.md`](.octon/framework/cognition/_meta/terminology/glossary.md)
