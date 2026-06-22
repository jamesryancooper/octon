# Refined Prompt

**Original:** Create a prompt instructing to run through the program lifecycle end-to-end and then move to the delivery wrapper once the lifecycle has completed. Leverage subagents where useful.
**Refined:** 2026-06-20T11:54:33Z
**Context Depth:** standard
**Status:** generated from explicit user request

---

## Execution Persona

Act as the accountable Octon program-lifecycle orchestrator: senior governance/runtime engineer, conservative about authority boundaries, aggressive about deterministic validation, and willing to use subagents for bounded child-packet execution and independent verification.

## Repository Context

Target program:

`.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening`

Primary context and contracts:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening/architecture/child-packet-contract.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening/architecture/program-closeout-plan.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`

## Intent

Run the `operator-free-lifecycle-delivery-autonomy-hardening` proposal program through the proposal-program lifecycle end-to-end from its current state. After the lifecycle reaches its terminal completed posture with required child-owned evidence intact, hand off to the canonical `proposal-program-delivery` wrapper and drive delivery to the highest authorized outcome, preferably `cleaned`, without widening authority.

## Requirements

1. Bind repository ingress and lifecycle authority before action.
2. Treat the parent program as coordination only until lifecycle gates authorize later steps.
3. Run or resume the proposal-program lifecycle from current state, including review, child readiness, implementation orchestration, verification/correction, closeout, and archive readiness where authorized by the lifecycle contract.
4. Preserve child authority. Child manifests, subtype manifests, receipts, validation verdicts, promotion targets, acceptance criteria, closeout receipts, and archive metadata remain child-owned.
5. Use subagents where useful, especially for independent child packets and independent verification, but keep one accountable orchestrator for sequencing and final integration.
6. Respect dependency gates from `resources/child-packet-index.yml`; do not dispatch a child ahead of its declared dependencies.
7. After lifecycle completion only, invoke the delivery wrapper route:
   `/proposal-program-delivery target=.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening outcome=cleaned`
   If a profile or explicit run id is required, create or bind the minimum valid profile/run id required by the workflow contract.
8. If delivery cannot proceed because prerequisite evidence is missing, stale, contradictory, or outside local authority, stop and report `blocked` with the exact owning lifecycle or wrapper stage that must run next.

## Assumptions Made

- The target remains a proposal program with `program_execution_mode: gated-parallel`.
- Current status may still be `draft`; the executor must re-read live files before deciding the next route.
- The desired final delivery outcome is `cleaned` unless evidence or authorization only supports a lower outcome.
- Subagents may be used for bounded child packet work and verification, but may not own parent authority, Git mutation, delivery claims, or cleanup authorization.

## Negative Constraints

- Do not treat parent summaries as satisfying child receipts.
- Do not treat proposal-local files, generated outputs, dashboards, host state, chat history, or model memory as authority.
- Do not edit generated/effective outputs by hand; use owning generators and retain freshness evidence.
- Do not widen accepted promotion targets or child write scopes.
- Do not use PR fallback for branch-no-PR delivery work.
- Do not mutate Git, hosted branches, PR state, or branch cleanup outside `closeout-change` or `closeout-worktree`.
- Do not delete residue or worktree artifacts outside `repo-hygiene-cleanup` with cleanup authorization.
- Do not archive, move, or rename child packets directly from the delivery wrapper.
- Do not claim `implemented`, `archive-ready`, `landed`, `synced`, or `cleaned` without fresh owning evidence and a validating receipt.

## Sub-Tasks

1. Bind context:
   - Read `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`.
   - Read the target parent proposal, child registry, child-packet contract, closeout plan, proposal-program lifecycle contract, and delivery wrapper workflow.
   - Inspect current worktree and current target status before planning.

2. Plan lifecycle execution:
   - Determine the next legal proposal-program lifecycle route from the current files and receipts.
   - Emit a concise lifecycle plan showing route order, child dependency groups, expected receipts, validation gates, and subagent assignments.

3. Run parent review and readiness gates:
   - Run parent proposal standard, architecture proposal, program structure, and proposal review gates as required.
   - If the parent requires revision, revise only within the parent proposal scope and re-run the review gate.

4. Run child packet lifecycles with bounded subagents:
   - Dispatch subagents only after the relevant review/dependency gate is satisfied.
   - Suggested child groups:
     - Foundation P0: `complete-program-blocker-vector-planner-output`, `lifecycle-validator-runtime-resolver`, `proposal-program-execution-mode-normalization`, `normalized-child-terminal-evidence-summary`.
     - Diagnostics/freshness P1: `completed-plan-nonblocking-diagnostics`, `targeted-proposal-freshness-checks`, `batched-review-and-architecture-digest-refresh`.
     - Recovery: `autonomous-proposal-program-recovery-envelope`.
     - Delivery hardening: `delivery-retained-evidence-index`, `branch-no-pr-delivery-receipt-builder`, `branch-no-pr-bounded-authorization-envelope`.
   - Each child subagent must stay within its child packet, child promotion targets, and child evidence requirements.
   - The orchestrator must integrate outputs, run cross-child validators, and resolve conflicts.

5. Verify and correct:
   - Run the child-specific validators listed in the child registry.
   - Run parent validators including `validate-proposal-program-structure.sh`, `validate-proposal-program-child-readiness.sh`, `validate-proposal-program-readiness-projection.sh`, and `generate-proposal-registry.sh --check` where applicable.
   - Use verifier subagents for conformance, drift/churn, freshness, receipt completeness, and authority-boundary checks.
   - If validation fails, generate bounded correction prompts or perform scoped corrections only through the owning lifecycle route.

6. Close out the program lifecycle:
   - Confirm all required children are terminal with child-owned implementation, conformance, drift/churn, validation, closeout, and archive evidence.
   - Confirm parent child registry consistency, generated artifact freshness, retained evidence posture, worktree hygiene, lifecycle residue status, and no protected evidence deletion.
   - Generate and run the program closeout route only when its lifecycle prerequisites are satisfied.

7. Transition to delivery wrapper:
   - Only after the lifecycle is complete and closeout evidence allows delivery, invoke `proposal-program-delivery`.
   - Bind a valid delivery profile and delivery run id.
   - Let the wrapper coordinate publication freshness, packet closeout/archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene through the owning workflows.
   - Validate the aggregate delivery receipt with `validate-proposal-program-delivery-receipt.sh`.

8. Final report:
   - Report final lifecycle status, delivery outcome, receipts created or validated, validators run, subagents used, unresolved blockers, and any handoff owner if blocked.
   - Make no final support or delivery claim beyond the evidence-backed outcome.

## Risks And Edge Cases

- Parent lifecycle can appear complete while child receipts are stale or missing; fail closed and re-check child-owned evidence directly.
- Generated registry or artifact freshness may drift during implementation; refresh only via canonical generators.
- Branch-no-PR delivery has strict proof locks and PR fallback is forbidden.
- Delivery wrapper is mutating and must not be entered before lifecycle completion and wrapper prerequisites are satisfied.
- Subagents can create inconsistent edits if dependencies are ignored; the orchestrator must serialize dependency-sensitive children.

## Success Criteria

- The parent program lifecycle reaches a terminal completed posture with required receipts present and fresh.
- Every required child packet has child-owned terminal evidence and validators appropriate to its promotion targets.
- Parent closeout evidence proves no parent summary replaced child authority.
- The delivery wrapper runs only after lifecycle completion.
- The aggregate delivery receipt validates.
- The final outcome is accurately reported as `cleaned`, or the highest evidence-backed lower outcome, or `blocked` with the owning next route.

## Self-Critique Results

- Completeness: includes parent, child, lifecycle, delivery, validation, and authority boundaries.
- Ambiguity: target program and intended delivery wrapper are explicit; `cleaned` is treated as preferred, not assumed if unsupported.
- Feasibility: lifecycle may be long-running and mutating; prompt requires replanning from live state and fail-closed blockers.
- Quality: subagent use is bounded to child packets and verification, preserving a single accountable orchestrator.

## Refined Prompt

Run the `operator-free-lifecycle-delivery-autonomy-hardening` proposal program end-to-end through the Octon proposal-program lifecycle, then move to the canonical `proposal-program-delivery` wrapper only after the lifecycle is complete and evidence gates allow delivery.

Target:

`.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening`

Start by reading `AGENTS.md`, `.octon/instance/ingress/AGENTS.md`, the target parent `proposal.yml`, `resources/child-packet-index.yml`, `architecture/child-packet-contract.md`, `architecture/program-closeout-plan.md`, `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`, `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`, and `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.

Use one accountable orchestrator. Use subagents where useful for independent child packet lifecycle work and independent verification, but keep each subagent bounded to its assigned child packet, declared promotion targets, and child-owned evidence. Parent summaries may summarize child outcomes but must never satisfy child receipts or child authority.

Run or resume the legal proposal-program lifecycle route from current live state. Respect the child registry dependency gates. Review and authorize the parent and child packets where required, implement children through their own accepted packet routes, run child-specific validators, run parent program structure and child-readiness validators, complete verification/correction, and close out the parent only after all required children are terminal and their child-owned gates pass.

After the lifecycle is complete, transition to:

`/proposal-program-delivery target=.octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening outcome=cleaned`

Bind any required delivery profile and run id. Let the delivery wrapper coordinate publication freshness, packet closeout/archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene through their owning workflows. Validate the aggregate delivery receipt before making a final outcome claim.

Fail closed if any prerequisite evidence is missing, stale, contradictory, or outside local authority. Do not widen promotion targets, edit generated outputs by hand, use PR fallback for branch-no-PR work, mutate Git outside Change closeout, delete residue outside repo-hygiene-cleanup authorization, or claim `cleaned` without fresh owning proof.

Final response must include lifecycle status, delivery outcome, receipts created or validated, validators run, subagents used, unresolved blockers if any, and the exact next owning route if blocked.
