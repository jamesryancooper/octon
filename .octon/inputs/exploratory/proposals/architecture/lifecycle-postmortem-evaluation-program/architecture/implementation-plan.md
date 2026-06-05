# Implementation Plan

## Phase 1: Workflow Surface

Implement `lifecycle-postmortem-meta-workflow` first. This child creates the
workflow contract, stage files, retained evidence output layout, and runtime
entry point needed to invoke the evaluator after a lifecycle run.

## Phase 2: Evaluator Template

Implement `lifecycle-postmortem-evaluator-template` after the workflow shape is
clear. This child defines the evaluator prompt/template and structured output
schema. It must add invariant evaluation before quality scoring, require the
strict invariant rating set, add invariant validity/evolution review before
final recommendations, and preserve the evaluator proof-plane rule that
evaluator outputs remain evidence only.

## Phase 3: Validator And Fixtures

Implement `lifecycle-postmortem-validator` after the workflow and evaluator
contracts stabilize. This child adds deterministic validation, positive
fixtures, invariant-failure and invariant-validity negative controls, and
assurance registration.

## Cross-Cutting Rules

- Do not add the postmortem as a mandatory run-closeout gate by default.
- Do not let postmortem reports mutate `runtime-state.yml`, journal events,
  review dispositions, support-target claims, or proposal status.
- Do not store canonical postmortem evidence under `generated/**` or
  `inputs/**`.
- Use retained evidence references, not chat history, as factual input.
- Treat Unknown invariant ratings as insufficient evidence, never as Pass.
- Treat generated/raw-input authority, second control plane, runtime
  authorization bypass, and missing consequential evidence invariant failures
  as blocking defects until separately corrected.
- Treat invariant validity/evolution recommendations as proposed evidence only;
  they must not amend constitutional, policy, runtime, support, or lifecycle
  authority without a separate governance route.
- Use high or very high scrutiny for recommendations to narrow, remove,
  downgrade, or add invariants.
- Record follow-up redesign recommendations as findings or proposal/evolution
  candidates only when a separate route accepts that work.
