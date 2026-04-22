# Current-State Gap Map

## Summary

Current architecture score: **8.1/10**.
Target-state architecture score: **10/10 only after mechanical proof and closure**.

The current architecture is strong enough to preserve. The remaining gaps are
not a reason to re-found Octon; they are the exact targets for hardening.

| Gap ID | Current limiting factor | Required target-state change | Closure proof |
| --- | --- | --- | --- |
| G10-001 | Authorization boundary is specified and partially implemented, but universal material side-effect coverage is not yet visibly unavoidable. | Expand material-side-effect inventory and coverage map; add runtime tests proving every material path calls `authorize_execution`. | `validate-authorization-boundary-coverage.sh` and negative-control tests pass; retained coverage report exists. |
| G10-002 | Support admissions/dossiers are credible but flat enough that live, stage-only, and non-live surfaces can be misread. | Partition support admissions/dossiers into `live/`, `stage-only/`, `unadmitted/`, `retired/`. | Support matrix generator refuses unpartitioned claim artifacts. |
| G10-003 | Support, pack admission, runtime routing, mission defaults, and disclosure claims are related but not yet sealed as one invariant graph. | Add support-pack-admission alignment contract and validator. | Validator fails on unadmitted pack in live route, stage-only tuple in live claim, missing proof bundle, or active mission non-live default. |
| G10-004 | Generated/effective freshness is declared but needs hard runtime rejection proof. | Add publication freshness gates contract and runtime/validator enforcement. | Stale or receiptless generated/effective output fails with FCR-007/FCR-022 route. |
| G10-005 | Root manifest is correct but overloaded with execution-governance detail. | Keep `octon.yml` as root anchor; move bulky execution policy into referenced contracts while preserving defaults. | Manifest remains small, references versioned contracts, and validators resolve all refs. |
| G10-006 | Ingress manifest mixes boot/orientation with closeout and branch workflow logic. | Split closeout and merge-lane logic into dedicated closeout workflow/policy. | `validate-operator-boot-surface.sh` passes; ingress manifest read path is concise. |
| G10-007 | Pack lifecycle is structurally sound but too manually layered to remain maintainable. | Define canonical pack lifecycle and generate runtime projections from one authored/control source. | Pack registry/admission/projection validator proves no manual drift. |
| G10-008 | Extension active state is strong but metadata-heavy; dependency locks are hard to inspect. | Normalize active dependency locks into grouped, content-addressed manifests. | Extension publication validator proves grouped locks and freshness. |
| G10-009 | Skills/services have useful contracts but some projection-era terminology and multi-file definitions can drift. | Use one canonical manifest per skill/service family plus generated host/runtime projections. | Validator detects obsolete symlink/projection inconsistencies. |
| G10-010 | Proof-plane architecture is well designed but not yet closure-grade for all claims. | Require SupportCards, HarnessCards, RunCards, replay bundles, proof bundles, and negative controls for live claims. | Proof completeness report links each live tuple to retained evidence. |
| G10-011 | Runtime CLI breadth exists, but productized install/doctor/first-run path is not target-state mature. | Add architecture health command, install/build docs, first-run fixture, migration/rollback path. | New operator can execute doctor → run start → inspect → disclose → close. |
| G10-012 | Compatibility shims are mostly labeled but not aggressively retired. | Require every compatibility surface to have owner, successor, review cadence, and retirement trigger. | Compatibility retirement validator blocks ownerless or triggerless shims. |
| G10-013 | Operator read models are useful but target generated maps are not yet sufficient to compress registry complexity. | Generate architecture, authority-flow, support-claim, pack-extension, and authorization-coverage maps from registries. | Maps are generated, traceable, and marked non-authoritative. |
| G10-014 | Mission/run/control-state model is strong, but active mission support posture must not imply non-live support. | Audit mission defaults and support tiers; stage or remove non-live defaults. | Mission runtime validator fails on non-live default without explicit stage-only posture. |
| G10-015 | Architecture conformance is distributed across many validators. | Add `validate-architecture-health.sh` as aggregator and closure gate. | One command reports pass/fail across structural, runtime, support, publication, proof, and retirement gates. |

## Gap severity

- **Structural blockers to 10/10:** G10-001, G10-003, G10-004, G10-010, G10-015.
- **Moderate restructuring needs:** G10-002, G10-005, G10-006, G10-007, G10-008.
- **Cleanup and legibility needs:** G10-009, G10-011, G10-012, G10-013, G10-014.

## Non-gaps

The following should not be reworked unless implementation evidence contradicts
current repo truth:

- super-root/class-root model;
- authored authority only in `framework/**` and `instance/**`;
- generated/read-model non-authority;
- run-first lifecycle;
- mission continuity container model;
- adapter non-authority;
- support-target bounded-claim philosophy;
- extension raw/desired/active/generated-effective separation.
