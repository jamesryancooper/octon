# Services Quick Reference

This is the harness-native quick reference for the production services under `.octon/capabilities/runtime/services`.

## Core Services

| Service | Domain Path | Primary Operation |
|---|---|---|
| `guard` | `governance/guard/` | `check`, `sanitize` |
| `prompt` | `modeling/prompt/` | `compile` |
| `cost` | `operations/cost/` | `estimate`, `record` |
| `flow` | `execution/flow/` | `run` |

## Common CLI Usage

### Guard

```bash
echo '{"content":"example"}' | .octon/capabilities/runtime/services/governance/guard/impl/guard.sh
```

### Prompt

```bash
echo '{"promptId":"workflow/implement","variables":{"target":".octon"}}' | \
  .octon/capabilities/runtime/services/modeling/prompt/impl/prompt.sh
```

### Cost

```bash
echo '{"operation":"estimate","workflowType":"code-from-plan","tier":"T2"}' | \
  .octon/capabilities/runtime/services/operations/cost/impl/cost.sh
```

### Flow

```bash
echo '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"flow-assets/architecture_assessment/00-overview.md","workflowManifestPath":"flow-assets/architecture_assessment/manifest.yaml"},"dryRun":true}' | \
  .octon/capabilities/runtime/services/execution/flow/impl/flow-client.sh
```

## Validation

```bash
bash .octon/capabilities/runtime/services/_ops/scripts/validate-services.sh
bash .octon/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh
```
