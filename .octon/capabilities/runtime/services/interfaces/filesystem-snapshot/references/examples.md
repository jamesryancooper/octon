# Filesystem Snapshot Examples

## Build and select the active snapshot

```bash
bash .octon/engine/runtime/run tool interfaces/filesystem-snapshot snapshot.build \
  --json '{"root":".","set_current":true}'
```

## Read a bounded file slice

```bash
bash .octon/engine/runtime/run tool interfaces/filesystem-snapshot fs.read \
  --json '{"path":"AGENTS.md","max_bytes":512}'
```
