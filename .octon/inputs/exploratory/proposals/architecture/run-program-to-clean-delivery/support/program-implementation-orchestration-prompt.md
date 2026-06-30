# Program Implementation Orchestration Prompt

program_implementation_orchestration_prompt_id: run-program-to-clean-delivery-program-implementation-orchestration-prompt-20260629T152100Z
route_id: generate-program-implementation-orchestration-prompt
prompt_set_id: octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt
run_id: 20260629T152100Z-run-program-to-clean-delivery-parent-orchestration-prompt
generated_at: 2026-06-29T15:21:00Z
parent_program_path: .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
authority_class: proposal-local generated prompt; non-authority

Read and follow `AGENTS.md` first.

## Execution Persona

Act as the accountable Octon lifecycle orchestrator for the parent proposal
program. Coordinate the already child-owned implementation evidence, rerun the
minimum required validators, route any stale or failed child evidence through
the owning child route, and write only parent-local aggregate orchestration
evidence.

Do not treat this prompt, the parent program, child packets, generated outputs,
chat/model memory, host UI state, tool availability, or raw inputs as durable
authority. Durable implementation authority remains with authored repository
surfaces and target-owned receipts.

## Target

Parent proposal program:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`

Expected route outcome:

- `support/program-implementation-orchestration-run.md` exists.
- The run receipt reports `verdict: pass` only when every required child
  implementation receipt validates from the child packet itself.
- The run receipt includes at least `verdict`, `implemented_at`,
  `promotion_evidence_count`, and `child_authority_preserved`.
- `child_authority_preserved` is `yes`.
- Parent evidence cites child evidence by repo-relative path and digest only.

This prompt authorizes implementation orchestration execution only. It does
not authorize proposal closeout, archive relocation, Change delivery, branch
landing, branch cleanup, deletion, external publication, or a cleaned terminal
claim.

## Bound Context

- `release_state: pre-1.0`
- `change_profile: atomic`
- `program_execution_mode: sequential`
- Parent status before this prompt: `accepted`
- Child readiness gate before this prompt: passing
- Required children: 6
- Required, non-deferred children currently claim `implemented`
- Current child promotion evidence total from child implementation-run receipts:
  42

## Required Preflight

Run these parent gates before writing or refreshing the parent orchestration
run receipt:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
```

If any preflight fails, stop and report the owning route. Do not hand-edit
review digests, child manifests, implementation receipts, generated effective
outputs, lifecycle state, or control truth.

## Child Packet Sequence

Process children in this exact sequence:

1. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture`
2. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing`
3. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff`
4. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata`
5. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators`
6. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`

For each child, use the child packet's own `proposal.yml`,
`architecture-proposal.yml`, implementation plan, validation plan, promotion
targets, acceptance criteria, authority notes, and support receipts. The parent
summary must never replace those inputs.

## Child Evidence Checks

For every child in sequence, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child> --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
```

For each child, retain a parent aggregate citation to these child-owned files
with `sha256` digests:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

If a child is no longer implemented, is missing implementation evidence, or has
stale/failing receipts, route only that child through its owning lifecycle
route before continuing:

- missing executable implementation path or implementation evidence:
  `run-packet-implementation`
- failed child conformance or drift/churn validation:
  `run-packet-verification-and-correction-loop`
- stale child review or implementation authorization before new child
  implementation work: `review-packet` or `revise-packet`

Do not repair child evidence from the parent route. Do not edit child receipt
digests manually.

## Parent Orchestration Run Receipt

After all child evidence checks pass, write or refresh:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/program-implementation-orchestration-run.md`

The receipt must include at least:

```yaml
verdict: pass
implemented_at: <iso-8601-timestamp>
promotion_evidence_count: <sum-of-child-owned-promotion-evidence-counts>
child_authority_preserved: yes
```

It must also include:

- parent program path;
- route id and run id;
- child packet paths in sequence;
- child implementation-run, implementation-conformance, and post-implementation
  drift/churn receipt refs by path and digest;
- validators run and exit outcomes;
- explicit statement that parent evidence is aggregate coordination evidence
  only and does not satisfy child receipts, child promotion targets, child
  validation verdicts, child closeout evidence, child archive metadata, Change
  delivery receipts, branch cleanup authorization, terminal proof, or cleaned
  claims;
- blockers, if any, with the next owning route.

Use `verdict: blocked` instead of `pass` if any required child evidence cannot
be validated by its owning route.

## Promotion And Next Route Boundary

When the parent orchestration run receipt reports `verdict: pass` and
`child_authority_preserved: yes`, the proposal-program lifecycle may replan
and select the next legal route, such as parent promotion to `implemented` or a
program verification prompt route, according to the lifecycle contract.

This prompt must not skip directly to closeout, archive, Change delivery,
branch cleanup, terminal local evidence, or `git_clean_terminal`. Those outcomes
belong to later owning routes and require their own receipts and validators.

## Required Post-Run Validation

After writing the parent orchestration run receipt, rerun:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
```

Then verify the parent review gate still passes:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --require-implementation-authorization
```

## Stop Conditions

Stop and report the blocker, owning route, evidence path, and next legal action
when any of these occur:

- parent review authorization is missing, stale, or denied;
- program child readiness fails;
- child implementation evidence is missing, stale, malformed, or failing and
  no owning child correction route can legally resolve it;
- parent evidence would substitute for child evidence;
- a child promotion target, validator, or acceptance criterion conflicts with
  parent coordination instructions;
- an implementation step requires scope expansion, policy override, unresolved
  ownership acceptance, external approval, generated-output hand editing,
  unsafe mutation, deletion, branch cleanup, archive relocation, or terminal
  cleaned proof.

## Final Response Contract For The Executor

Return:

- parent program route outcome;
- path to `support/program-implementation-orchestration-run.md`;
- child packet validation outcome by child;
- child evidence refs and digests summarized by child;
- `promotion_evidence_count`;
- `child_authority_preserved`;
- validators run and pass/fail results;
- files changed;
- blockers or non-blocking warnings;
- next owning route selected by replan, if known.

Before reporting success, confirm that every implemented child has passing
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md`. No child may proceed to
closeout or implemented archival unless those child-owned receipts pass.
