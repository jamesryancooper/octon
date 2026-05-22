# Acceptance Criteria

## Contract

- Incoming additive units have a required `intake.yml` envelope and required
  `payload/` raw payload root.
- The envelope is explicitly non-authoritative and cannot be interpreted as
  runtime, policy, generated, retained evidence, state/control, publication, or
  host-projection authority.
- The payload root is free-form below `payload/` and route-neutral before
  classification.
- Candidate extension packs or core skills inside `payload/` are treated as raw
  candidates only.

## Metadata

- `intake.yml` requires schema version, intake id, authority mode, status,
  staged time, submitter, reason, next step, route hint, payload root and form,
  provenance fields, and risk fields.
- `intake_id` must match the directory name.
- `authority_mode` must be `non_authoritative`.
- Missing or unverifiable provenance is represented in metadata and surfaced as
  a classification finding.

## Validation

- The incoming intake validator fails closed on malformed bundles, missing
  envelope, missing payload root, mismatched id, unsafe names, path escapes,
  symlinks, nested staging roots, and top-level payload leakage.
- The validator does not normalize, install, activate, publish, archive, or
  retain evidence.
- The input non-authority validator continues to prevent `.incoming/**` and
  `.archive/**` from being referenced as authority.
- Extension-pack validators continue to ignore `.incoming/**` as installed
  extension source.

## Workflow

- Intake validation, route classification, disposition, normalization,
  activation, publication, and archive retention are separate lifecycle steps.
- Classification, not intake shape validation, handles missing provenance,
  route ambiguity, secrets, proprietary material, opaque binaries, oversized
  payloads, and candidate pack fit.
- Blocked/proposal-required classification findings are represented without
  mutating the raw intake unit into authority.

## Migration

- Existing `.incoming` and `.archive` units are not rewritten by accepting the
  proposal.
- A later migration must inventory existing units, preserve non-authority, and
  require human governance approval before moving, archiving, or rewriting raw
  material.

## Negative Controls

- A normalized extension-pack manifest under `payload/` does not pass as an
  installed extension.
- A core skill candidate under `payload/` does not pass as an installed skill.
- A generated projection under `payload/` does not pass as generated authority.
- A retained-evidence-looking payload under `payload/` does not pass as retained
  evidence.
- A host-projection-looking payload under `payload/` does not pass as a host
  projection source.
