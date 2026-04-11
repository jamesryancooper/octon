# 09. Closure certification package

## 9.1 Certification purpose

The certification package defined here is the exact artifact set required to issue a truthfully bounded closure certificate for the packet target state.

## 9.2 Mandatory closure criteria

### Criterion C-01 — zero unresolved claim-critical items in scope
The following must all be closed:

- the latest explicit audit findings via the audit crosswalk;
- proposal-discovered claim-critical mismatches (`M-01`, `M-02`, `M-03`);
- all current claim-critical invariants must remain green.

### Criterion C-02 — packet-scope hardening closures complete
The current retained non-critical hardening items (`CS-01`, `CS-02`, `SR-01`, `SR-02`, `SR-03`, `SR-04`) must all be closed for the packet target state, together with the audit-confirmed contract-version coherence and projection-shell boundary hardening work.

### Criterion C-03 — dual-pass validation clean
Two consecutive validator passes must succeed with no new claim-critical issue.

### Criterion C-04 — evidence-backed admitted-universe sufficiency
Every admitted tuple must have:

- a support dossier,
- required retained runs,
- scenario coverage,
- proof-plane completeness,
- evaluator diversity,
- hidden-check breadth,
- at least one current release representative run,
- and, for consequential tuples, at least one naturalistic current-release representative run plus one non-host-exclusive evaluator path.

### Criterion C-05 — disclosure calibration integrity
No active disclosure artifact may:

- use unsupported universal wording,
- cite stale review packets as current,
- contradict support-targets or coverage ledgers,
- or make broader claims than the admitted live support universe.

### Criterion C-06 — residual discipline
The new residual ledger may contain only:

- future widening blockers, and/or
- explicit out-of-scope future hardening items that do not affect the current bounded certificate.

The six current retained residual items are **not** allowed to remain open in the target state.

## 9.3 Certification artifact list

The closure certificate must be issued together with, or point directly to, the following artifacts:

1. `harness-card.yml`
2. `closure-summary.yml`
3. `closure-certificate.yml`
4. `recertification-status.yml`
5. `support-universe-coverage.yml`
6. `support-universe-evidence-depth-report.yml`
7. `proof-plane-coverage.yml`
8. `evaluator-diversity-report.yml`
9. `hidden-check-breadth-report.yml`
10. `cross-artifact-consistency.yml`
11. `review-packet-freshness-report.yml`
12. `audit-resolution-report.yml`
13. `non-authority-surface-report.yml`
14. `contract-family-normalization-report.yml`
15. `contract-version-coherence-report.yml`
16. `disclosure-calibration-report.yml`
17. `host-authority-purity-report.yml`
18. `projection-shell-boundary-report.yml`
19. `runtime-family-depth-report.yml`
20. `continuity-linkage-report.yml`
21. `retirement-rationale-report.yml`
22. `residual-ledger.yml`

## 9.4 Required certificate statements

The closure certificate must state explicitly:

1. the claim is bounded to the admitted live support universe;
2. the current release does **not** widen support beyond active tuples;
3. all packet-scope claim-critical and retained-hardening items are closed;
4. all retained historical or generated surfaces remain non-authoritative;
5. any future widening requires a separate widening program and fresh recertification.

## 9.5 Exact pass/fail logic

### Pass
Issue the certificate only when all criteria `C-01` through `C-06` are satisfied.

### Fail
Do not issue the certificate if any one of the following is true:

- any audit finding lacks disposition;
- latest review packet is stale;
- active claim wording implies universality;
- any admitted tuple lacks required evidence depth;
- any packet-scope residual remains open;
- pass 1 or pass 2 fails.

## 9.6 Effect of certification

Certification authorizes only one present-tense statement:

> **Octon materially substantiates a fully hardened, normalized, evidence-backed Unified Execution Constitution for the admitted live support universe.**

It does **not** authorize broader language.
