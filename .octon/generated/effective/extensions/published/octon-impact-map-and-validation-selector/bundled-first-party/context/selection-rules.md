# Selection Rules

This pack is a selector and explainer. It never invents additional validation
logic or authority surfaces.

## Shared Decision Rules

1. Normalize the input first.
2. Prefer current repo facts over declared intent when they disagree.
3. Select the smallest existing validation set that still covers the direct
   impact class.
4. Record omitted but plausible higher-cost checks explicitly.
5. Fail closed when no published rule yields a credible floor.

## Input Normalization

- `touched_paths` must normalize to a deduplicated `string[]` of repo-relative
  paths.
- `proposal_packet` must resolve through `proposal.yml` plus exactly one
  subtype manifest.
- `refactor_target` must provide `type`.
- `rename` and `move` refactors must provide both `old` and `new`.
- `restructure` refactors may omit `new`, but they must describe the target
  scope well enough to audit references.

## Touched Path Classification

### Extension-Pack Surfaces

If any touched path is under `/.octon/inputs/additive/extensions/**`, the
minimum credible validation floor is:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`

Add these when commands or skills are exported:

- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`

### Authoritative Docs

If any touched path is an authoritative-doc trigger candidate, the minimum
credible floor is:

- `bash .octon/framework/assurance/runtime/_ops/scripts/classify-authoritative-doc-change.sh --stdin`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`

### Proposal Workspace Paths

If touched paths land inside the proposal workspace, resolve proposal kind from
the manifests and select:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <proposal-path>`
- one subtype validator:
  - `validate-architecture-proposal.sh`
  - `validate-policy-proposal.sh`
  - `validate-migration-proposal.sh`

Under `standard` or `deep`, add the matching proposal-audit workflow.

### Repo Hygiene And Retirement Surfaces

If touched paths alter `repo-hygiene`, retirement policy, or retirement review
surfaces, the minimum credible floor is:

- `bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh scan`

Under `balanced` or `release-gate`, escalate to:

- `bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh audit --audit-id <id>`

### Refactor-Oriented Paths

If the input is a refactor target, or the touched paths strongly imply rename,
move, or restructure work, the primary workflow route is:

- `/refactor`

Then add only the extra validators implied by the touched classes above.

### Broad Multi-Subsystem Harness Changes

Under `release-gate`, or under `balanced` when migration, freshness, or
cross-subsystem signals are explicit, the escalation route is:

- `/audit-pre-release`

## Proposal Packet Selection Rules

Resolve kind from:

1. `proposal.yml`
2. exactly one subtype manifest

Never resolve kind from generated proposal registry projections.

Minimum validator floor by kind:

- architecture: `validate-proposal-standard.sh` + `validate-architecture-proposal.sh`
- policy: `validate-proposal-standard.sh` + `validate-policy-proposal.sh`
- migration: `validate-proposal-standard.sh` + `validate-migration-proposal.sh`

Under `standard` or `deep`, add the matching proposal-audit workflow.

Default next-step routing:

- primary: `/octon-concept-integration-packet-refresh-and-supersession`
- alternate: `/octon-concept-integration-packet-to-implementation` when the
  packet is already current and implementation-ready

## Mixed Input Rules

- Touched paths outrank proposal or refactor intent for factual impact claims.
- Keep packet or refactor-derived validations only when they still match the
  observed surfaces.
- If packet scope and touched paths diverge materially, prefer packet refresh
  or clarification over weak validation.
- If refactor scope is under-specified, prefer clarification over guessed audit
  coverage.

## No-Match Rule

If no published rule yields a credible floor:

- set `impact_map.status` to `needs-clarification` or `blocked`
- leave `selected[]` empty
- explain exactly which missing fact prevented a credible answer
