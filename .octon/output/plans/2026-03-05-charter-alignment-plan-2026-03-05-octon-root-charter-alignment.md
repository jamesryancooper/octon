# Charter Alignment Plan

- Run ID: `2026-03-05-octon-root-charter-alignment`
- Skill: `plan-charter-alignment`
- Charter Path: `.octon/CHARTER.md`
- Findings Source: `.octon/output/reports/analysis/2026-03-05-charter-audit-2026-03-05-octon-root-charter.md`
- Target Score: `95`
- Requested Scope: `charter-only`
- Planning Mode: `read-only`

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `stable`
- `release_state_evidence`: charter metadata version `1.2.1` in `.octon/CHARTER.md:6`
- `selection_mode`: `auto`
- `recommended_atomic_mode`: `Clean Break`
- `profile_facts`:
  - `downtime_tolerance`: one-step charter cutover is acceptable because the planned work is limited to charter text clarification and no live runtime migration or data cutover is planned.
  - `external_consumer_coordination_ability`: one coordinated PR-based update is sufficient for the charter itself; no temporary dual-charter state is required.
  - `data_migration_backfill_needs`: none for the charter-only plan.
  - `rollback_mechanism`: revert the single charter change set and rerun the charter audit.
  - `blast_radius_and_uncertainty`: moderate governance wording impact, but bounded to one charter file and associated same-change metadata updates.
  - `compliance_policy_constraints`: charter change control in `§14` remains mandatory; `/.octon/cognition/governance/principles/principles.md` is protected and out of scope.
- `hard_gate_evaluation`:
  - `zero_downtime_requirement_prevents_one_step_cutover`: `false`
  - `external_consumers_cannot_migrate_in_one_coordinated_release`: `false`
  - `live_migration_backfill_requires_temporary_coexistence`: `false`
  - `operational_risk_requires_progressive_exposure_and_staged_validation`: `false`
- `rationale`: The findings describe clarity, ownership, and auditability gaps inside a single charter. They do not require temporary coexistence, staged routing behavior, or data backfill. `atomic` is the smallest sufficient profile and preserves deterministic authority.
- `target_outcome`: Raise the charter from `Partially aligned` to a re-auditable state that plausibly achieves `>=95` on the charter-only scorecard without widening implementation scope.

## Implementation Plan

### Target Charter Properties

The implementation should leave `.octon/CHARTER.md` with these properties:

1. Objective-contract divergence is defined by explicit comparison criteria and reconciliation evidence.
2. Bootstrap equivalence is deterministic, approvable, and auditable from charter text alone.
3. Success signals are measurable because ownership, evidence artifacts, and target declaration requirements are explicit.
4. Routing-order and recovery-readiness claims are testable from required evidence fields.
5. Owner resolution and change-control terminology no longer depend on external interpretation for routine charter use.

### Change Bundles

| Bundle | Findings covered | Planned charter changes | Acceptance criteria | Validation scenario |
| --- | --- | --- | --- | --- |
| `B1. Objective Contract Integrity` | `G1`, `C3` | In `§9`, define `mutually consistent` and `divergence`; require same-change approval evidence to resolve divergence; expand reconciliation evidence to include changed fields, approving authority, and effective version; normalize or define `material autonomy` if it remains in the text. | A new reader can determine whether the objective brief and intent contract are aligned or divergent without consulting external policy. | Compare two hypothetical objective artifact pairs: one aligned, one divergent. The charter must produce the same routing consequence for both readers. |
| `B2. Bootstrap Equivalence Control` | `G2`, `C2` | In `§10`, replace bare `equivalent assurance entrypoint` language with minimum equivalence criteria, named approval responsibility, and required decision-artifact evidence; tighten the optional alias-file rule so it depends on recorded approval/evidence if triggered by equivalence. | Bootstrap conformance is determinable from charter text, and alternative entrypoints can be audited against a minimum required check set. | Evaluate two bootstrap setups, one with `alignment-check` and one with an alternative. Both must satisfy the same minimum controls or be non-compliant. |
| `B3. Operable Success Signals and Evidence` | `G3`, `G4`, `C1`, `R3`, `R4` | In `§8` and `§13`, add minimum evidence fields for routing-order and rollback or recovery posture; require a measurement owner, evidence artifact, and method for each success signal; require `workspace target` and `support target` declarations in approved conventions before the reporting period when a signal depends on them. | Each success signal can be measured or explicitly marked as a governance gap, and `routing before side effects` can be verified from required evidence. | Walk each success signal table row and identify the owner, evidence location, method, and threshold directly from the charter or explicitly declared workspace slots. |
| `B4. Authority and Change-Control Completion` | `G5`, `G6`, `C4` | In `§6`, `§7`, `§12`, and `§14`, add a deterministic fallback for selecting the `applicable policy owner` when multiple explicit owners could apply; define `affected references` and `standard assurance gates`; optionally require discovery metadata conformance evidence where `§12:328` currently remains partially testable. | Escalation ownership and charter change completeness are determinable without importing external doctrine. | Simulate a conflict involving overlapping domain and workspace authorities and verify that the charter yields a single escalation path. |

### Execution Sequence

1. Apply `B1` first so the objective-contract control path is explicit before any downstream evidence or measurement rules are tightened.
2. Apply `B2` next so bootstrap conformance and equivalence approval become deterministic.
3. Apply `B3` to close the main operability gaps in success signals and evidence-based assertions.
4. Apply `B4` last to tighten fallback authority and change-control completeness after the core control model is stable.
5. Re-run the charter audit and confirm that every former Medium finding is closed or downgraded with explicit rationale.

### Draft Acceptance Thresholds

- No unresolved Medium findings remain in a re-run of `audit-charter` against `.octon/CHARTER.md`.
- `Normative integrity`, `How operational sufficiency`, and `Enforceability/auditability` each score `>=90`.
- `Overall stands on its own score` scores `>=95`.
- No new direct contradictions are introduced.
- All new normative additions remain charter-local and do not require immediate edits to protected principles governance.

### Validation Scenarios

1. **Canonical framing preservation**: confirm that the updated charter still reads as a governed autonomous engineering harness and does not drift into product-runtime or implementation detail.
2. **Objective divergence detection**: test that the charter distinguishes aligned, missing, invalid, and divergent objective artifacts with a unique outcome for each case.
3. **Bootstrap equivalence approval**: verify that an alternative assurance entrypoint is either provably equivalent under the charter or non-compliant.
4. **Routing-order proof**: verify that required evidence fields are sufficient to prove the routing outcome existed before the first material side effect.
5. **Recovery-readiness proof**: verify that required rollback or recovery posture fields make readiness testable before execution.
6. **Success-signal operability**: for each success signal, identify owner, method, evidence artifact, and threshold without importing repo context beyond the slots the charter explicitly allows.
7. **Precedence and owner-resolution conflict**: simulate two plausible owners for one decision and confirm that the charter selects a single escalation path or fail-closed outcome.
8. **Dependency resilience fallback**: remove one normative reference conceptually and verify that the charter still states the safe fallback behavior.
9. **Change-control completeness**: verify that a charter edit checklist can be executed from `§14` without guessing what counts as affected references or standard assurance gates.

## Impact Map (code, tests, docs, contracts)

| Surface | In-scope impact | Planned action | Out of scope for this plan |
| --- | --- | --- | --- |
| `code` | None directly | No code changes are planned. | Validator, schema, or runtime updates that may later be needed to enforce revised charter rules. |
| `tests` | Charter-validation scenarios only | Re-run `audit-charter` and perform the nine validation scenarios above as review checks for the rewritten charter text. | Automated lint or schema tests outside the charter unless separately planned. |
| `docs` | Primary impact on `.octon/CHARTER.md` | Rewrite `§9`, `§10`, `§13`, and `§14`; add smaller clarifications in `§6`, `§7`, and `§12`; update charter metadata in the same change if the charter is revised. | Non-charter documentation refreshes unless required by `affected references` once that term is defined. |
| `contracts` | Charter governance contract only | Tighten normative wording and evidence obligations inside the charter so the control model is self-sufficient. | Machine-readable schema or runtime contract changes unless implementation discovers they are mandatory for correctness. |

### Planned Section Touch Map

- `§6. Authority and Precedence`: owner-resolution fallback for competing explicit owners.
- `§7. Accountability Model`: add any missing flow ownership if success-signal or bootstrap-equivalence decisions remain implicit.
- `§8. Operating Model`: minimum routing-order and rollback or recovery evidence fields.
- `§9. Objective Contract and Boundary Routing`: divergence criteria and reconciliation evidence.
- `§10. Bootstrap Contract`: equivalence criteria and approval path.
- `§12. Surface Model`: optional discovery-metadata evidence clarification if needed to close partial testability.
- `§13. Success Signals`: measurement owner, evidence artifact, method, and target declaration rules.
- `§14. Change Control`: define `affected references` and `standard assurance gates`.
- Charter metadata block: same-change `version` and `effective_date` update when the charter is actually edited.

### Explicit Follow-on Scope

The audit findings do not force immediate expansion beyond the charter file for planning purposes. If implementation later shows that machine-readable schemas, validators, or workspace convention templates must change in the same release to remain truthful to the charter, that is follow-on work and should be planned separately rather than silently absorbed into this plan.

## Compliance Receipt

- `planning_scope`: `charter-only`
- `implementation_status`: `not started`
- `protected_charter_scope`: `/.octon/cognition/governance/principles/principles.md` remains untouched and outside this plan.
- `findings_coverage`:

| Audit finding | Severity | Planned disposition |
| --- | --- | --- |
| `G1` Objective-contract consistency criteria missing | Medium | Address in `B1` |
| `G2` Bootstrap equivalence undefined | Medium | Address in `B2` |
| `G3` Success-signal measurement underdefined | Medium | Address in `B3` |
| `G4` Routing-order and recovery evidence fields missing | Medium | Address in `B3` |
| `G5` Applicable policy owner fallback missing | Low | Address in `B4` |
| `G6` Change-control term definitions missing | Low | Address in `B4` |
| `C1` Success measurement depends on unspecified methods | Medium | Address in `B3` |
| `C2` Bootstrap equivalence conflict | Medium | Address in `B2` |
| `C3` Objective divergence conflict | Medium | Address in `B1` |
| `C4` Multi-owner escalation ambiguity | Low | Address in `B4` |

- `charter_change_control_requirements_to_apply_during_implementation`:
  - Charter `owner` approval is mandatory.
  - Same-change metadata updates are mandatory if the charter text changes.
  - PR-based review and assurance gates remain mandatory.
  - ADR or decision-record linkage remains mandatory for material charter framing changes.
  - Named approver, review date, and evidence links remain mandatory.
- `score_target_assessment`: `95` is justified for a charter-only re-audit if all four bundles are implemented cleanly and no new medium-severity ambiguity is introduced.
- `decision_completeness`: The plan settles the governance decisions needed to rewrite the charter text itself; it does not authorize runtime or schema changes.

## Exceptions/Escalations

### Assumptions

- The charter remains the only artifact being modified in the implementation that follows this plan.
- A single coordinated charter update is acceptable; no dual-publish or staged rollout is required for the charter text.
- The target score applies to a re-run of the charter audit, not to broader systemwide operational conformance.

### Required Escalations If Triggered During Implementation

1. Escalate if implementation reveals that a correct charter rewrite requires direct edits to `/.octon/cognition/governance/principles/principles.md`; that file remains under protected change control.
2. Escalate if owner-resolution fallback cannot be written without contradicting a higher-precedence governance rule.
3. Escalate and re-plan if schema, validator, or runtime contract changes become mandatory for correctness in the same release; that would widen scope beyond `charter-only`.
4. Escalate if a reviewer determines that a proposed owner for success-signal measurement or bootstrap equivalence is not inferable from existing charter concepts.

### No-Change / Deferred Items

- No separate change bundle is planned for purely stylistic edits that do not affect authority, enforceability, or auditability.
- Discovery-metadata clarification in `§12` should be implemented only if the final draft still leaves `§12:328` partially testable after `B1-B3` land.
