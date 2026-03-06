# Charter Alignment Plan

- Run ID: `2026-03-06-harmony-root-charter-alignment-rerun`
- Skill: `plan-charter-alignment`
- Charter Path: `.harmony/CHARTER.md`
- Findings Source: `.harmony/output/reports/2026-03-06-charter-audit-2026-03-06-harmony-root-charter-rerun.md`
- Target Score: `95`
- Requested Scope: `charter-only`
- Planning Mode: `read-only`

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `stable`
- `release_state_evidence`: charter metadata version `1.3.0` in `.harmony/CHARTER.md:6`
- `selection_mode`: `auto`
- `recommended_atomic_mode`: `Clean Break`
- `profile_facts`:
  - `downtime_tolerance`: one-step charter cutover is acceptable because the planned work is limited to charter text remediation and no live operational migration is required.
  - `external_consumer_coordination_ability`: a single coordinated PR-based release is sufficient for the charter itself; no temporary dual-charter state is needed.
  - `data_migration_backfill_needs`: none, because the plan is charter-only and does not introduce live data conversion.
  - `rollback_mechanism`: revert the charter change set and rerun `audit-charter` against the reverted file.
  - `blast_radius_and_uncertainty`: moderate governance wording impact, but bounded to one charter file plus same-change metadata updates required by `§14`.
  - `compliance_policy_constraints`: charter change control in `§14` remains mandatory; `/.harmony/cognition/governance/principles/principles.md` remains protected and out of scope.
- `hard_gate_evaluation`:
  - `zero_downtime_requirement_prevents_one_step_cutover`: `false`
  - `external_consumers_cannot_migrate_in_one_coordinated_release`: `false`
  - `live_migration_backfill_requires_temporary_coexistence`: `false`
  - `operational_risk_requires_progressive_exposure_and_staged_validation`: `false`
- `rationale`: The findings describe wording, evidence, terminology, and measurement-operability gaps inside a single charter. They do not require staged coexistence, phased migration, or progressive runtime exposure. `atomic` is the smallest robust profile that closes the findings without inventing transitional state.
- `target_outcome`: Raise the charter from `Partially aligned` to a re-auditable, closed-book-operable state that can plausibly score `>=95` without widening implementation beyond the charter file and its required same-change metadata.

## Implementation Plan

### Target Charter Properties

The implementation should leave `.harmony/CHARTER.md` with these properties:

1. Every term used to gate objective divergence, bootstrap validity, routing prerequisites, measurement placement, and same-change approval is defined in-charter.
2. Every material evidence class relied on by the charter has a minimum baseline contract sufficient for closed-book auditability.
3. Every success signal states its scope and can be measured from a named owner, evidence artifact, method, and threshold or target.
4. Core value claims on privacy preservation, append-only continuity, and portability are aligned to explicit charter measurement hooks rather than remaining aspirational only.
5. Accountability coverage is complete for materiality classification, bootstrap equivalence, and equivalent governance review selection.

### Change Bundles

| Bundle | Findings covered | Planned charter changes | Acceptance criteria | Validation scenario |
| --- | --- | --- | --- | --- |
| `B1. Terminology and Definition Closure` | `G1`, `G6` | In `§4`, add explicit definitions for `same-change approval evidence`, `approved workspace conventions`, `routing prerequisites`, and `alignment-check`; refine `divergence` to require linked same-change approval evidence; extend `measurement record` to include scope and artifact linkage. | A closed-book reader can resolve every undefined governance term used by `§9`, `§10`, and `§13` without consulting other documents. | Read `§4`, `§9`, `§10`, and `§13` in isolation and verify that each gating term used in a normative clause is defined once and used consistently. |
| `B2. Evidence Contract and Accountability Completion` | `G2`, `G5`, `C3`, `C4` | In `§7`, add explicit flows for pre-run materiality classification and equivalent governance review selection; in `§8`, add a minimum evidence contract for decision, execution, assurance, continuity, and measurement artifacts, including shared run identifier, artifact type, producing actor, sequence or time marker, linked intent reference, and related evidence links; in `§9`, require reconciliation evidence, linked approval evidence, and blocked-state evidence fields to use that baseline contract. | The charter explicitly assigns decision, execution, and escalation ownership for every flow it depends on, and the evidence needed to prove routing and reconstruction is normalized. | Simulate one material run, one blocked run, and one charter-review substitution. The charter must identify owners and required evidence for each without guesswork. |
| `B3. Success Signal Normalization and Core Claim Alignment` | `G3`, `G4`, `C1`, `C2` | Rewrite the `§13` opening rule so each success signal declares its scope as per-material-run, per-material-change, or per-reporting-period; require each measurement record to include owner, evidence artifact, method, scope, and any required target; preserve the existing eight signals and add explicit `Privacy preservation`, `Continuity integrity`, and `Tool and vendor portability` signals with corresponding measurement rules; update the relevant `§3` framing language only if needed to keep the claims and signal set fully aligned. | Every success signal has one unambiguous audit scope and a measurable control path, and the charter's highest-level promises are matched by explicit success-signal hooks. | Walk the signal table row by row and confirm that two independent readers assign the same scope, owner, evidence artifact, method, and pass or fail condition. |
| `B4. Bootstrap and Dependency Fallback Precision` | `G6`, `C3` | In `§10`, define the minimum behavior of `alignment-check` and the equivalence criteria for an alternative assurance entrypoint; in `§14`, make charter-owner approval explicit for any equivalent governance review used in place of the audit or review baseline; in `§15`, clarify safe fallback text for missing higher-precedence governance during bootstrap, missing intent schema, missing delegation-boundaries support, and the limited dependency role of protected principles for non-governance edits. | Bootstrap equivalence and dependency fallback behavior are fully stated in-charter, and the equivalent-review path does not rely on implied owners. | Evaluate one default bootstrap path, one alternative entrypoint, and one missing-reference scenario. The charter must yield a single compliant outcome for each case. |

### Execution Sequence

1. Apply `B1` first so every later rewrite can rely on stable in-charter terminology.
2. Apply `B2` next so the shared evidence contract and missing accountability flows are established before signal measurement rules depend on them.
3. Apply `B3` after the evidence contract lands, because the signal table should reference normalized artifact and scope language rather than invent it locally.
4. Apply `B4` last to tighten bootstrap equivalence and dependency fallback text using the now-stable terminology and ownership model.
5. Update charter metadata in the same change if the charter text is revised, then rerun `audit-charter` against the new file.

### Draft Acceptance Thresholds

- No unresolved Medium gaps remain in a re-run of `audit-charter` against `.harmony/CHARTER.md`.
- No unresolved Medium conflicts remain in the contradiction or conflict log.
- `Normative integrity`, `How operational sufficiency`, and `Enforceability/auditability` each score `>=90`.
- `Overall stands on its own score` scores `>=95`.
- No new direct contradictions are introduced.
- No implementation step requires immediate edits to `/.harmony/cognition/governance/principles/principles.md`.

### Validation Scenarios

1. **Canonical framing preservation**: the rewritten charter still reads as a governed autonomous engineering harness rather than drifting into product-runtime design guidance.
2. **Definition closure**: every newly used governance term in `§9`, `§10`, `§13`, `§14`, and `§15` resolves to a single in-charter definition.
3. **Objective divergence detection**: aligned, missing, invalid, and divergent objective artifacts produce distinct outcomes from the charter text alone.
4. **Evidence-baseline proof**: a reviewer can verify routing order, blocked-state evidence, rollback or recovery posture, and traceability using only the required artifact fields.
5. **Materiality and owner-resolution conflict**: one borderline operation and one competing-owner decision both produce a single escalation path without importing repo context.
6. **Success-signal operability**: every success signal yields the same scope and measurement method for two independent readers.
7. **Core-claim alignment**: privacy, append-only continuity, and broad portability claims each map to an explicit signal and measurement rule.
8. **Bootstrap equivalence approval**: an alternative assurance entrypoint is compliant only when it satisfies the stated minimum checks and approval evidence.
9. **Dependency resilience fallback**: removing one normative reference conceptually still leaves the charter with a safe fallback result.
10. **Change-control completeness**: a charter editor can execute `§14` without guessing what counts as an affected reference, an equivalent governance review, or standard assurance gates.

## Impact Map (code, tests, docs, contracts)

| Surface | In-scope impact | Planned action | Out of scope for this plan |
| --- | --- | --- | --- |
| `code` | None directly | No code or runtime changes are planned. | Validator, schema, or automation changes that may later be needed to enforce the revised charter text. |
| `tests` | Charter-validation scenarios only | Re-run `audit-charter` and execute the ten validation scenarios above as review checks for the rewritten charter. | Automated runtime or schema tests outside the charter unless separately planned. |
| `docs` | Primary impact on `.harmony/CHARTER.md` | Rewrite `§4`, `§7`, `§8`, `§9`, `§10`, `§13`, `§14`, and `§15`; update charter metadata in the same change if the file is edited. | Non-charter documentation refreshes unless required by `affected references` once the revised `§14` defines them precisely. |
| `contracts` | Charter governance contract only | Tighten normative wording, accountability flows, and evidence obligations so the charter becomes self-sufficient under closed-book review. | Machine-readable schema or runtime contract changes unless implementation later proves they are mandatory for correctness. |

### Planned Section Touch Map

- `§4. Definitions`: add and refine the terms needed to close `G1` and `G6`.
- `§7. Accountability Model`: add explicit flows for materiality classification and equivalent governance review selection.
- `§8. Operating Model`: add minimum baseline evidence fields for material runs and material changes.
- `§9. Objective Contract and Boundary Routing`: bind divergence and reconciliation rules to the new evidence terms.
- `§10. Bootstrap Contract`: define `alignment-check` minimum behavior and alternative-entrypoint equivalence criteria.
- `§13. Success Signals`: normalize scope, measurement-record fields, and core-claim signal coverage.
- `§14. Change Control`: make equivalent-review approval and affected-reference expectations explicit.
- `§15. Normative References`: tighten missing-reference fallback text where the audit found ambiguity.
- Charter metadata block: same-change `version` and `effective_date` update when the charter is actually edited.

### Explicit Follow-on Scope

The findings do not require immediate expansion beyond the charter for planning purposes. If implementation later proves that schemas, validators, workspace-conventions templates, or reporting artifacts must change in the same release to keep the charter truthful, that is follow-on scope and must be planned explicitly rather than silently absorbed into this plan.

## Compliance Receipt

- `planning_scope`: `charter-only`
- `implementation_status`: `not started`
- `protected_charter_scope`: `/.harmony/cognition/governance/principles/principles.md` remains untouched and outside this plan.
- `parameter_resolution`:
  - `findings_source`: resolved to the latest matching audit for the same charter because none was provided explicitly.
  - `target_score`: defaulted to `95` from the skill registry because none was provided explicitly.
  - `change_profile`: resolved from `auto` to `atomic`.
  - `release_state`: resolved from `auto` to `stable`.
  - `scope`: defaulted to `charter-only`.
- `findings_coverage`:

| Audit finding | Severity | Planned disposition |
| --- | --- | --- |
| `G1` `same-change approval evidence` undefined | Medium | Address in `B1` and `B2` |
| `G2` baseline evidence-artifact requirements not normalized | Medium | Address in `B2` |
| `G3` success-signal scope mixed across per-run, per-change, and per-period units | Medium | Address in `B3` |
| `G4` privacy, continuity, and broad portability claims exceed current measurement hooks | Medium | Address in `B3` |
| `C1` Section 13 scope conflict | Medium | Address in `B3` |
| `C2` core claims exceed measurement hooks | Medium | Address in `B3` |
| `C4` artifact contract inconsistency risk | Medium | Address in `B2` |
| `G5` materiality classification flow missing from accountability model | Low | Address in `B2` |
| `G6` `alignment-check` and `approved workspace conventions` undefined | Low | Address in `B1` and `B4` |
| `C3` equivalent-review ownership remains implicit | Low | Address in `B2` and `B4` |

- `charter_change_control_requirements_to_apply_during_implementation`:
  - Charter `owner` approval is mandatory.
  - Same-change metadata updates are mandatory if the charter text changes.
  - PR-based review and standard assurance gates remain mandatory.
  - ADR or decision-record linkage remains mandatory for material charter framing changes.
  - Named approver, review date, and evidence links remain mandatory.
- `score_target_assessment`: `95` is justified for a charter-only rerun if all four bundles land as written, all Medium findings close, and no new Medium ambiguity is introduced.
- `decision_completeness`: The plan settles the governance decisions needed to rewrite the charter itself. It does not authorize runtime, schema, or validator changes.

## Exceptions/Escalations

### Assumptions

- The implementation that follows this plan modifies the charter and its mandatory same-change metadata only.
- A single coordinated charter update is acceptable; no staged publication or transitional coexistence is required.
- The post-remediation score target applies to a rerun of `audit-charter`, not to broader systemwide operational conformance.

### Required Escalations If Triggered During Implementation

1. Escalate if a correct charter rewrite requires direct edits to `/.harmony/cognition/governance/principles/principles.md`; that file remains under protected change control.
2. Escalate if a higher-precedence governance source blocks the planned owner-resolution fallback or equivalent-review approval path.
3. Escalate and re-plan if implementation proves that schemas, validators, workspace-conventions templates, or runtime contracts must change in the same release for the charter text to remain truthful.
4. Escalate if the charter owner will not accept adding the new success signals needed to align the privacy, continuity, and portability claims; the score target should then be reduced and re-planned rather than guessed.

### No-Change / Deferred Items

- No separate change bundle is planned for stylistic edits that do not affect authority, enforceability, or auditability.
- No follow-on runtime or schema work is included in this plan unless implementation later proves it is mandatory.
- Non-charter documentation updates are deferred unless the revised `§14` makes them mandatory as affected references in the same change.
