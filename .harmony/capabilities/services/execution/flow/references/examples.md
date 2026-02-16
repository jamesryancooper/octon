# Flow Examples

## Native Dry Run (Default Adapter)

```bash
cd .harmony/runtime/crates
cargo run -p harmony_kernel -- tool execution/flow run --json \
  '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"packages/workflows/architecture_assessment/00-overview.md","workflowManifestPath":"packages/workflows/architecture_assessment/manifest.yaml","workflowEntrypoint":"architecture-inventory","workspaceRoot":".","runtime":{"type":"native-harmony"}},"dryRun":true}'
```

## Native Live Run

```bash
cd .harmony/runtime/crates
cargo run -p harmony_kernel -- tool execution/flow run --json \
  '{"config":{"flowName":"docs_glossary","canonicalPromptPath":"packages/workflows/docs_glossary/00-overview.md","workflowManifestPath":"packages/workflows/docs_glossary/manifest.yaml","workflowEntrypoint":"docs-glossary-collect","workspaceRoot":".","runtime":{"type":"native-harmony"}},"params":{"docsPath":"docs"}}'
```

## Optional LangGraph HTTP Run

```bash
cd .harmony/runtime/crates
cargo run -p harmony_kernel -- tool execution/flow run --json \
  '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"packages/workflows/architecture_assessment/00-overview.md","workflowManifestPath":"packages/workflows/architecture_assessment/manifest.yaml","workflowEntrypoint":"architecture-inventory","workspaceRoot":".","runtime":{"type":"langgraph-http","url":"http://127.0.0.1:8410","timeoutSeconds":60}},"adapter":"langgraph-http"}'
```
