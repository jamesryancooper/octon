# Executable Implementation Prompt

implementation_prompt_id: incoming-additive-intake-unit-contract-implementation-prompt-2026-05-22
proposal_path: .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-22T18:43:40Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, process intake units, or substitute for retained evidence.
`.incoming/**` and `.archive/**` remain non-authoritative raw input surfaces.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: define the intake envelope, docs, schema, validator behavior,
  workflow contract, command contract, and tests as one coherent Octon-internal
  boundary change
- transitional exception: not authorized

## Mandatory Preflight

Before durable edits, re-run the packet gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
```

Refuse implementation if the accepted review digest is stale, the implementation
authorization fails, clarification becomes required, or promotion targets drift.

## In Scope

Durable edits may touch only these approved promotion targets:

- `.octon/framework/cognition/_meta/architecture/inputs/README.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/`
- `.octon/framework/engine/governance/inputs/additive/`
- `.octon/framework/capabilities/runtime/commands/process-incoming-intake.md`
- `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/README.md`
- `.octon/inputs/additive/README.md`
- `.octon/inputs/additive/.incoming/README.md`

Expected durable work:

1. Update input taxonomy and additive intake docs so the required incoming unit
   contract is:

   ```text
   .octon/inputs/additive/.incoming/<intake-id>/
     intake.yml
     payload/
     README.md
   ```

   `intake.yml` and `payload/` are required. `README.md` is optional
   non-authoritative human context. Raw payload must live only under
   `payload/`.

2. Add a schema under
   `.octon/framework/cognition/_meta/architecture/inputs/additive/`, such as
   `.octon/framework/cognition/_meta/architecture/inputs/additive/schemas/incoming-intake-unit.schema.json`.
   The schema must require:

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
   - `provenance.status`
   - `provenance.origin_class`
   - `provenance.imported_from`
   - `provenance.origin_uri`
   - `provenance.source_digest_sha256`
   - `provenance.attestation_refs`
   - `risk.contains_executable`
   - `risk.contains_binary`
   - `risk.contains_secret_or_private_data`
   - `risk.redistribution_risk`
   - `risk.size_class`

3. Tighten `.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh`
   so it fails closed on path/id violations, missing or malformed `intake.yml`,
   mismatched `intake_id`, missing or empty `payload/`, unexpected top-level
   raw payload, invalid enums or digest formats, symlink or hardlink escapes,
   nested `.incoming` or `.archive` staging roots, unsafe path controls, and
   staging under forbidden authority/projection surfaces.

4. Keep missing, partial, declared-only, or unverified provenance out of hard
   shape failure when the envelope parses and the payload is contained. Surface
   those as classification findings that block promotion or require a proposal.
   Do the same for opaque binaries, executables, secrets, proprietary material,
   oversized payloads, candidate extension packs, candidate core skills, and
   ambiguous routes.

5. Update `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`,
   `.octon/framework/capabilities/runtime/commands/process-incoming-intake.md`,
   and `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`
   so intake validation, route classification, disposition, normalization,
   activation, publication, archive retention, and cleanup remain separate
   lifecycle steps.

6. Update `.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
   and related raw-input dependency tests so `.incoming/**` and `.archive/**`
   cannot become runtime, policy, generated, retained evidence, state/control,
   publication, extension-pack, skill, or host-projection authority by
   reference or by containing authority-looking files.

7. Add or update tests in `.octon/framework/assurance/runtime/_ops/tests/`.
   Use temporary fixtures through `OCTON_DIR_OVERRIDE` and `OCTON_ROOT_DIR`;
   do not create, rewrite, migrate, archive, normalize, activate, publish, or
   process real intake units under `.octon/inputs/additive/.incoming/**` or
   `.octon/inputs/additive/.archive/**`.

## Out Of Scope

Do not change `proposal.yml#status`. Do not install, normalize, activate,
publish, archive, migrate, clean up, or otherwise process any intake unit. Do
not rewrite existing `.incoming/**` or `.archive/**` units, including legacy
units that still use `intake-status.yml`. Do not introduce route-specific
incoming requirements that belong to normalized extension packs or core skill
installation. Do not treat payload candidates as installed extensions, installed
skills, generated output, retained evidence, state/control truth, policy,
runtime source, publication source, or host-projection source.

Human governance approval is required before any archive rewrite, existing
intake migration, proprietary-material handling, or source-material deletion.

## Required Evidence And Receipts

Retain implementation evidence under:

```text
.octon/state/evidence/validation/proposals/incoming-additive-intake-unit-contract/<timestamp>/
```

Retain:

- repository reconnaissance for the docs, validator, tests, workflow, command,
  and non-authority surfaces touched;
- schema validation receipt for valid and invalid `intake.yml` examples;
- incoming validator receipts for valid minimal intake, missing envelope,
  malformed YAML, mismatched id, missing payload, empty payload, top-level raw
  payload leakage, symlink escape, hardlink/path escape, nested `.incoming`,
  nested `.archive`, unsafe path controls, and forbidden target resolution;
- classification-finding receipts for missing provenance, opaque binaries,
  executables, secrets/private data, proprietary or redistribution-risk
  material, oversized payloads, candidate extension packs, candidate core
  skills, and ambiguous routes;
- non-authority receipts proving `.incoming/**` and `.archive/**` are ignored
  as runtime, policy, generated, retained evidence, state/control, publication,
  extension-pack, skill, and host-projection authority;
- migration note stating existing `.incoming/**` and `.archive/**` units were
  inventoried only if necessary and were not rewritten without separate human
  governance approval;
- rollback posture for reverting docs, schema, validators, workflow, command,
  and tests to the previous path-only plus marker behavior.

After implementation, update:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md` or `support/validation/<timestamp>.md` if packet
  validation receipts are retained packet-locally

The conformance and drift/churn receipts must be refreshed after the durable
implementation, not reused as pre-implementation evidence.

## Required Validation

Run packet gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
```

Run focused implementation checks:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh
```

Also run any extension-pack, skill, publication, or host-projection regression
tests touched by the implementation to prove `.incoming/**` and `.archive/**`
are not consumed as installed or authoritative sources.

If proposal registry projection is maintained during closeout, refresh or check
it with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
```

## Rollback And Closeout Refusal

Rollback is revert of the durable docs, schema, validator, workflow, command,
and test changes introduced for this packet. Rollback must not move, delete,
archive, normalize, activate, publish, or otherwise process any intake unit
without separate governance approval.

Refuse closeout or archive if:

- `.incoming/**` or `.archive/**` can be consumed as runtime, policy,
  generated, retained evidence, state/control, publication, extension-pack,
  skill, or host-projection authority;
- the validator accepts missing `intake.yml`, missing `payload/`, mismatched
  ids, top-level raw payload leakage, nested staging roots, symlink or hardlink
  escapes, unsafe names, or forbidden target resolution;
- the validator treats missing or unverifiable provenance as a hard shape
  failure instead of a blocked classification finding when the unit is otherwise
  bounded;
- candidate packs or core skills under `payload/` are treated as normalized or
  installed;
- migration, archive rewrite, proprietary-material handling, or deletion occurs
  without human governance approval and retained receipts;
- `support/implementation-conformance-review.md` and
  `support/post-implementation-drift-churn-review.md` are absent, stale, or do
  not pass their validators.
