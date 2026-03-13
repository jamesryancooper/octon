# {{component-name}} - Developer Guide

## Quick Snapshot

- Modes or variants: <if applicable>
- Inputs: <requests, records, events, files>
- Outputs: <responses, events, artifacts>
- Artifacts: <if produced, include schema_version>
- External dependencies: <if any>

## What It Does

- <Primary responsibilities in 3-6 bullets>

## Why Teams Use It

- <Key benefits: reliability, speed, reuse, observability, etc.>

## Key Design Choices

- Core libraries/frameworks and why they were selected
- Data formats/protocols and trade-offs
- Alternatives considered and why they were not selected
- Link ADRs for consequential or organization-wide choices

## Responsibilities and Boundaries

- Owns: <what this component guarantees>
- Does not own: <what is intentionally out of scope>

## Integrations

- Upstream inputs: <systems, jobs, producers>
- Downstream consumers: <systems, APIs, jobs>

## Operating Modes (Optional)

- When to use each mode
- Trade-offs between modes
- Example configurations

## Interfaces and Contracts

- API contracts: `packages/contracts/openapi.yaml`
- Payload schemas: `packages/contracts/schemas/feature-name.schema.json`
- Input/output summary: <required fields, IDs, provenance>

## Artifacts and Layout (Optional)

```text
<artifact-root>/
  artifact.ext
  meta.json            # includes schema_version and build/source metadata
  manifest.json        # checksums and references
```

## Versioning and Compatibility

- Contract schema versioning policy
- Breaking change policy
- Migration or downgrade notes

## Configuration

Minimal configuration example:

```yaml
enabled: true
mode: default
limits:
  maxItems: 1000
```

Advanced configuration example:

```json
{
  "feature": { "strategy": "balanced", "retry": 2 },
  "limits": { "maxItems": 1000, "timeoutMs": 5000 }
}
```

## Validation and Health

- Health checks
- Drift/parity checks
- Contract validation checks

## Observability (Optional)

- Logs: key fields to emit
- Metrics: key counters/latency/error rates
- Traces: key spans and tags

## Octon Alignment

- Spec-first and contract-driven
- Auditable, versioned documentation updates
- Risk-aware rollout and rollback readiness
- See `.octon/cognition/practices/methodology/README.md`

## Minimal Interface Examples

```json
{ "mode": "default", "output": { "dir": "out/" } }
```

## Troubleshooting

- Symptom -> likely cause -> fix

## Common Questions

- <FAQ 1>
- <FAQ 2>
