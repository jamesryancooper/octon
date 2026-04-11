---
title: Host-Tool Provisioning and Multi-Repo Portability Full Implementation Prompt
description: Execution-grade prompt for fully implementing the host-tool provisioning and multi-repo portability architecture proposal against the live Octon repository.
---

You are the principal Octon portability, bootstrap-boundary, and host-runtime
provisioning engineer for this repository.

Your job is to fully implement the architecture proposal at:

`/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/`

Treat this as a real implementation, migration, validation, and consumer
integration program. Do not treat it as a design review, prose rewrite, or
partial planning exercise.

The proposal packet lives under `inputs/**` and is non-authoritative. Use it
as the execution specification, but promote all durable outcomes only into
canonical authored, runtime, bootstrap, and validation surfaces under:

- `/.octon/framework/**`
- `/.octon/instance/**`
- `/.octon/state/**`
- `/.github/workflows/**` only when the promoted architecture requires
  workflow integrations outside `/.octon/**`

## Working doctrine

This is not a repo-local vendoring exercise. It is a portability and boundary
hardening program for host-scoped external tools.

Your governing thesis is:

1. Repo-local `/.octon/**` should declare desired host-tool requirements and
   governance only.
2. Actual installed binaries and toolchains should live outside the repo in a
   host-scoped Octon home.
3. Multiple Octon-enabled repositories on one system must be able to share the
   same host cache without sharing desired state.
4. `/init` must remain repo-bootstrap-only.
5. Repo-native consumers such as `repo-hygiene` must resolve tools through the
   new subsystem and fail closed when mandatory tools are unresolved.

## Required reading order

Read these before planning or implementation:

1. `AGENTS.md`
2. `/.octon/instance/ingress/AGENTS.md`
3. `/.octon/framework/constitution/CHARTER.md`
4. `/.octon/framework/constitution/charter.yml`
5. `/.octon/framework/constitution/obligations/fail-closed.yml`
6. `/.octon/framework/constitution/obligations/evidence.yml`
7. `/.octon/framework/constitution/precedence/normative.yml`
8. `/.octon/framework/constitution/precedence/epistemic.yml`
9. `/.octon/framework/constitution/ownership/roles.yml`
10. `/.octon/framework/constitution/contracts/registry.yml`
11. `/.octon/instance/charter/workspace.md`
12. `/.octon/instance/charter/workspace.yml`
13. `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`
14. `/.octon/instance/bootstrap/START.md`
15. `/.octon/instance/bootstrap/catalog.md`
16. `/.octon/instance/extensions.yml`
17. `/.octon/framework/engine/governance/extensions/README.md`
18. `/.octon/framework/engine/governance/extensions/trust-and-compatibility.md`
19. `/.octon/framework/capabilities/runtime/commands/init.md`
20. `/.octon/framework/capabilities/runtime/README.md`
21. `/.octon/instance/governance/policies/repo-hygiene.yml`
22. `/.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md`
23. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/README.md`
24. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/proposal.yml`
25. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture-proposal.yml`
26. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/navigation/source-of-truth-map.md`
27. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/current-state-gap-map.md`
28. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/target-architecture.md`
29. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/file-change-map.md`
30. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/implementation-plan.md`
31. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/migration-cutover-plan.md`
32. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/validation-plan.md`
33. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/acceptance-criteria.md`
34. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/closure-certification-plan.md`
35. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/architecture/follow-up-gates.md`
36. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/resources/evidence-plan.md`
37. `/.octon/inputs/exploratory/proposals/.archive/architecture/host-tool-provisioning-and-multi-repo-portability/resources/rejection-ledger.md`

Use this precedence while executing:

1. Live repo state and canonical authored/runtime surfaces determine current
   reality.
2. The constitutional kernel, workspace charter pair, bootstrap model, and
   extension activation model define the architectural boundaries that the new
   subsystem must preserve.
3. The host-tool proposal defines the intended target state only where it does
   not conflict with newer live durable authority.
4. Historical prompts and archived proposal packets are informative only.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: this is a new subsystem with no competing canonical
  predecessor, so the correct implementation posture is a clean-break landing
  of the durable repo surfaces with iterative runtime use afterward
- `transitional_exception_note`: not applicable unless a true hard gate forces
  temporary coexistence

Emit a Profile Selection Receipt before implementation.

## Core objective

Fully implement a governed host-tool provisioning subsystem so Octon can be
dropped into any repository on any supported OS and correctly separate:

1. repo-owned desired host-tool requirements;
2. framework-owned tool contracts and provisioning logic;
3. host-scoped actual installs, quarantine state, and provisioning receipts;
4. repo command resolution and run evidence.

Completion means all of the following are true in substance, not just in
documentation:

1. No third-party binaries or toolchains are stored under `/.octon/**`.
2. A framework host-tool contract family exists and is validator-covered.
3. A repo-owned requirements surface exists for desired tool state.
4. A provisioning command exists in the framework command lane.
5. Actual installs resolve into one host-scoped Octon home outside the repo.
6. Multiple Octon-enabled repos on one system can share installed tools while
   retaining independent desired state.
7. `/init` remains repo bootstrap only and does not silently install tools.
8. `repo-hygiene` resolves required tools through the new subsystem rather
   than through temp-install fallbacks.
9. Host-tool provisioning emits retained provisioning receipts and repo runs
   emit resolved-tool evidence.
10. Structural validation, bootstrap docs, and at least one multi-repo
    integration path are in place.

## Repo facts you must preserve

Assume and verify all of the following:

1. `/.octon/instance/extensions.yml` already models repo-owned desired state.
2. `/.octon/framework/engine/governance/extensions/**` already models the
   desired/actual/quarantine/publication pattern.
3. `/init` is documented as repo bootstrap only.
4. `repo-hygiene` is the current motivating consumer for external tools such as
   `shellcheck`, `cargo-machete`, and `cargo +nightly udeps`.
5. `/.octon/framework/capabilities/runtime/commands/**` is the correct lane
   for a shared cross-repo provisioning command.
6. `/.octon/instance/capabilities/runtime/commands/**` is the correct lane for
   repo-native consumers.

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Continue through implementation, validation, and consumer integration until
   the acceptance criteria are either met or blocked by a true hard blocker.
3. Promote durable outcomes into canonical repo surfaces, never back into
   proposal paths.
4. Preserve the repo-vs-host authority boundary. Host actual state may be
   resolved or exercised during validation, but it must not be authored under
   `/.octon/**`.
5. Prefer the extension-governance pattern as the architectural template,
   adapted to a host-scoped actual-state model rather than copied literally.
6. After any turn that changes files, ask exactly:
   `Are you ready to closeout this branch?`
7. Stop only for a true hard blocker:
   - unresolved constitutional conflict
   - unsupported host-path or OS handling that cannot be safely generalized
   - required validation impossible without unavailable external capability
   - approval needed for irreversible host mutation beyond the declared command

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not vendor third-party host binaries into `/.octon/**`.
2. Do not collapse host-scoped actual install state into repo-local `state/**`
   or `generated/**`.
3. Do not make `/init` silently install host tools.
4. Do not keep `/tmp` as the canonical steady-state install location.
5. Do not make multiple repos on one host compete for one mutable unversioned
   tool slot.
6. Do not make repo commands depend on proposal paths after promotion.
7. Do not widen support targets, packs, adapters, locales, or workload classes
   by default.
8. Do not treat PATH-only assumptions as sufficient architecture.
9. Do not leave consumer integration at the level of docs only; make
   `repo-hygiene` actually resolve through the new subsystem.

## Required implementation surfaces

Implement the proposal by creating or updating at minimum:

### Framework host-tool contract family

- `/.octon/framework/capabilities/runtime/host-tools/README.md`
- `/.octon/framework/capabilities/runtime/host-tools/registry.yml`
- `/.octon/framework/capabilities/runtime/host-tools/contracts/<tool-id>.yml`

Define initial contracts for the concrete first-wave tools required by
`repo-hygiene`, including:

- `shellcheck`
- `cargo-machete`
- `cargo-udeps`
- any supporting rust toolchain requirement that must be modeled explicitly

Each contract must cover:

- tool id
- display name
- supported OS/arch matrix
- installer kinds
- version detection
- verification command
- entrypoint path semantics
- whether side-by-side version installs are allowed or required

### Shared provisioning command

- update `/.octon/framework/capabilities/runtime/commands/manifest.yml`
- add `/.octon/framework/capabilities/runtime/commands/provision-host-tools.md`
- add `/.octon/framework/scaffolding/runtime/_ops/scripts/provision-host-tools.sh`

The command should support explicit modes such as:

- `verify`
- `install`
- `repair`

It must:

- resolve the current repo root
- read repo-owned desired requirements
- install or verify tools under a host-scoped Octon home
- record actual state, quarantine, and provisioning receipts
- avoid silent global package-manager mutation

### Repo-owned desired requirement surfaces

- add `/.octon/instance/capabilities/runtime/host-tools/requirements.yml`
- add `/.octon/instance/governance/policies/host-tool-resolution.yml`

These surfaces must define:

- required tools by consumer command/workflow/validator
- minimum or exact version semantics
- required versus optional resolution
- fail-closed behavior
- adoption rules for already-installed host tools

### Consumer integration

Update the `repo-hygiene` consumer surfaces to bind to the new subsystem:

- `/.octon/instance/governance/policies/repo-hygiene.yml`
- `/.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md`
- any implementation scripts required so the resolver is actually used

### Validation

- add `/.octon/framework/assurance/runtime/_ops/scripts/validate-host-tool-governance.sh`

The validator must check:

- contract family presence and parse validity
- repo requirements presence and parse validity
- shared provisioning command registration
- bootstrap docs updated correctly
- `repo-hygiene` binds to the new subsystem
- no host-specific binaries are stored under `/.octon/**`

### Bootstrap docs

Update:

- `/.octon/instance/bootstrap/START.md`
- `/.octon/instance/bootstrap/catalog.md`

The docs must make the following explicit:

- `/init` remains repo bootstrap only
- host-tool provisioning is a distinct explicit operation
- multiple repos on one host can share host-scoped tool installs

## Host-scoped actual-state model

Implement one host-scoped Octon home model with this resolution order:

1. explicit `OCTON_HOME`
2. platform default:
   - macOS: `~/Library/Application Support/Octon`
   - Linux: `${XDG_DATA_HOME:-~/.local/share}/octon`
   - Windows: `%LocalAppData%\\Octon`

Inside that home, implement at minimum:

- host manifest
- versioned tool install roots
- actual active/quarantine state
- retained provisioning evidence
- optional generated effective repo-resolution views

Keep all of that outside the repo.

## Multi-repo requirement

Prove the architecture against this scenario:

1. one host has multiple Octon-enabled repos
2. repo A requires tool version X
3. repo B requires tool version Y
4. both can coexist without mutating each other’s desired state
5. shared installs may be reused when compatible

Implement tests or equivalent deterministic validation for this.

## Validation you must run

Run at minimum:

- `bash -n` on every new/updated shell script
- `yq -e '.'` on every new/updated YAML file
- `git diff --check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-tool-governance.sh`
- existing relevant bootstrap/architecture validators affected by the change
- repo-local verification that `repo-hygiene` resolves tools through the new
  subsystem
- at least one provisioning run or verify/repair cycle that emits receipts
- multi-repo or equivalent shared-cache validation

If any required external host action cannot be performed locally, record that
explicitly in retained evidence and keep the subsystem fail-closed.

## Done means

Do not mark the work complete unless all of the following are true:

1. the framework host-tool contract family exists and parses
2. the repo-owned requirement and policy surfaces exist and parse
3. the provisioning command exists, is registered, and is documented
4. actual host installs are modeled outside the repo
5. `repo-hygiene` is integrated onto the subsystem
6. bootstrap docs preserve the repo-vs-host split
7. validator coverage exists and passes
8. no host-specific binaries are committed under `/.octon/**`
9. evidence exists for successful provisioning and repo-side tool resolution
10. the acceptance criteria in the proposal packet are explicitly assessed in
    the closeout report

## Final response format

Return:

1. concise summary of what changed
2. validation run and results
3. any unresolved blockers or host-specific gaps
4. explicit note on how the final implementation reuses the extensions pattern
   and where it intentionally diverges
5. acceptance-criteria status against AC-01 through AC-10
