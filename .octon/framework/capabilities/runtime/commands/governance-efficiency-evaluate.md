# /governance-efficiency-evaluate

Run the advisory governance efficiency evaluator against retained lifecycle or
proposal evidence.

This command is a thin operator surface for:

```text
.octon/framework/assurance/runtime/_ops/scripts/evaluate-governance-efficiency.sh
```

## Usage

```text
/governance-efficiency-evaluate target=<proposal-or-program-path> output=<optional-report-path>
```

## Authority Boundary

Evaluator output is advisory-only. It cannot authorize review, validation,
closeout, cleanup, archive, terminal proof, policy mutation, lifecycle
transition, branch landing, branch cleanup, or child receipt substitution.
Recommendations require a future accepted proposal before any governance,
workflow, validator, or policy mutation.
