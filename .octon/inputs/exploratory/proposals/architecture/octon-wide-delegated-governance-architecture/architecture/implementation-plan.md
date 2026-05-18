# Implementation Plan

This packet does not implement the migration. It defines the implementation
sequence expected for a later proposal program.

## Phase 1: Inventory And Vocabulary

Create an Octon-wide inventory of approval/default-authority surfaces across:

- authority engine approval request and grant artifacts;
- mission/runtime `approval_required` posture;
- connector admission, quarantine, replay, rollback, and external-effect
  contracts;
- run-health and operator read models;
- workflow and capability classifications;
- governance docs, schemas, and assurance validators;
- lifecycle contracts and delegated proof artifacts.

Classify each surface as delegated execution, typed human exception, deny-only,
projection-only, or needs-more-evidence.

## Phase 2: Shared Contract Model

Define a generic delegation-contract-style interface for non-lifecycle
surfaces. It should capture:

- decision class;
- safe delegation posture;
- authority zones allowed;
- declared scope source;
- required evidence gates;
- required receipts before dispatch;
- replay or compensation class;
- automated recovery policy;
- typed human-only boundaries.

Do not require every domain to use the lifecycle route schema verbatim. Require
the same proof semantics.

## Phase 3: Domain Migrations

Implement domain-specific child packets only after this architecture packet is
accepted:

- migrate authority engine approval defaults into typed exception grants and
  grant-consumption evidence;
- normalize mission/runtime posture so automation blocks on proof failure or a
  typed human boundary, not generic approval requirement;
- preserve authorized effect tokens and require them for material side-effect
  execution;
- make connector external-effect paths delegable only with explicit token,
  rollback, compensation, egress, and irreversibility proof;
- update run-health/read-model states to report proof state without granting
  authority;
- update workflow and capability classifications to derive human-only outcomes
  from proof boundaries where possible;
- update validators and negative controls.

## Phase 4: Program Proposal

After review acceptance, create a parent proposal-program that sequences child
packets for the domains above. The parent program must preserve child-owned
authority, require implementation-grade completeness for each child, and retain
aggregate evidence outside proposal-local paths.
