# Target Architecture

## Decision

Adopt one **Repository Hygiene and Retirement** capability family that is
repo-specific, Rust + Shell native, fail-closed, evidence-backed, and
consolidated onto the existing Octon build-to-delete governance spine.

The family is composed of four durable parts:

1. a repo-owned governance policy for classification and routing;
2. a repo-native command surface for detection and operator use;
3. minimal contract extensions to the existing retirement/drift/ablation
   reviews; and
4. assurance and CI integrations that keep the capability live and bounded.

## Target-state operating model

### 1. Detection and classification authority

A new repo-owned policy at
`/.octon/instance/governance/policies/repo-hygiene.yml` becomes the canonical
classification and routing surface for:

- static dead Rust code;
- unused Rust dependencies;
- shell/script orphaning;
- stale generated outputs and other repository bloat;
- transitional residue; and
- historical-retained or never-delete surfaces.

The policy does **not** authorize deletion. It only defines scope,
classifications, protections, confidence rules, same-change update rules, and
mode boundaries.

### 2. Repo-native command surface

A new command `repo-hygiene` lives under
`/.octon/instance/capabilities/runtime/commands/repo-hygiene/` and is
registered in the instance command manifest. The command supports four modes:

- `scan` — read-only discovery;
- `enforce` — read-only gate that fails on blocking findings;
- `audit` — governed audit packet emission under retained evidence roots;
- `packetize` — stage-only attachment of findings into an existing
  build-to-delete review packet.

The command is intentionally placed in the repo-native command lane because the
live repo already reserves that lane for instance-owned commands and the
command/problem is repository-specific rather than additive-pack reusable.

### 3. Retirement and build-to-delete routing

No new transitional registry is created. Instead, the existing retirement
policy, retirement registry, retirement register, drift review, retirement
review, closeout review set, claim gate, and ablation-driven deletion workflow
remain authoritative.

The proposed hygiene capability adds only the missing routing and evidence
hooks:

- newly detected transitional residue must register into the existing
  retirement registry/register in the same change;
- repo-hygiene findings become a required input to retirement review and
  ablation/deletion decisions;
- closure-grade packets must carry a repo-hygiene findings attachment;
- claim-adjacent or active-release surfaces remain protected from direct
  delete.

### 4. Assurance and CI integration

Implementation requires one new validator and small updates to existing
architecture/closure validators, plus a dedicated repo-hygiene workflow.
Those repo-local workflow edits are essential for the operational target state,
but they are treated as **dependent integration surfaces** rather than active
proposal promotion targets because the proposal standard forbids mixed target
families in one active proposal.

## Target authority, control, evidence, disclosure, and derived-view posture

| Category | Target posture |
| --- | --- |
| Durable authority | `framework/**` and `instance/**` only. The new policy, command registration, command documentation/scripts, and validator changes all land there. |
| Operational truth and retained evidence | `state/**` only. Repo-hygiene audit packets and release-packet attachments are retained evidence, not authored authority. |
| Derived views | `generated/**` remains projection-only and never becomes the hygiene control plane. |
| Proposal-local artifacts | temporary, non-canonical, implementation-scoped only. |
| Disclosure and claim posture | active release, current governance review, and latest build-to-delete packet remain protected and non-deletable by hygiene routing. |

## Detection layers in the target state

1. **Rust static deadness** via `cargo check` and `cargo clippy` over the live
   runtime workspace.
2. **Dependency deadness** via `cargo machete` on fast paths and
   `cargo +nightly udeps` on slower audit paths.
3. **Shell/script orphaning** via tracked-file inventory, shebang detection,
   `shellcheck`, syntax checks, and reader scans across source, workflows,
   validators, and manifests.
4. **Artifact bloat** via generated/output classification driven by
   `.octon/octon.yml` commit-default posture plus reader scans.
5. **Transitional residue** via path/content heuristics plus mandatory
   retirement-registry reconciliation.

## Target decision grammar

Every finding is routed into one of these actions only:

- `safe-to-delete`
- `needs-ablation-before-delete`
- `retain-with-rationale`
- `demote-to-historical`
- `register-for-future-retirement`
- `never-delete`

This grammar is intentionally narrower than generic lint output. `unused` is
not treated as synonymous with `safe-to-delete`.

## Target invariants

1. No second retirement or transitional control plane exists.
2. Support-target admissions and capability-pack scope remain unchanged by
   default.
3. Detection is independent from destructive action.
4. Any ambiguity resolves to observe-only, stage-only, escalation, or
   retention pending review.
5. Newly detected transitional residue in authoritative, workflow, generated,
   or retained-evidence roots must register into the existing retirement spine
   before closure claims can proceed.
6. Active release and current review packet surfaces remain dynamically
   protected from hygiene-driven deletion.
7. Target-state completion means the governed capability family exists and has
   produced baseline evidence; it does **not** mean the repository can never
   accumulate future residue.

## Durable surfaces to create or update

### New durable surfaces

- `/.octon/instance/governance/policies/repo-hygiene.yml`
- `/.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md`
- `/.octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh`
- `/.octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene-common.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- dependent repo-local integration: `/.github/workflows/repo-hygiene.yml`

### Updated durable surfaces

- `/.octon/instance/capabilities/runtime/commands/manifest.yml`
- `/.octon/instance/governance/contracts/retirement-policy.yml`
- `/.octon/instance/governance/contracts/retirement-review.yml`
- `/.octon/instance/governance/contracts/drift-review.yml`
- `/.octon/instance/governance/contracts/ablation-deletion-workflow.yml`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-phase7-build-to-delete-institutionalization.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-global-retirement-closure.sh`
- dependent repo-local integrations: `/.github/workflows/architecture-conformance.yml`, `/.github/workflows/closure-certification.yml`

## Explicit non-claims

This proposal does not claim:

- that the repository is currently free of dead code or repository bloat;
- that all current transitional residue is already registered;
- that repo-local workflow integrations can be promoted as part of an
  octon-internal active proposal target list; or
- that the implementation may bypass existing ACP, support-target, or
  build-to-delete governance.

## Acceptance conditions for the target state

The target state is reached only when all of the following are true:

1. the authoritative `.octon/**` policy, command, contract, and validator
   surfaces are promoted;
2. dependent workflow integrations exist and run;
3. a baseline audit has been emitted under retained evidence roots;
4. closure-grade packets know how to carry repo-hygiene findings; and
5. high-confidence transitional residue is either fixed or registered in the
   same change before target-state closure is claimed.
