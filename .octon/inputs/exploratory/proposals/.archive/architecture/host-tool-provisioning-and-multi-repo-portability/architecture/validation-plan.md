# Validation Plan

## Validation model

Validation has three layers:

1. proposal-packet validation;
2. structural host-tool governance validation inside the repo;
3. runtime provisioning and multi-repo behavior validation outside the repo.

## Validation families

### Family A — packet conformance

Validate:

- `proposal.yml`
- `architecture-proposal.yml`
- required navigation files
- required architecture working docs
- inventory and checksums

### Family B — structural governance validation

Validate after implementation:

- host-tool registry exists and parses;
- repo requirements surface exists and parses;
- provisioning command is registered;
- repo-hygiene binds to host-tool requirements rather than PATH-only assumptions;
- bootstrap docs describe the correct boundary.

### Family C — host runtime validation

Validate on supported hosts:

- path selection for `OCTON_HOME` and OS defaults;
- side-by-side installs for distinct versions;
- reuse across multiple repos on one machine;
- quarantine behavior on failed installs;
- adoption of already-satisfied PATH tools when policy allows.

### Family D — export and authority boundary validation

Validate that:

- host-scoped binaries do not enter `bootstrap_core` or `repo_snapshot`;
- repo-local generated views remain non-authoritative;
- repo commands fail closed when mandatory tools are unresolved.

## Required evidence

- proposal validation receipts;
- host-tool provisioning receipts under `$OCTON_HOME/state/evidence/provisioning/host-tools/**`;
- repo run evidence that records resolved tool ids, versions, and paths under
  `/.octon/state/evidence/runs/**`;
- multi-repo integration test outputs showing shared cache reuse.
