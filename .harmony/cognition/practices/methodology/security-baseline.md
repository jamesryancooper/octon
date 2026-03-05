---
title: Security Baseline
description: Provider-agnostic security baseline mapped to OWASP ASVS and NIST SSDF with STRIDE-driven verification requirements.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/authority-crosswalk.md"
---

# Security Baseline

This document defines normative security controls for Harmony without binding to a specific provider.

## OWASP ASVS and NIST SSDF Alignment

- ASVS controls must be mapped in specs for auth, session, access control, validation, logging, crypto, and secure configuration.
- SSDF lifecycle controls must be present across planning, protection, secure production, and vulnerability response.

## Required Security/Quality Checks

1. STRIDE threats are documented and mapped to mitigations and tests.
2. CSRF controls exist for state-changing operations.
3. Core security headers are configured for affected surfaces.
4. SSRF controls are present for outbound integrations.
5. Secrets remain in approved secret stores or runtime environment managers (never source or logs).
6. Static and semantic security scans meet tiered severity thresholds defined in [ci-cd-quality-gates.md](./ci-cd-quality-gates.md) (`Gates by Tier` and `Gate Checklist`).
7. SBOM artifacts exist for required build/release surfaces.
8. License policy checks pass for dependency changes.
9. Non-security performance and bundle budgets are owned by [performance-and-scalability.md](./performance-and-scalability.md) and [ci-cd-quality-gates.md](./ci-cd-quality-gates.md), not by this security baseline.

## Secrets, Headers, and Provenance

- Secret handling is provider-agnostic: use managed secret stores and least-privilege access.
- Security headers may be enforced at application middleware, gateway, or platform edge; avoid conflicting duplicates.
- Provenance is mandatory for pipeline/release-surface changes: attest artifacts and link evidence in PR receipts.

## Privacy and Accessibility Addendum

- Never log PII/PHI; redact by default and log stable identifiers only.
- Maintain secure cookie/session defaults (`HttpOnly`, `Secure`, `SameSite`) and CSRF protections.
- Enforce critical accessibility checks on reviewable UI flows.
