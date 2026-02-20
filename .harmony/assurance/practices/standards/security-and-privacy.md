---
title: Security and Privacy Baseline
description: Lightweight, actionable baseline for data classification, threat modeling, secrets, redaction, and vulnerability management aligned to Harmony gates.
---

# Security and Privacy Baseline

Status: Draft stub (align with product/regulatory needs)

## Two‑Dev Scope

- Threat modeling: STRIDE‑lite in ≤ 20 minutes per High‑risk change; record risks → mitigations → tests in the PR.
- Scans: require secret scanning and CodeQL/Semgrep on PRs; SBOM on releases only; block on criticals, backlog others with an SLA.
- Controls: keep to essentials (secrets via env/VaultKit, GuardKit redaction, secure headers). Avoid heavy IAM/RBAC frameworks until necessary.
- Ownership: one security lead (or rotating) approves waivers; keep waivers time‑boxed with follow‑ups.

## Pillars Alignment

- Speed with Safety: Security gates run continuously in CI/CD so small PRs ship safely; flags and kill‑switches protect risky paths.
- Simplicity over Complexity: A lightweight baseline (classification, STRIDE‑lite, secrets, redaction) avoids heavyweight frameworks while meeting essentials.
- Quality through Determinism: Deterministic scans (CodeQL/Semgrep/SBOM), documented controls, and auditable evidence ensure reproducibility and compliance.
- Guided Agentic Autonomy: GuardKit performs default redaction; agents may propose policy/test updates but humans approve and own risk decisions.
- Evolvable Modularity: Clear security contracts and adapter boundaries let you change providers (IDP, storage, scanners) or hosting without weakening controls or rewriting the core model.

See `.harmony/cognition/methodology/README.md` for Harmony’s five pillars.

## Objectives

- Make security controls predictable and auditable for a tiny team.
- Align to OWASP ASVS/NIST SSDF via policy gates; keep implementation lean.

## Data Classification (initial)

- Public, Internal, Confidential, Restricted (PII/PHI). Define examples per slice.
- Tag data at boundaries; apply least privilege and redaction at emit boundaries.

## Threat Modeling (STRIDE‑lite)

- When: new features, auth/payment changes, external exposure.
- Artifacts: checklist + notes in PR; ADR for architectural changes.

## Secrets and Redaction

- Secrets only via VaultKit; never log/trace/metric secrets.
- GuardKit scrubs PII/PHI at write boundaries; record rule IDs (not values) for provenance.

## Vulnerability and Patch Management

- CI: SAST/dep/secret scans; SBOM; treat critical as blocking unless waived.
- Upgrades: small/regular PRs; document risk/rollback.

## Runtime Controls

- AuthN/Z required for protected actions; fail‑closed by default.
- Flags separate deploy/release; kill switches for risky paths.

## Related Docs

- Governance model: `.harmony/cognition/_meta/architecture/governance-model.md`
- Runtime policy: `.harmony/cognition/_meta/architecture/runtime-policy.md`
- Observability requirements: `.harmony/cognition/_meta/architecture/observability-requirements.md`
- Knowledge Plane: `.harmony/cognition/knowledge-plane/knowledge-plane.md`
- Methodology overview: `.harmony/cognition/methodology/README.md`
- Implementation guide: `.harmony/cognition/methodology/implementation-guide.md`
- Layers model: `.harmony/cognition/methodology/layers.md`
- Improve layer: `.harmony/cognition/methodology/improve-layer.md`
