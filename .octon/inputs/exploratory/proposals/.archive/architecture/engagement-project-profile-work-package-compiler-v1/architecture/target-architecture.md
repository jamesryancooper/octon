# Target Architecture

## Summary

Engagement / Project Profile / Work Package Compiler v1 adds a product-level lifecycle layer above Octon's existing runtime contracts. It turns drop-in repository adoption and orientation into a governed first-run readiness bundle without replacing the run lifecycle, mission model, support-target model, or authorization boundary.

The MVP support envelope is prepare-only until the existing run lifecycle
accepts a run-contract candidate. Engagement, Project Profile, per-engagement
Objective Brief, Work Package, Decision Request, context-pack request, connector
posture, generated read model, and run-contract candidate records may prepare
authorization, but none of them authorize material effects by themselves.

## Final v1 lifecycle

1. Start Engagement.
2. Run Safe Adoption Preflight.
3. Bind Authority.
4. Classify Project/Adoption State.
5. Orient and create retained evidence.
6. Create or reconcile Project Profile.
7. Capture seed intent.
8. Create per-engagement Objective Brief candidate.
9. Reconcile Workspace Charter.
10. Decide run-only versus mission-required mode.
11. Compile Work Package.
12. Classify risk/materiality/reversibility.
13. Discover validation and tests.
14. Plan rollback and reversibility.
15. Reconcile support target.
16. Assess capability/tool/MCP connector posture.
17. Select Evidence Profile.
18. Prepare context-pack request.
19. Generate Decision Requests.
20. Create first run-contract candidate.
21. Return `ready_for_authorization`, `stage_only`, `requires_decision`,
    `blocked`, `denied`, or `escalate`.

## New standardized primitives

### Engagement

**Definition:** The top-level operator-facing assignment container for drop-in governed work in one repository context.

**Responsibilities:**

- hold seed intent and lifecycle status;
- bind project/adoption classification;
- reference Project Profile, Objective Brief, Work Package, Decision Requests, run-contract candidate, and evidence roots;
- provide the operator-facing status surface without becoming a parallel run lifecycle.

**Canonical placement:**

- portable contract: `framework/engine/runtime/spec/engagement-v1.schema.json`;
- constitutional contract registration: `framework/constitution/contracts/runtime/engagement-v1.schema.json` if needed by the contract family;
- operational truth: `state/control/engagements/<engagement-id>/engagement.yml`;
- retained evidence: `state/evidence/engagements/<engagement-id>/**`;
- generated read model: `generated/cognition/projections/materialized/engagements/<engagement-id>.yml`.

### Project Profile

**Definition:** Repo-local durable orientation authority backed by retained orientation evidence.

**Responsibilities:**

- record stable repo facts such as project type, language/toolchain, test commands, CI posture, ownership hints, protected zones, validation strategy, dependency surface, rollback constraints, and known risks;
- remain narrower than workspace charter and broader than a run-bound context pack;
- provide a reusable baseline for Work Package compilation.

**Placement:**

- portable schema: `framework/engine/runtime/spec/project-profile-v1.schema.json`;
- durable repo authority: `instance/locality/project-profile.yml`;
- profile source evidence: `state/evidence/project-profiles/<profile-id>/**` and `state/evidence/orientation/<orientation-id>/**`;
- generated projection only: `generated/cognition/projections/materialized/project-profile.yml`.

### Objective Brief

**Definition:** Per-engagement objective candidate/control state used to shape
one Work Package.

**Responsibilities:**

- capture the engagement-scoped objective summary, scope, done conditions, and
  acceptance criteria;
- cite the workspace-charter pair as higher authority;
- record reconciliation status without rewriting workspace authority;
- block or emit a Decision Request when the objective cannot be reconciled.

**Placement:**

- portable schema:
  `framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json`;
- control truth:
  `state/control/engagements/<engagement-id>/objective/objective-brief.yml`;
- evidence:
  `state/evidence/engagements/<engagement-id>/objective/**`.

The Objective Brief is not workspace-charter authority, does not rewrite
`instance/charter/workspace.md`, and cannot authorize execution.

### Work Package

**Definition:** The compiled plan/safety envelope that bridges objective, support posture, capability posture, validation, rollback, evidence, context, approvals, and run-contract readiness.

**Responsibilities:**

- compile the current Engagement, Project Profile, Objective Brief, charter reconciliation, risk/materiality, support target, capability posture, evidence profile, rollback plan, validation plan, context request, Decision Requests, and first run-contract candidate;
- produce a clear outcome: `ready_for_authorization`, `stage_only`, `blocked`, `denied`, or `requires_decision`;
- include the Autonomy Envelope as an internal section rather than adding a separate primitive.

**Placement:**

- portable schema: `framework/engine/runtime/spec/work-package-v1.schema.json`;
- control truth: `state/control/engagements/<engagement-id>/work-package.yml`;
- compilation evidence: `state/evidence/engagements/<engagement-id>/work-packages/<work-package-id>/**`;
- generated operator view: `generated/cognition/projections/materialized/work-packages/<work-package-id>.yml`.

### Decision Request

**Definition:** Unified operator-facing approval/escalation primitive that resolves internally into approval grant, denial, exception lease, revocation, risk acceptance, policy clarification, support/capability posture decision, or closure acceptance.

**Responsibilities:**

- stop users from needing to know the low-level approval/exception/revocation artifact family;
- preserve canonical control roots for approvals, grants, exceptions, and revocations;
- bind every human decision to Engagement, Work Package, run-contract candidate, and evidence.

**Placement:**

- portable schema: `framework/engine/runtime/spec/decision-request-v1.schema.json`;
- authority contract: `framework/constitution/contracts/authority/decision-request-v1.schema.json`;
- control truth: `state/control/engagements/<engagement-id>/decisions/<decision-id>.yml`;
- canonical low-level roots: `state/control/execution/approvals/**`, `state/control/execution/exceptions/**`, and `state/control/execution/revocations/**` remain the actual execution control artifacts;
- evidence: `state/evidence/decisions/<decision-id>/**`.

### Evidence Profile

**Definition:** Risk-scaled evidence-depth selection for orientation, stage-only, and repo-consequential work.

**v1 profiles:**

- `orientation-only` — preflight/orientation evidence only, no material repo mutation;
- `stage-only` — prepare, inspect, produce candidate artifacts, no live material effects;
- `repo-consequential` — full run evidence required for repo-local governed work.

**Placement:**

- portable schema: `framework/engine/runtime/spec/evidence-profile-v1.schema.json`;
- repo policy: `instance/governance/policies/evidence-profiles.yml`;
- run binding: included in Work Package and run-contract candidate `required_evidence`.

### Preflight Evidence Lane

**Definition:** Narrow constrained lane that permits adoption/orientation/context evidence creation before ordinary material execution authorization, while forbidding project-code mutation and external side effects.

**Purpose:** Resolve the bootstrap tension where context/orientation evidence may be required before authorization can decide whether a consequential run may proceed.

**Allowed:**

- adoption classification evidence;
- orientation scan evidence;
- Project Profile source evidence;
- context-pack request preparation;
- read-only repo inventory;
- operator-visible diagnostics.

**Forbidden:**

- project code mutation;
- generated/effective publication;
- service/tool/MCP effectful invocation;
- credential use;
- support-target widening;
- capability activation.

### Tool/MCP Connector posture

**Definition:** v1 stage-only posture model for future tool and MCP connector support.

**Responsibilities:**

- identify external connectors without authorizing effectful use;
- map each future connector operation to existing capability packs and material-effect classes;
- determine whether posture is `observe_only`, `dry_run`, `stage_only`, `blocked`, or `denied`;
- require future live connector work to pass support/capability admission, egress, credential, evidence, rollback, and authorization checks.

**Placement:**

- portable schema:
  `framework/engine/runtime/spec/tool-connector-posture-v1.schema.json`;
- connector policy and registry schemas:
  `framework/engine/runtime/spec/connector-posture-policy-v1.schema.json` and
  `framework/engine/runtime/spec/connector-posture-registry-v1.schema.json`;
- machine-readable repo posture:
  `instance/governance/connectors/{registry.yml,posture.yml}`.

Connector posture is stage/block/deny policy for Work Package readiness. It is
not support admission, capability admission, egress authority, or live execution
authority.

## Autonomy Envelope and Autonomy Window decisions

- **Autonomy Envelope:** merged into Work Package as an internal section. Separate primitive rejected for v1 to avoid concept sprawl.
- **Autonomy Window:** deferred to mission-runner phase. v1 preserves hooks by allowing Work Package to state whether mission mode is required and what lease/budget/breaker prerequisites would be needed, but it does not implement unattended mission continuation.

## Runtime outcomes

The compiler must return one of:

- `ready_for_authorization`: first run-contract candidate can be submitted to existing authorization.
- `stage_only`: preparation artifacts are available, but live material effects are not authorized.
- `requires_decision`: one or more Decision Requests block progress.
- `blocked`: missing required authority/evidence/support/capability/context/rollback facts.
- `denied`: policy or fail-closed route denies the request.
