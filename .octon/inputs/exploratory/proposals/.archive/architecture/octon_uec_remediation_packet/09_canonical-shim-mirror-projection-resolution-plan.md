# Canonical / Shim / Mirror / Projection Resolution Plan

## Principle
Every surfaced file family must have exactly one status:
- **canonical**
- **historical shim**
- **subordinate governance shim**
- **mirror**
- **projection-only**
- **deleted**

No surface may be semantically in-between.

## 1. Live Canonical Surfaces (preserve)
- `/.octon/framework/constitution/**`
- `/.octon/instance/charter/**`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**` *(evidence-only subordinate canon)*
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exceptions/**` *(directory-family only)*
- `/.octon/state/control/execution/revocations/**` *(directory-family only)*
- `/.octon/state/evidence/**`
- `/.github/workflows/**`

## 2. Compatibility Surfaces to Delete or Re-home
### Delete from live control roots
- `/.octon/state/control/execution/exceptions/leases.yml`
- `/.octon/state/control/execution/revocations/grants.yml`

### Optional generated replacements
If aggregate readers are still needed, regenerate them only under:
- `/.octon/generated/effective/control/execution/exception-leases.aggregate.yml`
- `/.octon/generated/effective/control/execution/revocations.aggregate.yml`

These are projections, never authority.

## 3. Projection-Only Surfaces (preserve, but enforce non-authority)
- `/.octon/generated/effective/**`
- governance mirrors generated from active release evidence
- any generated aggregate support-target or authority views

## 4. Historical Shims (preserve unless later retired)
- repo-root `AGENTS.md`, `CLAUDE.md`, `.octon/AGENTS.md`
- `/.octon/instance/bootstrap/OBJECTIVE.md`
- `/.octon/instance/cognition/context/shared/intent.contract.yml`
- agency / cognition historical constitution-style surfaces already marked by the registry

## 5. Subordinate Governance Shims (preserve)
- assurance-governance local weighting / scoring charter surfaces
- protected subordinate principles surfaces

## 6. Mirror Surfaces (preserve, but generated only)
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/instance/governance/closure/**`

Mirrors must never diverge from the active release bundle.

## 7. Exact Resolution Outcomes for Blockers
- Blocker A: support-target duplicate authored semantics removed from canonical surfaces.
- Blocker B: flat compatibility aggregates removed from canonical authority roots.
- Blocker C: claim-envelope wording confined to disclosure surfaces only.
- Blocker D: stage-attempt family canonicalized; no mixed active claim-bearing set.
- Blocker E: projection and mirror drift blocked by validator and blocker-ledger generation.
