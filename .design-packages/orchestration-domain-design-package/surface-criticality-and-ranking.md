# Surface Criticality And Ranking

## Criticality Scale

- `10`: foundational; the orchestration system is materially incomplete without it
- `7-9`: highly important; not always foundational, but close to essential in a
  mature system
- `4-6`: useful and meaningful, but not required for a functional core
- `1-3`: optional or scale-oriented

## Surface Ranking Table

| Surface | Complexity | Criticality (1-10) | Usefulness Rank | Need Rank | Notes |
|---|---|---:|---:|---:|---|
| `workflows` | Medium | 10 | 1 | 1 | Core orchestration primitive |
| `missions` | Medium | 8 | 2 | 2 | Core bounded multi-session initiative surface |
| `runs` | Medium | 8 | 3 | 3 | Core trust, audit, replay, and debugging surface |
| `automations` | High | 6 | 4 | 5 | First major autonomy extension |
| `incidents` | High | 5 | 5 | 4 | Safety and containment surface |
| `queue` | Medium | 4 | 6 | 6 | Event-scale intake and backpressure surface |
| `watchers` | High | 3 | 7 | 7 | Useful only when event-driven detection becomes common |
| `campaigns` | Medium | 2 | 8 | 8 | Optional portfolio surface |

## Interpretation

### Core

- `workflows`
- `missions`
- `runs`

These are the mature core because they define bounded work, bounded initiative
state, and trustworthy execution evidence.

### High-Leverage Next Surface

- `automations`

This is the highest-leverage next addition because it turns a bounded but manual
model into a truly autonomous one without corrupting workflow boundaries.

### Safety Surface

- `incidents`

This matters earlier than `watchers` or `campaigns` if Harmony expects
autonomous execution to encounter real failure modes.

### Scale Surfaces

- `queue`
- `watchers`

These surfaces matter when operating load, signal volume, or asynchronous event
intake justify them.

### Optional Strategic Surface

- `campaigns`

This helps when mission coordination becomes materially complex. It should not
be introduced just to make the model look more complete.
