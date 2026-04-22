# Runtime Enforcement Hardening Plan

## Objective

Make the engine-owned execution authorization boundary mechanically unavoidable
for every material side-effect path.

## Current posture

The live repo already has:

- `execution-authorization-v1.md` requiring all material execution to pass through
  `authorize_execution(request) -> GrantBundle`;
- `material-side-effect-inventory.yml` listing material classes;
- `authorization-boundary-coverage.yml` mapping known paths to authorization;
- Rust `authority_engine` implementation with active checks for intent, role,
  policy mode, protected execution, executor profiles, run lifecycle binding,
  support, ownership, approval, rollback, budget, and egress;
- kernel CLI surfaces for run lifecycle, workflow compatibility, services,
  Studio, and orchestration inspection.

The target-state gap is not conceptual. It is full coverage, tests, fixtures,
and closure evidence.

## Target changes

### 1. Expand material side-effect inventory

Inventory must include:

- repo mutation;
- evidence mutation;
- control mutation;
- generated/effective publication;
- executor launch;
- service invocation;
- protected CI checks;
- workflow compatibility run;
- pack admission/publication;
- extension activation/publication;
- closeout/disclosure publication;
- adapter-mediated actions.

### 2. Expand authorization coverage map

Each path must include:

- `path_id`;
- entrypoint;
- side-effect class;
- affected roots;
- request builder;
- `authorize_execution` reference;
- grant artifact reference;
- receipt artifact reference;
- denial reason code;
- negative controls;
- tests;
- last validation evidence ref.

### 3. Add negative-control fixtures

Minimum fixture set:

- raw input as runtime dependency;
- generated artifact as authority;
- host projection as authority;
- missing support tuple;
- stage-only tuple claimed live;
- unadmitted pack;
- missing run contract;
- missing rollback plan;
- missing approval grant;
- stale generated/effective output;
- unsupported adapter;
- missing evidence-store completeness;
- hidden human intervention;
- material path missing coverage entry.

### 4. Bind runtime CLI to coverage checks

`octon doctor --architecture` must fail if any CLI command that can cause a
material side effect lacks coverage. Workflow commands may remain only as
compatibility wrappers and must route through run-first lifecycle.

### 5. Retain enforcement evidence

Every closure-grade validation run must retain:

- coverage report;
- negative-control report;
- authorization phase results;
- denial/stage-only receipts;
- sample run bundle;
- replay bundle.

## Acceptance

This plan closes only when a reviewer can prove from retained evidence that no
material side-effect path can proceed without a valid grant bundle and matching
receipt trail.
