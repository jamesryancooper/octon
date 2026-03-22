# ADR 060: Runtime Execution Governance Hardening Atomic Cutover

- Date: 2026-03-21
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/runtime-execution-governance-hardening/`
  - `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
  - `/.octon/state/evidence/migration/2026-03-21-runtime-execution-governance-hardening-cutover/`

## Context

Octon already had strong deny-by-default and receipt contracts for parts of the
runtime, but material execution still split across multiple non-symmetric
surfaces:

1. service invocation used direct policy checks while workflow stages and
   executor launches did not share one mandatory pre-side-effect boundary,
2. workflow contracts declared stage structure but not stage-level
   authorization metadata,
3. protected CI paths could still rely on workflow-local enforcement rather
   than one explicit protected-execution posture check, and
4. material runtime evidence for services, workflow stages, and executor
   launches used different bundle conventions.

## Decision

Promote runtime execution governance hardening as one atomic clear-break
cutover.

Rules:

1. Material execution must pass through `authorize_execution(...)` before side
   effects occur.
2. Protected execution is legal only under `hard-enforce`; weaker requested
   modes are denied.
3. Executor launch behavior is engine-owned and must flow through named
   executor profiles plus wrapper-enforced dangerous-flag filtering.
4. `workflow-contract-v2` is the only live workflow contract and every stage
   declares an `authorization` block.
5. Runtime execution evidence is retained under `state/evidence/runs/**` with
   execution request, grant, receipt, outcome, and side-effect artifacts.
6. Protected GitHub workflows must assert protected posture explicitly and emit
  /upload receipts.
7. The runtime-execution-governance-hardening proposal package is archived as
   implemented once the durable runtime, workflow, CI, and assurance surfaces
   are promoted.

## Consequences

### Benefits

- Services, stdio requests, workflow stages, kernel-side mutations, and
  protected CI control flows now share one engine-owned grant boundary.
- Dangerous raw executor flags are centralized behind profile gating instead of
  being embedded directly in workflow runners.
- Workflow validation can fail closed on missing stage authorization metadata.
- Runtime-effective validation now checks execution-governance surfaces
  alongside extension and capability publication state.

### Costs

- Kernel runtime, workflow contracts, generated publication locks, CI
  workflows, validators, and multiple architecture docs changed together.
- The clear-break workflow contract migration required bulk updates across all
  live workflow units and their fixtures.
- Publication artifacts had to be regenerated so their recorded root-manifest
  hashes matched the new execution-governance config.

### Follow-on Work

1. Tighten non-kernel fixture consumers to model `workflow-contract-v2`
   authorization semantics more deeply where they currently use lightweight
   stubs.
2. Extend protected CI receipts if future workflows need explicit reviewer or
   rollback metadata beyond the current posture assertion.
