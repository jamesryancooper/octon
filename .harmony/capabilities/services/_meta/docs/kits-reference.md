# Services Quick Reference

This is the harness-native quick reference for the production services under `.harmony/capabilities/services`.

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
echo '{"content":"example"}' | .harmony/capabilities/services/governance/guard/impl/guard.sh
```

### Prompt

```bash
echo '{"promptId":"workflow/implement","variables":{"target":".harmony"}}' | \
  .harmony/capabilities/services/modeling/prompt/impl/prompt.sh
```

### Cost

```bash
echo '{"operation":"estimate","workflowType":"code-from-plan","tier":"T2"}' | \
  .harmony/capabilities/services/operations/cost/impl/cost.sh
```

### Flow

```bash
echo '{"config":{"flowName":"architecture_assessment","canonicalPromptPath":"packages/workflows/architecture_assessment/00-overview.md","workflowManifestPath":"packages/workflows/architecture_assessment/manifest.yaml"},"dryRun":true}' | \
  .harmony/capabilities/services/execution/flow/impl/flow-client.sh
```

## Validation

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh
```
