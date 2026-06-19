# Acceptance Criteria

- Git mutation preflight diagnostics identify fetch, checkout, landing, sync,
  cleanup, and branch deletion permission paths.
- Diagnostics emit owning rerun routes for permission-sensitive operations.
- Diagnostics do not bypass cleanup authorization, landing proof, sync proof,
  branch deletion authorization, or human approval gates.
- Parent evidence does not satisfy child git mutation evidence.
