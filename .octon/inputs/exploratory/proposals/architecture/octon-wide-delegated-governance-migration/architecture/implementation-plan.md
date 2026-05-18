# Implementation Plan

The parent program implements no runtime behavior directly. It sequences child
packets in this order:

1. `delegated-governance-inventory-and-vocabulary` inventories approval and
   default-authority surfaces and locks the vocabulary.
2. `delegated-governance-shared-contract-model` defines the generic proof-first
   contract semantics for non-lifecycle surfaces.
3. Domain children migrate authority engine, mission/runtime, connectors,
   run-health/read-models, and workflow/capability classification in gated
   parallel after the shared model.
4. `governance-validator-negative-controls` adds cross-domain validators and
   negative controls after enough migrated surface exists.
5. `delegated-governance-cutover-closeout` performs compatibility retirement,
   final proof-state checks, and aggregate closeout.

Each child must be reviewed and accepted before implementation. Each
implemented child must retain implementation run, validation, conformance,
drift/churn, and promotion evidence outside proposal-local inputs.
