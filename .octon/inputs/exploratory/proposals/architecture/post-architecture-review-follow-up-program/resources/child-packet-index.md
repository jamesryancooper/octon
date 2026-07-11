# Child Packet Index (Human View)

Machine registry: `child-packet-index.yml` (schema
`octon-proposal-program-child-registry-v2`, execution mode `gated-parallel`).
All child packets are **planned sibling packets** at
`.octon/inputs/exploratory/proposals/architecture/<child-id>/` — none exist
yet; none may nest under this parent program.

| Child id | Findings | Phase | Deps | Required | What it owns |
| --- | --- | --- | --- | --- | --- |
| `retirement-register-compatibility-refresh` | F-04 | phase-0 | none | yes (seed reference) | Runs or structures the seven overdue compatibility reviews (`retirement-register.yml` entries dated 2026-06-30) with retained evidence and clear closeout criteria. |
| `runtime-spec-directory-index` | F-05 | phase-0 | none | yes | Adds the missing local index/navigation surface for the 201-file `engine/runtime/spec/` directory without changing runtime authority. |
| `retained-evidence-operability-contract` | F-03, F-06 | phase-0 | none | yes | Defines the operational contract for the `immutable://` external evidence store (authority, backup/recovery, verification) and retention-duration lifecycle enforcement (or an explicit policy-only declaration). **Pre-acceptance evidence gate (not yet run):** targeted Prompt 5 (Domain Architecture Audit) over the evidence-retention domain must produce retained evidence under `state/evidence/validation/architecture/reviews/domain-architecture-audit/<review-id>/` covering F-03, F-06, and F-09 dependency implications; the child may be created before the gate but not accepted until that evidence exists, is cited, **and carries a recorded disposition** (proceed / revise / defer / escalate / no-action — see the registry `result_handling` block and the child contract). |
| `continuity-coherence-validator` | F-07 | phase-1 | none (phase pacing only) | yes | Defines the pre-resumption continuity-coherence validator and its evidence contract before any implementation. |
| `evidence-classification-v2-migration` | F-09 | phase-1 | `retained-evidence-operability-contract` | yes | Plans the evidence-classification v1 (Class A/B/C) to v2 (proof-plane) migration with retained evidence, validation, and rollback criteria; gated on the operability contract so migration follows the retention rules it defines. Must treat the targeted Prompt 5 gate evidence as dependency input and cite it before implementation planning. |
| `historical-runcard-support-audit` | F-08 | phase-2 | none (phase pacing only) | yes | Audits historical RunCard support-tuple references (~1,085 RunCards) and defines remediation criteria — or a frozen-as-of-issuance declaration — if drift is found. |
| `governance-quorum-revisit-trigger` | F-10 | phase-2 | none | **conditional** | Creates a decision/revisit packet only if durable action is justified; otherwise the program records a no-action rationale at closeout. |

Excluded by design: `runtime-environment-override-governance` (F-01/F-02) —
an existing sibling packet with its own lifecycle; it is not a child of this
program and this program must not advance it.

Deferred findings not structured here: none — F-03 through F-10 are all
covered above (F-01/F-02 excluded as owned elsewhere).
