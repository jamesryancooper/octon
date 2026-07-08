# Target Architecture

Delivery admission exposes a structured input checklist:

- target program path
- target outcome
- delivery run id
- delivery profile path
- release state
- order policy
- PR policy
- stash policy
- readiness preflight ref
- runner handoff refs when present
- include-path classification state
- source freshness state

The checklist reports blockers and the owning next route. It does not generate admission evidence by itself.
