---
title: Spec Kit One-Pager Template
description: Prompt scaffold for generating Spec Kit one-pagers with harmony-specific guardrails.
---

- Title: 
- Owner: 
- Date: 
- Links: ADR, issue, designs

## Problem
- What user/customer problem are we solving?
- Why now? Impact, dependencies, risks.

## Scope & Cuts
- In scope:
- Out of scope:

## Contracts
- UI routes/screens and states
- API endpoints (OpenAPI refs in `packages/contracts`)
- Data contracts (schemas), events, and error semantics

## Acceptance Criteria
- Observable behaviors and edge cases
- Negative tests from STRIDE threats

## Non-Functionals
- Performance budgets (TTFB/p95/etc.)
- Security (ASVS controls), privacy, compliance
- Reliability (SLOs), availability, latency, error rate

## Threat Model (STRIDE)
- Spoofing:
- Tampering:
- Repudiation:
- Information Disclosure:
- Denial of Service:
- Elevation of Privilege:
- Mitigations/tests:

## Rollout & Flags
- Feature flags (see `@config/flags`)
- Migration/rollback plan (promote prior Vercel preview)

## Telemetry & Ops
- SLIs/SLOs, alerting, dashboards
- Traces/metrics/logs required

