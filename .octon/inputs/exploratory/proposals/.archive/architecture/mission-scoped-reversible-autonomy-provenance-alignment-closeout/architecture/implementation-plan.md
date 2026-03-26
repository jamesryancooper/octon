# Implementation Plan

This proposal should land as one big-bang, clear-break, atomic promotion.
The runtime closeout already landed at `0.6.3`; the remaining work is to make
proposal lineage, ADR discovery, migration evidence, and operator guidance
describe that same steady state without mixed provenance.

The authoritative execution record for the promotion belongs in:

`/.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`

This proposal-local implementation plan mirrors that atomic shape so the packet
remains self-contained until promotion and archive.

## Profile Selection Receipt

- Date: 2026-03-25
- Version source(s): `version.txt`, `/.octon/octon.yml`
- Current version: `0.6.3`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - the runtime, policy, control, evidence, and generated MSRAOM model are
    already at their intended post-closeout state
  - the remaining work is bounded to proposal manifests, registry projection,
    ADR and migration discovery, operator-facing documentation, and archive
    normalization
  - the affected surfaces all live inside one repo-local trust boundary, so
    staged coexistence would preserve the exact ambiguity this packet is meant
    to remove
  - rollback remains full-branch revert plus proposal-registry regeneration,
    not dual live provenance rules
- Hard-gate outcomes:
  - no compatibility window required
  - no staged or transitional profile justified
  - no runtime release bump required
  - no partial merge acceptable if registry, archive, decision, and docs do not
    converge together
- Tie-break status: `atomic` selected without exception

## Atomic delivery rules

1. No runtime, policy, schema, control-truth, or generated-runtime semantic
   change may ride in the same branch.
2. No archived MSRAOM proposal packet may remain `draft` after merge.
3. No registry projection may omit a promoted archived MSRAOM packet that still
   claims canonical historical value.
4. No old ADR is rewritten to hide lineage drift; append-only correction lands
   through one new provenance-closeout ADR and migration record.
5. The active implementing proposal remains in the active workspace during
   branch work and is archived only in the final closeout transaction.
6. If archive manifests, indices, docs, and registry output cannot all be made
   consistent on one tree, the branch does not merge.

## Execution model

The branch should execute in five ordered phases.
Work can happen in parallel inside the branch, but integration should follow
this dependency order:

| Phase | Outcome | Primary surfaces | Depends on |
|---|---|---|---|
| 0 | Baseline inventory and no-change lock | proposal packet, archive manifests, registry, ADR/migration references | none |
| 1 | Archive-manifest normalization | archived MSRAOM proposal manifests and archive-local README/navigation notes | 0 |
| 2 | Decision and migration closeout authoring | new ADR, migration plan, migration evidence bundle, discovery indexes | 1 |
| 3 | Registry and navigation alignment | generated proposal registry, root docs, architecture docs, source-of-truth maps | 1, 2 |
| 4 | Final proof and archival transaction | validation receipts, change inventory, current proposal archival closeout | 1, 2, 3 |

## Phase 0 — Baseline inventory and no-change lock

### Goal

Lock the actual residual gap so the branch does not drift back into runtime
remediation work.

### Actions

1. Record the actual `0.6.3` steady state from `version.txt` and
   `/.octon/octon.yml`.
2. Inventory the current MSRAOM proposal lineage across:
   - active proposal workspace
   - archive workspace
   - `/.octon/generated/proposals/registry.yml`
   - ADRs 063 through 067
   - migration records and evidence bundles under the MSRAOM cutover lineage
3. Freeze the no-change zones from
   [`../navigation/change-map.md`](../navigation/change-map.md):
   - mission runtime helpers
   - mission-autonomy policy and ownership rules
   - control/evidence/generated runtime families
   - CI semantics unrelated to proposal integrity
4. Record the specific residual gaps that the branch must close:
   - archived packet manifests still declaring `draft`
   - missing archive metadata and promotion evidence
   - missing or incomplete proposal-registry lineage
   - missing provenance-closeout ADR and migration record
   - docs/navigation that still force readers to infer provenance from runtime

### Exit gate

The branch has a closed list of provenance gaps to fix and a locked list of
runtime surfaces that must not change.

## Phase 1 — Archive-manifest normalization

### Goal

Make the MSRAOM archive self-describing before any registry or ADR layer tries
to project it.

### Actions

1. Normalize the archived proposal manifests for:
   - `mission-scoped-reversible-autonomy-steady-state-cutover`
   - `mission-scoped-reversible-autonomy-final-closeout-cutover`
2. Set their lifecycle state to archived and add explicit archive metadata:
   - `archived_at`
   - `archived_from_status`
   - `disposition`
   - `original_path`
   - `promotion_evidence`
3. Keep the archived packets historical rather than reactivating them in the
   active workspace.
4. Add minimal archive-local context where needed so a reader can tell:
   - why the packet is historical
   - which ADR or evidence bundle proves promotion
   - which later packet closed the remaining provenance issue
5. Do not change the runtime-remediation substance of those archived packets;
   normalize only provenance and lifecycle metadata.

### Exit gate

The archived steady-state and final-closeout packets can be projected as clean
historical records without inventing new runtime claims.

## Phase 2 — Decision and migration closeout authoring

### Goal

Add one durable, append-only closeout record for the provenance cleanup instead
of retroactively editing historical ADR intent.

### Actions

1. Add one new ADR under `/.octon/instance/cognition/decisions/**` that states:
   - MSRAOM runtime closeout already landed at `0.6.3`
   - ADRs 066 and 067 remain historical runtime-closeout records
   - proposal packets are historical lineage, not active runtime authority
   - the steady-state and final-closeout archived packets are normalized and
     projected intentionally
   - this provenance-alignment packet is the final repo-side closure statement
2. Add the matching migration plan under
   `/.octon/instance/cognition/context/shared/migrations/**`.
3. Define the required migration evidence bundle under
   `/.octon/state/evidence/migration/**`:
   - `bundle.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
4. Update discovery indexes:
   - `/.octon/instance/cognition/decisions/index.yml`
   - `/.octon/instance/cognition/context/shared/migrations/index.yml`
5. Keep ADR 066 and ADR 067 append-only historical records. If they still point
   at old active proposal paths, correct that lineage by adding the new closing
   ADR rather than rewriting their accepted context.

### Exit gate

One new ADR and one new migration record explain the final provenance state
without mutating historical runtime-closeout decisions.

## Phase 3 — Registry and navigation alignment

### Goal

Make proposal discovery and operator guidance project the same historical
lineage that the archive and decision records now claim.

### Actions

1. Regenerate and commit `/.octon/generated/proposals/registry.yml` so it
   includes the normalized archived MSRAOM packets with coherent status,
   disposition, and archive metadata.
2. Ensure the registry does not imply any active MSRAOM implementation packet
   beyond the current implementing proposal while the branch is open.
3. Update:
   - `/.octon/README.md`
   - `/.octon/instance/bootstrap/START.md`
   - `/.octon/framework/cognition/_meta/architecture/specification.md`
   - `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
4. Make those docs point readers to:
   - canonical runtime and governance roots first
   - the new provenance-closeout ADR and migration record second
   - proposal packets only as historical lineage
5. Refresh proposal-local navigation in this packet so it cites:
   - the audit as baseline
   - the observed post-`0.6.3` residual gap
   - the intended durable promotion surfaces

### Exit gate

Registry, docs, and proposal-local navigation all tell the same post-`0.6.3`
MSRAOM story.

## Phase 4 — Final proof and archival transaction

### Goal

Close the branch only when the repo can prove that provenance was normalized
without runtime drift.

### Actions

1. Run the validation suite in
   [`validation-plan.md`](./validation-plan.md).
2. Produce a final change inventory proving that only allowed surfaces changed.
3. Record validation and command receipts in the migration evidence bundle.
4. Archive this implementing proposal in the same closeout transaction that
   lands:
   - the new ADR
   - the new migration plan
   - the migration evidence bundle
   - the normalized archive manifests
   - the regenerated proposal registry
5. Regenerate proposal discovery one final time after archiving the current
   packet so the archive and registry reflect the same final state.

### Exit gate

The current implementing packet can be archived without losing discoverability,
and no active MSRAOM proposal packet remains ambiguous after merge.

## Final-state verification gate

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-version-parity.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --all-standard-proposals`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,mission-autonomy`
- targeted structural review of the new ADR, migration plan, migration index,
  decision index, and evidence-bundle references
- diff inventory proving no runtime, policy, schema, control, or generated
  runtime semantic surface changed

The merge gate is simple: no merge until all of the above are green against the
same final tree.

## Impact map

### Durable authority

- `/.octon/instance/cognition/decisions/**`
- `/.octon/instance/cognition/decisions/index.yml`
- `/.octon/instance/cognition/context/shared/migrations/**`
- `/.octon/instance/cognition/context/shared/migrations/index.yml`
- `/.octon/state/evidence/migration/**`

### Proposal lineage and discovery

- `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-*/**`
- `/.octon/generated/proposals/registry.yml`

### Operator-facing guidance

- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`

### Expected no-change zones

- `/.octon/framework/orchestration/runtime/**`
- `/.octon/framework/engine/runtime/**`
- `/.octon/instance/governance/policies/mission-autonomy.yml`
- `/.octon/instance/governance/ownership/registry.yml`
- `/.octon/state/control/execution/**`
- `/.octon/state/evidence/control/**`
- `/.octon/state/evidence/runs/**`
- `/.octon/generated/effective/**`
- `/.octon/generated/cognition/**`
- `/.github/workflows/**`

## Rollback

- revert the full provenance-alignment change set
- restore the previous archived proposal manifests if the normalized lineage
  cannot be validated
- regenerate `/.octon/generated/proposals/registry.yml` from the reverted
  manifests
- do not keep the new provenance-closeout ADR, migration record, or archival
  metadata while restoring the pre-closeout registry view
