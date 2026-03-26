# Final Remediation Ledger

This ledger maps every currently identified unresolved issue to one concrete
remediation with no deferrals.

| Issue | Final fix | Canonical surfaces touched | Enforcement |
| --- | --- | --- | --- |
| Version surfaces diverge | Bump `version.txt` and `.octon/octon.yml` together and add a blocking version-parity validator | `version.txt`, `.octon/octon.yml`, assurance validation scripts, CI workflow wiring | version-parity validator + CI |
| Mission scaffold does not create full control family | Update scaffold and/or create-mission workflow to create and seed the complete control + continuity family automatically | `instance/orchestration/missions/**`, `state/control/execution/missions/**`, `state/continuity/repo/missions/**` | scaffold validator + source-of-truth validator |
| Interaction grammar is only partly realized | Add `authorize-updates.yml` and `authorize-update-v1.schema.json`; wire handlers and receipts | `state/control/execution/missions/**`, `framework/orchestration/runtime/**`, `framework/engine/runtime/spec/**`, `state/evidence/control/execution/**` | runtime-contract validator + scenario suite |
| Route linkage is not hard invariant | Make `mode-state.effective_scenario_resolution_ref` required and refreshed on every relevant mutation | `state/control/execution/missions/**`, `generated/effective/**`, runtime evaluators | runtime-effective-state validator |
| Empty intent register can still coexist with material autonomy semantics | Require current intent + current slice for material autonomous work | runtime, evaluator, intent register, summaries | runtime-effective-state validator + scenario suite |
| Recovery can degrade to generic fallback semantics | Derive recovery from slice + policy only; else tighten to `STAGE_ONLY`, `SAFE`, or `DENY` | route generator, policy engine, evaluator, receipts | scenario suite + receipt validator |
| Safe-boundary taxonomy drift | Normalize mission/action-family to one boundary taxonomy and validate route output | mission-autonomy policy, route generator, action-slice contract | route validator + scenario suite |
| Breaker vocabulary mismatch / weak automation | Normalize breaker vocabulary and emit recomputed budget/breaker receipts | control contracts, runtime update path, control evidence | runtime-contract validator + evidence validator |
| Control mutation evidence too narrow | Emit control receipts for directives, authorize-updates, schedule changes, burn/breaker transitions, safing, break-glass, and finalize controls | `state/evidence/control/execution/**`, runtime mutation handlers | evidence-coverage validator |
| Mission/operator views are not clearly generalized | Generate summary set, operator digests, and mission-view for every active mission on all relevant triggers | `generated/cognition/**`, summary generators, projection generators | generated-view validator |
| Mission projection root is declared but underused | Materialize `mission-view.yml` per active mission and register contract | `generated/cognition/projections/materialized/missions/**` | generated-view validator |
| CI does not clearly run all required gates | Extend or split workflows so all validators and scenario tests are blocking | `.github/workflows/**`, assurance scripts | branch protection + CI |
| Remaining proposal/debt ambiguity | Write decision + migration evidence, archive prior completion-cutover, archive this packet after merge | `instance/cognition/decisions/**`, `instance/cognition/context/shared/migrations/**`, `inputs/exploratory/proposals/**` | release checklist |

## No Deferred Items

There is intentionally no “phase 2” column in this ledger.

Every issue above is part of the one atomic merge set.
