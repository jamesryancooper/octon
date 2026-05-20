---
name: octon-drift-triage
description: >
  Selects and optionally runs existing Octon drift, alignment, and publication
  checks from changed paths, then emits a ranked non-authoritative remediation
  packet for maintainers.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/reports/*)
---

# Octon Drift Triage

Use this skill when you want changed paths, diff refs, or an existing triage
packet converted into a ranked remediation packet.

## Core Workflow

1. Normalize the changed-path input set.
2. Read the additive routing and ranking sources of truth.
3. Select direct checks, recommendation bundles, and conditional repo-hygiene.
4. If `mode=run`, execute the selected read-only checks and distill results.
5. Merge evidence into remediation families and rank the outcomes.
6. Materialize the packet under `/.octon/inputs/exploratory/reports/`.

## Inputs

- `changed_paths`
- `diff_base`
- `diff_head`
- `packet_path`
- `mode`
- `alignment_mode`

`mode` defaults to `select`. `alignment_mode` defaults to `auto`.

## Outputs

- a report rooted under `/.octon/inputs/exploratory/reports/`
- `packet.yml` with stored input state, selected checks, repo-hygiene status,
  ranking metadata, and remediation items
- human-facing reports, a remediation plan, and a maintainer-ready prompt
- optional raw check output captures in `support/raw-check-output/`

## Boundaries

- Additive only.
- The packet remains non-authoritative and must never be treated as a control,
  policy, or runtime source of truth.
- V1 may only select or run existing read-only checks.
- Do not publish effective outputs, rewrite governance, or apply fixes from
  this skill.
- `repo-hygiene` is conditional and scan-only.

## References

- `context/check-routing.yml`
- `context/ranking-model.yml`
- `prompts/octon-drift-triage-remediation-packet/manifest.yml`
