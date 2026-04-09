# Disclosure Delta Examples

These examples are **illustrative patches**, not mandatory exact syntax.

## 1. HarnessCard known-limits calibration

```yaml
# instance/governance/disclosure/HarnessCard.yml
known_limits:
  - "The attainment claim is bounded to the admitted live support universe only; no universal support claim is made outside active support-target tuples."
  - "Deterministic authored-lab ↔ dossier ↔ admission ↔ proof reference integrity is a required hardening item for the next recertified release."
  - "Host adapters are non-authoritative by contract; release CI continues to harden projection-purity guarantees so labels/comments/checks cannot mint authority."
  - "Residual persona/identity overlays remain non-authoritative and are subject to continued simplification and retirement review."
  - "Evaluator diversity and hidden-check breadth remain bounded to the currently admitted adapter and scenario set."
```

## 2. Hardening delta artifact

```yaml
# state/evidence/disclosure/releases/<release>/closure/hardening-delta.yml
schema_version: octon-hardening-delta-v1
release_id: 2026-05-xx-uec-hardening-recert
support_scope_change: none

closed_claim_critical_items:
  - CC-01
  - CC-02
  - CC-03
  - CC-04
  - CC-05

open_claim_strengthening_items:
  - CS-01
  - CS-02

retained_transitional_surfaces:
  - surface: "/.octon/instance/ingress/AGENTS.md"
    status: demoted
    rationale: "Still useful as a stable user-facing ingress adapter while canonical surface map adoption matures."
    next_review_due: 2026-06-15

recertification_blockers: []
notes:
  - "All claim-critical hardening findings are closed for the admitted support universe."
```

## 3. Lab reference integrity report

```yaml
# state/evidence/disclosure/releases/<release>/closure/lab-reference-integrity-report.yml
schema_version: octon-lab-reference-integrity-v1
release_id: 2026-05-xx-uec-hardening-recert
status: pass
summary:
  authored_scenarios_checked: 24
  dossier_refs_checked: 24
  admission_refs_checked: 24
  proof_refs_checked: 48
  unresolved_refs: 0
violations: []
generated_at: 2026-05-xxT12:00:00Z
```

## 4. Runtime family depth report

```yaml
# state/evidence/disclosure/releases/<release>/closure/runtime-family-depth-report.yml
schema_version: octon-runtime-family-depth-v1
release_id: 2026-05-xx-uec-hardening-recert
status: pass
families:
  stage_attempts:
    schema_validated: true
    disclosure_backed: true
  checkpoints:
    schema_validated: true
    disclosure_backed: true
  continuity:
    schema_validated: true
    disclosure_backed: true
  contamination:
    schema_validated: true
    disclosure_backed: true
  retries:
    schema_validated: true
    disclosure_backed: true
```

## 5. Release-lineage entry for hardened successor

```yaml
# instance/governance/disclosure/release-lineage.yml (illustrative entry)
- release_id: 2026-05-xx-uec-hardening-recert
  status: active
  supersedes: 2026-04-08-uec-full-attainment-cutover
  claim_mode: global-complete-finite
  support_scope_change: none
  harness_card_ref: "state/evidence/disclosure/releases/2026-05-xx-uec-hardening-recert/harness-card.yml"
  closure_ref: "state/evidence/disclosure/releases/2026-05-xx-uec-hardening-recert/closure/unified-execution-constitution.yml"
  hardening_delta_ref: "state/evidence/disclosure/releases/2026-05-xx-uec-hardening-recert/closure/hardening-delta.yml"
```
