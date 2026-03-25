# Final Remediation Ledger

This ledger translates the remediation list in the [implementation audit](./implementation-audit.md) into the final closeout actions for this packet.

| Audit issue | Final corrective action | Primary files | Exit signal |
|---|---|---|---|
| Mission lifecycle not clearly atomic | Adopt seed-before-active as the only valid lifecycle for autonomous missions | mission scaffold, activation/seed scripts, lifecycle validator, bootstrap docs | active missions fail validation unless seed-complete |
| Forward intent not yet proven universal | Require fresh current intent + action slice for material autonomy | evaluator, kernel/policy engine, intent validator, scenario suite | material autonomy from empty/stale intent fails closed |
| Control evidence not broad enough | Emit receipts for all control mutations and transitions | directive/update writers, receipt writer, evidence validator | every listed mutation type has receipts and validator coverage |
| Burn/breaker automation under-proven | Add recompute reducer and transition receipts | reducer script, evaluator, evidence validator, scenario suite | burn and breaker transitions are evidence-derived and CI-proven |
| Scenario precedence not explicit enough | Add route provenance and normalization checks | mission-autonomy policy, route publisher, route validator | route shows family/boundary/recovery source and no generic fallback for material work |
| Generated views not obviously universal | Require summaries, digests, and mission view for every active autonomous mission | artifact sync, generators, generated-view validator | all active autonomous missions have required generated outputs |
| Last docs/runtime ambiguity | Update docs and architecture surfaces to match lifecycle and validators exactly | `.octon/README.md`, architecture spec, runtime-vs-ops contract | no canonical doc claims unsupported behavior |
| Last CI blind spots | Add lifecycle, route normalization, intent invariants, and mission-view checks to blocking workflow | assurance scripts, architecture-conformance workflow | CI blocks merge on any MSRAOM invariant failure |
