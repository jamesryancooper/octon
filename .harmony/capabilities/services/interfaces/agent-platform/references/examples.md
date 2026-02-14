# Examples

## Native Context Budget Report

```bash
bash .harmony/capabilities/services/interfaces/agent-platform/impl/context-budget.sh \
  --limit 10000 \
  --used 8200 \
  --unit tokens
```

## Session Policy Validation

```bash
bash .harmony/capabilities/services/interfaces/agent-platform/impl/validate-session-policy.sh \
  --file .harmony/capabilities/services/interfaces/agent-platform/fixtures/native-session-policy.json
```

## Adapter Capability Negotiation

```bash
bash .harmony/capabilities/services/interfaces/agent-platform/impl/negotiate-capabilities.sh \
  --mode adapter \
  --adapter-id openclaw
```

## Memory Flush Evidence

```bash
bash .harmony/capabilities/services/interfaces/agent-platform/impl/memory-flush-evidence.sh \
  --session-id session-123 \
  --limit 10000 \
  --used 9200 \
  --compaction-requested true \
  --flush-ok true
```
