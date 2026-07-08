# Implementation Plan

1. Choose the command location after reviewing current runtime and extension command surfaces.
2. Implement command expansion to the existing lifecycle runner.
3. Add help text that distinguishes request, execution, and cleaned claim.
4. Preserve existing `--execute-routes`, `--max-steps`, resume, and cancellation controls.
5. Add tests for command expansion, handoff-only preservation, clean-delivery request semantics, and blocked states.
