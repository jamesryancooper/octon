# Traceability Map

Every source requirement (from the child charter and method-taxonomy §§3–6) maps
to a packet artifact, an implementation action, a validation check, an acceptance
criterion, and a closure condition.

| # | Source requirement | Implementation action | Validation | Acceptance | Closure |
| --- | --- | --- | --- | --- | --- |
| R1 | Author Tradeoff method doc (§3) | create `tradeoff-review-method.md` (shared shape) | consistency check §1; naming regression | AC-1, AC-5, AC-6 | doc present + consistent |
| R2 | Author Failure-Mode method doc (§4) | create `failure-mode-review-method.md` | consistency check §1 | AC-2, AC-5, AC-6 | doc present + consistent |
| R3 | Author Evolution/Fitness method doc (§5) | create `evolution-fitness-review-method.md` | consistency check §1 | AC-3, AC-5, AC-6 | doc present + consistent |
| R4 | Author Boundary/Authority method doc (§6) | create `boundary-authority-review-method.md` | consistency check §1 | AC-4, AC-5, AC-6, AC-9 | doc present + consistent |
| R5 | One shared contract shape across all four | apply the 8-part shape from `target-architecture.md` | consistency check §1 (shape assertions) | AC-1..AC-4 | uniform shape verified |
| R6 | Lenses from the shared bank only; no private catalog | cite `lens-bank.yml` `method_profiles.<slug>`; list exact required/optional | consistency check §1.4–1.6; lens-references validator | AC-6 | lens sets match verbatim |
| R7 | Failure-Mode vs readiness failure-mode boundary | add boundary statement citing `architecture-readiness/framework.md` "## Mandatory Failure-Mode Analysis" | consistency check §1.9 | AC-8 | boundary present |
| R8 | Boundary/Authority vs surface-audit single-unit classification | add boundary statement citing `.../methodology/audits/surface-architecture.md` "## Authority Model Classification" | consistency check §1.9 | AC-9 | boundary present |
| R9 | Boundary/Authority Octon-only in v1 | state Octon-only, generic mode deferred | consistency check §1.9 | AC-9 | statement present |
| R10 | Non-authority output boundary (fail-closed) per method | add Output Boundary section to each doc | consistency check §1.8 | AC-10 | invariant present |
| R11 | Escalation cites routing, not new authority | Escalation Rules cite `review-routing.yml` `method_selection` | consistency check §1.7; routing regression | AC-11 | escalation targets valid |
| R12 | Discoverability: naming `doc:` pointer + README links | add 4 `doc:` pointers to `naming.yml`; 4 links to `README.md` | consistency check §1.3; naming regression | AC-5, AC-7 | pointers/links resolve |
| R13 | Balanced remains default; no new mechanism/mode/gate/schema/facade | change nothing but the four docs + additive wiring | naming/routing regression; file-change-map guardrails | AC-10 | invariants hold |
| R14 | Methodology-docs child ⇒ doc-consistency check (obligation 4) | define + run the §1 check | `validation-plan.md` §1 | AC-11 | check passes for all 4 |
| R15 | Independent validity + child-owned evidence (obligations 1–2) | full packet at sibling path; evidence root outside packet | `validate-proposal-standard.sh --skip-registry-check` | AC-12 | packet valid; evidence retained |
| R16 | Write-scope discipline (obligation 7) | confine all writes to `architectural-review/` | drift/churn gate; `git` diff review | AC-10 | diff confined |
| R17 | Source⇄repo reconciliations (obligation 3) | use naming.yml slugs and live audit paths | current-state-gap-map §Reconciliations | AC-5 | no stale claim implemented |

No source finding is dropped. Two source elements are explicitly delegated, not
implemented here, and are recorded as such:

- Report/routing-decision schema `method`/`lenses_applied` fields → owned by
  `architectural-review-schema-extensions`.
- Method-id recording in run evidence + advisory lifecycle text + generated
  refresh → owned by `architectural-review-suite-integration`.
