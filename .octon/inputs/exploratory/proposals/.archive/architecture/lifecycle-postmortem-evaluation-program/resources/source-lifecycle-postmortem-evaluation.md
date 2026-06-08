# Source Lifecycle Postmortem Evaluation

The source request asks Octon to add a rigorous post-mortem evaluation process
for lifecycle processes after they have run. The evaluator must distinguish
bad lifecycle execution from wrong lifecycle architecture, reconstruct the
actual run from evidence, apply first-principles and Chesterton's Fence
analysis, evaluate Octon invariant compliance as hard constitutional
guardrails before quality scoring, review invariant validity and evolution
pressure before final recommendations, score lifecycle quality attributes, and
end with a final lifecycle fitness judgment plus concrete follow-up actions.

The integration recommendation selected in this program:

- use a post-run assurance evaluator rather than a normal lifecycle stage;
- retain evaluator outputs as evidence under canonical evidence roots;
- consume retained run/control/evidence artifacts rather than chat memory;
- emit structured review findings for durable traceability;
- require invariant preservation, enforcement, evidence, gap, blocking, and
  correction analysis for Octon lifecycle subjects;
- require separate invariant validity/evolution analysis for stale,
  incomplete, ambiguous, conflicting, over-broad, under-specified,
  implementation-specific, or hack-inducing invariants;
- avoid making postmortem reports authorize closeout, promotion, redesign, or
  support claims;
- add deterministic validation for report shape, invariant compliance,
  invariant validity/evolution review, evidence refs, final judgment enum, and
  authority boundary negative controls.

Relevant existing Octon anchors:

- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/framework/assurance/evaluators/README.md`
- `.octon/framework/constitution/contracts/assurance/family.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/shared/validation-and-evidence-contract.md`
