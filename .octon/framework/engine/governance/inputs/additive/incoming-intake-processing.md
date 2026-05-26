# Incoming Intake Processing

This document governs Octon intake units staged under
`inputs/additive/.incoming/<intake-id>/`.

Incoming intake units are raw intake only. They may inform a route decision, but
they are never runtime, policy, publication, generated, state/control, retained
evidence, or host-projection authority. Processing begins only after the intake
unit is classified into exactly one final route.

New intake units must be bounded by a minimal, non-authoritative envelope:

```text
inputs/additive/.incoming/<intake-id>/
  intake.yml
  payload/
  README.md
```

`intake.yml` and `payload/` are required. `README.md` is optional human context.
Raw payload must live only under `payload/`. The envelope records intake-time
facts needed for deterministic capture and classification; it is not a
normalized extension pack, installed skill, evidence bundle, generated output,
state/control source, publication source, policy source, runtime source, or
host projection.

## Lifecycle

1. **Intake**
   - Required source path: `inputs/additive/.incoming/<intake-id>/`.
   - Reject root `.archive/**`, Downloads paths, host skill directories,
     generated outputs, state/control truth, normalized extension roots, and any
     path outside `.octon/inputs/additive/.incoming/**`.
   - Validate with
     `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id <intake-id>`.
   - Require `intake.yml`, `payload/`, and no other top-level entries except
     optional `README.md`.
   - Inventory meaningful payload files under `payload/`, exclude platform
     noise such as `.DS_Store`, and record checksums for retained decision
     evidence.
   - Treat validator-reported provenance, route, binary, executable,
     secret/private-data, redistribution, size, candidate extension pack, and
     candidate core skill findings as classification inputs.
2. **Classification**
   - Apply Governed Incoming Intake Routing.
   - Emit a
     `governed-incoming-intake-route-decision-v1` receipt under
     `state/evidence/**` before any proposal admission handoff, installation,
     normalization, activation, publication, archive move, closeout, or cleanup.
   - Select exactly one route: `single-work-unit-handoff`,
     `coordinated-program-handoff`, `target-owned-direct-handoff`, or
     `blocked-rejected-deferred`.
3. **Handoff Or Denial**
   - `single-work-unit-handoff` creates only advisory context for target-owned
     proposal packet admission.
   - `coordinated-program-handoff` creates only advisory context for
     target-owned proposal program admission.
   - `target-owned-direct-handoff` is denied until a non-proposal target-owned
     intake admission contract exists.
   - `blocked-rejected-deferred` records denial evidence and performs no
     install, activation, publication, projection, closeout, cleanup, or target
     dispatch.
4. **Validation**
   - Run route-decision, handoff, target admission, and target return validators
     before claiming a handoff or denial is complete.
   - Use target-owned proposal lifecycle and GLO validation for proposal packet
     or program admission.
   - Do not hand-create generated/effective or host-specific projection files.
5. **Cleanup**
   - Remove `.incoming/<intake-id>/` only through a governed final disposition
     whose archive or evidence-only posture is safe and evidenced.
   - Leave `.incoming/<intake-id>/` in place when processing stops after
     classification or advisory handoff without applying final disposition.
   - Any current `.incoming/<intake-id>/` directory that remains in place must
     preserve its non-authoritative `intake.yml` envelope. Legacy directories
     with `intake-status.yml` remain non-authoritative raw intake until a
     separately governed migration or disposition occurs.
   - Retain rejected, superseded, historical, or blocked intake copies under
     `inputs/additive/.archive/<intake-id>/` only when retention is safe,
     reviewable, justified, and evidenced.
   - Keep decision, validation, and cleanup evidence under `state/evidence/**`.

## Governed Decision Matrix

| Route | Required Criteria | Target Owner | Required Gates |
| --- | --- | --- | --- |
| `single-work-unit-handoff` | One coherent intent, one primary target surface, no child sequencing, no migration/cutover, no cross-surface dependency, reviewable provenance, bounded validation | proposal packet lifecycle | route decision receipt, advisory handoff receipt, proposal packet intake admission contract, target-owned proposal creation receipt |
| `coordinated-program-handoff` | Multiple surfaces or candidate changes, dependency ordering, staged adoption, migration/cutover, governance plus runtime change, or child packet coordination | proposal program lifecycle | route decision receipt, advisory handoff receipt, proposal program intake admission contract, parent program creation receipt, child receipt isolation |
| `target-owned-direct-handoff` | Future non-proposal target with a valid target-owned intake admission contract | future target lifecycle | denied until the target contract, validators, receipts, rollback posture, and fail-closed fixtures exist |
| `blocked-rejected-deferred` | Malformed envelope, unsafe provenance/licensing, secrets/private data, proprietary or binary risk, unsupported target, ambiguity, stale evidence, requested-route mismatch, scope drift, or authority-confused claims | intake routing denial evidence | no handoff, no target dispatch, denial receipt, no install, no activation, no publication, no runtime exposure |

## Target-Owned Handoff Routes

`single-work-unit-handoff` and `coordinated-program-handoff` may create
`governed-incoming-intake-handoff-v1` advisory context after the route decision
is retained. The target proposal lifecycle must independently validate the
handoff, scope, freshness, authority boundary, receipts, rollback posture, and
target gates before creating any packet or program.

The handoff context may include source facts, payload inventory digests,
classification rationale, and expected return evidence. It must not authorize
Git mutation, hosted provider action, branch cleanup, worktree cleanup, repo
hygiene deletion, promotion, archive, scope expansion, proposal completion,
Change closeout, or target lifecycle mutation.

Proposal packet lifecycle owns packet creation, review/revision,
implementation readiness, implementation prompt/run, verification/correction,
proposal closeout, archive, and packet-local receipts. Proposal program
lifecycle owns parent program creation, child registry planning, dependency
ordering, program checkpoints, program evidence, and child receipt isolation.
Parent program evidence never satisfies child packet receipts.

## Legacy Direct Dispositions

The former direct additive extension pack and core Octon skill dispositions are
legacy behavior until a governed migration removes them from runtime use. New
mature intake routing should prefer proposal packet or proposal program
admission for extension packs, core Octon skills, and other core surfaces.

Do not install, normalize, activate, publish, project, archive, close out, clean
worktrees, or delete repo hygiene residue from raw intake classification.
Those effects belong to target-owned lifecycle routes and their receipts.

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
- envelope facts, classification findings, and inventory of meaningful payload
  files with explicitly excluded noise
- route decision and rationale
- rejected routes and why they were rejected
- provenance, trust, and compatibility findings
- route decision receipt digest
- advisory handoff receipt digest when handoff context is created
- target admission contract reference when handoff is requested
- target-owned preflight result when invoked
- target return evidence refs when a target lifecycle returns evidence
- validation commands and outcomes
- final disposition or stop point for `.incoming/<intake-id>/`
- proof that `.incoming/<intake-id>/` is absent after final disposition, or proof
  that processing stopped after classification or advisory handoff before final
  disposition
- archive retention decision, including evidence-only disposition when source
  retention is unsafe
- final route disposition: `single-work-unit-handoff`,
  `coordinated-program-handoff`, or `blocked-rejected-deferred`; retained
  archive metadata may separately explain blocked, rejected, deferred,
  superseded, or historical handling without creating additional route outcomes

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
- treat proposal handoff context or lifecycle interaction receipts as target
  authorization
- let parent program evidence satisfy child packet receipts
- leave `.incoming/<intake-id>/` after final disposition; classification-only
  and advisory-handoff stops may leave raw intake in place when no final
  disposition has been applied
- scan `.incoming/**` autonomously as an implicit installation trigger; future
  automation must enter through admitted workflow or run contracts
