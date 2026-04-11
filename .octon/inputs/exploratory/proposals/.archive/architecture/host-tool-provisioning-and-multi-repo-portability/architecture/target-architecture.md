# Target Architecture

## Decision

Adopt one **Host-Tool Provisioning** subsystem that separates:

1. framework-owned host-tool contracts;
2. repo-owned desired requirements;
3. host-scoped actual installs and provisioning evidence; and
4. consumer command resolution and fail-closed behavior.

The subsystem is specifically designed so Octon can be dropped into multiple
repositories on one host without duplicating binaries per repo and without
committing host-specific artifacts into `/.octon/**`.

## Target-state operating model

### 1. Framework host-tool contract family

Octon gains a new framework surface:

- `/.octon/framework/capabilities/runtime/host-tools/README.md`
- `/.octon/framework/capabilities/runtime/host-tools/registry.yml`
- `/.octon/framework/capabilities/runtime/host-tools/contracts/<tool-id>.yml`

Each tool contract defines:

- tool id and display name;
- supported platforms and architectures;
- version selection and side-by-side install rules;
- installer kinds such as `cargo`, `archive-download`, `system-adopt`;
- verification commands and expected version parsing;
- PATH entrypoint semantics;
- whether the tool is mandatory or optional for a consumer profile.

### 2. Repo-owned desired requirements

Each repository declares desired host-tool requirements in:

- `/.octon/instance/capabilities/runtime/host-tools/requirements.yml`

This repo-local surface declares which commands, workflows, or validators need
which host tools and with what version floor or exactness.

Repo-owned requirements are authoritative for desired state, but they do not
store binaries and do not directly mint actual host installs.

### 3. Host-scoped Octon home

Actual installed binaries and provisioning receipts live outside the
repository in one user-scoped Octon home.

Canonical resolution order:

1. explicit `OCTON_HOME`
2. OS-default user-scoped Octon home:
   - macOS: `~/Library/Application Support/Octon`
   - Linux: `${XDG_DATA_HOME:-~/.local/share}/octon`
   - Windows: `%LocalAppData%\\Octon`

Target layout:

```text
$OCTON_HOME/
├── manifest.yml
├── tools/
│   └── <tool-id>/<version>/<platform>/**
├── state/
│   ├── control/host-tools/{active,quarantine}.yml
│   └── evidence/provisioning/host-tools/<provision-id>/**
└── generated/effective/host-tools/repos/<repo-fingerprint>.yml
```

This host-scoped tree is operational truth and retained evidence, not repo
authority. Multiple repos on the same system share the installed tool cache,
while retaining separate repo-owned desired requirements.

### 4. Provisioning command

Octon adds one shared framework command:

- `/.octon/framework/capabilities/runtime/commands/provision-host-tools.md`
- implementation script:
  `/.octon/framework/scaffolding/runtime/_ops/scripts/provision-host-tools.sh`

Command responsibilities:

- verify or install required tools into `$OCTON_HOME/tools/**`;
- record provisioning receipts and quarantine failures;
- support modes such as `verify`, `install`, and `repair`;
- resolve per-repo requirements using the current repo root;
- optionally adopt an already-installed PATH tool when it satisfies contract
  requirements and provenance policy.

### 5. Consumer resolution

Repo-local commands such as `repo-hygiene` stop assuming PATH-only or ad hoc
temp installs. Instead they:

- declare their host-tool requirements through the new requirement surface;
- resolve actual tool paths through the host-tool resolver;
- emit repo-local run evidence describing which resolved tool versions were
  used; and
- fail closed when a mandatory requirement is unresolved.

### 6. `/init` boundary

`/init` remains repo bootstrap only.

It may:

- generate or refresh repo-local desired requirement surfaces;
- report missing host-tool prerequisites after bootstrap.

It must not:

- silently install external host tools;
- mutate shared host caches without explicit operator intent.

### 7. CI and ephemeral hosts

The same contract applies in CI and ephemeral environments, but the host home
may be job-local. That is an execution detail, not a different architecture.

CI may point `OCTON_HOME` at a workspace-local or temp path, but repo-local
durable authority still remains under `/.octon/**`.

## Target invariants

1. No third-party binaries are committed under `/.octon/**`.
2. Multiple repos on one host may share one host-scoped tool cache.
3. Different repos may pin different tool versions without clobbering one
   another.
4. Repo commands fail closed on missing mandatory tools.
5. `/init` does not become a hidden host mutation lane.
6. Host-scoped actual state stays outside repo authority and export profiles.
7. Temporary `/tmp` installs remain emergency or CI tactics only, never the
   canonical host-tool model.
