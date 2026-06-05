# Validation Plan

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-validator --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-validator
```

After implementation:

```bash
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-postmortem.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh --report <report> --structured <evaluation.yml>
```

The test harness must prove both pass and fail fixtures. Invariant-specific
fail fixtures must cover missing invariant evaluation, invalid invariant
rating, Unknown treated as Pass, missing invariant evidence gap, and missing
blocking correction for a material invariant failure.

Invariant-validity fail fixtures must cover missing validity/evolution review,
invalid recommendation category, missing required change, weak change-control
bar, and a report that presents invariant changes as approved.
