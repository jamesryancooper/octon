# Current State Gap Map

## Current State

Incoming additive material is staged under
`.octon/inputs/additive/.incoming/<intake-id>/`.

The current validator primarily enforces path boundary, intake id, symlink, and
basic inventory checks. The input non-authority validator recognizes a
marker-style `intake-status.yml` for long-lived incoming units. The docs already
say `.incoming/**` is raw, non-authoritative, and must not be installed or
activated by path.

## Gap

The current marker model does not create a single deterministic place for:

- payload root declaration;
- provenance status;
- risk declarations;
- submitted-by and staged-at metadata;
- route hint as advisory data;
- clear split between hard intake failures and classification findings.

As a result, raw payload can be bounded by path while still being ambiguous to
workflow operators and validators.

## Proposed Change

Move from marker-only status to a minimal intake envelope:

- `intake-status.yml` becomes `intake.yml` in the proposed contract;
- raw payload moves under required `payload/`;
- top-level sprawl is rejected except for admitted non-authoritative notes;
- provenance and risk become explicit intake facts;
- missing trust is a blocked classification finding rather than a shape failure.

## Kept As Is

- `.incoming/**` remains non-authoritative.
- `.archive/**` remains non-authoritative.
- Extension-pack validators continue to ignore `.incoming/**`.
- Raw intake cannot be a runtime, policy, generated, retained evidence,
  state/control, publication, or host-projection dependency.
- Classification and disposition remain governed workflow steps.
