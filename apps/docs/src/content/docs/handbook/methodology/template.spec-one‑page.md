---
title: Spec — <Feature/Change> (One Page)
---

## Problem & Goal

- Problem statement (1–2 sentences)
- Business goal & appetite (days)

## Scope & Cuts

- In-scope:
- Out-of-scope (cuts):

## Contracts (APIs/UI)

- OpenAPI path(s): ...
- UI contracts/states: ...
- Data model changes: ...

## Non-Functionals

- Perf budgets (API/UI): ...
- Reliability: initial SLOs/SLIs: ...
- Privacy & data retention: ...

## Security (OWASP ASVS / STRIDE)

- ASVS levels/sections touched: (e.g., v5 V2, V3, V10)
- STRIDE table:

| Threat | Risk | Mitigation | Test |
|---|---|---|---|
| Spoofing | OAuth state steal | state+nonce, sameSite cookies | neg. test |
| Tampering | Webhook body | sign verification | unit+contract |
| ... | ... | ... | ... |

## NIST SSDF Activities (SP 800-218)

- Plan: threat model done; SBOM impact noted.
- Protect: branch protection; secret mgmt plan.
- Produce: CodeQL/Semgrep rules; tests planned.
- Respond: rollback plan; postmortem criteria.

## Flags & Rollout

- Flag keys: ...
- Rollout plan & guardrails: ...

## Observability

- OTel spans, key logs, dashboards.

## Acceptance Criteria

- ...

## ADR link

- ADR-###: ...
