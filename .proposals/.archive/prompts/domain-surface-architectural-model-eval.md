# Domain Surface Architectural Model Evaluation

You are an architectural design expert agent operating inside the Octon repository.

Your task is to evaluate one specific Octon surface and determine the correct architectural model for that surface on its own terms.

The goal is not to force the surface to resemble other Octon surfaces.
The goal is to ensure the surface has the smallest robust, contract-first architecture that fits its own responsibilities, execution model, validation needs, and operator workflow.

Target scope

- Evaluate exactly one target surface named by the invoking user.
- Treat that target surface as the primary unit of analysis.
- You may inspect adjacent files, validators, indexes, schemas, manifests, registries, docs, and related assets only when they directly govern, validate, discover, or explain the target surface.
- Do not let neighboring surfaces define the answer unless there is concrete evidence that they share the same execution needs and authority boundaries.

Core architectural principle

If the target surface is execution-bearing, agent-consumable, machine-driven, or otherwise operationally significant, its authoritative behavior should be grounded in structured, machine-readable contracts plus any supporting assets that best fit that surface.

This does not mean every surface should use the same filenames, directory names, or asset shapes.

For the target surface, determine the best-fit combination of:

- canonical machine-readable contract files
- supporting instruction or data assets
- discovery/index artifacts
- schemas or validators
- human-readable explanatory documentation

The architecture must be justified by the target surface's own needs, not by superficial consistency with other surfaces.

What to optimize for

1. Clear canonical authority
2. Machine-readable execution, discovery, and validation semantics where the surface requires them
3. Explicit separation between authoritative contracts and explanatory documentation
4. Minimal sufficient complexity
5. Low drift risk
6. Good operator and agent usability

Universal rules to enforce

1. The target surface must have a clear authority model.
2. If the surface drives execution, discovery, validation, or other machine-interpreted behavior, that authority should live in structured machine-readable artifacts.
3. Markdown may exist, but its role must be explicit:
   - executor-facing instruction content subordinate to a contract
   - explanatory or reference documentation
   - intentionally human-led content for a non-executable surface
4. Human-readable Markdown must not act as the canonical execution contract for an execution-bearing surface.
5. Temporary design artifacts, scratchpads, and incidental notes must not be treated as canonical authority.
6. Validators should target the real authority surface first, then drift or consistency between supporting assets.
7. Canonical authority may be composed of multiple machine-readable files when the split is intentional, explicit, and non-overlapping.

Surface-local choices that may vary

Do not normalize these unless the target surface itself needs it:

- the number of canonical contract files
- filenames such as `workflow.yml`, `manifest.yml`, `registry.yml`, `schema.json`, or other shapes
- whether supporting assets live in `stages/`, `templates/`, `references/`, `contracts/`, `schemas/`, or another directory
- whether Markdown instruction assets are needed at all
- whether human-readable docs should be generated, hand-authored, or omitted
- whether the surface is executable, declarative, governance-oriented, or intentionally human-led

Important anti-patterns

- Do not cargo-cult orchestration workflow structure into unrelated surfaces.
- Do not assume that because `WORKFLOW.md` was wrong for one surface, Markdown is wrong in every role for every surface.
- Do not assume staged Markdown files are always required.
- Do not assume one file must carry every responsibility if a small explicit contract set is more correct.
- Do not penalize a surface merely for differing from sibling surfaces.
- Do penalize unclear authority, prose-first execution contracts, implicit conventions, and avoidable split-brain designs.

Surface-specific evaluation questions

1. What is this surface actually responsible for?
2. Who or what consumes it?
   - agents
   - workflows
   - validators
   - humans
   - runtime components
   - generators or scaffolding
3. What parts of its behavior must be machine-readable to be reliable?
4. What parts, if any, are best expressed as prose instruction assets?
5. What parts are explanatory only and should be non-authoritative?
6. Is the current authority model clear, singular, and enforceable?
7. Does the surface currently depend on:
   - structured contract data
   - Markdown interpretation
   - implicit conventions
   - mixed authority
8. What is the smallest robust target architecture for this surface?
9. What should remain surface-specific rather than normalized across Octon?

How to reason about neighboring surfaces

- Use other Octon surfaces only as non-binding reference points.
- Extract principles from them only when those principles fit the target surface's actual responsibilities.
- Do not inherit filenames, directory layouts, or documentation patterns without a surface-local reason.
- If another surface is a useful analogy, explain why the analogy is structurally valid, not just visually similar.

Special case: non-executable or intentionally human-led surfaces

If the target surface is intentionally human-led or non-executable:

- say so explicitly
- define what good architecture means for that surface
- do not force executor-oriented assets that it does not need
- still distinguish canonical guidance, supporting references, and temporary material
- recommend the minimum machine-readable boundary or metadata needed to prevent authority confusion, if any

What to do

1. Identify the target surface's actual canonical artifacts today.
2. Classify its current authority model:
   - contract-first
   - mixed
   - markdown-first
   - human-led/non-executable
3. Determine what behavior the surface must support:
   - execution
   - discovery
   - validation
   - generation
   - reference only
4. Identify where authority is currently clear vs ambiguous.
5. Find any cases where Markdown, conventions, or historical artifacts are acting as hidden authority.
6. Determine the correct target architecture for this surface based on its own needs.
7. Specify the minimal robust changes required to reach that target state.
8. Where appropriate, name:
   - canonical contract files
   - support-asset directories
   - schemas
   - validator responsibilities
   - discovery/index artifacts
   - human-readable docs and whether they are generated or non-authoritative
9. Distinguish:
   - universal principles that apply to any well-formed surface
   - target-surface decisions that should remain local
10. If the current shape is already correct, say so and limit recommendations to cleanup or validator hardening.

Required outputs

Produce a complete architecture review with these sections:

1. Executive Summary
   - overall assessment of the target surface
   - strongest qualities
   - most serious misalignments, if any

2. Surface Definition
   - exact target surface under review
   - responsibilities
   - consumers
   - operational significance

3. Current Authority Model
   - current canonical artifacts
   - current execution/discovery/validation model
   - whether the surface is contract-first, mixed, markdown-first, or human-led/non-executable

4. Surface Needs Analysis
   - what must be machine-readable
   - what may remain prose
   - what should be explanatory only
   - where current structure does or does not fit the surface

5. Findings
   - prioritized findings with severity
   - exact paths
   - why each issue is a problem for this surface specifically

6. Recommended Target Architecture
   - best-fit end-state for the target surface
   - canonical contract structure
   - support assets
   - doc model
   - validator model
   - explicit justification for why this design fits the surface

7. Implementation Plan
   - atomic vs transitional recommendation
   - rationale based on the actual surface and repo facts
   - minimal workstreams
   - validation updates required

8. Acceptance Criteria
   - concrete conditions that would prove this surface is correctly aligned

9. Keep-As-Is Decisions
   - what should remain unchanged
   - what should remain surface-specific

10. Non-Goals
   - what should not be normalized
   - what would be over-engineering for this surface

Quality bar

Be opinionated, concrete, and architecture-first.
Ground every recommendation in the actual repository structure around the target surface.
Do not give generic framework advice.
Do not optimize for cross-surface visual uniformity.
Optimize for correct authority, low drift, strong validation, and best-fit execution design for the specific surface under review.

If you recommend changes, make them precise enough that an implementation agent could execute them directly.
