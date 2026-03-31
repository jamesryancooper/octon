# Bootstrap Authority and Ingress Alignment

## Problem

`/.octon/instance/bootstrap/START.md` still lists `inputs/additive/extensions/**` under "Instance-native repo authority".

That conflicts with the constitutional kernel and the umbrella architecture specification, both of which say:

- only `framework/**` and `instance/**` are authored authority
- raw `inputs/**` are non-authoritative
- raw inputs must never become direct runtime or policy authority

This is the highest-signal remaining orientation-doc authority leak.

## Target rule

Bootstrap and orientation surfaces may describe additive packs, compatibility, provenance, trust activation, and publication flow — but they may **not** describe raw additive inputs as authored authority.

## Required edit

In `/.octon/instance/bootstrap/START.md`:

- remove `inputs/additive/extensions/**` from any list titled or semantically equivalent to:
  - instance-native repo authority
  - authored authority
  - canonical repo authority
- add a separate section for **raw additive inputs**
- bind raw additive inputs to the actual authority/publication chain:

```text
raw pack input:
  /.octon/inputs/additive/extensions/**

desired trust activation:
  /.octon/instance/extensions.yml

actual/quarantine state:
  /.octon/state/control/extensions/{active.yml,quarantine.yml}

compiled runtime-facing outputs:
  /.octon/generated/effective/extensions/**
```

## Allowed explanation after remediation

The document may say all of the following:

- additive packs are repo-local raw inputs
- additive packs carry compatibility and provenance
- additive packs become active only through authored trust and published control/effective roots
- raw packs themselves are not runtime or policy authority

## Not required

This packet does **not** require a structural change to the extension model itself. The issue is orientation-doc semantics, not the extension publication architecture.

## Parity surfaces

The fix must remain consistent with:

- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/README.md`
- `/.octon/instance/ingress/AGENTS.md`

## Validator contract

Add a doc-parity/authority-surface validator that fails if an orientation document under:

- `/.octon/instance/bootstrap/**`
- `/.octon/README.md`
- `/.octon/instance/ingress/**`

contains an authored-authority list that includes any raw `inputs/**` path.

A simple string/fragment check is sufficient initially because the error class is high-signal and low-ambiguity.

## Expected end state

After promotion:

- `START.md` explains additive packs correctly
- no orientation doc widens authored authority into raw inputs
- the constitutional boundary is the same in kernel docs, architecture docs, README docs, and bootstrap docs
