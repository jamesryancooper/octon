# Validation Plan

Run these gates for the parent:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
```

Run proposal standard and architecture validators for every child packet.

After implementation, run the child-owned validator and tests:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh --run-id <fixture-run-id>
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-postmortem.sh
```

Invariant-specific fail fixtures must cover missing invariant evaluation,
Unknown treated as Pass, missing invariant evidence gaps, generated or raw
input authority, second control plane claims, authorization bypass, and missing
blocking correction for material invariant violations.

Invariant-validity fail fixtures must cover missing validity/evolution review,
invalid recommendation categories, missing required-change field,
recommendations that treat invariant changes as approved, and relaxation or
removal recommendations without a high or very high change-control bar.

Do not claim program closeout until child-owned implementation, conformance,
drift/churn, and validation evidence exists.
