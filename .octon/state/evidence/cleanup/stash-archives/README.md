# Local Stash Archives

`state/evidence/cleanup/stash-archives/**` stores local cleanup evidence for
Git stash entries that were inspected during repository hygiene work and then
dropped from the stash stack.

This root is ignored by Git by default. Stash archives can contain arbitrary
local patches, generated residue, control snapshots, retained evidence, or
operator-specific context. They are retained for local recoverability and
review, not as repository-wide source, authority, active control state, or
validation proof.

## When To Archive Before Dropping

Archive a stash before dropping it when the stash contains local-only evidence,
control snapshots, generated-output residue, closeout residue, or mixed
authored/evidence content whose future review value is plausible but whose
restoration into the worktree would be unsafe or misleading.

Dropping without archiving is acceptable when the stash is proven duplicate,
obsolete, superseded by tracked commits, rebuildable generated output, build
cache, or otherwise disposable, and no local evidence-retention need remains.

## Minimum Archive Layout

Each archive directory should use a stable, human-readable name such as:

`<stash-short-sha>-<context-slug>/`

Minimum retained files:

- `metadata.txt`: stash commit identity, dates, and original context.
- `stat.txt`: summary of changed paths and sizes.
- `name-status.txt`: path-level add/modify/delete inventory.
- `stash.patch`: full textual patch when practical.
- `classification-receipt.yml`: local cleanup classification and boundary
  statement.

An opaque archive such as `original-archive.tar.gz` may be retained as a
convenience copy, but it must not be the only evidence when a readable layout
is practical.

## Authority Boundary

Stash archives under this root are local cleanup evidence only. They are not
authority, current control state, validation proof, generated-output freshness
evidence, or receipts authorizing restoration.

Restoration or integration requires intentional review against current
`origin/main`, current contracts, authority boundaries, receipt semantics, and
cleanup-safety rules. Generated, control, evidence, proposal-local, host-state,
or lifecycle-event residue from an archive must never be restored as current
authority.
