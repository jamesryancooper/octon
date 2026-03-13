# Methodology Alignment Audit

You are a read-only governance auditor for the Octon repository.

Objective:
Audit methodology artifacts in `.octon/cognition/practices/methodology/` and decide, with evidence, both:

1) artifact-level action, and
2) content-within-artifact action (section/block-level),
including whether to keep, prune, remediate, move/merge, or remove.

Scope:

- In scope: `.octon/cognition/practices/methodology/**`
- Out of scope: file edits, code changes, policy rewrites
- Mode: read-only audit with actionable recommendations

Authoritative baseline (read first, in order):

1) `AGENTS.md`
2) `.octon/cognition/governance/principles/principles.md` (mandatory baseline)
3) `.octon/agency/governance/CONSTITUTION.md`
4) `.octon/agency/governance/DELEGATION.md`
5) `.octon/agency/governance/MEMORY.md`
6) `.octon/agency/runtime/agents/architect/AGENT.md`
7) `.octon/agency/runtime/agents/architect/SOUL.md`
8) `.octon/cognition/practices/index.yml`
9) `.octon/cognition/practices/methodology/index.yml`
10) `.octon/cognition/practices/methodology/methodology-as-code.md`
11) `version.txt` (derive `release_state`)

Unit of analysis (mandatory):

- Artifact level: each file under methodology.
- Content-unit level: each top-level heading section plus any normative table/checklist/rule block within that file.

Evaluation criteria (apply to every artifact and content-unit):

1) Principles alignment (objective, principles, direction).
2) Canonical governance alignment.
3) Internal consistency (cross-artifact and intra-artifact).
4) Practical executability (clear, testable, operational guidance).
5) Structural/index/reference integrity.
6) Profile-governance compatibility (`change_profile`, `release_state`, required receipts).
7) Placement fitness (best location, duplication, ownership, relocation need).

Allowed actions:

- Content-unit actions: `keep`, `prune`, `remediate`, `move_or_merge`, `remove`
- Artifact actions: `keep`, `prune`, `remediate`, `move_or_merge`, `remove`

Per-content-unit remove-vs-remediate rule (strict):
Set `unit_remove_candidate = true` only if all are true:
A) Unit conflicts with canonical contracts/principles in multiple critical ways.
B) Unit is materially broken/contradictory/invalid (not minor).
C) Unit is unsalvageable without near-total rewrite.
D) Keeping unit would preserve contradictory governance after reasonable remediation.
E) Removing (or relocating then removing) unit is lower risk than remediating.
If any gate fails, do not remove that unit.

Per-artifact action roll-up (derived from content-unit outcomes):

- `remove` only if every unit is `remove` or `move_or_merge` with preservation plan.
- `prune` if file has mixed `keep` + `remove` units and core remains valid.
- `remediate` if issues are fixable in place and no unit requires removal.
- `move_or_merge` if most durable value belongs elsewhere.
- `keep` if all units are aligned and executable.

Global roll-up:

- `recommended_action = remove_all` only if every artifact is `remove` or `move_or_merge` with complete preservation plan.
- `recommended_action = partial_prune` for mixed outcomes.
- `recommended_action = remediate_in_place` if no artifact is remove/move.
- `completely_out_of_alignment = true` only when `recommended_action = remove_all`.

Case-handling requirements (must be explicit for every non-keep action):

- `prune`: specify exact sections/blocks to delete and why; list required link/index cleanup.
- `remediate`: specify exact sections/blocks to rewrite; define intended corrected behavior.
- `move_or_merge`: specify source sections, destination path, move type (`move|merge|summarize-and-link`), and source cleanup plan.
- `remove`: prove no unique value is lost, or relocation completed first; list downstream cleanup required.

Required per-artifact outputs:

- `status`: `Aligned | Partially Aligned | Misaligned`
- `artifact_action`: `keep | prune | remediate | move_or_merge | remove`
- `salvageability`: `high | medium | low`
- `evidence`: path + heading/line/excerpt refs
- `gaps`
- `recommended_changes`
- `relocation_assessment`
- `gate_results(A-E)` summary

Required per-content-unit outputs:

- `unit_id` (file + heading/block identifier)
- `status`
- `unit_action`
- `evidence`
- `gaps/conflicts`
- `recommended_change`
- `destination` (if moved)
- `gate_results(A-E)`
- `unit_remove_candidate: true|false`

Output persistence requirements (mandatory):

- Write outputs to `.proposals/methodology-alignment/`.
- Create/overwrite the following files:
  - `INDEX.md`
  - `overall-verdict.md`
  - `principles-alignment-summary.md`
  - `evidence-summary.md`
  - `artifact-audit-matrix.csv`
  - `content-unit-decision-matrix.csv`
  - `relocation-preservation-plan.csv`
  - `comprehensive-remediation-list.md`
  - `removal-prune-impact-analysis.md`
  - `gaps-and-unknowns.md`
  - `explicit-no-issue-confirmation.md`
  - `compliance-receipt.md`
  - `audit-report.json`
- Keep terminal/chat response minimal: return only file write confirmation, key verdict, and paths.

File formats:

- `artifact-audit-matrix.csv` columns:
  `file,status,artifact_action,salvageability,gate_A,gate_B,gate_C,gate_D,gate_E,evidence_refs,key_gaps,recommended_changes`
- `content-unit-decision-matrix.csv` columns:
  `unit_id,status,unit_action,unit_remove_candidate,gate_A,gate_B,gate_C,gate_D,gate_E,evidence_refs,gap_or_conflict,recommended_change,destination`
- `relocation-preservation-plan.csv` columns:
  `source_unit,destination_path,move_type,rationale,cleanup_required,priority`
- `audit-report.json` must include:
  `release_state,completely_out_of_alignment,recommended_action,confidence,no_issues_found,artifact_counts,unit_action_counts`

Constraints:

- Do not edit methodology files as part of the audit.
- Do not rely on unstated assumptions.
- Every critical claim must cite file-path evidence.
- Prefer remediation when evidence is mixed/uncertain.
