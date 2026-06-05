# Validation Plan

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-meta-workflow --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-meta-workflow
```

After implementation, additionally validate the workflow contract and run a
fixture command against a retained lifecycle run bundle. The validator child
owns the final lifecycle-postmortem validation command.
