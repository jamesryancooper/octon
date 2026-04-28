# Engagement / Project Profile / Work Package Compiler v1

## Purpose

The compiler is the product-level preparation layer above the run lifecycle. It
turns a seed operator intent into retained adoption evidence, a Project Profile,
a Work Package, Decision Requests, a context-pack request, and a first
run-contract candidate.

The compiler does not replace `run-contract-v3`, the Run Journal, authority
artifacts, context-pack receipts, support-target admissions, or generated handle
freshness rules. Material execution still enters through:

```text
octon run start --contract .octon/state/control/execution/runs/<run-id>/run-contract.yml
```

## MVP Boundary

The v1 compiler is a prepare-only readiness surface until the existing runtime
authorization path accepts a run contract. It may prepare and retain Engagement,
Project Profile, per-engagement Objective Brief, Work Package, Decision Request,
context-pack request, connector posture, and run-contract candidate records, but
none of those records authorizes material effects by itself.

The per-engagement Objective Brief is candidate/control state scoped to one
Engagement. It is not the workspace charter, does not rewrite
`.octon/instance/charter/workspace.md`, and cannot authorize execution.

Connector posture is machine-readable policy under
`.octon/instance/governance/connectors/posture.yml`. MCP, API, and browser
connector classes are stage-only, blocked, or denied for v1 live effects unless
future support-target admission, capability admission, egress, credential,
rollback, evidence, and runtime authorization gates are promoted.

Generated compiler read models are optional projections only. They must remain
non-authoritative and forbidden as runtime, policy, support, or approval inputs.

## Canonical Control Shape

Mutable compiler control truth lives under:

- `.octon/state/control/engagements/<engagement-id>/engagement.yml`
- `.octon/state/control/engagements/<engagement-id>/objective/objective-brief.yml`
- `.octon/state/control/engagements/<engagement-id>/work-package.yml`
- `.octon/state/control/engagements/<engagement-id>/decisions/<decision-id>.yml`
- `.octon/state/control/engagements/<engagement-id>/context/context-pack-request.yml`
- `.octon/state/control/engagements/<engagement-id>/run-candidates/<run-id>/run-contract.yml`

Control records summarize current compiler state only. They may point at the
run-contract candidate, but they do not authorize the candidate and do not make
the candidate executable.

The per-engagement Objective Brief is candidate/control state scoped to one
Engagement. It may cite the workspace-charter pair as higher authority, but it
is not workspace-charter authority and does not rewrite the workspace charter.

Connector posture is resolved from machine-readable repo governance:

- `.octon/instance/governance/connectors/posture.yml`
- `.octon/instance/governance/connectors/registry.yml`

README or prose-only connector documentation is insufficient authority. The
Work Package may cite connector posture to stage, block, deny, or request a
decision, but connector posture does not authorize live connector effects.

## Retained Evidence Shape

The compiler retains preparation evidence under:

- `.octon/state/evidence/engagements/<engagement-id>/adoption-preflight/**`
- `.octon/state/evidence/engagements/<engagement-id>/classification/**`
- `.octon/state/evidence/engagements/<engagement-id>/objective/**`
- `.octon/state/evidence/engagements/<engagement-id>/profiling/**`
- `.octon/state/evidence/engagements/<engagement-id>/work-packages/<work-package-id>/**`
- `.octon/state/evidence/orientation/<orientation-id>/**`
- `.octon/state/evidence/project-profiles/<profile-id>/source-facts/**`
- `.octon/state/evidence/decisions/<decision-id>/**`
- `.octon/state/evidence/engagements/<engagement-id>/run-contract-readiness/**`

Preflight evidence is allowed before ordinary material execution authorization
only inside the Preflight Evidence Lane. It is retained proof for preparation,
not proof of an executed run.

## Continuity Shape

Engagement resumability is operator handoff state:

- `.octon/state/continuity/engagements/<engagement-id>/handoff.yml`

It may reference engagement control and retained evidence. It must not replace
either, and it must not authorize execution.

## Generated Read Models

Generated operator views are optional:

- `.octon/generated/cognition/projections/materialized/engagements/<engagement-id>.yml`
- `.octon/generated/cognition/projections/materialized/work-packages/<work-package-id>.yml`
- `.octon/generated/cognition/projections/materialized/project-profile.yml`

Every generated compiler projection must declare `authority_status:
non_authoritative`, cite source control/evidence refs, and remain forbidden as a
runtime, policy, support, or approval source.

## Compiler Stages

1. `start_engagement` creates the draft Engagement control record.
2. `adoption_preflight` writes non-invasive adoption and classification
   evidence.
3. `bind_authority` verifies ingress, charter, governance, support, and
   registry refs.
4. `profile_project` writes orientation evidence before a Project Profile can
   be retained.
5. `shape_objective` writes a per-engagement Objective Brief candidate under
   engagement control and retains backing objective evidence.
6. `decide_mode` returns run-only, mission-required, stage-only, blocked, or
   denied.
7. `compile_work_package` assembles plan, risk, validation, rollback, support,
   capability, evidence, context, Decision Request, and run-candidate posture.
8. `prepare_context_pack_request` prepares a request for the existing Context
   Pack Builder.
9. `emit_candidate_run_contract` writes a candidate only. Existing run
   authorization remains required.

## Fail-Closed Rules

The compiler returns `blocked`, `denied`, `stage_only`, or `requires_decision`
when any of these are missing or invalid:

- authority binding evidence
- retained orientation evidence for Project Profile facts
- support-target posture
- capability and connector posture
- context-pack request readiness
- rollback posture for repo-consequential work
- required Decision Request or canonical low-level authority artifact
- generated projection non-authority metadata

`inputs/**`, proposal-local paths, generated read models, host UI state, and
chat transcripts are invalid authority inputs after promotion.

## Related Contracts

- `.octon/framework/engine/runtime/spec/engagement-work-package-compiler-v1.md`
- `.octon/framework/engine/runtime/spec/engagement-v1.schema.json`
- `.octon/framework/engine/runtime/spec/project-profile-v1.schema.json`
- `.octon/framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json`
- `.octon/framework/engine/runtime/spec/work-package-v1.schema.json`
- `.octon/framework/engine/runtime/spec/decision-request-v1.schema.json`
- `.octon/framework/engine/runtime/spec/evidence-profile-v1.schema.json`
- `.octon/framework/engine/runtime/spec/preflight-evidence-lane-v1.md`
- `.octon/framework/engine/runtime/spec/connector-posture-policy-v1.schema.json`
- `.octon/framework/engine/runtime/spec/connector-posture-registry-v1.schema.json`
- `.octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json`
- `.octon/framework/engine/runtime/spec/connector-posture-policy-v1.schema.json`
- `.octon/framework/engine/runtime/spec/connector-posture-registry-v1.schema.json`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/constitution/contracts/runtime/run-contract-v3.schema.json`
- `.octon/instance/governance/policies/engagement-work-package-compiler.yml`
- `.octon/instance/governance/policies/evidence-profiles.yml`
- `.octon/instance/governance/policies/preflight-evidence-lane.yml`
- `.octon/instance/governance/connectors/posture.yml`
- `.octon/instance/governance/engagements/path-families.yml`
