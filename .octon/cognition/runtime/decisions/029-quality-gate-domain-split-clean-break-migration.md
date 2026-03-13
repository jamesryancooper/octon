# ADR 029: Quality-Gate Domain Split Clean-Break Migration

- Date: 2026-02-21
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: monolithic `quality-gate` runtime domain layout for skills and workflows

## Context

The runtime auditing and remediation surfaces had accumulated under a single
`quality-gate/` directory in both capabilities and orchestration. Over time,
that directory became a mixed authority boundary containing distinct concerns:
audits, remediation operations, and refactor orchestration.

This overloaded domain naming increased discovery ambiguity and made future
migration risk higher as more skills/workflows attach to the same namespace.
The repository now requires focused runtime domain ownership before further
scale.

## Decision

Adopt focused runtime domains and remove `quality-gate` in a clean-break
migration:

- Skills:
  - `/.octon/capabilities/runtime/skills/audit/`
  - `/.octon/capabilities/runtime/skills/remediation/`
  - `/.octon/capabilities/runtime/skills/refactor/`
- Workflows:
  - `/.octon/orchestration/runtime/workflows/audit/`
  - `/.octon/orchestration/runtime/workflows/refactor/`

Remove `/.octon/capabilities/runtime/skills/quality-gate/` and
`/.octon/orchestration/runtime/workflows/quality-gate/` in the same change
set. Update manifests, registries, validators, and active docs to use the new
domains only.

Validation gates and banlists must fail on reintroduction of `quality-gate`
path/group authority in active surfaces.

## Consequences

### Benefits

- Clearer runtime ownership boundaries by concern class.
- Better discoverability for audit vs remediation vs refactor functions.
- Lower long-term migration cost by reducing overloaded namespace coupling.
- Stronger enforcement through explicit deprecated-path and banlist checks.

### Risks

- Broad path churn can leave stale references in active contracts/docs.
- Existing tooling may still expect legacy directory locations.
- False-positive scans can arise due to retained IDs like
  `documentation-quality-gate`.

### Mitigations

- One-shot clean-break update across paths, group taxonomy, validators, and
  active references.
- Explicit deprecated-path checks in validators for removed directories.
- Banlist entries for removed paths and taxonomy keys.
- Migration evidence report with static and runtime validation receipts.
