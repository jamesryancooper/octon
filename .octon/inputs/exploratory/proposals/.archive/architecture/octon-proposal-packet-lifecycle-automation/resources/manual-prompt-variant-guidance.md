# Manual Prompt Variant Guidance

- proposal: `octon-proposal-packet-lifecycle-automation`

## Purpose

This file preserves normalized guidance variants of the user's current manual
proposal packet prompts. These variants are source guidance for implementing
the `octon-proposal-packet-lifecycle` extension pack. They are not authority,
not final prompt text, and not a substitute for live repository grounding.

The implemented extension pack may refine wording, file names, and route
structure, but it must preserve the behavioral intent captured here unless a
live Octon standard or validator requires a stricter rule.

## Normalization Rules

- Treat every variant as a reusable meta-prompt pattern, not a one-off current
  Octon thesis.
- Derive current Octon framing from the live repository, canonical read order,
  proposal standards, subtype manifests, validators, and durable promotion
  targets.
- Use user-supplied target lenses, such as deterministic-workflow-first
  framing, only as inputs unless the live repository makes them authoritative.
- Convert "downloadable archive" language into canonical proposal packet
  materialization under `.octon/inputs/exploratory/proposals/<kind>/<id>/`.
- Convert "do not stop" language into bounded execution with evidence,
  validation, correction loops, and fail-closed terminal states.
- Use atomic or big-bang implementation only when the packet profile, user
  constraints, or migration risk requires it.
- Keep generated prompts and support artifacts under packet `support/**`.
- Keep source audits, evaluations, and requirements under packet `resources/**`.
- Preserve proposal non-authority and durable promotion target boundaries.

## Variant 1 - Audit-Aligned Proposal Packet Creation

Route: `create-proposal-packet`

Scenario: `audit-aligned-packet`

Use when the source input is an audit, constitutional consistency report,
finding set, or completion verdict that must be turned into a proposal packet.

Guidance:

- Preserve the complete audit under packet `resources/**`, normally
  `resources/source-audit.md`.
- Create a standard Octon proposal packet that maps every audit finding to:
  - a stable finding id,
  - repository evidence,
  - remediation artifact or implementation action,
  - acceptance criteria,
  - validation command or verification step,
  - closure evidence.
- Include required proposal artifacts outside `resources/**`, including
  manifests, target architecture or equivalent subtype content, gap map,
  implementation plan, validation plan, acceptance criteria, cutover checklist,
  rollback or stop policy, and closure certification plan.
- If the requested outcome is an unqualified complete verdict, define closure
  as zero unresolved findings or explicitly disallow deferral.
- If the source audit requires two consecutive clean validation passes, include
  that as packet acceptance and closeout evidence.
- Select atomic clean-break migration only when the audit, user request, or
  proposal profile requires it.

## Variant 2 - Concise Proposal Packet Creation

Route: `create-proposal-packet`

Scenario: `source-to-packet`

Use when the user provides compact requirements, a short target-state request,
or an evaluation summary and expects a complete Octon-aligned proposal packet.

Guidance:

- Expand concise input into a complete manifest-governed proposal packet.
- Preserve the full supplied evaluation or source material under `resources/**`.
- Fill all required proposal artifacts from live proposal standards and subtype
  requirements rather than relying on the user's short wording.
- Keep the output implementation-oriented, promotion-safe, and closure-ready.
- Ask for clarification only when the proposal kind, durable promotion target,
  or target state cannot be reasonably inferred from repository context.

## Variant 3 - Architectural Evaluation Proposal Packet Creation

Route: `create-proposal-packet`

Scenario: `architecture-evaluation-packet`

Use when the input is an architecture evaluation, score target, quality review,
or gap-to-target assessment.

Guidance:

- Ground the packet in the live repository state, not an abstract ideal.
- Preserve the complete evaluation and supporting analysis under
  `resources/**`.
- Include current-state evaluation, target-state gaps, risks, tradeoffs,
  required changes, and validation strategy.
- If the user supplies a score target such as "10/10", translate it into
  concrete structural, enforcement, runtime, proof, governance, maintainability,
  and boundary-discipline requirements.
- Avoid rhetorical score inflation. The packet must identify what actually
  prevents the target score and how each blocker is closed.
- Clearly distinguish authored authority, generated/read-model outputs,
  state/control surfaces, state/evidence surfaces, implemented runtime reality,
  architecture intent, and proposal-local analysis.
- Do not invent a rival control plane.

## Variant 4 - Highest-Leverage Next-Step Proposal Packet Creation

Route: `create-proposal-packet`

Scenario: `highest-leverage-next-step-packet`

Use when the input is a target thesis plus a request to choose the single best
next proposal packet.

Guidance:

- Inspect the live repository before selecting the implementation target.
- Treat the user's target thesis as an input lens unless already authoritative
  in the live repository.
- Select one highest-leverage next step, not a broad redesign.
- If the live repo shows a narrower prerequisite is required first, choose that
  prerequisite and explain why.
- Include focused current-state evaluation, target gap analysis, dependency
  rationale, implementation plan, validation plan, acceptance criteria,
  rollback or stop policy, operator disclosure, and follow-on signposts.
- Keep later packets out of scope unless required to implement the selected
  step correctly.
- Explicitly prevent prompts, generated projections, raw inputs, external
  dashboards, GitHub state, browser state, model memory, MCP/tool availability,
  Durable Object state, or external workflow engines from becoming Octon
  authority, control truth, runtime policy, or permission.

## Variant 5 - Proposal Packet Closeout Prompt

Route: `generate-closeout-prompt`

Execution route: `closeout-proposal-packet`

Use after implementation and verification are complete enough to close out the
proposal packet.

Guidance:

- Generate a packet-specific closeout prompt from the implemented packet,
  current repo state, current PR/check state, and closeout gates.
- Archive or update the proposal packet using existing proposal lifecycle
  workflows.
- Preserve required generated outputs and evidence outputs.
- Run housekeeping before staging.
- Exclude incidental build, output, cache, local log, and scratch artifacts.
- Decide intentionally whether prompt scaffolding or local skill logs belong in
  the final changeset.
- Stage only intended files.
- Create a compliant commit and PR.
- Investigate and fix every failing required check, job, and script.
- Re-run checks until required checks are green.
- Verify and resolve every open review conversation before merge.
- Merge only when checks are green and review conversations are resolved.
- Clean up local and remote branches and confirm local/origin sync.

## Variant 6 - Executable Implementation Prompt Generation

Route: `generate-implementation-prompt`

Use when an existing proposal packet needs a complete packet-specific execution
prompt.

Guidance:

- Re-read the packet, manifests, promotion targets, acceptance criteria,
  validation plan, risk register, and support artifacts.
- Re-ground against the live repository before implementing.
- Convert broad "do not stop" intent into bounded execution:
  - implement declared durable targets,
  - record evidence,
  - run validation,
  - generate correction prompts for findings,
  - fail closed on blockers that require packet revision or user decision.
- Use subagents only when the execution environment and task decomposition
  support safe parallel work.
- Do not let the implementation prompt broaden the packet beyond its declared
  scope or promote proposal-local analysis as authority.

## Variant 7 - Evaluation Prompt Refresh

Route: `create-proposal-packet` preflight or `explain-proposal-packet` support

Use when an existing evaluation prompt may have drifted from Octon's current
architecture.

Guidance:

- Re-ground the evaluation prompt against the current repository before reuse.
- Identify changed architecture, terminology, authority, runtime, validation,
  or publication surfaces that affect the evaluation lens.
- Update the evaluation prompt only as needed to match current repo authority.
- Preserve the old evaluation prompt as source context when it materially
  influenced packet creation.

## Variant 8 - Proposal Packet Explanation

Route: `explain-proposal-packet`

Use when the user asks what a packet does, what durable state it would promote,
or how it prepares follow-on work.

Guidance:

- Explain the problem the packet solves.
- Explain the target state after implementation.
- Explain what becomes durable authority if promoted.
- Distinguish promoted authored authority from runtime control truth, generated
  outputs, proposal-local analysis, and support prompts.
- Name affected repository surfaces and their purpose.
- Explain how the packet improves Octon using live repository framing.
- Identify follow-on work without expanding the current packet's scope.
- Keep the explanation repository-grounded, scope-bounded, promotion-safe, and
  strict about not creating a rival control plane.

## Variant 9 - Follow-Up Verification Prompt Creation

Route: `generate-verification-prompt`

Use after a packet implementation claims completion.

Guidance:

- Generate a packet-specific verification prompt that checks implementation
  against manifests, acceptance criteria, implementation plan, validation plan,
  promotion targets, evidence expectations, and residual risks.
- Require live repository inspection before verdict.
- Emit findings with stable ids, severity, affected paths, evidence, expected
  behavior, correction scope, and acceptance criteria.
- Identify whether each finding requires implementation correction, packet
  revision, explicit deferral, or closeout blocker handling.
- Feed unresolved findings into `generate-correction-prompt` and the
  verification/correction convergence loop.

## Implementation Use

The extension pack should use these variants to seed scenario fixtures,
bundle-stage examples, route companion prompts, and validation expectations.
It should not copy these variants verbatim when a more precise prompt contract
fits the implemented pack structure better.
