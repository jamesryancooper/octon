# Incoming Intake Processing

This document governs Octon intake units staged under
`inputs/additive/.incoming/<intake-id>/`.

Incoming intake units are raw intake only. They may inform a route decision, but
they are never runtime, policy, publication, generated, state/control, retained
evidence, or host-projection authority. Processing begins only after the intake
unit is classified into exactly one final route.

## Lifecycle

1. **Intake**
   - Required source path: `inputs/additive/.incoming/<intake-id>/`.
   - Reject root `.archive/**`, Downloads paths, host skill directories,
     generated outputs, state/control truth, normalized extension roots, and any
     path outside `.octon/inputs/additive/.incoming/**`.
   - Validate with
     `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id <intake-id>`.
   - Inventory meaningful files, exclude platform noise such as `.DS_Store`,
     and record checksums for retained decision evidence.
2. **Classification**
   - Apply the decision matrix below.
   - Emit a decision receipt under `state/evidence/**` before any installation,
     normalization, activation, publication, archive move, or cleanup.
   - Select exactly one route: additive extension pack, core Octon skill, or
     blocked/proposal-required.
3. **Disposition**
   - Additive extension route normalizes reviewed content into
     `inputs/additive/extensions/<extension-pack-id>/` and keeps activation in
     `instance/extensions.yml`.
   - Core skill route installs only the reviewed skill payload under
     `framework/capabilities/runtime/skills/**` and updates existing skill
     manifests, registries, validations, and host projection flows.
   - Blocked route retains or archives the intake copy without installing it and
     routes missing contracts, unsafe posture, or ownership ambiguity to a
     proposal or design update.
4. **Validation**
   - Run the route-specific validation floor before claiming success.
   - Use existing extension, skill, publication, and host-projection pipelines.
   - Do not hand-create generated/effective or host-specific projection files.
5. **Cleanup**
   - Remove `.incoming/<intake-id>/` after every final route disposition and
     evidence capture.
   - Leave `.incoming/<intake-id>/` in place only when processing explicitly stops
     after classification without applying disposition.
   - Any `.incoming/<intake-id>/` directory that remains in place must include
     `intake-status.yml` with `schema_version:
     octon-additive-incoming-intake-status-v1`, matching `intake_id`,
     `authority_mode: non_authoritative`, one allowed status, and a reason.
   - Retain rejected, superseded, historical, or blocked intake copies under
     `inputs/additive/.archive/<intake-id>/` only when retention is safe,
     reviewable, justified, and evidenced.
   - Keep decision, validation, and cleanup evidence under `state/evidence/**`.

## Decision Matrix

| Route | Required Criteria | Examples | Destination | Required Gates |
| --- | --- | --- | --- | --- |
| Additive extension pack | Optional, selectable, portable, trust-gated, externally sourced, or useful as a reusable pack outside the core harness | prompt bundles, optional language support packs, templates, portable commands, extension-owned skills | `inputs/additive/extensions/<extension-pack-id>/` | `pack.yml`, `validation/compatibility.yml`, capability profiles, provenance, trust decision, extension publication validation |
| Core Octon skill | Always-on foundation capability required by Octon itself, framework-owned, not optional, not trust-selected, and needed by core orchestration or capability routing | canonical foundation skill, required governance support skill, built-in harness behavior skill | `framework/capabilities/runtime/skills/<family>/<skill-id>/` | skill manifest/registry integration, allowed-tool review, skill validation, capability routing, host projection validation when projections change |
| Blocked / proposal-required | Ownership unclear, provenance missing, unsafe trust posture, invalid structure, schema mismatch, route ambiguity, or no existing Octon contract fits | downloaded kit with no provenance, direct installer that tries to modify host-specific directories, source bundle requiring new authority surface, malformed extension with no compatible schema | `inputs/additive/.archive/<intake-id>/` when safely retained; decision evidence under `state/evidence/**` | blocked decision receipt, proposal/design route, no activation, no publication, no runtime consumption |

## Additive Extension Route

Use this route when the intake unit should become optional, selectable,
portable, externally sourced, trust-gated, or reusable as an additive extension
pack.

Required implementation behavior:

- normalize reviewed content into
  `inputs/additive/extensions/<extension-pack-id>/`
- add or verify `pack.yml` with `schema_version: octon-extension-pack-v5`
- add or verify `validation/compatibility.yml`
- declare capability profiles and required contracts
- carry provenance in `pack.yml`
- update `instance/extensions.yml` only when there is an explicit activation
  decision
- publish only through existing extension publication pipelines
- remove or archive the original `.incoming/<intake-id>/` copy after evidence is
  captured; final disposition must leave no `.incoming/<intake-id>/` dependency

Validation floor:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`

When extension contributions affect capabilities or host projections, also run:

- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`

## Core Octon Skill Route

Use this route only when the intake unit contains a framework-owned always-on
skill required by Octon itself.

Required implementation behavior:

- install only reviewed skill files under
  `framework/capabilities/runtime/skills/**`
- merge fragments into existing skill manifests, registries, capability groups,
  and routing surfaces; never replace shared files wholesale
- validate allowed tools, triggers, skill family, and command exposure
- publish routing and host projections only through existing scripts
- move the consumed incoming copy to input `.archive/<intake-id>` when safely
  retained as historical source material, or remove it after evidence captures
  the necessary inventory; final disposition must leave no
  `.incoming/<intake-id>/` dependency

Validation floor:

- `bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh <skill-id>`
- `bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict <skill-id>`
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`

When host projections change, also run:

- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`

## Blocked Or Proposal-Required Route

Use this route when the incoming intake unit cannot be safely installed or
normalized under existing contracts.

Blocking conditions include:

- ambiguous ownership between `framework/**`, `instance/**`, and `inputs/**`
- missing or unverifiable provenance
- trust posture requiring a human acknowledgement that has not been granted
- schema mismatch or unsupported extension API version
- installer instructions that bypass Octon manifests, registries, validation,
  publication, or host projection flows
- attempts to write directly to `.codex/skills`, `.claude/skills`,
  `.cursor/skills`, generated/effective outputs, state/control truth, or root
  `.archive/**`
- no existing Octon contract fits the requested capability

Required behavior:

- do not install, activate, publish, project, or expose the intake unit
- write a blocked decision receipt under `state/evidence/**`
- retain the intake unit under `inputs/additive/.archive/<intake-id>/` only when
  retention is safe and needed for review, or leave only evidence if retention
  is unnecessary or unsafe
- remove the source `.incoming/<intake-id>/` copy when blocked disposition is
  final; leave it in `.incoming` only for explicit classification-only stops
- route contract, schema, authority, or ownership gaps to an appropriate design,
  migration, architecture, or policy proposal

## Archive Retention Policy

The additive intake archive is not a general dumping ground. A retained intake
copy may be committed only when it is safe, reviewable, and justified by
evidence.

Use evidence-only retention instead of copying source material when an intake
unit contains:

- secrets, credentials, private keys, tokens, or local user data
- proprietary, licensed, or redistribution-unsafe material
- unsafe binaries or opaque executable payloads
- excessive size or material better represented by an external replay pointer
- content whose retention would widen trust, policy, or runtime authority

Retained archive evidence must state why the source copy is retained or why only
evidence pointers were kept.

## Evidence Requirements

Each processing run must retain:

- incoming path and intake id
- inventory of meaningful files and explicitly excluded noise
- route decision and rationale
- rejected routes and why they were rejected
- provenance, trust, and compatibility findings
- exact file/path changes made
- validation commands and outcomes
- cleanup disposition for `.incoming/<intake-id>/`
- proof that `.incoming/<intake-id>/` is absent after final disposition, or proof
  that processing stopped after classification before disposition
- archive retention decision, including evidence-only disposition when source
  retention is unsafe
- final status: normalized-extension, installed-core-skill, blocked, rejected,
  superseded, or historical

Decision and validation evidence belongs under `state/evidence/**`; the intake
copy itself is not evidence authority.

## Non-Goals And Prohibited Shortcuts

Do not:

- use root `.archive/**` or Downloads paths as installation staging
- treat `.incoming/**` or `.archive/**` as an installed pack, active extension,
  policy source, runtime source, generated output, retained evidence, or
  host-projection authority
- install directly into `.codex/skills`, `.claude/skills`, `.cursor/skills`, or
  any other host-specific skill directory
- activate an extension without `instance/extensions.yml`
- publish extension or host-projection outputs by hand
- replace shared manifests, registries, routing, or capability files wholesale
- widen allowed tools, trust posture, capability groups, support targets, or
  extension profiles just to make an intake unit install
- bypass validation because the intake unit appears complete
- leave `.incoming/<intake-id>/` after final disposition; only
  `stop_after_classification` may leave raw intake in place
- scan `.incoming/**` autonomously as an implicit installation trigger; future
  automation must enter through admitted workflow or run contracts
