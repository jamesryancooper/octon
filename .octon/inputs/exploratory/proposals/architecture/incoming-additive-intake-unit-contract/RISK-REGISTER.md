# Risk Register

## Raw Intake Mistaken For Authority

Risk: A more formal shape may make `.incoming/**` look normalized or trusted.

Mitigation: Every document, schema, and validator must state that `intake.yml`
is non-authoritative bookkeeping and that `payload/` is raw material only.
Non-authority dependency scans must remain strict.

## Overfitting To Current Examples

Risk: The contract could match the current staged unit rather than the lifecycle
boundary.

Mitigation: Require only identity, non-authority, payload root, provenance
status, risk declarations, and next-step metadata. Do not require route-specific
extension-pack or skill fields.

## Malformed Bundles

Risk: Bad YAML, mismatched ids, empty payloads, or top-level sprawl could make
classification non-deterministic.

Mitigation: Treat these as hard intake validation failures.

## Missing Provenance

Risk: Requiring provenance proof at intake would block raw capture; ignoring it
would hide trust gaps.

Mitigation: Require provenance status fields. Treat missing or unverified
provenance as a blocked or proposal-required classification finding.

## Nested Staging Roots

Risk: Payloads can contain nested `.incoming` or `.archive` roots, creating
confusing lifecycle claims.

Mitigation: Reject nested staging roots during intake validation.

## Symlink And Path Escapes

Risk: Symlinks, hardlinks, dot segments, or encoded path controls can escape the
intake boundary.

Mitigation: Resolve paths during validation and fail any escape or unsafe name.

## Opaque Binaries

Risk: Binary payloads can hide executable, proprietary, or unsafe material.

Mitigation: Allow only as declared raw payload. Classification must block or
require proposal-backed review before normalization.

## Oversized Payloads

Risk: Very large payloads can make validator and classification behavior
expensive or incomplete.

Mitigation: Declare `size_class`; validators should enforce bounded inventory
behavior and route oversized payloads to blocked classification findings.

## Secrets And Proprietary Material

Risk: Raw intake may contain credentials, private data, or restricted source.

Mitigation: Intake metadata must declare known risk. Classification must block
promotion and require human governance for handling, redaction, archive
retention, or deletion.

## Candidate Packs Inside Payload

Risk: A payload may contain a valid-looking extension pack or core skill that
operators treat as installed.

Mitigation: Keep `payload/` route-neutral and require normalization outside
`.incoming/**` before installation or activation.

## Archive Migration

Risk: Updating `.archive/**` to match the new shape could rewrite retained raw
history without approval.

Mitigation: Require separate human governance approval and retained receipts for
any archive migration.
