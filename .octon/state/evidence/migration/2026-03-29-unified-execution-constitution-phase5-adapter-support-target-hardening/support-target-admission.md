# Phase 5 Support-Target Admission

The published support-target matrix remains `/.octon/instance/governance/support-targets.yml`.

## Supported tuples

- `MT-A / WT-1 / LT-REF / LOC-EN`
  Route: `allow`
  Status: `supported`
  Mission required: `false`
  Allowed packs: `repo`, `shell`, `telemetry`
- `MT-B / WT-2 / LT-REF / LOC-EN`
  Route: `allow`
  Status: `supported`
  Mission required: `false`
  Allowed packs: `repo`, `git`, `shell`, `telemetry`

## Reduced or staged tuples

- `MT-B / WT-3 / LT-REF / LOC-EN`
  Route: `stage_only`
  Status: `reduced`
  Mission required: `true`
  Allowed packs: `repo`, `git`, `shell`, `telemetry`
- `MT-B / WT-2 / LT-EXT / LOC-EN`
  Route: `stage_only`
  Status: `reduced`
  Mission required: `false`
  Allowed packs: `repo`, `git`, `shell`, `telemetry`
- `MT-B / WT-2 / LT-REF / LOC-MX`
  Route: `stage_only`
  Status: `reduced`
  Mission required: `false`
  Allowed packs: `repo`, `git`, `shell`, `telemetry`
- `MT-C / WT-2 / LT-REF / LOC-EN`
  Route: `stage_only`
  Status: `experimental`
  Mission required: `false`
  Allowed packs: `repo`, `shell`, `telemetry`

## Unsupported tuples

- `MT-B / WT-4 / LT-REF / LOC-EN`
  Route: `deny`
  Status: `unsupported`
  Mission required: `true`
  Allowed packs: none

## Governed but unadmitted packs

- `browser`
  Admission: `unadmitted`
  Runtime route: `deny`
- `api`
  Admission: `unadmitted`
  Runtime route: `deny`
