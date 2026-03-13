# Flow Examples

## Native Dry Run (Default Adapter)

```bash
cd .octon/engine/runtime/crates
cargo run -p octon_kernel -- tool execution/flow run --json \
  '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"flow-assets/architecture_assessment/00-overview.md","workflowManifestPath":"flow-assets/architecture_assessment/manifest.yaml","workflowEntrypoint":"architecture-inventory","workspaceRoot":".","runtime":{"type":"native-octon"}},"dryRun":true}'
```

## Native Live Run

```bash
cd .octon/engine/runtime/crates
cargo run -p octon_kernel -- tool execution/flow run --json \
  '{"config":{"flowName":"docs_glossary","canonicalPromptPath":"flow-assets/docs_glossary/00-overview.md","workflowManifestPath":"flow-assets/docs_glossary/manifest.yaml","workflowEntrypoint":"docs-glossary-collect","workspaceRoot":".","runtime":{"type":"native-octon"}},"params":{"docsPath":"docs"}}'
```

## Optional LangGraph HTTP Run

```bash
cd .octon/engine/runtime/crates
cargo run -p octon_kernel -- tool execution/flow run --json \
  '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"flow-assets/architecture_assessment/00-overview.md","workflowManifestPath":"flow-assets/architecture_assessment/manifest.yaml","workflowEntrypoint":"architecture-inventory","workspaceRoot":".","runtime":{"type":"langgraph-http","url":"http://127.0.0.1:8410","timeoutSeconds":60}},"adapter":"langgraph-http"}'
```
