# Implementation Plan

1. Review the existing Proposal Program Delivery workflow, command, skill, receipt schema, and validators.
2. Add required receipt fields and evidence-index references for clean-delivery claims.
3. Update delivery validators to fail missing, incomplete, stale, or child-authority-replacing evidence.
4. Wire `validate-run-program-clean-delivery.sh` to require the delivery receipt and evidence index.
5. Add fixtures for valid delivery, missing receipt, missing index, stale evidence, and child-authority substitution attempts.
