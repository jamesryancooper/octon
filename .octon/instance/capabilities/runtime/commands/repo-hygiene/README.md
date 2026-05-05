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
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --confirm
```

The helper removes nothing unless `--confirm` is provided. It protects tracked
files and untracked files referenced by tracked locks, receipts, governance, or
workflow surfaces. Unknown `.octon/state/**` artifacts, build-to-delete
evidence, referenced evidence, and active control state route to retention or
manual review rather than cleanup.

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
