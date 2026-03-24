---
title: ".octon Super-Root Architecture"
description: Class-first super-root architecture for Octon.
---

# `.octon/` Super-Root Architecture

## Purpose

Octon's top level is organized by artifact class, not by domain. This makes
authored authority, raw inputs, operational truth, and rebuildable outputs
explicit.

## Canonical Topology

```text
.octon/
  README.md
  AGENTS.md
  octon.yml
  framework/
  instance/
  inputs/
  state/
  generated/
```

## Meanings

- `framework/` is portable authored Octon core and portable helper assets only.
- `instance/` is repo-specific durable authored material.
- `inputs/` is non-authoritative additive and exploratory input.
- `state/` is mutable operational truth and retained evidence.
- `generated/` is rebuildable output only.

Within `state/**`:

- `state/continuity/**` owns active repo and scope handoff state
- `state/evidence/**` owns retained operational trace and receipts
- `state/control/**` owns mutable publication and quarantine truth

Canonical repo-instance authority includes these instance-native surfaces:

- `instance/manifest.yml`
- `instance/ingress/**`
- `instance/bootstrap/**`
- `instance/locality/**`
- `instance/cognition/context/**`
- `instance/cognition/decisions/**`
- `instance/capabilities/runtime/**`
- `instance/orchestration/missions/**`
- `instance/extensions.yml`

Overlay-capable repo-instance authority is a bounded subset of `instance/**`
and is legal only when the framework overlay registry declares the point and
the instance manifest enables it:

| Overlay point | Instance path | Merge mode | Precedence |
| --- | --- | --- | ---: |
| `instance-governance-policies` | `instance/governance/policies/**` | `replace_by_path` | 10 |
| `instance-governance-contracts` | `instance/governance/contracts/**` | `replace_by_path` | 20 |
| `instance-agency-runtime` | `instance/agency/runtime/**` | `merge_by_id` | 30 |
| `instance-assurance-runtime` | `instance/assurance/runtime/**` | `append_only` | 40 |

Canonical locality inputs and outputs are:

- authored locality control metadata: `instance/locality/{manifest.yml,registry.yml}`
- authored per-scope manifests: `instance/locality/scopes/<scope-id>/scope.yml`
- durable scope-local context: `instance/cognition/context/scopes/<scope-id>/**`
- mutable scope-local continuity: `state/continuity/scopes/<scope-id>/**`
- mutable repo continuity: `state/continuity/repo/**`
- retained operational evidence: `state/evidence/**`
- mutable extension actual/quarantine state:
  `state/control/extensions/{active.yml,quarantine.yml}`
- raw additive extension packs: `inputs/additive/extensions/<pack-id>/**`
- raw exploratory proposals:
  `inputs/exploratory/proposals/<kind>/<proposal_id>/**`
- archived exploratory proposals:
  `inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/**`
- mutable locality quarantine: `state/control/locality/quarantine.yml`
- compiled effective locality outputs: `generated/effective/locality/**`
- compiled effective capability-routing outputs:
  `generated/effective/capabilities/**`
- compiled effective extension outputs: `generated/effective/extensions/**`
- derived cognition summaries, graphs, and projections:
  `generated/cognition/**`
- generated proposal discovery:
  `generated/proposals/registry.yml`

## Portability

`octon.yml` defines profile-driven portability. Do not copy the whole `.octon/`
tree as the default bootstrap model.

- `bootstrap_core` installs `octon.yml`, `framework/**`, and
  `instance/manifest.yml`; `/init` completes repo-local bootstrap projections.
- `repo_snapshot` exports `octon.yml`, `framework/**`, `instance/**`, and the
  clean published enabled-pack dependency closure through `/export-harness`
  and fails closed on incompatible, missing, or unclean enabled-pack state.
- `pack_bundle` exports selected additive packs plus dependency closure only
  and does not apply repo trust activation policy.
- `full_fidelity` is advisory only and uses a normal Git clone.
- `inputs/exploratory/**`, `state/**`, and `generated/**` stay out of
  `bootstrap_core` and `repo_snapshot`.

Raw pack compatibility and provenance travel with `inputs/additive/extensions/<pack-id>/pack.yml`.
Repo trust remains in `instance/extensions.yml`.

## Boundaries

- `framework/**` must not contain repo-local mutable state, retained evidence,
  or generated outputs.
- `framework/overlay-points/registry.yml` is the canonical overlay registry.
- `instance/manifest.yml#enabled_overlay_points` is the only repo-side
  overlay enablement surface.
- repo-root ingress adapters are projections only; canonical authored ingress
  lives under `instance/ingress/**`, `/.octon/AGENTS.md` is the projected
  ingress surface, and root `AGENTS.md` / `CLAUDE.md` must be symlinks or
  byte-for-byte parity copies only.
- framework updates preserve repo-owned `instance/**` content unless an
  explicit migration contract says otherwise
- undeclared or disabled overlay artifacts fail closed; there is no blanket
  `instance/**` shadow-tree model
- Raw `inputs/**` paths must never become direct runtime or policy
  dependencies.
- Proposal packages are integrated raw exploratory input only; they remain
  non-canonical and are discovered through `generated/proposals/registry.yml`
  without making that registry authoritative. The registry is rebuilt
  deterministically from proposal manifests and belongs to the generated/ops
  plane rather than the runtime authority plane.
- Retained validation and assurance receipts belong under
  `state/evidence/validation/**`; generated outputs remain rebuildable only.
- Human-led ideation is part of `inputs/exploratory/ideation/**`.
- Legacy mixed roots are not canonical and must not be reintroduced.
- Locality is root-owned; descendant `.octon/` roots, hierarchical scope
  inheritance, and ancestor-chain scope composition are invalid in v1.
- Descendant-local or scope-local proposal workspaces are invalid in v1.
