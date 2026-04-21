# Target-State Gap Analysis

## Gap severity legend

- **Critical**: target-state impossible or unsafe without correction.
- **High**: target-state claims lack proof or enforcement.
- **Medium**: target-state usability/maintainability reduced.
- **Low**: cleanup or refinement.

| Gap | Severity | Why it matters | Required closure |
|---|---:|---|---|
| Duplicate fail-closed/evidence obligation IDs | Critical | Reason-code and evidence traceability can be ambiguous. | Unique ID validators and renumbering. |
| Unproven side-effect coverage | High | Governed runtime claim depends on complete mediation. | Side-effect inventory and coverage validator. |
| Runtime module concentration | High | Auditing and change containment suffer. | Command/request/phase modularization. |
| Proof-plane completeness not enforced | High | Evidence can exist without proving closure. | Completeness receipts and proof-bundle validator. |
| Support dossier sufficiency too low for mature claims | High | Live support claims need stronger retained proof. | Raise dossier thresholds and add negative controls. |
| Generated/effective freshness not negative-tested | High | Runtime might trust stale projections. | Publication/freshness validator and tests. |
| Compatibility projections unmanaged | Medium-high | Transitional shims can become parallel architecture. | Owner/consumer/expiry and retirement validation. |
| Active-doc transitional residue | Medium | Agents/operators may follow stale paths. | Active-doc hygiene validator and doc cleanup. |
| Registry navigation opacity | Medium | Correctness becomes hard to use. | Generated maps from registry. |
| Skill projection inconsistency | Medium | Host adapter semantics may be confused. | Single generated-routing projection model. |
