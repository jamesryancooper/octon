# Target Architecture

## Decision
Ratify a conservative integrity update for Octon's proposal system where:
- proposals remain temporary, non-canonical, manifest-governed change packets
- the current four proposal kinds remain unchanged: `design`, `migration`, `policy`, `architecture`
- the current active lifecycle statuses remain unchanged: `draft`, `in-review`, `accepted`, `implemented`, `rejected`, `archived`
- base and subtype contract layers align around one machine-readable contract per subtype
- `/.octon/generated/proposals/registry.yml` becomes a deterministically rebuilt projection from proposal manifests rather than a manually trusted lifecycle surface
- the main proposal archive contains only standard-conformant archived packets; broken or partial historical remnants are normalized or excluded from the main projection
- explicit `validate-proposal`, `promote-proposal`, and `archive-proposal` workflows complete the lifecycle
- `navigation/artifact-catalog.md` becomes generated inventory after promotion, while `navigation/source-of-truth-map.md` becomes the primary manual boundary and authority map
- `implemented` becomes provable from retained promotion receipts and no target may retain backreferences to proposal paths after promotion

## Status
- status: draft
- proposal area: proposal-system contract alignment, registry projection discipline, archive normalization, lifecycle completion, and navigation simplification
- dependencies:
  - `inputs-exploratory-proposals`
  - `generated-effective-cognition-registry`
  - `validation-fail-closed-quarantine-staleness`
  - `migration-rollout`
- change class: tighten existing architecture instead of replacing it

## Why This Proposal Exists
The current proposal model is already architecturally right. Proposals are clearly temporary, non-canonical, manifest-governed, and promotion-oriented. The repo also already separates durable authority, retained evidence, and generated projections correctly.

What needs work is narrower:
1. Contract layers drift in ways that let schemas, validators, and templates disagree.
2. The registry behaves like a projection in theory, but the visible repo state still allows orphaned or inconsistent archived entries.
3. The archive boundary is not clean enough to prove that every archived proposal packet exited correctly.
4. Proposal lifecycle tooling is strong at creation and audit but incomplete at validation, promotion, and archival.
5. The artifact catalog currently adds more maintenance than authority.

This proposal therefore preserves the model and tightens only the weak seams.

## Preserved Invariants
| Invariant | Decision |
| --- | --- |
| Proposals are temporary and non-canonical | Keep |
| `proposal.yml` and exactly one subtype manifest are the proposal-local authority pair | Keep |
| Registry is projection-only and subordinate to proposal manifests | Keep |
| No new proposal kinds are needed now | Keep |
| No new active lifecycle statuses are needed now | Keep |
| Promotion targets must point outside the proposal workspace | Keep |
| Source-of-truth maps remain manual and semantic | Keep |
| Archive packets must never become active authority again without normalization | Keep |

## Problems To Fix Now
| Concern | Current signal | Minimal fix |
| --- | --- | --- |
| Contract drift | Base archive enums and subtype schemas disagree with validators and templates | Align standards, schemas, validators, and templates around one effective contract |
| Registry drift | Package-to-registry checks exist, but reverse drift can survive | Rebuild the registry from manifests and validate the projection in both directions |
| Archive integrity | Some archived entries are incomplete, inconsistent, or use invalid lineage values | Normalize or exclude broken packets before fail-closed projection checks are enforced |
| Lifecycle gap | Create and audit workflows exist; generic validate, promote, and archive operations are missing | Add explicit meta-workflows and retained evidence bundles |
| Navigation overhead | Hand-authored artifact catalogs are derivable and drift-prone | Generate inventory; keep manual authority mapping only where humans must make semantic choices |

## Target Operating Model

### What A Proposal Is
A proposal is a temporary change packet for work that needs explicit review, explicit promotion targets, explicit evidence expectations, and explicit archival provenance before durable surfaces change.

### What A Proposal Is Not
A proposal is not:
- a durable architecture, runtime, or policy authority
- a second lifecycle source of truth alongside the manifests
- the long-term home for operational evidence
- a reason to let generated projections outrank authored inputs

### Lifecycle
The target lifecycle stays:
1. `draft`
2. `in-review`
3. `accepted`
4. `implemented` or `rejected`
5. `archived`

The rules tighten:
- `accepted` means ready to use as the temporary implementation or decision aid; it does not mean canonical.
- `implemented` requires a promotion receipt plus target validation that no promoted surface depends on proposal-local paths.
- `rejected` means no promotion will occur and archival handling is next.
- `archived` requires valid archive metadata and a correct archive path.
- `archive.disposition=implemented` requires non-empty `archive.promotion_evidence`.
- Staleness is handled by audit and warning, not by inventing new statuses.

### Package Boundaries
| Layer | What lives there | What stays out |
| --- | --- | --- |
| Proposal-local | `proposal.yml`, subtype manifest, working docs, source-of-truth map, support resources | Durable runtime or policy authority |
| Framework-core | Standards, templates, schemas, validators | Proposal-local lifecycle state |
| Generated or projection-only | Registry, generated artifact catalog, future indexes | Authoritative lifecycle decisions |
| Workflow and evidence | Create, validate, promote, archive workflows and retained receipts under `state/evidence/**` | Proposal-local SSOT |
| Archive-only | Archived packets and historical lineage | Active authoring or runtime truth |

## Target Architecture

### 1. One Effective Contract Per Proposal Surface
The promoted contract is:
- human-readable standard
- matching template manifest
- matching JSON schema
- matching validator behavior

No surface may silently define a competing contract. Where the current repo already has a live template plus validator pair that agrees with active manifests, that pair becomes the promoted baseline and the lagging schema is corrected to match.

### 2. Deterministic Registry Projection
`/.octon/generated/proposals/registry.yml` becomes a deterministic build output from the current proposal manifests:
- scan active packages under `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`
- scan archived packages under `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`
- validate each packet before projection
- write sorted `active` and `archived` sections
- fail closed on duplicate ids, missing packets, invalid archive metadata, path mismatches, kind mismatches, or status mismatches

Manual registry edits stop being trusted behavior. Workflow operations may still update the committed file, but they do so by invoking the generator or rebuild path rather than editing registry state by hand.

### 3. Clean Archive Boundary
The main archive remains the retained home for archived proposal packets, but it is tightened:
- archive paths must contain only packets that validate against the standard
- packets in archive paths must use `status: archived`
- invalid historical imports are either normalized into standard packets or removed from the main registry until they are
- `legacy-unknown` remains allowed only for retained historical lineage and may not be used to reactivate a packet without normalization
- `superseded` remains a valid archive disposition and must be supported consistently across the standard, schema, and registry contract

### 4. Explicit Proposal Operations
The lifecycle gains three durable workflow entry points:
- `validate-proposal`
- `promote-proposal`
- `archive-proposal`

#### validate-proposal
Runs the base validator plus the subtype validator, rebuilds or checks the registry projection, and writes a workflow bundle under `state/evidence/runs/workflows/`.

#### promote-proposal
Requires `status: accepted`, validates targets, verifies no target retains a proposal-path dependency, writes a promotion bundle, and only then allows `status: implemented`.

#### archive-proposal
Moves the packet into the correct archive path, rewrites `proposal.yml` with valid archive metadata, rebuilds the registry, writes an archive receipt, and seals the packet as retained lineage.

### 5. Stronger Proof For `implemented`
`implemented` stops being a narrative claim. In the promoted model it requires:
- an explicit promotion workflow run
- a retained bundle under `state/evidence/runs/workflows/`
- a summary or validation receipt under `state/evidence/validation/` when appropriate
- target validation showing that durable surfaces no longer depend on proposal-local paths
- registry and packet state that agree

### 6. Navigation Simplification
The navigation model is simplified rather than expanded:
- `navigation/source-of-truth-map.md` stays manual and becomes more explicit about external authorities, projections, evidence, and boundary rules
- `navigation/artifact-catalog.md` becomes generated inventory after promotion
- no additional navigation artifacts are added

### 7. Evidence Placement
Evidence of proposal operations belongs under `state/evidence/**`, not inside proposal packages and not under `generated/**`.
Expected bundle pattern:
- `bundle.yml`
- `summary.md`
- `commands.md`
- `validation.md`
- `inventory.md`

Additional workflow-specific files may exist, but those five remain the common baseline so proposal operations stay reviewable and consistent with existing workflow evidence patterns.

## File-Level Promotion Intent
Durable promoted outputs should land in:
- `.octon/framework/scaffolding/governance/patterns/`
- `.octon/framework/scaffolding/runtime/templates/`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- top-level orientation docs such as `.octon/README.md` and `.octon/instance/bootstrap/START.md` where operator guidance needs to change

Archive cleanup inside the proposal workspace is still required, but it is migration-only repair work rather than a durable promotion target.

## Non-Goals
This proposal does not:
- add new proposal kinds
- add new active lifecycle statuses
- make proposals canonical
- make the registry authoritative
- introduce a heavy proposal dependency graph
- revive packet numbering or alternate proposal workspace models
- force a companion migration proposal unless archive repair grows materially beyond the listed inventory

## Deferred
- Design-subtype contract changes beyond confirmed evidence
- A separate historical-import registry unless normalization work proves large enough to justify one
- Any broader redesign of proposal authoring ergonomics beyond the minimal artifact-catalog simplification and workflow completion in this proposal
