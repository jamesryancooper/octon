# Concept Coverage Matrix

| Concept | Current repo evidence | Coverage status | Gap type | Proposed motion | Final disposition |
| --- | --- | --- | --- | --- | --- |
| Stewardship Program | No live stewardship program surface found; mission surfaces exist. | not_currently_present | greenfield_only | Add framework contract, instance authority, control/evidence/continuity roots, CLI/runtime handlers. | adopt |
| Stewardship Epoch | Mission leases/budgets/breakers exist but no stewardship epoch. | partially_covered | extension_needed | Add finite epoch object that wraps program-level recurring windows and hands off to v2 missions. | adopt |
| Stewardship Trigger | Watcher/automation ideas exist elsewhere, but no stewardship trigger contract. | partially_covered | extension_needed | Add normalized trigger contract and admission path. | adopt |
| Stewardship Admission Decision | No stewardship admission decision surface. | not_currently_present | greenfield_only | Add control/evidence decision artifact before mission creation. | adopt |
| Idle Decision | Existing pause/close concepts do not encode no-admissible-work as success. | not_currently_present | greenfield_only | Add explicit idle outcome under admission and renewal decisions. | adopt |
| Renewal Decision | Mission leases expire, but no epoch renewal semantics. | partially_covered | extension_needed | Add renewal decision contract and closeout requirements. | adopt |
| Stewardship Ledger | Mission/run ledgers assumed in v2; no stewardship rollup. | not_currently_present | greenfield_only | Add stewardship ledger that indexes epochs, triggers, missions, optional campaigns, and decisions. | adopt |
| Stewardship Evidence Profile | Evidence profiles assumed in v1/v2, but no stewardship profile. | partially_covered | extension_needed | Add stewardship-level evidence profile mapping trigger/admission/renewal/closeout proof. | adopt |
| Stewardship-Aware Decision Request | v1/v2 Decision Requests assumed; no stewardship blocking semantics. | partially_covered | extension_needed | Extend Decision Requests to program/epoch/trigger/renewal/campaign gates. | adapt |
| Optional Campaign Coordination Hook | Campaign criteria exist and campaigns remain deferred. | partially_covered | overlap_existing_surface | Preserve campaign no-go default; add only hooks to evaluate promotion criteria. | adapt |
