# Filesystem Discovery Examples

## Start a discovery session

```bash
bash .harmony/runtime/run tool interfaces/filesystem-discovery discover.start \
  --json '{"query":"harmony","limit":5}'
```

## Query graph neighbors from a snapshot

```bash
bash .harmony/runtime/run tool interfaces/filesystem-discovery kg.neighbors \
  --json '{"node_id":"file:.harmony/START.md","edge_type":"CONTAINS","direction":"in","limit":20}'
```
