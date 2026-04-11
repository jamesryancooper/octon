# Repo Evidence 03 — Runtime Command, Support, and Workflow Excerpts

## Repo-native command lane

**Source:** `/.octon/instance/capabilities/runtime/commands/README.md`

- `/.octon/instance/capabilities/runtime/commands/` is reserved for
  repo-specific command capabilities that should remain instance-owned rather
  than becoming reusable additive packs.

**Source:** `/.octon/instance/capabilities/runtime/commands/manifest.yml`

- schema version: `octon-instance-command-manifest-v1`
- current content: `commands: []`

## Support universe and bounded admissions

**Source:** `/.octon/instance/governance/support-targets.yml`

- default route: `deny`
- support claim mode: `bounded-admitted-live-universe`
- admitted capability packs include:
  - `repo`
  - `git`
  - `shell`
  - `telemetry`
  - `browser`
  - `api`
- admitted workload classes include:
  - `observe-and-read`
  - `repo-consequential`
  - `boundary-sensitive`
- support-target review is the admission review contract for changes to this
  universe

## Existing architecture and closure workflow posture

**Source:** `/.github/workflows/architecture-conformance.yml`

- the workflow already watches `.octon/instance/governance/policies/**`,
  `.octon/instance/governance/contracts/**`,
  `.octon/instance/governance/retirement-register.yml`,
  `.octon/instance/governance/support-targets.yml`, and multiple framework
 /runtime/state surfaces
- it already contains a `build-to-delete-governance` job that runs
  `validate-phase7-build-to-delete-institutionalization.sh`

**Source:** `/.github/workflows/closure-certification.yml`

- closure certification already runs two passes
- both passes already validate review-packet freshness, retirement-register
  depth, support-target live claims, projection-shell boundaries, and the
  unified execution closure assertion

## Implication for this packet

The repo already has the right command lane, support-bounded admissions, and CI
families. What is missing is a hygiene-specific policy, command, validator, and
workflow integration — not a new support universe or a new runtime lane.
