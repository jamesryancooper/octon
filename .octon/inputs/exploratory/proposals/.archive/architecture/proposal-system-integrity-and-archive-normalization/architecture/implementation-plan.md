# Implementation Plan

## Strategy
Implement the proposal-system update as a tight, subtractive-first sequence:
1. align one contract
2. make the registry fail closed
3. complete the lifecycle operations
4. normalize the archive
5. remove low-value manual friction

This keeps the proposal system recognizable while making it materially more reliable.

## Workstream 1 — Align The Contract Layer
### Goal
Remove schema, standard, template, and validator disagreement.

### Durable targets
- `.octon/framework/scaffolding/governance/patterns/`
- `.octon/framework/scaffolding/runtime/templates/`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/cognition/_meta/architecture/generated/proposals/`

### Changes
- Update `proposal-standard.md` where needed so archive semantics, lifecycle, and navigation expectations match the promoted design.
- Update subtype standards for architecture, migration, and policy so they describe the same manifest contract already used by the live templates and validators.
- Update `proposal.schema.json` so `archive.disposition` includes `superseded`.
- Update `architecture-proposal.schema.json` to require `architecture_scope` and `decision_type`.
- Update `migration-proposal.schema.json` to require `change_profile` and `release_state`.
- Update `policy-proposal.schema.json` to require `policy_area` and `change_type`.
- Update validators only where they still encode a divergent rule after the schema and standards are corrected.

### Done when
- Standard, schema, template, and validator rules match for base, architecture, migration, and policy manifests.
- A regression check or test fixture proves the contract layers stay aligned.

## Workstream 2 — Deterministic Registry Projection
### Goal
Make `/.octon/generated/proposals/registry.yml` behave like a true projection.

### Durable targets
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/cognition/_meta/architecture/generated/proposals/`

### Changes
- Add a registry rebuild path, preferably a dedicated script such as `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`.
- Rebuild `registry.yml` from proposal manifests rather than editing it by hand.
- Extend validation so every registry entry must resolve to exactly one valid proposal package.
- Fail closed on duplicate ids, path mismatches, kind mismatches, status mismatches, invalid archive metadata, and orphaned entries.
- Update create, promote, and archive workflows to call the generator or rebuild path.

### Done when
- Rebuilding the registry from manifests reproduces the committed file.
- Reverse validation catches broken or orphaned entries.
- Normal proposal operations no longer depend on manual registry maintenance.

## Workstream 3 — Complete The Lifecycle Tooling
### Goal
Make proposal lifecycle transitions explicit and provable.

### Durable targets
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/assurance/runtime/`
- `.octon/state/evidence/runs/workflows/`
- `.octon/state/evidence/validation/`

### Changes
- Add `.octon/framework/orchestration/runtime/workflows/meta/validate-proposal/`.
- Add `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`.
- Add `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`.
- Reuse the existing workflow-bundle pattern: `bundle.yml`, `summary.md`, `commands.md`, `validation.md`, `inventory.md`.
- Make `promote-proposal` require `status: accepted`, target validation, registry sync, and proposal-path backreference checks.
- Make `archive-proposal` require correct archive path, archive metadata, registry sync, and promotion evidence when disposition is `implemented`.

### Done when
- `implemented` can be proved from a promotion workflow receipt.
- `archived` can be proved from an archive workflow receipt.
- A generic validation entry point exists for humans and CI.

## Workstream 4 — Normalize The Archive
### Goal
Make the main archive trustworthy enough to support fail-closed projection.

### Operational targets
- `/.octon/inputs/exploratory/proposals/.archive/**`
- `/.octon/generated/proposals/registry.yml`

### Changes
- Repair or exclude the archive inventory listed in `resources/archive-normalization-inventory.md`.
- Reconstruct complete archived packets where possible.
- Replace impossible lineage values such as `archived_from_status: proposed` with valid prior states or explicit historical-import handling.
- Remove incomplete or untrusted archive entries from the main registry until they are repaired.
- Keep `legacy-unknown` only for true historical carry-forward that is not yet normalized.

### Done when
- Every main-registry archived entry resolves to a standard-conformant packet.
- The main registry contains no impossible lifecycle lineage values.
- The archive path and manifest state agree for every projected packet.

### Split trigger
If archive repair grows beyond the listed inventory or requires broad packet reconstruction work, open a companion migration proposal `proposal-registry-and-archive-normalization` and keep this architecture proposal focused on durable contract and workflow changes.

## Workstream 5 — Simplify Navigation And Guidance
### Goal
Remove low-value manual maintenance while improving human and agent readability.

### Durable targets
- `.octon/framework/scaffolding/runtime/templates/`
- `.octon/framework/scaffolding/governance/patterns/`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`

### Changes
- Generate `navigation/artifact-catalog.md` during proposal creation or validation.
- Strengthen source-of-truth-map templates so they require explicit external authorities, projections, evidence surfaces, and boundary rules.
- Update high-level repo guidance where proposal-system operation is surfaced to operators.
- Keep README documents human-facing and explanatory rather than authoritative.

### Done when
- Proposal authors no longer need to hand-maintain artifact inventories.
- Source-of-truth maps do real semantic work.
- High-level guidance matches the promoted workflow names and boundary rules.

## Rollout Order
1. Land contract alignment first.
2. Rebuild and validate the registry.
3. Add the missing workflows.
4. Normalize the archive inventory.
5. Turn on stricter fail-closed checks in normal validation and CI.
6. Archive this proposal only after the promoted system no longer depends on proposal-local instructions.

## Risks And Controls
| Risk | Control |
| --- | --- |
| Turning on fail-closed validation before repair work is finished | Normalize or exclude broken archive entries first |
| Accidentally making the registry authoritative | Keep manifests first in every workflow and regenerate the registry from manifests |
| Expanding the proposal into a redesign | Preserve kinds, statuses, non-canonical rules, and proposal-local authority order |
| Adding authoring drag | Generate artifact catalogs and keep changes subtractive-first |
| Losing archival lineage during cleanup | Treat archive repair as retained historical work, not disposable cleanup |

## Explicitly Deferred
- New proposal kinds
- New active lifecycle statuses
- A heavy proposal dependency graph
- A broader redesign of design-proposal internals without new evidence
