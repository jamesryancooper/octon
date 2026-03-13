# Filesystem Discovery Examples

## Start a discovery session

```bash
bash .octon/engine/runtime/run tool interfaces/filesystem-discovery discover.start \
  --json '{"query":"octon","limit":5}'
```

## Query graph neighbors from a snapshot

```bash
bash .octon/engine/runtime/run tool interfaces/filesystem-discovery kg.neighbors \
  --json '{"node_id":"file:.octon/START.md","edge_type":"CONTAINS","direction":"in","limit":20}'
```
