# Spec Kit — <Feature/Change>

## Problem
<user need, scope, constraints>

## API/UI Contracts
- OpenAPI: `packages/contracts/openapi.yaml`
- Schemas: `packages/contracts/schemas/*.json`
- SLIs/SLOs: latency p95, error rate, availability

## Non-functionals
- Perf, Security, Observability

## Micro Threat Model
- Map to OWASP ASVS + NIST SSDF

## BMAD Story
- Context packets
- Agent plan
- Acceptance criteria

## Test Plan
- Unit, contract (oasdiff / Pact), e2e (if any)
