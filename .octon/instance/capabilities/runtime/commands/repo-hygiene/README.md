# Repository Hygiene

`repo-hygiene` is the repo-native command for detecting dead or stale surfaces
in the Rust + Shell Octon repository and routing transitional or historical
outcomes into the existing build-to-delete retirement spine.

## Contract

- Command id: `repo-hygiene`
- Policy: `/.octon/instance/governance/policies/repo-hygiene.yml`
- Host-tool requirements:
  `/.octon/instance/capabilities/runtime/host-tools/requirements.yml`
- Host-tool resolution policy:
  `/.octon/instance/governance/policies/host-tool-resolution.yml`
- Provisioning command:
  `/.octon/framework/capabilities/runtime/commands/provision-host-tools.md`
- Evidence root: `/.octon/state/evidence/runs/ci/repo-hygiene/<audit-id>/`
- Closure packet attachment:
  `/.octon/state/evidence/validation/publication/build-to-delete/<packet>/repo-hygiene-findings.yml`
- Destructive posture: detection only; the command never deletes anything

## Invocation

Use the registered command id in host adapters, or invoke the script directly:

```bash
bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh scan
bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh enforce
bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh audit --audit-id 2026-04-11-baseline
bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh packetize --audit-id 2026-04-11-baseline
```

## Modes

- `scan`: read-only discovery. Prints a summary and any findings to stdout.
  This is the fast path; it prioritizes repo metadata, historical/transitional
  reconciliation, and lightweight shell inventory over full Rust compilation.
- `enforce`: read-only gate. Exits nonzero when blocking findings exist or a
  required detector is unavailable.
- `audit`: runs the full detector stack, writes retained evidence under
  `state/evidence/runs/ci/repo-hygiene/<audit-id>/`, and exits nonzero on
  blocking findings or required-detector failures.
- `packetize`: writes `repo-hygiene-findings.yml` into the latest
  build-to-delete review packet derived from
  `/.octon/instance/governance/contracts/closeout-reviews.yml`.

## Local Run Artifact Hygiene

Publication, validation, service-build, closeout, and agent-quorum runs can
leave untracked local `.octon/state/**` files after the durable receipts or
active state have already been retained. Do not broadly ignore or delete those
paths. Classify them with the dry-run-first helper:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --authorize /tmp/repo-hygiene-cleanup-authorization.json
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --authorization /tmp/repo-hygiene-cleanup-authorization.json
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --confirm
```

The helper removes nothing unless either `--confirm` is provided or a validating
`repo-hygiene-cleanup-authorization-v1` receipt is passed with
`--authorization <receipt.json>`. `--authorize <out.json>` emits a non-mutating
receipt over the current cleanup candidate set; the delete path then revalidates
the current git refs, status digest, classification digest, cleanup path set,
protected paths, and manual-review paths before removing only the exact
authorized files.

The receipt route does not bypass filesystem, sandbox, host, provider, or
platform safety controls. Missing, malformed, denied, expired, stale, or
path-mismatched receipts fail closed before deletion. The helper protects
tracked files and untracked files referenced by tracked locks, receipts,
governance, or workflow surfaces. Unknown `.octon/state/**` artifacts,
build-to-delete evidence, referenced evidence, active control state, raw input
surfaces, generated authority, generated run-health projections, and
user-owned or ignored residue route to retention or manual review rather than
generic cleanup.

Generated run-health projection pruning remains generator-owned. Use
`generate-run-health-read-model.sh --all-runs` and retain the generator's
`pruned_paths` evidence instead of deleting
`.octon/generated/cognition/projections/materialized/runs/**` with the local
artifact helper.

## Local Stash Archive Hygiene

When Git stash triage finds local-only evidence or mixed residue that should
not remain on the stash stack but may need later review, archive it under:

`/.octon/state/evidence/cleanup/stash-archives/<stash-short-sha>-<context-slug>/`

Use a readable layout when practical:

- `metadata.txt`
- `stat.txt`
- `name-status.txt`
- `stash.patch`
- `classification-receipt.yml`

The archive root is ignored by Git by default because stash archives may
contain arbitrary local patches, stale generated output, stale control state,
retained evidence, proposal-local residue, or operator-specific context. Track
the convention, not each local stash archive, unless a later governed review
intentionally promotes a specific artifact.

Each classification receipt must say that the archive is local cleanup evidence
only. It is not authority, current control state, validation proof,
generated-output freshness evidence, or a receipt authorizing restoration.
Restoration or integration requires intentional review against current
`origin/main`, current contracts, authority boundaries, receipt semantics, and
cleanup-safety rules.

Drop without archiving only when the stash is proven duplicate, obsolete,
superseded by tracked commits, rebuildable generated output, build cache, or
otherwise disposable, and no local evidence-retention need remains. Generated,
control, evidence, proposal-local, host-state, or lifecycle-event residue from
a stash archive must not be restored as current authority.

## External Evidence Localization

Terminal or explicitly inactive protected operational evidence that must leave
the checkout routes through [External Evidence Localization](./evidence-localization.md).
The route copies and verifies an exact digest-bound archive before it may emit
a separate cleanup authorization. It never treats classification as deletion
authority and never accepts a caller-selected archive root.

## Detector Stack

- `cargo check`
- `cargo clippy` with `dead_code`, `unused_imports`, and `unused_variables`
- `cargo machete`
- `cargo +nightly udeps` in `audit` mode
- `git ls-files`
- `find`
- `rg`
- `shellcheck -x`
- `bash -n`
- `sh -n`

If a detector tool is unavailable, the command records that explicitly and
fails closed in `enforce`, `audit`, and `packetize`.

`cargo check` and `cargo clippy` run against the stable toolchain even when a
temporary nightly is present for `cargo +nightly udeps`.

For `enforce` and `audit`, mandatory host-scoped tools are resolved through the
host-tool provisioning subsystem rather than through ad hoc temp-install
assumptions.

## Decision Grammar

The command may emit only these actions:

- `safe-to-delete`
- `needs-ablation-before-delete`
- `retain-with-rationale`
- `demote-to-historical`
- `register-for-future-retirement`
- `never-delete`

`unused` never implies `safe-to-delete`.
