# ADR 030: Documentation Audit Clean-Break Rename

- Date: 2026-02-21
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: `documentation-quality-gate` workflow identifier, command, and runtime path

## Context

After splitting the monolithic `quality-gate` domains into focused runtime
domains, one workflow still retained the legacy naming pattern:
`documentation-quality-gate`.

Keeping this identifier created avoidable overlap in naming semantics and left a
single legacy token in active runtime routing.

## Decision

Adopt `documentation-audit` as the sole canonical workflow identifier and
runtime path for documentation release checks.

This clean-break includes:

- Workflow id rename: `documentation-quality-gate` -> `documentation-audit`
- Command rename: `/documentation-quality-gate` -> `/documentation-audit`
- Runtime path rename:
  - `/.octon/orchestration/runtime/workflows/audit/documentation-quality-gate/`
  - ->
  - `/.octon/orchestration/runtime/workflows/audit/documentation-audit/`
- Report artifact rename:
  - `YYYY-MM-DD-documentation-quality-gate.md`
  - ->
  - `YYYY-MM-DD-documentation-audit.md`

No compatibility alias is retained for the removed command or id.

## Consequences

### Benefits

- Removes the final legacy quality-gate workflow identifier from active runtime
  routing.
- Aligns docs workflow naming with the audit domain taxonomy.
- Simplifies discovery and maintenance by using a single clear command/id pair.

### Risks

- Existing humans/automation invoking `/documentation-quality-gate` will fail.
- Stale references can remain in active docs if call-sites are missed.

### Mitigations

- One-shot call-site update across manifests, registry, workflow docs, and
  active references.
- Add deprecated-path enforcement in workflow validator.
- Add legacy-banlist entries for removed identifier/path.
- Record verification evidence in a dedicated migration report.
