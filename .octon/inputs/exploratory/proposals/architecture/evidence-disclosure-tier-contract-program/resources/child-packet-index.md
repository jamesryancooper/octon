# Child Packet Index

_Status: In-review parent-program registry companion_

The YAML registry at `resources/child-packet-index.yml` is the structured
proposal-program registry. This Markdown file is navigation only. Child paths
are canonical sibling locations. Current lifecycle truth remains child-owned;
this table summarizes it without satisfying child receipts or authorizing
parent orchestration.

| Child ID | Status | Required | Phase | Depends On | Purpose |
| --- | --- | --- | --- | --- | --- |
| `evidence-disclosure-tier-contracts` | implemented; child receipts preserve accepted review evidence | yes | `phase-1` | none | Define the four evidence tiers, allowed roots, Git posture, authority role, and promotion rule. |
| `local-evidence-store-boundary` | accepted, prompt generated | yes | `phase-2` | `evidence-disclosure-tier-contracts` | Establish the local-only raw evidence root and resolve ignore behavior through `.octon/state/evidence/.gitignore`. |
| `publishable-evidence-receipts` | accepted, prompt generated | yes | `phase-3` | `evidence-disclosure-tier-contracts` | Define concise claim-sufficient publishable receipt contracts and schemas. |
| `disclosure-and-read-model-alignment` | accepted, prompt generated | yes | `phase-3` | `evidence-disclosure-tier-contracts`, `publishable-evidence-receipts` | Align disclosure artifacts and generated read models without making generated outputs authoritative. |
| `evidence-tier-validator-gates` | accepted, prompt generated | yes | `phase-4` | `evidence-disclosure-tier-contracts`, `local-evidence-store-boundary`, `publishable-evidence-receipts`, `disclosure-and-read-model-alignment` | Enforce tier metadata, local-only tracking denial, publishable evidence concision, and hosted closeout boundaries. |
| `closeout-repo-hygiene-evidence-flow` | accepted, prompt generated | yes | `phase-5` | `local-evidence-store-boundary`, `publishable-evidence-receipts`, `evidence-tier-validator-gates` | Update closeout and repo-hygiene flows so raw logs remain local and hosted/shared closeout uses publishable receipts. |
| `evidence-residue-migration-closeout` | accepted, prompt generated | yes | `phase-6` | `closeout-repo-hygiene-evidence-flow`, `evidence-tier-validator-gates` | Migrate, archive, replace, or explicitly retain existing evidence residue after the new boundaries are validated. |

No child packet directory may be nested under this parent. The parent
coordinates sequence only and does not own child lifecycle truth. Parent
implementation orchestration remains gated by a fresh accepted parent review
and live child-readiness validation.
