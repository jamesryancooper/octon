# Source Lineage

- PM-004: generated run-health projections dominated tracked residue.
- Audit evidence: 1132 tracked modifications existed in the original workspace,
  1010 were under `.octon/generated/cognition`, 1008 modified tracked files
  ended in `health.yml`, and parent drift evidence observed 1036 dirty
  generated run-health paths unchanged by tests.
- Audit acceptance: rerunning validators does not dirty tracked generated
  health files unless an owning publisher runs with an explicit publish flag and
  freshness receipt.
- Operator decision: run-health projections should be diagnostic read models by
  default and durable evidence only when route-promoted by reference and digest.
