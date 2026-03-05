---
title: Worked Example - OAuth Login and Org Billing
description: Example spec-to-delivery walkthrough for OAuth login and billing with risk-tiered governance.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/README.md"
---

# Worked Example - OAuth Login + Org Billing

## Spec Extract (Abbreviated)

- Problem: add OAuth (Google) login + org billing (Stripe).
- Contracts: `/api/auth/callback`, `/api/billing/webhook` (OpenAPI).
- Non-functionals: p95 auth callback <= 600ms; availability >= 99.9%.
- Security: ASVS V2 (authentication), V3 (session), V4 (access control), V10
  (errors/logging).
- STRIDE highlights:
  - spoofing (OAuth state)
  - tampering (webhook signature)
  - information disclosure (PII)
  - DoS (webhook storms)
  - elevation of privilege (role mapping)
- Mitigations: state+nonce, Stripe signature verification, PII minimization,
  rate limit, RBAC checks.

## Feature Story -> AI IDE

- Context packets: OAuth sequence, Stripe events
  (`checkout.session.completed`, `invoice.paid`).
- Agent plan:
  - adapters: `adapters/oauth-google.ts`, `adapters/stripe.ts`
  - domain services: `AuthService`, `BillingService`
  - routes and tests (unit + Pact for webhook)
  - e2e smoke on Preview
- Acceptance:
  - user can sign in
  - org is created/linked
  - paid plan toggles `billing.active`
  - webhook retries remain idempotent

## PR Flow

- Tiny PR 1: contracts + stub adapters + failing tests -> green.
- Tiny PR 2: OAuth implementation behind `flag.oauth_google`, CSRF/state
  checks, contract tests pass.
- Tiny PR 3: Stripe webhook signature verification + idempotent store; Pact
  verifies; Playwright smoke passes on Preview.
- Release: enable `flag.oauth_google` for internal org only, monitor SLO/error
  rate, then widen cohorts.
