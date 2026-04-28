# Implementation Plan

## Phase 1 — Contracts and registry hooks

1. Add `engagement-v1.schema.json` under runtime spec and constitutional runtime contract family as needed.
2. Add `project-profile-v1.schema.json`.
3. Add `work-package-v1.schema.json`.
4. Add `decision-request-v1.schema.json` and map it to canonical approval/exception/revocation roots.
5. Add `evidence-profile-v1.schema.json`.
6. Add `preflight-evidence-lane-v1.md` and policy file.
7. Add `tool-connector-posture-v1.schema.json` with v1 stage-only semantics.
8. Register all new contracts in the relevant contract and architecture registries.

## Phase 2 — Control and evidence roots

1. Create `state/control/engagements/<engagement-id>/` contract expectations.
2. Define `state/evidence/engagements/<engagement-id>/**` retained evidence expectations.
3. Define `state/evidence/orientation/<orientation-id>/**` evidence bundle shape.
4. Define `state/evidence/project-profiles/<profile-id>/**` profile-source evidence shape.
5. Define Decision Request evidence roots.
6. Define generated operator read-model paths under `generated/cognition/projections/materialized/**` as projections only.

## Phase 3 — Compiler pipeline

Implement compiler stages:

1. `start_engagement`: create draft Engagement and seed intent record.
2. `adoption_preflight`: non-invasive repo scan and adoption classification.
3. `bind_authority`: verify ingress, charter pair, support targets, policies, contract registry, and root class placement.
4. `profile_project`: create orientation evidence and Project Profile draft/reconciliation.
5. `shape_objective`: create a per-engagement Objective Brief candidate and workspace-charter reconciliation result.
6. `decide_mode`: run-only, mission-required, stage-only, blocked, or denied.
7. `compile_work_package`: plan, risk, validation, rollback, support, capability, evidence, context, Decision Request, and run-contract candidate.
8. `prepare_context_pack_request`: create request binding for existing context-pack builder.
9. `emit_candidate_run_contract`: produce run-contract v3 candidate without live material effects.

## Phase 4 — Runtime CLI integration

Add MVP commands:

- `octon start [--intent <text>] [--prepare-only]`
- `octon profile --engagement-id <id>`
- `octon plan --engagement-id <id>`
- `octon arm --engagement-id <id> --prepare-only`
- `octon decide --engagement-id <id> --decision-id <id> --response <approve|deny|accept-risk|clarify|revoke>`
- `octon status --engagement-id <id>`

Decision Requests remain compiler control records that resolve into canonical
approval, exception, revocation, risk, or evidence artifacts before live
effects. `octon decide` does not authorize material execution by itself.

Integrate with existing:

- `octon run start --contract <path>`
- `octon run inspect --run-id <id>`
- `octon run close --run-id <id>`
- `octon run replay --run-id <id>`
- `octon run disclose --run-id <id>`

## Phase 5 — Validators and tests

Add validators that fail closed when:

- Engagement lacks authority binding evidence;
- Project Profile is written without retained orientation evidence;
- Work Package lacks support/capability/context/evidence/rollback/risk sections;
- Decision Request tries to replace canonical approvals/exceptions/revocations;
- non-admitted connector is marked live;
- generated/read-model output is consumed as authority;
- proposal-local files are referenced by durable targets after promotion.

## Phase 6 — MVP cutover

1. Implement one Engagement, one Project Profile, one per-engagement Objective Brief candidate, one Work Package, one Decision Request set, one context-pack request, and one run-contract candidate.
2. Limit live capability posture to repo-local admitted packs.
3. Treat MCP/API/browser connector operations as stage-only, blocked, or denied
   unless future admission and authorization gates are promoted.
4. Run existing `octon run start --contract` only after compiler output passes validation and authorization readiness.
