---
title: Methodology-as-Code
description: Policy for maintaining Octon methodology as machine-readable, verifiable repository contracts.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/constitution/CHARTER.md"
  - "/.octon/framework/constitution/precedence/normative.yml"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
---

# Methodology-as-Code

Status: Active (repository version from `version.txt`; pre-1.0 release state at time of this review)

## Overview

Octon treats methodology as code by keeping operational guidance anchored to machine-readable discovery indexes, tier templates, and assurance checks that can be verified deterministically.

**Guiding principle:** repository contract artifacts are authoritative; narrative docs must stay synchronized with those artifacts.

## Canonical Methodology Contract Surfaces

The methodology contract in this repository is defined by these artifacts:

- `index.yml` - canonical discovery index for methodology artifacts.
- `README.index.yml` - sidecar section index for overview targeting.
- `implementation-guide.index.yml` - sidecar section index for implementation targeting.
- `templates/index.yml` - canonical discovery index for tier templates.
- `templates/spec-tier1.yaml`, `templates/spec-tier2.yaml`, `templates/spec-tier3.yaml` - tiered planning contracts.
- `migrations/index.yml` and `audits/index.yml` - governance doctrine discovery contracts for migration/audit workflows.

When discovery indexes and content diverge, update indexes first, then align all linked docs.

## Version and Release-State Contract

- Repository release state is determined from `version.txt`:
  - `pre-1.0`: `< 1.0.0` or prerelease.
  - `stable`: `>= 1.0.0` and not prerelease.
- Determine current release state directly from `version.txt` at validation time; avoid fixed version literals in methodology narratives.
- Do not hardcode version in downstream methodology docs; read `version.txt` for release-state evaluation.
- Methodology discovery/index files use explicit `schema_version` keys; tier templates use `_schema_version` keys.
- Any migration/governance-impacting methodology update must preserve profile-governance receipts (`change_profile`, `release_state`, and required sections).

## Deterministic Validation Expectations

Methodology updates must be validated with deterministic checks:

1. **Discovery integrity**
   - Every `path:` entry in methodology indexes resolves to an existing file.
2. **Reference integrity**
   - No dangling relative links in methodology markdown.
3. **Contract alignment**
   - Assurance checks pass for harness/framing alignment.

Canonical assurance invocation:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,framing
```

## CI Integration Baseline

Methodology policy checks should run in CI using existing assurance surfaces rather than ad-hoc package-local validators.

```yaml
# .github/workflows/pr-quality.yml
- name: Validate methodology alignment
  run: bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,framing
```

## Source of Truth Hierarchy

1. **Repository constitutional and agency execution contracts (binding precedence)**
   - `/AGENTS.md`
   - `/.octon/framework/constitution/CHARTER.md`
   - `/.octon/framework/constitution/obligations/fail-closed.yml`
   - `/.octon/framework/constitution/precedence/normative.yml`
   - `/.octon/framework/execution-roles/governance/CONSTITUTION.md`
   - `/.octon/framework/execution-roles/governance/DELEGATION.md`
   - `/.octon/framework/execution-roles/governance/MEMORY.md`
2. **Cognition governance framing (principles and pillars)**
   - `/.octon/framework/cognition/governance/principles/principles.md`
   - `/.octon/framework/cognition/governance/principles/README.md`
   - `/.octon/framework/cognition/governance/pillars/README.md`
3. **Methodology authority crosswalk**
   - `/.octon/framework/cognition/practices/methodology/authority-crosswalk.md`
4. **Methodology discovery contracts**
   - `/.octon/framework/cognition/practices/methodology/index.yml`
   - `/.octon/framework/cognition/practices/methodology/*/*.yml` index surfaces
5. **Tier and workflow contracts**
   - `/.octon/framework/cognition/practices/methodology/templates/spec-tier*.yaml`
   - `/.octon/framework/cognition/practices/methodology/migrations/*`
   - `/.octon/framework/cognition/practices/methodology/audits/*`
6. **Narrative methodology docs**
   - `/.octon/framework/cognition/practices/methodology/*.md`

Runtime promotion authority sentence used across methodology artifacts:

`ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.`

## Breaking Change Procedure

For methodology-breaking changes:

1. Update the affected discovery/index contracts first.
2. Update linked narrative docs in the same change.
3. Record migration/governance receipts when required by policy.
4. Run alignment and integrity checks before merge.
5. If removing artifacts, ensure no downstream references remain.

## Deprecation and Removal Rules

- Deprecate by removing artifact references from discovery indexes first.
- Relocate durable guidance into surviving canonical artifacts before deletion.
- Avoid dual-authority states where removed artifacts are still referenced by indexes or overview docs.

## Related Documents

- [Methodology Overview](./README.md)
- [Methodology Index](./index.yml)
- [Authority Crosswalk](./authority-crosswalk.md)
- [Templates Index](./templates/index.yml)
- [Migration Governance](./migrations/README.md)
- [Audit Governance](./audits/README.md)
- [Alignment Check Script](../../../assurance/runtime/_ops/scripts/alignment-check.sh)
