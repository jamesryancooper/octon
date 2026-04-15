# Source of Truth Map

## Canonical authority hierarchy used by this packet

| Layer | Role | Current source(s) | Why it matters here |
|---|---|---|---|
| Constitutional kernel | Supreme repo-local control regime | `/.octon/framework/constitution/**` | Prevents packet drift into new control planes or unsupported support claims |
| Umbrella architecture | Cross-subsystem topology and placement | `/.octon/framework/cognition/_meta/architecture/specification.md` | Determines legal class-root placement |
| Root manifest | Topology, profiles, runtime contract family hooks | `/.octon/octon.yml` | Confirms run-centered execution and current contract family routing |
| Instance manifest | Overlay enablement | `/.octon/instance/manifest.yml` | Confirms this repo can legally refine governance, agency runtime, and assurance runtime overlays |
| Workspace charter pair | Repo-wide active objective layer | `/.octon/instance/charter/workspace.md`, `workspace.yml` | Confirms run contracts are the atomic consequential execution path beneath mission continuity |
| Support-target declarations | Live support universe | `/.octon/instance/governance/support-targets.yml` | Any runtime/capability change must respect admitted tuples and evidence requirements |
| Governance exclusions | Explicit denied/prohibited space | `/.octon/instance/governance/exclusions/action-classes.yml` | Prevents silent widening of execution claims |
| Runtime contract family | Run-lifecycle constitutional contracts | `/.octon/framework/constitution/contracts/runtime/**` | Holds the live instruction-layer manifest contract already in use |
| Engine runtime spec | Authorization, request, grant, receipt semantics | `/.octon/framework/engine/runtime/spec/**` | Holds the current capability invocation boundary this packet refines |
| Capability pack family | Portable pack contracts above raw tools | `/.octon/framework/capabilities/packs/**` | Current place where broader action surfaces are defined |
| Repo-local capability governance | Repo-specific admission and default routes | `/.octon/instance/governance/capability-packs/**`, `/.octon/instance/capabilities/runtime/packs/**` | Current place where pack admission and required evidence are localized |
| Repo-local runtime overlays | Repo-specific runtime refinements | `/.octon/instance/agency/runtime/**` | Current place for output budget and related runtime-policy refinements |
| Assurance / CI | Blocking conformance execution | `/.octon/framework/assurance/runtime/_ops/scripts/**`, `.github/workflows/architecture-conformance.yml` | Must enforce any new semantics introduced by this packet |

## Current active proposal lineage considered

| Proposal path | Role in this packet |
|---|---|
| `/.octon/inputs/exploratory/proposals/architecture/octon_bounded_uec_proposal_packet/` | Adjacent but broader packet. It is closure-oriented and bounded-claim-focused, so this packet is a sibling refinement rather than an extension. |

## Non-authoritative surfaces explicitly excluded from promotion targets

- `inputs/**` except this packet itself
- `generated/**` except optional read-model refinements after authoritative changes land
- chat/UI host signals
- generated summaries
- proposal registry outputs
