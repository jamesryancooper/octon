# Implementation Plan

## Program overview

The implementation program should land the host-tool subsystem without
collapsing repo bootstrap and host mutation into one blurry flow.

Governing principle:

> **Keep desired requirements repo-local, actual installs host-local, and
> command resolution fail-closed.**

## Workstreams

### Workstream A — Framework contract family

Deliverables:

- host-tool registry
- tool-specific contracts
- provisioning command registration and doc

Exit criteria:

- one shared framework family exists for host tools;
- tool ids and installer kinds are canonicalized.

### Workstream B — Repo requirement and policy surfaces

Deliverables:

- repo requirement manifest
- host-tool resolution policy
- first consumer alignment for `repo-hygiene`

Exit criteria:

- repo desired requirements are explicit;
- repo-hygiene stops describing ad hoc temp installs as the practical model.

### Workstream C — Host provisioning runtime

Deliverables:

- provisioning script
- host-home path selection logic
- actual/quarantine/evidence model outside repo

Exit criteria:

- tools install or verify into one shared host cache;
- multiple repos can reuse the same host cache without sharing desired state.

### Workstream D — Validation and bootstrap integration

Deliverables:

- host-tool governance validator
- bootstrap and catalog doc updates
- integration tests for multiple repos on one host

Exit criteria:

- structural drift is catchable;
- bootstrap boundaries are explicit and documented.

## Ordered phases

### Phase 0 — Proposal review

Accept the separation between repo-local desired state and host-local actual
state before implementation starts.

### Phase 1 — Contract landing

Land the framework registry, tool contracts, repo requirements surface, and
resolution policy.

### Phase 2 — Provisioning command

Land `provision-host-tools` and the host-home resolver plus receipts.

### Phase 3 — Consumer integration

Rebind `repo-hygiene` to the new requirement and resolution model.

### Phase 4 — Validation and documentation

Land the validator, bootstrap docs, and multi-repo integration tests.

## Dependencies

- no hidden bootstrap mutation lane;
- no repo-local vendoring of host binaries;
- no proposal-path runtime dependencies;
- no support-target widening required by default.
