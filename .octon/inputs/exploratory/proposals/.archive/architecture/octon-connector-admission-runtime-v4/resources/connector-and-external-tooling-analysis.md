# Connector and External Tooling Analysis

## Core problem

External tool availability is not authority. A model seeing an MCP tool, browser session, API key, or CI provider must not imply permission to use it.

## Connector operation model

Every external operation must be normalized into a connector operation contract.

Examples:

| External tool operation | Capability packs | Material class | Default v4 posture |
| --- | --- | --- | --- |
| Read GitHub issue metadata | `api`, `telemetry` | service-invocation | read-only if admitted |
| Create GitHub issue | `api`, `telemetry` | service-invocation | stage-only until proof |
| Merge PR | `api`, `git`, `telemetry` | protected-ci-check/service-invocation | denied or high-approval |
| Read CI logs | `api`, `telemetry` | service-invocation | read-only if admitted |
| Trigger deployment | `api`, `telemetry` | service-invocation/protected-ci-check | deferred to Release Envelope |
| Browser form submit | `browser`, `api`, `telemetry` | service-invocation | denied/deferred |

## MCP treatment

MCP is a transport/protocol/source of tools, not a trust class. Do not make MCP a giant capability pack. Treat each MCP-exposed function as a connector operation with its own side-effect, support, evidence, and authorization posture.

## Credential posture

Credentialed operations must require credential class, storage/scope policy, redaction policy, and retained evidence. V4 MVP should avoid self-provisioning credentials.
