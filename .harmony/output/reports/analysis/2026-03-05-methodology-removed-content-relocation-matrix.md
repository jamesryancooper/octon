---
title: Methodology Removed-Content Relocation Matrix
description: Source-to-destination relocation map for architectural, structural, tooling, and operational content removed from methodology normalization.
author: Harmony Architect Agent
date: "2026-03-05"
status: draft
---

# Methodology Removed-Content Relocation Matrix

## Scope

This matrix maps removed content under `.harmony/cognition/practices/methodology/**` to the appropriate destination surface in Harmony. It distinguishes between:

- Content that should be relocated to skills or other domain surfaces
- Content already covered elsewhere and only needing cross-links
- Content that should remain removed because it conflicts with canonical governance

## Matrix

| Removed Cluster | Primary Removed Sources | Destination Surface | Destination Path(s) | Relocation Mode | Acceptance Checks |
|---|---|---|---|---|---|
| Twelve-Factor runtime discipline (config/logs/build-release-run) | `implementation-guide.md`, `architecture-and-repo-structure.md` | Assurance standards + architecture policy | `.harmony/assurance/practices/standards/security-and-privacy.md`, `.harmony/cognition/_meta/architecture/runtime-policy.md` | Relocate as provider-agnostic controls | Includes explicit 12-factor style checklist language without provider lock-in; linked from methodology index surfaces |
| Hexagonal boundary enforcement examples | `implementation-guide.md`, `architecture-and-repo-structure.md` | Architecture (canonical) + assurance enforcement notes | `.harmony/cognition/_meta/architecture/repository-blueprint.md`, `.harmony/cognition/_meta/architecture/monorepo-layout.md` | Already covered canonically; add enforcement references when missing | Boundary rules remain domain-inward; any example tools treated as non-normative |
| Monorepo structure examples | `architecture-and-repo-structure.md`, `implementation-guide.md` | Architecture canonical + onboarding docs | `.harmony/cognition/_meta/architecture/monorepo-layout.md`, `.harmony/cognition/_meta/architecture/repo-layout-for-new-engineers.md` | Already covered; preserve as canonical references | `apps/*` vs `packages/*` guidance remains consistent across docs |
| Turborepo task-graph and cache troubleshooting | `implementation-guide.md` | Skill (platform execution) | `.harmony/capabilities/runtime/skills/platforms/turborepo-taskgraph/` | Relocate to specialized skill | Skill registered in manifest/registry/capabilities; validation passes; outputs deterministic run log |
| CI gate triage recipes (contracts/security/quality) | `implementation-guide.md`, `tooling-and-metrics.md`, `ci-cd-quality-gates.md` | Skill (remediation execution) + assurance standards references | `.harmony/capabilities/runtime/skills/remediation/ci-gate-triage/`, `.harmony/assurance/practices/standards/testing-strategy.md`, `.harmony/assurance/practices/standards/security-and-privacy.md` | Relocate execution steps to skill; standards remain policy-neutral | Skill includes deterministic phases and escalation; references canonical gate standards |
| Incident response, rollback choreography, and postmortem workflow | `reliability-and-ops.md`, `sandbox-flow.md` | Skill (operations execution) + runtime policy | `.harmony/capabilities/runtime/skills/operations/incident-response/`, `.harmony/cognition/_meta/architecture/runtime-policy.md` | Relocate execution workflow to skill | Skill produces run artifact/report; retains policy linkage to runtime-policy and ACP gates |
| Provider-specific deploy/promotion details (Vercel/GitHub previews) | `README.md`, `implementation-guide.md`, `sandbox-flow.md`, `tooling-and-metrics.md` | Platform skills + non-normative stack profile | `.harmony/capabilities/runtime/skills/platforms/provider-vercel-delivery/`, `.harmony/capabilities/runtime/skills/platforms/provider-github-gates/`, `.harmony/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md` | Already relocated to skills/profile | Provider steps do not appear as canonical governance requirements |
| Next.js/Astro runtime-specific behavior (SSR/SSG/Edge, caching, headers) | `implementation-guide.md`, `architecture-and-repo-structure.md` | Platform skill + stack profile | `.harmony/capabilities/runtime/skills/platforms/provider-nextjs-astro-runtime/`, `.harmony/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md` | Already relocated | Guidance remains explicitly non-normative outside canonical contracts |
| Preview smoke commands and evidence pattern | `README.md`, `ci-cd-quality-gates.md`, `implementation-guide.md` | Platform skill + workflow contract | `.harmony/capabilities/runtime/skills/platforms/provider-preview-smoke/`, `.github/workflows/smoke.yml` | Relocated to skill + workflow | No references to removed scripts; smoke evidence path is documented |
| Security/perf tool lists with unimplemented specifics (e.g., tool-by-tool mandates) | `implementation-guide.md`, `security-baseline.md`, `performance-and-scalability.md` | Assurance standards (tool-agnostic) + optional skills | `.harmony/assurance/practices/standards/security-and-privacy.md`, `.harmony/assurance/practices/standards/testing-strategy.md` | Normalize to provider/tool-neutral baseline | Canonical docs avoid hardcoding unimplemented provider/tool commands |
| Stale/non-runnable path references (`scripts/smoke-check.sh`, `scripts/flags-stale-report.js`, `infra/ci/pr.yml`) | `README.md`, `ci-cd-quality-gates.md`, `tooling-and-metrics.md`, `implementation-guide.md` | Do not relocate as-is | N/A | Keep removed; replace only with live workflow/skill references | No broken path references remain in methodology docs |
| Non-canonical risk taxonomy (`Trivial/Low/Medium/High`) | `implementation-guide.md` | Do not relocate | N/A | Keep removed | Methodology uses canonical `T1/T2/T3` only |

## Skill Scaffolds Triggered By This Matrix

1. `platforms/turborepo-taskgraph`
2. `remediation/ci-gate-triage`
3. `operations/incident-response`

## Verification Notes

- Relocation-to-skill entries require:
  - manifest + registry + capabilities wiring
  - required reference files for declared capability sets
  - validator pass for each new skill ID
- Relocation-to-doc entries require provider-agnostic language and canonical cross-linking.
