# Prompt: Implement Deferred Governed Runtime Evaluation Children

Use this prompt to create, review, implement, validate, close out, and archive
the three deferred evaluation candidates from the archived
`governed-workflow-runtime-transition-program`.

This file is an advisory exploratory plan. It is not proposal authority,
runtime authority, policy, validation evidence, or closeout evidence.

## Starting Point

The archived parent program is:

- `.octon/inputs/exploratory/proposals/.archive/architecture/governed-workflow-runtime-transition-program`

The deferred candidates are recorded as optional, non-required, uncreated, and
lab-only in:

- `.octon/inputs/exploratory/proposals/.archive/architecture/governed-workflow-runtime-transition-program/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/.archive/architecture/governed-workflow-runtime-transition-program/support/deferred-evaluation-child-disposition.md`
- `.octon/state/evidence/validation/proposals/governed-workflow-runtime-transition-program/deferred-evaluation-child-disposition-2026-06-09.md`

The deferred candidate ids are:

- `durable-coordination-adapter-evaluation`
- `mcp-integration-evaluation`
- `external-workflow-engine-adapter-evaluation`

## Objective

Implement the deferred evaluation children as child-owned proposal packets.
Do not use the archived parent to satisfy any child manifest, receipt,
validator, promotion target, acceptance criterion, archive metadata, retained
evidence, or implementation authority.

The target outcome is one of these explicitly evidenced states for each
candidate:

- implemented, validated, closed out, and archived as a child-owned proposal;
- rejected with child-owned evaluation evidence and retained rationale;
- superseded by a named child-owned successor packet; or
- still deferred with fresh retained evidence explaining why implementation is
  not currently authorized.

Do not leave any candidate as an unexplained missing path.

## Authority Boundaries

Preserve these boundaries throughout the work:

- Durable coordination adapters may be evaluated only as replaceable live
  coordination adapters. They must not store canonical Octon control truth,
  retained evidence, authority decisions, support claims, closeout truth, or
  durable policy.
- MCP may be evaluated only as connector/protocol input. MCP descriptors,
  servers, tools, prompts, and resources are never permission, support
  admission, runtime policy, retained evidence, or authority.
- External workflow engines may be evaluated only as adapters, executors, or
  lab targets. They must not own Octon workflow truth, run truth, closeout
  truth, support claims, or authorization decisions.
- Raw `inputs/**`, generated projections, host affordances, external
  dashboards, tool availability, chat transcripts, model memory, and agent
  outputs are non-authoritative.
- Support-target or adapter-backed live claims require proof-backed admission,
  disclosure coverage, negative controls, and retained evidence before they
  can enter the admitted support universe.

## Required Workflow

1. Read repository ingress and proposal rules:
   - `AGENTS.md`
   - `.octon/instance/ingress/AGENTS.md`
   - `.octon/inputs/exploratory/proposals/README.md`
   - `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
   - `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
   - `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
   - `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
   - `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
2. Verify the archived parent and prerequisite children still match current
   state before creating new packets.
3. Select exactly one `change_profile` and record a Profile Selection Receipt.
4. Decide whether these three candidates need a new follow-up parent proposal
   program. Prefer standalone child packets if dependency sequencing is simple;
   create a new parent only if coordination evidence, aggregate child registry,
   or shared closeout sequencing is materially needed.
5. Create child-owned architecture proposal packets for the candidates that are
   being implemented. Each packet must include all required proposal files,
   a child-specific scope statement, promotion targets outside proposal paths,
   acceptance criteria, validation plan, rollback posture, and explicit
   non-authority statements.
6. For each child packet, run the proposal lifecycle:
   - create packet;
   - review packet;
   - obtain a fresh accepted `support/proposal-review.md` with implementation
     authorization;
   - produce `support/implementation-grade-completeness-review.md`;
   - generate `support/executable-implementation-prompt.md`;
   - implement only the child-owned durable targets;
   - retain child validation evidence under
     `.octon/state/evidence/validation/proposals/<child-id>/...`;
   - write `support/implementation-run.md`;
   - write `support/validation.md`;
   - write and pass `support/implementation-conformance-review.md`;
   - write and pass `support/post-implementation-drift-churn-review.md`;
   - write `support/proposal-closeout.md`;
   - archive only when archive authorization is earned.
7. Regenerate and check the proposal registry and any generated proposal
   indexes touched by the work.
8. Close out the Change using the appropriate route. End with a clean worktree,
   no stashes, synced `main` and `origin/main`, and no active implemented or
   archive-authorized proposal left unarchived.

## Recommended Child Packet Scope

### `mcp-integration-evaluation`

Evaluate MCP as a bounded connector/protocol input surface.

Candidate durable outputs may include:

- lab-only MCP adapter evaluation notes under `.octon/framework/lab/`;
- connector admission candidate records under
  `.octon/instance/governance/connector-admissions/`;
- adapter-boundary documentation or schema additions under
  `.octon/framework/constitution/contracts/adapters/`;
- validation scripts or fixtures proving MCP cannot widen authority, support
  claims, permissions, or evidence truth.

Required evidence:

- positive lab scenario for admitted read-only or stage-only MCP use;
- negative controls proving MCP resources, prompts, and tool listings are not
  authority, permission, policy, retained evidence, or support admission;
- drift check proving no runtime route consumes MCP availability as authority.

### `durable-coordination-adapter-evaluation`

Evaluate durable coordination adapters as replaceable coordination support,
not as canonical Octon state.

Candidate durable outputs may include:

- lab-only durable coordination adapter boundary notes under
  `.octon/framework/lab/`;
- adapter conformance criteria under
  `.octon/framework/constitution/contracts/adapters/`;
- connector admission or exclusion records under
  `.octon/instance/governance/connector-admissions/`;
- retained lab evidence under `.octon/state/evidence/lab/`.

Required evidence:

- positive lab scenario for coordination handoff or observation support;
- negative controls proving canonical run control, evidence retention,
  authority decisions, support claims, and closeout truth remain local Octon
  surfaces;
- rollback or quarantine posture for adapter unavailability, stale state, or
  digest drift.

### `external-workflow-engine-adapter-evaluation`

Evaluate external workflow engines as replaceable adapters or executors, not
as Octon workflow authority.

Candidate durable outputs may include:

- lab-only external engine adapter evaluation notes under
  `.octon/framework/lab/`;
- adapter conformance criteria under
  `.octon/framework/constitution/contracts/adapters/`;
- connector admission or exclusion records under
  `.octon/instance/governance/connector-admissions/`;
- validation scripts or fixtures proving external engine state cannot own Octon
  run state, workflow state, closeout truth, or authorization.

Required evidence:

- positive lab scenario for external execution observation or delegated
  stage-only execution;
- negative controls proving Octon workflow truth, run truth, closeout truth,
  support claims, and authorization remain governed by local Octon authority;
- replay or trace evidence showing external execution can be reconciled back to
  Octon retained evidence without becoming the evidence store.

## Validation Floor

Run at least:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child> --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Add child-specific validators for any new schema, adapter admission contract,
lab evidence contract, negative control, generated index, or runtime-facing
route touched by the implementation.

## Refusal And Stop Conditions

Stop and route to correction, rejection, or supersession if:

- an archived prerequisite child has drifted or no longer satisfies its
  implementation claim;
- the work would require reopening or rewriting the archived parent without an
  explicit operator-approved correction/supersession route;
- a child tries to use parent aggregate evidence as its own implementation,
  validation, closeout, archive, or promotion evidence;
- implementation requires a live support claim but lacks proof-backed support
  admission, disclosure, negative controls, and retained evidence;
- a candidate cannot produce behavior or boundary evidence beyond prose;
- a new dependency is required but no Dependency Receipt justifies it;
- ownership of the durable target is ambiguous.

## Required Final Report

Report:

- archived parent and prerequisite-child re-verification result;
- created child packet paths;
- disposition of each candidate;
- durable outputs promoted by each child;
- retained evidence locations;
- validation commands and outcomes;
- proposal registry/index regeneration result;
- final git state and closeout route.
