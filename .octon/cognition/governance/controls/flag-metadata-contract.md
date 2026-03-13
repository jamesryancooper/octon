---
title: Flag Metadata Contract
description: Canonical metadata requirements for feature flags used in ACP promotion evidence.
status: Active
---

# Flag Metadata Contract

Flag metadata is canonical at:

- data file: `.octon/capabilities/governance/policy/flags.metadata.json`
- schema: `.octon/capabilities/governance/policy/flags.metadata.schema.json`
- validator: `.octon/capabilities/_ops/scripts/validate-flag-metadata.sh`

## Required Fields

- `flag_id`
- `owner`
- `created`
- `expires`
- `cleanup_by`
- `default`
- `description`
- `risk`
- `links`

ACP promotion for operations that modify flags requires `flags.metadata`
evidence and a valid metadata contract result.
