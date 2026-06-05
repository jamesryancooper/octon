# Lifecycle Postmortem

This read-only meta workflow prepares and validates retained postmortem evidence
for an existing lifecycle run. It reconstructs known facts from retained run
control and evidence roots, prepares evaluator input, validates evaluator
outputs when present, and writes only under the run-local assurance evidence
root.

## Inputs

- `run_id`: retained lifecycle run id to inspect.
- `report_path`: optional evaluator-authored Markdown report.
- `structured_output_path`: optional structured evaluator output.

## Outputs

- `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evidence-map.yml`
- `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluator-input.md`
- optional validated report, structured output, and review-finding records under
  the same postmortem evidence root.

## Stages

1. `bind-evidence`: bind the run id and reconstruct retained control and
   evidence references.
2. `invoke-evaluator`: prepare the evaluator input from the lifecycle-postmortem
   template and retained evidence map.
3. `materialize-findings`: retain optional `review-finding-v1` records as
   evidence only.
4. `final-report`: validate any report or structured output and record final
   postmortem status.

## Authority Boundary

Postmortem outputs are retained evidence. They do not authorize lifecycle
transition, closeout, promotion, redesign, support widening, generated-output
publication, or invariant amendment.
