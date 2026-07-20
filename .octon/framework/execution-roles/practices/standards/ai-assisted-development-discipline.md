# AI-Assisted Development Discipline

## Authority Posture

This standard is subordinate to the constitutional kernel, instance ingress,
and the orchestrator role. It does not create a new constitutional authority
surface.

Controlling references:

- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`

## Purpose

Prevent AI-assisted changes from introducing unnecessary authored surfaces,
duplicate logic, speculative abstractions, dependency bloat, shallow validation
evidence, generated-output authority drift, raw-input authority drift, or
proposal-path dependency leakage. Prevent recommendations from transferring an
Octon requirement into a fork, patch, modification, or reengineering effort
against an external tool.

## Applies To

Use this standard for non-trivial AI-assisted work that affects governance,
runtime behavior, refactors, migrations, generated publication posture,
dependency posture, assurance, or repo-consequential surfaces.

Trivial local copy edits may record `n/a` for the receipts below when no new
surface, behavior, dependency, policy, generated output, or evidence claim
changes.

## Required Discipline

Before implementation, the orchestrator must produce or cite:

- Profile Selection Receipt.
- Repository Reconnaissance Receipt.
- Minimal Implementation Plan.
- Impact Map.
- Evidence Plan.
- Dependency Receipt when dependencies or dependency risk change.
- Cleanup or deletion-safety plan when code, contracts, artifacts, generated
  outputs, or retained material are removed or simplified.

## Minimal Implementation Rule

The selected implementation must be the smallest robust change that preserves:

- constitutional authority boundaries;
- control and evidence separation;
- generated and input non-authority rules;
- support-target boundedness;
- runtime authorization coverage;
- rollback and closeout posture;
- external-tool integrity: external dependencies remain unmodified and every
  required solution change is Octon-owned.

Forbidden by default:

- speculative abstractions;
- duplicate helpers, contracts, validators, policies, workflows, or generated
  outputs;
- policy prose with no enforcement or validation path;
- generated outputs without publication and freshness handling;
- dependency changes without receipt;
- proposal-only authority;
- cleanup mixed with behavior change unless the plan routes and validates both.
- forking, patching, modifying, reengineering, or maintaining a private
  derivative of an external tool;
- making an upstream change a prerequisite for Octon acceptance or delivery;
- relying on an undocumented external-tool internal instead of a supported
  interface.

When an external limitation is encountered, apply
`.octon/framework/execution-roles/practices/standards/external-tool-integrity.md`:
redesign inside Octon, reduce scope, or record a blocker.

## Required Completion Receipt

The final run, Change, or PR-backed Change output must include a Minimality /
Anti-Bloat Receipt with:

- existing surfaces searched;
- existing utilities, contracts, policies, or validators reused;
- new files and rationale;
- new abstractions and rationale;
- generated outputs and publication/freshness rationale;
- dependency changes or `none`;
- code or artifacts deleted or simplified;
- speculative work rejected;
- cleanup pass result;
- behavior-preservation evidence;
- generated, input, proposal, and authority-boundary checks;
- external-tool integrity result, including supported interfaces and Octon-owned
  adaptation surfaces when external tools are involved;
- remaining implementation-quality risk or `none`.

## Boundary Rule

Generated projections, raw inputs, proposal packets, host affordances, and chat
history may inform work only within their declared authority class. They must
not become direct runtime, policy, support, or closure authority.

## Related Standards

- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`
- `.octon/framework/execution-roles/practices/standards/external-tool-integrity.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
