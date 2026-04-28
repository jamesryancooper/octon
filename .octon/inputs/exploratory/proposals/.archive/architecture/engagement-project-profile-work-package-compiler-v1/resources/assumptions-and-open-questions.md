# Assumptions and Open Questions

## Assumptions

- v1 remains repo-local and single-engagement.
- Existing admitted live capability packs remain the only live packs in scope.
- Existing `octon run start --contract` remains the material execution entrypoint.
- Mission runner work is deferred.
- MCP/API/browser connectors are not live in v1.

## Open questions before implementation

1. Should Engagement IDs be human-provided slugs, generated IDs, or both?
2. Should Project Profile live directly at `instance/locality/project-profile.yml` or under `instance/locality/projects/<project-id>/profile.yml` for future multi-project repos?
3. Should Work Package candidates be immutable once compiled, or mutable with versioned compilation receipts?
4. Should Decision Requests live under Engagement first and then project into canonical approval roots, or be created directly in canonical approval roots with Engagement index refs?
5. Should preflight evidence writes require a minimal adoption approval in totally unadopted repos, or may they write into a temporary external staging directory before `.octon/` exists?

## Recommended v1 answers

- Use generated Engagement IDs with optional title.
- Use `instance/locality/project-profile.yml` for v1, with schema allowing future `project_id`.
- Version Work Packages by `work_package_id` and retain compilation receipts.
- Store Decision Request wrapper under Engagement and require canonical low-level artifact refs when resolved.
- In totally unadopted repos, write preflight evidence only after explicit adoption/preflight consent, or stage externally until `.octon/` is created.
