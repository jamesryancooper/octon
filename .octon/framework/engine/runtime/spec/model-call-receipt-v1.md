# Model Call Receipt v1

Model Call Receipt v1 is the retained evidence contract for one model call made
by an Agent Node v1 activity.

The receipt proves context digest binding, model routing, model eligibility,
budget enforcement, fallback and retry posture, retained cost/usage evidence,
output validation, terminal outcome, and replay inputs. It is evidence and
validation material. It is not a grant, policy source, workflow transition,
effect token, support claim, connector admission, or closeout artifact.

## Required Binding

Every model-call receipt must bind:

- run id, request id, agent-node ref, and task-specific harness state;
- model adapter and model tier from the declared support-target universe;
- support-target tuple ref and model-routing policy ref;
- model eligibility decision, including deny/stage-only reasons when
  ineligible;
- context-pack ref, context-pack receipt ref, model-visible context ref, and
  model-visible context SHA-256 digest;
- input schema ref, output schema ref, and output validation result;
- context, token, cost, retry, and fallback budgets;
- retained cost/usage receipt refs under `/.octon/state/evidence/**`;
- terminal outcome and replay envelope; and
- authority-boundary booleans that keep model output non-authoritative.

## Budget And Fallback Discipline

The receipt must show both configured budget ceilings and observed usage for:

- model-visible context bytes or tokens;
- input and output tokens;
- estimated or actual cost;
- retry attempts; and
- fallback attempts.

Missing cost evidence routes to stage-only or deny according to
`/.octon/instance/governance/policies/model-call-routing.yml` and
`/.octon/instance/governance/policies/execution-budgets.yml`.

Fallback may only narrow execution. It cannot select an ineligible model,
increase budget, bypass context-pack evidence, admit a connector, or treat
generated or raw-input material as authority.

## Output Validation

Model output may enter downstream processing only after output schema validation
is recorded. A valid output remains bounded evidence or candidate content. It
does not own workflow state, transition a run, mint authority, widen support,
mutate policy, consume effect tokens, admit connectors, or close work.

## Replay Envelope

The replay envelope preserves enough references to reconstruct what was shown
to the model and how the receipt was evaluated. It must include retained
context, routing, budget, validation, cost/usage, and terminal-outcome refs. It
does not guarantee bit-for-bit reproduction of probabilistic model output.

## Related Contracts

- `/.octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/agent-node-v1.md`
- `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `/.octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/policy-interface-v1.md`
- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/instance/governance/policies/model-call-routing.yml`
- `/.octon/instance/governance/policies/execution-budgets.yml`
