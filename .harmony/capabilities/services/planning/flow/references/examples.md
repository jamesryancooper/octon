# Flow Examples

## Dry Run

```bash
echo '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"packages/workflows/architecture_assessment/00-overview.md","workflowManifestPath":"packages/workflows/architecture_assessment/manifest.yaml"},"dryRun":true}' | ./impl/flow-client.sh
```

## Live Run

```bash
FLOW_SERVICE_URL="http://127.0.0.1:8410/flows/run" \
echo '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"packages/workflows/architecture_assessment/00-overview.md","workflowManifestPath":"packages/workflows/architecture_assessment/manifest.yaml"},"params":{"targetPath":"src"}}' | ./impl/flow-client.sh
```
