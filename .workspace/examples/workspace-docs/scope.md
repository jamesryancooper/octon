# Scope: api-reference

## This Workspace Covers

API reference documentation for the public REST API.

## In Scope

- Endpoint documentation (request/response schemas)
- Authentication and authorization guides
- Error code reference
- Code examples (curl, JavaScript, Python)
- Changelog and versioning notes

## Out of Scope

- Internal API documentation (belongs in `docs/internal/`)
- Architecture decisions (belongs in `docs/architecture/`)
- User tutorials (belongs in `docs/guides/`)
- SDK documentation (belongs in `packages/sdk/`)

## Decision Authority

**Decide locally:**

- Documentation structure and organization
- Example code formatting
- Error message wording

**Escalate:**

- API versioning strategy
- Deprecation timelines
- Public-facing terminology changes

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `apps/api/` | Source of truth for endpoints |
| `docs/guides/` | Links to tutorials |
| `packages/contracts/` | OpenAPI schemas |
