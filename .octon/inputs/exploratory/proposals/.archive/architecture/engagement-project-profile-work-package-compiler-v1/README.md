# Engagement / Project Profile / Work Package Compiler v1

## Purpose

This proposal packet defines the highest-leverage next implementation step for Octon's drop-in governed autonomy direction: a product-level compiler that connects repository adoption and orientation to a first safe, authorized governed run candidate.

The packet is intentionally narrow. It does **not** implement broad MCP execution, arbitrary API/browser autonomy, deployment automation, autonomous governance mutation, or a fully unattended long-horizon mission runner. It defines the missing layer that lets Octon produce a governed Engagement, Project Profile, Work Package, Decision Requests, evidence posture, support/capability posture, context-pack request, rollback/validation plan, and first run-contract candidate.

The MVP boundary is prepare-only until the existing `octon run start
--contract` authorization path accepts a run-contract candidate. The
per-engagement Objective Brief is candidate/control state, connector posture is
machine-readable stage/block/deny policy, and generated read models remain
non-authoritative projections.

## Canonical path

`/.octon/inputs/exploratory/proposals/architecture/engagement-project-profile-work-package-compiler-v1/`

## Why this packet exists

The live repository already has strong low-level governance primitives: constitutional authority roots, ingress/bootstrap, workspace charter, run lifecycle, execution authorization, context-pack builder, support-targets, capability packs, evidence store, rollback/replay/disclosure, mission lease, autonomy budget, circuit breaker, and generated/effective handle rules. What is missing is the product-level lifecycle object that lets an operator start from “this repo exists” and arrive at “this first governed run is ready, staged, blocked, or denied.”

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/repository-baseline-audit.md`
3. `resources/architecture-evaluation.md`
4. `resources/conversation-alignment.md`
5. `architecture/target-architecture.md`
6. `architecture/current-state-gap-map.md`
7. `architecture/file-change-map.md`
8. `architecture/implementation-plan.md`
9. `architecture/validation-plan.md`
10. `architecture/acceptance-criteria.md`
11. `architecture/cutover-checklist.md`
12. `architecture/rollback-plan.md`
13. `architecture/promotion-readiness-checklist.md`

`resources/octon-workflow-improvement-conversation.md` is retained source
lineage for the packet. Read it only when auditing how the proposal was
derived; `resources/conversation-alignment.md` is the packet-local distillation
of that source into v1 decisions.

## Non-authority notice

This packet lives under `inputs/exploratory/proposals/**`. It is implementation guidance and lineage only. Promotion outputs must land in durable `.octon/**` targets outside the proposal workspace. No runtime, policy, support, or generated/effective route may depend on this proposal path after promotion.
