# Incoming Additive Intake

`inputs/additive/.incoming/<intake-id>/` is the only staging surface for raw
additive intake before classification.

Required layout for new intake units:

```text
.incoming/<intake-id>/
  intake.yml
  payload/
  README.md
```

`intake.yml` and `payload/` are required. `README.md` is optional
non-authoritative human context. All unreviewed imported source artifacts for
one intake unit must live under `payload/`.

Prohibited contents include raw payload outside `payload/`, normalized
extension source packs as installed sources, generated output as generated
authority, state/control files, retained evidence, runtime or policy sources,
host projections, symlink or hardlink escapes, unsafe path controls, and nested
`.incoming` or `.archive` staging roots.

Lifecycle:

1. A human explicitly invokes `/process-incoming-intake`.
2. The intake envelope is validated before route classification.
3. Governed Incoming Intake Routing selects exactly one route:
   `single-work-unit-handoff`, `coordinated-program-handoff`,
   `target-owned-direct-handoff`, or `blocked-rejected-deferred`.
4. Handoff routes create advisory target-owned context only; they do not install,
   normalize, activate, publish, or project raw intake.
5. Final disposition removes the `.incoming/<intake-id>/` copy unless the run
   explicitly stops after classification or advisory handoff.

`intake.yml` must include:

- `schema_version: octon-additive-incoming-intake-unit-v1`
- `intake_id` matching the directory name
- `authority_mode: non_authoritative`
- `status`
- `staged_at`
- `submitted_by`
- `reason`
- `next_step`
- `route_hint`
- `payload.root: payload/`
- `payload.form`
- provenance fields for known or missing source facts
- risk fields for executable, binary, secret/private-data, redistribution, and
  size posture

Missing or unverified provenance, binaries, executables, secrets/private data,
redistribution risk, oversized payloads, candidate extension packs, and
candidate core skills are classification findings. They do not make the intake
unit authoritative and do not by themselves normalize, install, activate,
publish, archive, migrate, or retain evidence.

Legacy `.incoming/<intake-id>/` directories that still contain
`intake-status.yml` are not current-envelope intake. They remain
non-authoritative raw material until migrated to `intake.yml` plus `payload/` or
disposed with human governance approval.

Authority status: non-authoritative raw input only.

Validator coverage:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
