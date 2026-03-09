# Pipelines

`runtime/pipelines/` is the canonical autonomous orchestration surface.

Pipelines are manifest-first runtime contracts. They own:

- pipeline discovery metadata
- per-pipeline execution contracts
- canonical stage assets under `stages/`
- structured artifact and projection metadata

`runtime/workflows/` remains as a generated projection surface for humans and
slash-facing compatibility.

## Collection Layout

```text
runtime/pipelines/
├── manifest.yml
├── registry.yml
├── _ops/
│   └── scripts/
├── _scaffold/
│   └── template/
└── <group>/<pipeline-id>/
    ├── pipeline.yml
    ├── stages/
    ├── schemas/    # optional
    ├── fixtures/   # optional
    └── _ops/       # optional
```

## Authority Model

1. `manifest.yml` and `registry.yml` provide collection discovery and routing.
2. `pipeline.yml` is the per-pipeline canonical contract.
3. `stages/` holds versioned runtime stage assets.
4. `runtime/workflows/` is a projection surface and must not be treated as the
   canonical autonomous contract.
