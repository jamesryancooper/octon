# Implementation Plan

## Workstream 1 — Contract formalization

1. Add connector operation schema.
2. Add connector admission schema.
3. Add connector trust dossier schema.
4. Add connector execution receipt schema.
5. Add connector admission operating standard.

## Workstream 2 — Governance placement

1. Create repo-specific connector registry pattern under `instance/governance/connectors/**`.
2. Create connector admission pattern under `instance/governance/connector-admissions/**`.
3. Add support-targets reference fields for connector admissions and connector proof roots.
4. Ensure no support-target tuple is widened by generated projections.

## Workstream 3 — Control/evidence roots

1. Define connector status control roots under `state/control/connectors/**`.
2. Define retained connector evidence roots under `state/evidence/connectors/**`.
3. Define validation evidence roots under `state/evidence/connectors/<connector-id>/validation/**`.
4. Define receipt linkage to run evidence for any future material connector attempt.

## Workstream 4 — Runtime/CLI

1. Add `octon connector inspect`.
2. Add `octon connector list`, `octon connector status`, and `octon connector validate`.
3. Add `octon connector admit --stage-only`.
4. Add `octon connector admit --read-only`; unsupported read-only operations require a Decision Request instead of changing admission.
5. Add `octon connector quarantine`.
6. Add `octon connector retire`.
7. Add `octon connector evidence`.
8. Ensure no command can execute a connector operation directly.
9. Route material connector invocation only through run contract + context pack + authorization + verified effect.

## Workstream 5 — Validators

1. Validate connector registry presence and shape.
2. Validate operations map to existing capability packs.
3. Validate operations map to material-effect classes.
4. Validate admission mode is compatible with support-target posture.
5. Validate trust dossier exists for read-only/live-effectful modes.
6. Validate evidence roots for admission.
7. Validate generated connector projections are not consumed as authority.
8. Validate stage-only/non-live connectors fail closed when invoked materially.

## Workstream 6 — Documentation

1. Update runtime docs with connector admission model.
2. Update governance docs with connector dossier model.
3. Update support-target docs to explain connector proof hooks.
4. Add operator guide for inspection/admission/quarantine/retirement.
5. Update deferred-scope ledger to exclude broad MCP/browser/API autonomy.

## Workstream 7 — Cutover

1. Land contracts and validators.
2. Land sample stage-only connector fixture.
3. Land CLI inspect/admit/quarantine support.
4. Run validation suite twice.
5. Promote docs and evidence.
6. Keep all connectors stage-only/read-only until proof-backed admission exists.
