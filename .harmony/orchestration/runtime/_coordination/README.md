# Orchestration Coordination

Internal lock state used to enforce target-global coordination for
side-effectful orchestration actions.

## Layout

```text
_coordination/
└── locks/
    └── <encoded-coordination-key>.json
```

The lock artifact stores the canonical `coordination_key` inside the file. The
file name is a deterministic encoded representation used to keep the file system
safe for arbitrary coordination-key values.

## Boundary

- Lock state here is orchestration runtime state, not durable continuity
  evidence.
- Decision records carry lock evidence references into continuity-owned
  decision artifacts.
