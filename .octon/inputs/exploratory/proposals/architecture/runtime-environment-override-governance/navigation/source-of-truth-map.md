# Source-of-Truth Map

| Claim class | Source of truth | Note |
| --- | --- | --- |
| Review findings (F-01, F-02, deferred F-03/F-05) | `.octon/state/evidence/validation/architecture/reviews/super-root-balanced-review/20260709-super-root-balanced-review/findings.yml` | Retained evidence; copies under `resources/retained-review-evidence/` are convenience mirrors |
| Routing decision that warranted this packet | `.../20260709-super-root-balanced-review/route-decision.yml` | Recommends one packet; does not create it |
| Code behavior of the overrides | `.octon/framework/engine/runtime/crates/{authority_engine,core,policy_engine,kernel}/src/**` at commit `eff350fcfec641e59665e74544f104f2e5bc6a4d` | Live repo outranks this packet's summaries (epistemic precedence) |
| Constitutional constraints | `.octon/framework/constitution/**` (CHARTER, precedence, fail-closed, evidence, roles) | This packet is subordinate to all of them |
| Policy interface contract | `.octon/framework/engine/runtime/spec/policy-interface-v1.md` | Documentation target for F-02 |
| Packet lifecycle state | `proposal.yml#status` | draft until governed review/acceptance |
| Decision authority for option selection | `.octon/framework/constitution/ownership/roles.yml` (human governance) | This packet recommends, never decides |

Nothing in this packet is authority. Where any packet statement disagrees with
the live repository or constitutional surfaces, those sources win and the
packet needs revision.
