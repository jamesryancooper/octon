# Target Architecture

## Decision

Define a minimal validator-backed intake-unit contract for
`.octon/inputs/additive/.incoming/<intake-id>/`.

The contract is intentionally partial. It establishes an intake envelope and raw
payload boundary, but it does not require or imply the shape of a normalized
extension pack, core Octon skill, runtime command, publication projection,
retained evidence bundle, state/control surface, or host projection.

## First Principles

Raw additive intake has a different job from every later lifecycle step. Its
job is capture and bounded observation before trust is granted. Therefore the
incoming unit must answer only the questions required to make capture
deterministic and fail-closed:

- Which unit is this?
- Is this unit explicitly non-authoritative?
- Where is the raw payload?
- Why was it staged?
- What provenance is known or missing?
- What obvious risk classes are visible?
- What lifecycle step is allowed next?

Every fact that decides installability, route fit, normalization, activation,
publication, archive retention, or durable evidence belongs to a later governed
step.

## Required Layout

```text
.octon/inputs/additive/.incoming/<intake-id>/
  intake.yml
  payload/
  README.md
```

Required:

- `intake.yml`: non-authoritative intake envelope.
- `payload/`: the only allowed raw payload root.

Optional:

- `README.md`: human note about the staged source. It is never authority.

No other top-level files are allowed except future envelope-adjacent files
explicitly admitted by the schema. The first version should avoid extra
top-level files so validators can fail closed when raw payload accidentally
spills outside `payload/`.

## Intake Envelope

`intake.yml` replaces the current marker-only `intake-status.yml` model.

Required fields:

```yaml
schema_version: "octon-additive-incoming-intake-unit-v1"
intake_id: "<intake-id>"
authority_mode: "non_authoritative"
status: "unclassified"
staged_at: "2026-05-22T00:00:00Z"
submitted_by:
  type: "human|agent-assisted|unknown"
  name: "<operator or agent label>"
reason: "<why the unit was staged>"
next_step: "<allowed governed next step>"
route_hint: "unknown"
payload:
  root: "payload/"
  form: "directory|archive-expanded|archive-unexpanded|mixed|unknown"
provenance:
  status: "declared|partial|missing|unverified"
  origin_class: "first_party_bundled|first_party_external|third_party|unknown"
  imported_from: "<local path, external system, or unknown>"
  origin_uri: "<uri or null>"
  source_digest_sha256: "<64 hex chars or null>"
  attestation_refs: []
risk:
  contains_executable: "yes|no|unknown"
  contains_binary: "yes|no|unknown"
  contains_secret_or_private_data: "yes|no|unknown"
  redistribution_risk: "yes|no|unknown"
  size_class: "small|medium|large|oversized|unknown"
```

Allowed `status` values:

- `unclassified`
- `classified-pending-normalization`
- `rejected-pending-archive`
- `blocked`
- `intentionally-retained-temporarily`

Allowed `route_hint` values:

- `unknown`
- `additive-extension-pack`
- `core-octon-skill`
- `blocked-proposal-required`

`route_hint` is advisory. It must not bypass classification.

## Naming Rules

`<intake-id>` must:

- match `^[a-z][a-z0-9-]*$`;
- match `intake.yml:intake_id`;
- contain no path separators, dot segments, whitespace, shell metacharacters,
  percent-encoded path controls, or Unicode confusables;
- not resolve through a symlink;
- not be named `.incoming`, `.archive`, `payload`, `generated`, `state`,
  `runtime`, `extensions`, or another reserved Octon surface name.

## Payload Layout

All raw material must live under `payload/`.

Allowed payload contents:

- expanded directories;
- unexpanded source archives;
- notes, manifests, and source files from the imported material;
- candidate extension-pack or skill directories treated as opaque raw material;
- binaries or executables only when declared in `risk`.

Disallowed payload effects:

- symlinks or hardlinks that resolve outside the intake unit;
- nested `.octon/inputs/additive/.incoming/` or `.archive/` staging roots;
- material staged directly under runtime, policy, generated, state/control,
  publication, retained-evidence, or host-projection paths;
- generated files or projection outputs that claim authority because they were
  included in raw payload.

## Provenance And Trust

The envelope must make provenance visible, but the intake validator must not
pretend missing provenance is a shape error when the payload is otherwise
bounded. Missing or unverifiable provenance should be a classification finding
that blocks promotion or requires a proposal-backed disposition.

Hard shape validation asks whether provenance fields exist and parse.
Classification asks whether the provenance is sufficient for the route.

## Hard Validator Failures

The incoming intake validator should fail when:

- the intake path or id is invalid;
- `intake.yml` is missing, malformed, or mismatched with the directory name;
- `authority_mode` is absent or not `non_authoritative`;
- required envelope fields are missing;
- enum values or digest formats are invalid;
- `payload/` is missing or empty of meaningful files;
- raw payload appears outside the allowed top-level layout;
- symlink, hardlink, or resolved path traversal escapes the intake unit;
- nested `.incoming` or `.archive` staging roots appear inside the payload;
- the unit is staged under runtime, policy, generated, state/control,
  publication, retained-evidence, or host-projection surfaces;
- file names contain path separators, dot segments, shell-sensitive names, or
  other unsafe path controls.

## Classification Findings

The classification workflow should block, require a proposal, or require human
disposition, rather than failing the envelope shape, when:

- provenance is missing, partial, declared-only, or unverifiable;
- the payload contains opaque binaries, executables, secrets, private data, or
  proprietary material;
- the payload is oversized or expensive to inspect;
- a candidate extension pack or core skill shape appears inside `payload/`;
- route classification is ambiguous;
- installer instructions attempt to bypass governed normalization;
- the payload schema is unsupported or obsolete;
- no existing Octon contract can safely receive the material.

## Lifecycle Boundaries

Intake validation:

- validates envelope shape, path safety, payload containment, and non-authority
  markers;
- emits inventory and failures only;
- does not classify, normalize, install, activate, publish, archive, or retain
  evidence.

Route classification:

- reads bounded intake metadata and raw payload inventory;
- chooses `additive-extension-pack`, `core-octon-skill`,
  `blocked-proposal-required`, rejection, or temporary retention;
- records provenance and risk findings.

Disposition:

- executes the approved route or rejection outcome;
- may require human approval for archive movement, migration, or proprietary
  material handling.

Normalization:

- creates durable extension-pack or core-skill artifacts outside `.incoming/**`.

Activation:

- uses canonical activation surfaces such as instance extension configuration.

Publication:

- uses generated/effective projection surfaces only after durable authority
  admits the source.

Archive retention:

- preserves raw intake only through explicit archive disposition and retained
  evidence requirements. `.archive/**` remains non-authoritative raw input.

## Minimality Test

The contract is minimal because it does not ask incoming units to prove route
correctness. It only requires enough metadata to make intake deterministic,
auditable, and safely rejectable.
