# Current-State Gap Map

## Authoritative current-state baseline

The live repository already provides several architectural patterns that this
proposal should reuse rather than replace:

- `/.octon/instance/bootstrap/START.md` defines the bootstrap and profile
  model and keeps `bootstrap_core` repo-local.
- `/.octon/framework/engine/governance/extensions/**` already separates
  desired state, actual state, quarantine, and generated publication.
- framework commands such as `/init` already live under
  `framework/capabilities/runtime/commands/**`.
- repo-native commands such as `repo-hygiene` already live under
  `instance/capabilities/runtime/commands/**`.

## Live repo reality relevant to this proposal

### Existing bootstrap posture

- `/init` is explicitly repo bootstrap only.
- bootstrap docs already distinguish repo-local authored surfaces from runtime
  or generated surfaces.

### Existing desired versus actual pattern

- extension packs use one desired/actual/quarantine/publication model:
  desired state in `instance/extensions.yml`, actual and quarantine state in
  `state/control/extensions/**`, and generated effective outputs under
  `generated/effective/extensions/**`.

### Existing command posture

- shared framework commands exist for cross-repo capabilities.
- repo-native commands exist for repo-specific consumers.
- there is no shared host-tool provisioning command.

### Existing motivating consumer

- `repo-hygiene` now declares external tool expectations such as
  `shellcheck`, `cargo-machete`, and `cargo +nightly udeps`.
- no durable host-tool provisioning architecture exists yet, so local
  execution pressure naturally falls toward PATH assumptions or temporary
  installs.

## Observed gaps

### Gap 1 — no host-tool contract family exists

There is no framework registry that defines what a host tool is, how it is
installed, how versions are resolved, or how cross-platform verification
should work.

### Gap 2 — no repo-local desired requirement surface exists

Repos can document tool expectations informally, but there is no canonical
repo-owned desired requirements surface for external host tools.

### Gap 3 — no host-scoped actual/quarantine/evidence model exists

Octon has a repo-local desired/actual pattern for extensions, but no host-wide
equivalent for installed external binaries.

### Gap 4 — no multi-repo shared-cache architecture exists

There is no live contract for how one system should share provisioned tools
across multiple Octon-enabled repositories while preserving per-repo desired
requirements.

### Gap 5 — `/init` has no explicit host-tool boundary contract

The current bootstrap story is repo-local, but there is no explicit durable
architecture that says host-tool provisioning is separate, intentional, and
not an implicit side effect of repo bootstrap.

### Gap 6 — consumers cannot resolve tools architecturally

A repo command can require tools, but it cannot yet resolve them through a
governed Octon subsystem. That leaves PATH-only assumptions and temp installs
as the practical fallback.

### Gap 7 — no validator exists for this subsystem

There is no structural validator that ensures repo requirements, host-tool
contracts, provisioning commands, and consumer bindings remain coherent.

## Constraints that must be preserved

1. Durable repo authority remains in `framework/**` and `instance/**`.
2. Host-scoped binaries do not become repo content.
3. Multiple repos on one system must not duplicate installs unnecessarily.
4. Commands must fail closed on missing mandatory tools.
5. Proposal paths must not become live dependencies.
6. Bootstrap remains explicit about repo-local versus host-scoped mutation.

## Current-state summary

Octon already has the right repo-local patterns for desired-versus-actual
state, bootstrap, and command lanes. What is missing is a host-scoped external
tool provisioning subsystem that applies those same architectural disciplines
to machine-local dependencies.
