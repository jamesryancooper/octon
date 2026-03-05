---
title: Security Baseline
description: Harmony’s security baseline mapped to OWASP ASVS and NIST SSDF, including STRIDE per feature, secrets and headers guidance, and accessibility/privacy addendum.
---

# Security Baseline

This document expands the security sections of the Harmony Methodology into a focused reference. Use it when designing specs, threat models, and CI gates that must align with OWASP ASVS, NIST SSDF, and Harmony’s privacy expectations.

## OWASP ASVS and NIST SSDF Alignment

**OWASP ASVS** (sample of included controls):

- **Auth/session/access control**, **input validation**, **error handling**, **logging/monitoring**, **config/hardening**, **crypto at rest/in transit**; map to Spec’s **ASVS IDs**; include a minimal evidence record per PR.

**NIST SSDF** (SP 800‑218) baked into lifecycle:

- **Plan/Organize**: threat modeling (STRIDE), SBOM plan, SLO/SLA doc.
- **Protect Software**: SCA, secret scanning, signed releases, protected branches.
- **Produce Well‑Secured Software**: code review, fuzz/negative tests, CodeQL/Semgrep, unit/contract/e2e.
- **Respond to Vulnerabilities**: triage SOP, patch SLAs, postmortems, SBOM updates.

## Baseline Security/Performance Gate Checks

These checks should be explicit in specs, PR evidence, and CI gate reviews:

1. STRIDE threats are documented and mapped to mitigations/tests.
2. CSRF protections exist for state-changing operations.
3. CSP and core security headers are configured for affected surfaces.
4. SSRF controls are present for outbound integrations (allow-list/egress controls).
5. Secrets remain in environment/secret managers only (never in source or logs).
6. CodeQL and Semgrep are clean at required severity thresholds.
7. SBOM artifacts are present for required build/release surfaces.
8. License policy checks pass for dependency changes.
9. p95 latency remains within documented budgets for affected paths.
10. Bundle-size budgets are met, or accepted with documented override evidence.

## STRIDE and Defenses

**STRIDE per feature** (micro‑threat model in Spec): identify risks → mitigations → tests → checklist items. (Use OWASP cheat sheets for CSP/CSRF/SSRF; for **Next.js** use **next-safe-middleware**. Use **Helmet** only when running a custom Node/Express server. For **Astro**, set security headers at the platform (e.g., Vercel project headers) for SSG; use SSR middleware only when using an SSR adapter.)

### Secrets, Headers, and Defenses

- **Secrets** only in Vercel envs; CI blocks leaks. **CSP/HSTS/X‑Frame‑Options/Referrer‑Policy** via framework middleware or platform headers; for Astro static sites, configure headers at the hosting layer (e.g., Vercel) and prefer platform‑level headers for SSG. For SSR (Next.js or Astro adapters), enforce headers in middleware; platform‑level headers take precedence, and SSR middleware should complement, not conflict. CSRF protections for mutations; SSRF‑hardening on outbound calls.
- **SBOM** in releases; **license policy** gates (ban GPL if incompatible).
  - **Data classification & PII**: classify data touched by a change; ensure appropriate handling (encryption, redaction, access controls) and avoid logging sensitive content.
  - **Provenance & signed releases**: attest build artifacts (e.g., GitHub attestations/Sigstore cosign) and sign releases; link provenance in PRs that modify pipelines or release processes.

## Accessibility & Privacy Addendum

- Enable `eslint-plugin-jsx-a11y` for UI surfaces; treat critical a11y violations as policy/eval failures on reviewable surfaces.
- Use semantic HTML and appropriate ARIA attributes; exercise keyboard/screen‑reader checks on critical flows using risk-based prioritization.
- Never log PII/PHI; rely on **GuardKit** redaction by default and log only stable IDs/non‑sensitive metadata.
- Enforce CSP and core security headers via platform/middleware (see Next.js guidance); avoid duplicative/conflicting policies.
- Cookies and sessions follow secure defaults: `HttpOnly`, `Secure`, `SameSite`, and CSRF tokens on mutations.
