# Traceability Map

Audit-aligned chain: every in-scope source finding maps to remediation,
acceptance criterion, validation, and closure proof. Deferred findings carry
owner and rationale (recorded in `proposal.yml#findings_deferred`).

| Source finding | Evidence anchor | Remediation artifact | Implementation action (post-acceptance) | Acceptance criterion | Validation | Closure condition |
| --- | --- | --- | --- | --- | --- | --- |
| F-01 stale-bundle bypass (`OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE`) | findings.yml F-01; execution.rs:68; core/config.rs:11; kernel mod.rs:1111-1114 | decision-options.md row 1; target-architecture.md §2 | Convert to explicit receipted publication input | acceptance-criteria row 1 + criteria 3 | Bypass removal/replacement proof + publication receipt linkage (validation-plan §3) | Ambient variable no longer read by authority paths; receipt chain retained |
| F-01 policy-mode overrides (`OCTON_POLICY_MODE_OVERRIDE`, `OCTON_EFFECTIVE_POLICY_MODE`) | findings.yml F-01; api.rs:734-735; policy_engine lib.rs:969; policy-interface-v1.md:308-309 | decision-options.md rows 2-3; target-architecture.md §4 | Remove; explicit invocation input | acceptance-criteria rows 2-3 + criterion 2 | Policy-mode override behavior proof (validation-plan §4) | No ambient policy-mode read; protected-mode invariance proven |
| F-01 execution role/intent overrides | findings.yml F-01; api.rs:720; active_intent_ref | decision-options.md rows 4-5; target-architecture.md §3 | Convert to explicit request/config fields | acceptance-criteria rows 4-5 | Invariance negative control (validation-plan §2) | Role/intent sourced only from governed inputs |
| F-01 missing inventory/negative control | findings.yml F-01; validator-depth-matrix.yml (env-override dimension: none/none) | target-architecture.md §§1,6,7 | Author env-input contract + FCR candidate + invariance validator | acceptance-criteria criteria 1, 4, 8 | Inventory check + protected-mode negative control (validation-plan §§1-2) | Validator green in assurance plane; boundary gap closed |
| F-01 operational-flexibility / self-governance risk of removal (bootstrap, recovery, dev/test ergonomics) | decision-options.md Option B costs analysis; kernel mod.rs:1111-1114 (bootstrap need) | operational-flexibility-and-migration.md §§1-3 (governance hierarchy); target-architecture.md replacement table with tier column | Build tier-1/tier-2 system-governed replacements before removal (migration phase 3); deprecation warnings before enforcement | acceptance-criteria criteria 3, 4, 4c, 4d + governance-tier table | Self-governed bootstrap positive/negative proofs, messaging check, break-glass boundary proof, self-governance regression check (validation-plan §§3, 7, 9a, 9b) | Bootstrap works with no human step while preconditions hold; break-glass reserved to rank-1 directives for true override only; no routine operation gains human approval; migration phases complete with rollback conditions unused |
| F-02 `stage_only_behavior` undocumented | findings.yml F-02; policy_engine lib.rs:195 | target-architecture.md §5 | Document in policy-interface-v1.md | acceptance-criteria row 6 + criterion 5 | Documentation check (validation-plan §5) | Field documented with variants, default, failure behavior |
| F-03 immutable:// store contract | findings.yml F-03 | **deferred** — evidence-retention domain | n/a | n/a | n/a | Deferral recorded with owner (proposal.yml) |
| F-05 spec directory index | findings.yml F-05 | **deferred** — delegable maintenance | n/a | n/a | n/a | Deferral recorded with owner (proposal.yml) |

Closure target: zero unresolved in-scope findings (F-01, F-02); deferrals are
explicit, owned, and outside scope by recorded rationale.

Post-acceptance gate: per the review-continuation decision
(`make-targeted-gates`), a targeted Prompt 4 Architecture Readiness Audit
(not yet run) gates implementation planning for this packet — see
`architecture/implementation-plan.md` precondition 3, its "Prompt 4 Gate
Result Handling" section (disposition required: proceed / revise / defer /
escalate / rerun), and acceptance criterion 7.
