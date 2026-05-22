# Implementation Plan

This plan is for a later promoted implementation. It does not process any
incoming intake unit.

## Phase 1: Document The Contract

Update:

- `.octon/framework/cognition/_meta/architecture/inputs/README.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/README.md`
- `.octon/inputs/README.md`
- `.octon/inputs/additive/README.md`
- `.octon/inputs/additive/.incoming/README.md`

Required content:

- define `intake.yml` plus `payload/` as the incoming unit shape;
- state that the envelope is non-authoritative bookkeeping;
- forbid raw payload outside `payload/`;
- separate hard validator failures from classification findings;
- preserve `.incoming/**` and `.archive/**` non-authority language.

## Phase 2: Add Schema

Add a schema under the additive input architecture surface, for example:

- `.octon/framework/cognition/_meta/architecture/inputs/additive/schemas/incoming-intake-unit.schema.json`

The schema should cover required envelope fields, enums, id matching, digest
format, payload root value, and risk/provenance declarations.

## Phase 3: Tighten Validators

Update:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh`
- extension-pack validator regression tests that prove `.incoming/**` is not
  scanned as installed extension authority.

Validator behavior:

- fail on missing or malformed `intake.yml`;
- fail on missing or empty `payload/`;
- fail on unsafe paths, escapes, nested staging roots, and top-level payload
  leakage;
- pass bounded units with missing provenance while emitting classification
  findings through workflow, not shape validation;
- keep non-authority dependency scans strict for `.incoming/**` and `.archive/**`.

## Phase 4: Update Workflow And Command Contracts

Update:

- `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
- `.octon/framework/capabilities/runtime/commands/process-incoming-intake.md`
- `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/workflow.yml`
- stage docs under `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/stages/`

The workflow should require envelope validation before classification and make
classification findings explicit for missing provenance, opaque binaries,
secrets, proprietary material, oversized payloads, candidate packs, and route
ambiguity.

## Phase 5: Migration Guidance

Document, but do not execute in this proposal, a migration path:

- inventory existing `.incoming` and `.archive` units;
- for each unit, create `intake.yml` from existing marker metadata where safe;
- move raw top-level payload into `payload/`;
- retain pre-migration receipts outside raw intake;
- require human approval for any archive rewrite or proprietary material
  handling.

Existing units without a compliant envelope should be treated as legacy raw
intake until migrated or disposed. They should not become authority by failing
the new shape.

## Phase 6: Validation Receipts

Before implementation closeout, retain receipts for:

- valid minimal intake unit;
- missing envelope;
- malformed YAML;
- mismatched id;
- missing payload;
- empty payload;
- top-level raw payload leakage;
- symlink and hardlink path escape;
- nested `.incoming` and `.archive` roots;
- candidate extension pack under `payload/`;
- missing provenance classification block;
- opaque binary declaration;
- oversized payload finding;
- secret/proprietary material finding;
- raw intake dependency scan.

## Rollback

Rollback is bounded to the durable contract edits. Revert the schema,
validator, workflow, and documentation changes and restore the previous
path-only plus marker validation behavior. Do not move or delete intake units as
part of rollback without separate governance approval.
