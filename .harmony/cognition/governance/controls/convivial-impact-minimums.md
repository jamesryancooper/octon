---
title: Convivial Impact Minimums
description: Canonical minimum convivial-impact fields and review checks required for non-trivial planning and delivery artifacts.
status: Active
---

# Convivial Impact Minimums

> Convivial intent must be explicit and reviewable for non-trivial changes.

## Purpose

This contract operationalizes Harmony's Convivial Purpose by defining minimum
required convivial-impact fields for spec templates and minimum convivial checks
for pull requests.

It is the canonical governance control for:
- required convivial-impact planning fields,
- allowed value domains for attention and extraction classifications,
- minimum convivial review checklist presence in PR templates.

## Contract Scope

Applies to:
- `.harmony/cognition/practices/methodology/templates/spec-tier2.yaml`
- `.harmony/cognition/practices/methodology/templates/spec-tier3.yaml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/PULL_REQUEST_TEMPLATE/kaizen.md`

Tier 1/trivial planning is intentionally excluded.

## Required Planning Fields

Tier 2 and Tier 3 templates must define `convivial_impact` with at least:

- `capability_expansion`
- `attention_class`
- `extraction_risk`
- `manipulation_vectors`
- `mitigations`

## Classification Domains

Allowed `attention_class` values:
- `peripheral`
- `on_demand`
- `active`
- `interruptive`

Allowed `extraction_risk` values:
- `none`
- `minimal_local`
- `moderate_shared`
- `high_centralized`

## PR Checklist Minimums

PR templates must include a Convivial checklist section with checks for:
- capability expansion,
- attention respect and user control,
- anti-manipulation safeguards,
- extraction/data minimization safeguards.

## Relationship to Governance

- Convivial Purpose framing: `../purpose/convivial-purpose.md`
- Direction pillar validation expectations: `../pillars/direction.md`
- Principle translation layer: `../principles/README.md`

## Related Controls

- [RA/ACP Glossary](./ra-acp-glossary.md)
- [RA/ACP Promotion Inputs Matrix](./ra-acp-promotion-inputs-matrix.md)
- [Flag Metadata Contract](./flag-metadata-contract.md)
