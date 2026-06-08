# Validation Plan

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluator-template --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluator-template
```

After implementation, validate the structured output schema and run the
lifecycle-postmortem validator against positive and negative report fixtures.
Fixture coverage must include invariant records, rating enum validation,
Unknown-as-Pass rejection, missing evidence gaps, and blocking corrections for
material invariant failures.

Fixture coverage must also include invariant validity/evolution records,
recommendation enum validation, missing required-change rejection,
change-control bar validation, and rejection of reports that present invariant
changes as approved.
