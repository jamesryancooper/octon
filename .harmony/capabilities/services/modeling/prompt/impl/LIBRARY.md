# Prompt Library Implementation

This service currently points to the project-specific runtime implementation:

- `packages/kits/promptkit/`

## Invocation Contract

- `interface_type`: `library`
- input schema: `../schema/input.schema.json`
- output schema: `../schema/output.schema.json`

## Portability Note

Prompt service remains library-bound until wrapped as shell or MCP. This preserves current behavior while standardizing service metadata and contracts in `.harmony/capabilities/services/`.
