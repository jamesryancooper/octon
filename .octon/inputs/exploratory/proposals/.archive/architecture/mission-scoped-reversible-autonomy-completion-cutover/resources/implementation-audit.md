# Mission Scoped Reversible Autonomy Completion

## 1. Executive judgment

The implementation is **not complete** and **not fully integrated**. Octon has done real, non-cosmetic work: the repo now declares Mission-Scoped Reversible Autonomy as canonical, adds a mission autonomy policy and ownership registry, defines mission control truth under `state/control/execution/missions/<mission-id>/`, upgrades execution request/receipt/policy receipt contracts with mission/slice/oversight/recovery fields, and keeps ACP plus `STAGE_ONLY` as the durable execution-governance backbone. Those pieces are substantive and architecturally aligned. ([GitHub][1])

But the implementation is **not end-to-end**. The repo’s own `.octon/README.md` says derived `now / next / recent / recover` views should live under `generated/cognition/summaries/missions/<mission-id>/`, yet both the mission summaries and operator summaries directories are still just `.gitkeep` placeholders. The canonical mission control root exists, but in the committed tree it is effectively empty except for `.gitkeep`; the retained control-evidence root is also empty. The archived MSRAOM cutover proposal expected all of those surfaces—mission control state, generated read models, schedule/digest routing, autonomy burn budgets, circuit breakers, and safing rules—to be promoted together. That standard has not been met yet. ([GitHub][1])

So the operating model is **partially complete with moderate gaps**, not implementation-complete. The strongest implemented parts are the execution and policy contracts; the weakest parts are the operator/control-plane integration layers: forward intent publication, directive handling, schedule semantics, autonomy-burn automation, mission/operator read models, and scenario-aware routing. For the code-path evidence behind that conclusion, see this [audit code appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md).

Scenario handling is **partially sufficient, but only implicitly**. Today, Octon differentiates scenarios mainly through `mission_class`, action class / ACP policy, reversibility, executor profiles, and mission-autonomy defaults. That is a real routing model, but it is not yet materialized as a fully wired control/scheduling/awareness pipeline. A stronger scenario-routing resolver should exist, but as a **derived effective routing layer**, not as a second authoritative control plane. ([GitHub][2])

**Bottom line:** the claim that MSRAOM is “implemented and fully integrated” is **not supported by the current repo**. The right verdict is **Partially complete with moderate gaps**.

---

## 2. Intended model spine

The final intended MSRAOM spine from the conversation is:

* long-running agents operate under **mission-scoped standing delegation**
* mission continuity is separated from per-slice execution authority
* material work is decomposed into **action slices**
* agents publish **forward intent** before consequential work
* agents expose a live **mode beacon**
* control dimensions stay separate: **awareness, intervention, approval, reversibility**
* human interaction follows **Inspect / Signal / Authorize-Update**
* durable change crosses **grant → stage → promote → finalize** boundaries
* `STAGE_ONLY` is the humane fail-closed default when promote prerequisites are missing
* interruption happens at **safe boundaries**
* recovery is first-class: **rollback handles, compensation paths, recovery windows, finalize blockers**
* trust tightens via **autonomy burn budgets, circuit breakers, safing, break-glass**
* operator awareness is summary-first through **Now / Next / Recent / Recover**, digests, watch modes, and ownership routing
* source-of-truth separation remains strict across authored authority, mutable control truth, retained evidence, and derived read models

That is the baseline I used for the audit.

---

## 3. Implementation completeness matrix

Supplemental code-and-test evidence: [audit code appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md)

| Concept                           | Intended role                                                                               | Repo evidence                                                                                                                                                                                                                                            | Implementation status                 | Integration quality | Source-of-truth quality   | Notes / risks                                                                                                                                                        |
| --------------------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- | ------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mission-scoped authority          | Durable mission charter, registry, canonical mission/control/continuity placement           | `.octon/README.md` and missions README both define canonical mission authority, control, continuity, and summaries; mission template is `octon-mission-v2`. ([GitHub][1])                                                                                | **Fully implemented**                 | Strong              | Correct                   | Good repo-level placement.                                                                                                                                           |
| Execution grants / ACP / receipts | Engine-owned material execution boundary with mission-aware request/grant/receipt contracts | Policy interface, execution authorization, request/grant/receipt/policy receipt schemas are all present and mission-aware. ([GitHub][3])                                                                                                                 | **Fully implemented**                 | Strong              | Correct                   | This is the strongest part of the implementation.                                                                                                                    |
| `STAGE_ONLY` backbone             | Humane fail-closed outcome for missing promote prerequisites                                | Grant schema supports `STAGE_ONLY`; policy interface and deny-by-default policy preserve it; ACP policy maps many missing-requirement cases to `STAGE_ONLY`. ([GitHub][4])                                                                               | **Fully implemented**                 | Strong              | Correct                   | Faithful to the intended model.                                                                                                                                      |
| Continuation lease                | Keep mission running without ambient mutation authority                                     | Kernel code inspection shows `lease.yml` is required and enforced for `active/paused/revoked/expired` states; mission control root is canonical. [appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) ([GitHub][1])                               | **Implemented but incomplete**        | Medium              | Weak                      | Runtime uses it, but there is no visible committed schema/scaffold for lease files.                                                                                  |
| Mode beacon / execution modes     | Explicit oversight mode, posture, safety state, phase                                       | Request/receipt schemas carry `oversight_mode`, `execution_posture`, `reversibility_class`; mission-autonomy policy defines defaults by mission class. ([GitHub][5])                                                                                     | **Implemented but incomplete**        | Medium              | Medium                    | Contracts exist; operator-facing rendering is still missing.                                                                                                         |
| Action slices                     | Smallest governable mission units                                                           | `slice_ref` is carried in autonomy context and receipts. ([GitHub][3])                                                                                                                                                                                   | **Implemented but incomplete**        | Medium              | Correct                   | Present contractually; little visible operator/runtime surface beyond the request/receipt path.                                                                      |
| Forward intent register           | Publish next material slices before execution                                               | Kernel code inspection shows `intent-register.yml` is required for autonomous runs, but I found no committed schema, scaffold, publisher, or consumer beyond existence checks. [appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) ([GitHub][1]) | **Partially present**                 | Weak                | Weak                      | This is one of the biggest gaps.                                                                                                                                     |
| Human interaction model           | Separate Inspect / Signal / Authorize-Update                                                | Ownership registry defines precedence; receipts have `applied_directive_refs` and `applied_authorize_update_refs`. ([GitHub][6])                                                                                                                         | **Implemented but weakly integrated** | Weak                | Medium                    | Contract shape exists, but I found little evidence of real directive/update consumption in runtime.                                                                  |
| Safe interrupt boundaries         | Pause safely mid-flight                                                                     | Mission-autonomy policy defines safe boundary classes by scenario family. ([GitHub][7])                                                                                                                                                                  | **Partially present**                 | Weak                | Medium                    | I did not find strong runtime/scheduler enforcement for boundary pausing.                                                                                            |
| Schedule control semantics        | Suspend future runs vs pause active run; overlap/backfill; pause-on-failure                 | Mission-autonomy policy defines overlap defaults, backfill defaults, and pause-on-failure triggers; kernel code inspection shows `schedule.yml` is required. [appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) ([GitHub][7])                   | **Partially present**                 | Weak                | Weak                      | Policy exists, but end-to-end scheduler behavior is not clearly wired.                                                                                               |
| Rollback / recovery / finalize    | Rollback handle, compensation path, recovery window, finalize separation                    | Receipt schemas include rollback/compensation/recovery fields; ACP policy encodes reversibility and `finalize` ACP-4 boundaries. ([GitHub][8])                                                                                                           | **Implemented but incomplete**        | Medium              | Correct at contract layer | Kernel code inspection suggests fallback recovery metadata is hardcoded instead of fully policy-derived. [appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) |
| Autonomy burn budgets             | Tighten autonomy based on evidence                                                          | Mission-autonomy policy defines burn states and thresholds; receipt schemas carry budget state. ([GitHub][7])                                                                                                                                            | **Implemented but incomplete**        | Medium              | Medium                    | I found no clear burn-aggregation pipeline that updates state from receipts/incidents.                                                                               |
| Oversight circuit breakers        | Automatic tightening / stage-only / safing after threshold events                           | Mission-autonomy policy defines trip conditions and actions; ACP policy also has breaker sets; receipts carry breaker state. ([GitHub][7])                                                                                                               | **Implemented but incomplete**        | Medium              | Medium                    | Good policy structure; weak evidence of mission-level breaker automation.                                                                                            |
| Safing mode                       | Contraction to safe subset under degradation                                                | Mission-autonomy policy defines safing defaults; mode-state includes safety state; ownership precedence includes kill-switch/break-glass priority. ([GitHub][7])                                                                                         | **Partially present**                 | Weak                | Medium                    | I did not find strong runtime enforcement of safing subsets.                                                                                                         |
| Break-glass                       | Exceptional, accountable override                                                           | ACP policy makes emergency / ACP-4 break-glass gated; ownership precedence explicitly prioritizes break-glass or kill switch. ([GitHub][9])                                                                                                              | **Implemented but incomplete**        | Medium              | Correct at policy layer   | Present in governance, but not fully surfaced in mission/operator state.                                                                                             |
| Operator read models              | `Now / Next / Recent / Recover`, mission summaries, operator digests                        | `.octon/README.md` says these live under generated cognition summaries, but both mission and operator summary dirs are empty placeholders. ([GitHub][1])                                                                                                 | **Missing**                           | None                | Contradicted              | This is the clearest completeness failure.                                                                                                                           |
| Continuity / handoff              | Mission-local continuity and follow-up                                                      | Canonical continuity roots are declared for missions and repo continuity. ([GitHub][1])                                                                                                                                                                  | **Implemented but weakly integrated** | Medium              | Correct                   | The surfaces exist, but MSRAOM-specific handoff integration is not obvious.                                                                                          |
| Ownership routing / subscriptions | Route awareness and authority to the right humans                                           | Ownership registry exists; mission-autonomy policy defines precedence and digest routes; kernel requires `subscriptions.yml`. ([GitHub][6])                                                                                                              | **Implemented but weakly integrated** | Weak                | Medium                    | I found little evidence of actual runtime notification routing.                                                                                                      |
| Control-plane evidence            | Retain evidence for directives, updates, breaker trips, schedule mutations                  | `.octon/README.md` declares `state/evidence/control/execution/**` canonical, but the directory is empty in-tree. ([GitHub][1])                                                                                                                           | **Unclear / insufficient evidence**   | Weak                | Correct in theory         | The repo documents it, but I do not see real emitted artifacts.                                                                                                      |
| Scenario handling / routing       | Route different scenario families to the right control behaviors                            | Mission class exists in charters; mission-autonomy policy routes by mission class; ACP policy routes by action class/phase/reversibility; root manifest adds special executor-profile gates. ([GitHub][2])                                               | **Present under another name**        | Medium              | Medium                    | Real implicit routing exists, but no single effective scenario-resolution layer is clearly materialized.                                                             |

### What this matrix means

Octon has **implemented the contracts and policy spine** of MSRAOM. It has **not yet completed the mission control plane, operator read models, or scheduling/intervention runtime** that make the model practically governable for long-running agents.

---

## 4. Scenario handling analysis

### How scenarios are handled now

Scenarios are handled today through a **distributed implicit routing model**, not through a first-class “scenario routing” artifact.

The main routing inputs are:

* **mission class** in the mission charter (`observe`, `campaign`, `reconcile`, `maintenance`, `migration`, `incident`, `destructive`) ([GitHub][2])
* **mission-autonomy defaults** that map each mission class to an oversight mode, execution posture, preview timing, digest cadence, overlap/backfill defaults, pause-on-failure, safe interrupt boundary class, recovery windows, autonomy-burn thresholds, breaker actions, quorum, and safing defaults ([GitHub][7])
* **ACP action-class rules** in deny-by-default policy, which route by action class + phase + target conditions to ACP level, reversibility primitive, recovery window default, quorum, breaker set, and `STAGE_ONLY`/`DENY` fallback ([GitHub][9])
* **executor profiles** in `.octon/octon.yml`, which impose stronger review/hard-enforce requirements for release-sensitive or human-review-required flows ([GitHub][10])

That is already a meaningful scenario model. It can distinguish, for example, routine repo housekeeping, reconcile loops, migrations, incidents, and destructive work at the policy layer.

### Is there explicit scenario routing?

**Not really.** There is **implicit routing**, but I do not see a single runtime-resolved artifact or resolver that takes the scenario inputs and turns them into one effective operational decision shared by:

* scheduler behavior
* directive behavior
* operator preview/digest behavior
* recovery/finalize behavior
* escalation behavior

The mission-autonomy policy declares these defaults, but in my code inspection the kernel authorizer mainly checks that `mission-autonomy.yml` exists, then uses mission control files, mode state, budget state, and breaker state; it does not appear to consume the full mission-autonomy routing model directly. The same is true for ownership precedence and schedule/directive semantics. See the [audit code appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) and [grep appendix](sandbox:/mnt/data/msraom_audit_grep_appendix.md).

### Is scenario handling sufficient?

**Partially, but not enough.**

It is sufficient to say that Octon has the **policy ingredients** for scenario differentiation. It is not sufficient to say that the repo has fully implemented **scenario-aware runtime behavior** for the operating model.

The missing pieces are the ones that matter most in practice:

* route mission class + action class + reversibility into actual scheduler semantics
* route incident/destructive/public/external scenarios into actual preview/approval/notification behavior
* route observe-only missions into clean observe→operate escalation paths
* route late feedback, absent human, and conflicting human input into consistent directive and finalize behavior
* route compensable-only scenarios differently from truly reversible ones

### Should scenario routing be added as a first-class concept?

**Yes, but not as a new authoritative registry.**

Octon already has the better raw abstractions:

* mission class
* action class / ACP rule
* reversibility class
* execution posture
* safety state
* executor profile
* ownership routing
* breaker/budget state

The missing thing is a **derived scenario-resolution layer** that makes those inputs operationally explicit.

### Recommended scenario-routing design

The cleanest design is:

**Do not add a separate canonical “scenario registry.”**
Instead, add a **runtime scenario resolver** that compiles existing authoritative inputs into an effective route.

**Authoritative inputs remain:**

* mission charter
* mission-autonomy policy
* deny-by-default ACP policy
* root manifest executor-profile governance
* mutable mission mode / lease / directive / budget / breaker state

**Derived output should be:**

* an effective scenario-resolution artifact, likely under a generated surface such as
  `/.octon/generated/cognition/projections/materialized/missions/<mission-id>/scenario-resolution.latest.yml`
  or an equivalent generated mission summary surface

**That resolver should compute at least:**

* effective oversight mode
* effective execution posture
* preview lead and feedback deadline
* overlap/backfill behavior
* pause-on-failure behavior
* safe interrupt boundary class
* recovery profile
* digest/watch/alert route
* whether proceed-on-silence is still allowed
* whether a mission should fork an operate sub-mission from an observe mission
* whether finalize is currently blockable or approval-gated

### Where it should live

* **Authored policy stays where it already belongs**:
  `instance/governance/policies/mission-autonomy.yml`, ACP policy, `.octon/octon.yml`
* **Mutable live state stays where it already belongs**:
  `state/control/execution/missions/<mission-id>/`
* **Scenario resolution should be derived**:
  generated surface, not a second control truth
* **Scheduler and operator read models should consume the same resolved output**

That preserves Octon’s source-of-truth discipline.

---

## 5. Missing or incomplete features

### Critical

#### 1. Mission/operator read models are still missing

**Why it matters:** MSRAOM explicitly requires operator-legible `Now / Next / Recent / Recover` views and digests. Without them, the model is not practically operator-legible.
**What is missing:** materialized mission summaries and operator digests; current summary dirs are placeholders only.
**Where to add:** `generated/cognition/summaries/missions/<mission-id>/` and `generated/cognition/summaries/operators/`, with projection definitions and materialization wiring.
**Type:** derived read-model work. ([GitHub][1])

#### 2. Directive and schedule semantics are not clearly enforced end to end

**Why it matters:** the operating model depends on `pause_at_boundary`, `suspend_future_runs`, overlap/backfill rules, pause-on-failure, and finalize blocking. Without those, intervention is mostly rhetorical.
**What is missing:** visible runtime/scheduler enforcement for directives and schedule-control records.
**Where to add:** kernel/orchestration runtime plus canonical mission control state under `state/control/execution/missions/<mission-id>/`.
**Type:** runtime + mutable control truth.
**Evidence:** policy defines the semantics, but I found no strong runtime consumer path for them in the current code audit. ([GitHub][7])

#### 3. The forward intent register is not yet a real control primitive

**Why it matters:** MSRAOM requires forward publication of consequential work, not just receipts after the fact.
**What is missing:** a committed contract/scaffold plus publisher/consumer path for `intent-register.yml`; right now it appears as a required file more than a fully integrated feature.
**Where to add:** mission control root, mission scaffolding, runtime publisher, operator read-model generator.
**Type:** mutable control truth + derived read models. ([GitHub][1])

#### 4. The per-mission control-state family is required but not visibly contractized

**Why it matters:** the kernel expects lease, mode, intent register, directives, schedule, autonomy budget, circuit breakers, and subscriptions. If those are runtime-required, they need authoritative schemas or templates.
**What is missing:** committed schemas/templates/docs for those per-mission files; the mission scaffold only covers `mission.yml`, `mission.md`, `tasks.json`, and `log.md`.
**Where to add:** framework runtime/spec or instance mission scaffolding, plus docs.
**Type:** policy/runtime contract work. ([GitHub][11])

### Important

#### 5. Autonomy burn budgets and circuit breakers are only partly automated

**Why it matters:** MSRAOM requires automatic trust tightening after incidents.
**What is missing:** a clear pipeline that derives burn state from receipts/incidents/retries/rollbacks and then trips or resets breakers.
**Where to add:** policy-engine/runtime analytics plus mission control truth.
**Type:** runtime + control truth. ([GitHub][7])

#### 6. Recovery metadata is not fully policy-derived

**Why it matters:** recovery windows and rollback handles should come from action class / reversibility policy, not ad hoc fallback values.
**What is missing:** full derivation of recovery metadata from mission-autonomy and ACP policy into runtime resolution.
**Where to add:** kernel authorization / policy-engine integration.
**Type:** runtime + evidence.
**Evidence:** contracts clearly carry recovery metadata, but the code audit shows hardcoded fallback behavior. [appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) ([GitHub][8])

#### 7. Ownership precedence and subscription routing are declared but weakly consumed

**Why it matters:** conflict handling and operator notification quality depend on them.
**What is missing:** real runtime use of directive precedence and subscription routing in decision, alert, and digest behavior.
**Where to add:** orchestration runtime and summary/digest generator.
**Type:** mutable control truth + derived read models. ([GitHub][6])

#### 8. Safing mode exists in policy, but not clearly as runtime behavior

**Why it matters:** degraded conditions are a core MSRAOM concern.
**What is missing:** explicit safing subset enforcement and operator-visible safing transitions.
**Where to add:** mission mode state + orchestration runtime + read models.
**Type:** runtime + control truth + read model. ([GitHub][7])

#### 9. Control-plane evidence emission is not evident

**Why it matters:** directives, approvals, breaker trips, and schedule changes should leave canonical retained control evidence.
**What is missing:** visible writers/artifacts under `state/evidence/control/execution/**`.
**Where to add:** orchestration runtime and control mutation handlers.
**Type:** retained evidence. ([GitHub][1])

#### 10. Mission summary/orchestration readers appear out of sync with mission v2

**Why it matters:** operator surfaces will be wrong or incomplete if the reader still expects older fields.
**What is missing:** alignment between mission charter v2 and orchestration readers.
**Where to add:** core orchestration reader and mission summary projection.
**Type:** runtime/read-model integration.
**Evidence:** mission v2 scaffold uses `owner_ref`; the code audit shows orchestration readers still expect `owner`. [appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md) ([GitHub][2])

#### 11. Scenario resolution is not materialized

**Why it matters:** scenario differentiation exists, but not yet as one effective route consumed consistently by scheduler, runtime, and operator views.
**What is missing:** derived scenario-resolution layer.
**Where to add:** generated effective/projection layer plus runtime resolver.
**Type:** derived read-model/runtime glue. ([GitHub][7])

#### 12. End-to-end scenario tests are still insufficient

**Why it matters:** long-running autonomy needs scenario validation, not just schema and unit tests.
**What is missing:** conformance tests for absent-human, late-feedback, conflicting-human, observe→operate, schedule pause/backfill, breaker trips, safing, and finalize-block behavior.
**Where to add:** runtime/policy integration tests and validation suite.
**Type:** test coverage.
**Evidence:** the archived proposal explicitly called for a scenario suite and merge gates. ([GitHub][12])

### Nice to have

#### 13. Committed example missions and summary artifacts

**Why it matters:** they would make the operating model easier to verify and operate.
**What is missing:** a canonical non-production sample mission with populated control/read-model surfaces.
**Where to add:** instance mission examples and generated summaries.
**Type:** documentation/example artifact.

---

## 6. Architectural tensions or contradictions

The largest contradiction is that the repo **claims more integration than the tree shows**. `.octon/README.md` says Mission-Scoped Reversible Autonomy is canonical and says derived `now / next / recent / recover` views live under `generated/cognition/summaries/missions/<mission-id>/`, but those mission and operator summary directories are still empty placeholders. That is an architectural overclaim until the read-model pipeline exists. ([GitHub][1])

A second tension is that the repo defines a **canonical mission control root**, but the committed control tree is effectively empty and the mission scaffold does not create the files the kernel expects for autonomous runs. That means runtime assumptions are ahead of the authoring/scaffolding layer. ([GitHub][1])

A third tension is between **mission v2 authoring** and **existing orchestration readers**. The v2 mission scaffold uses `owner_ref`, but the orchestration code I inspected still reads `owner`. That is exactly the kind of subtle mismatch that makes operator surfaces look “implemented” while silently degrading fidelity. See the [audit code appendix](sandbox:/mnt/data/msraom_audit_code_appendix.md). ([GitHub][2])

A fourth tension is that the **mission-autonomy policy is rich**, but runtime consumption appears shallow. The policy declares mode defaults, digest cadence, overlap/backfill, pause-on-failure, recovery windows, safe boundaries, burn thresholds, breaker actions, quorum, and safing defaults; the current code audit suggests the kernel mostly checks that the file exists and then uses a smaller set of live mission files and simple state fields. That means the policy is ahead of the runtime resolver. ([GitHub][7])

A fifth tension is that the **projection layer has not caught up**. The current cognition runtime surface map only joins cognition context/decision indexes and the general projections index; it does not visibly route mission-autonomy control/read-model surfaces into a materialized MSRAOM operator view. ([GitHub][13])

---

## 7. Final verdict

**Partially complete with moderate gaps**

That is the only verdict the evidence supports.

Why:

* the contracts and governance backbone are real and substantial
* kernel/policy enforcement is no longer just aspirational
* but the control plane is not fully wired into scheduling, directives, operator views, and scenario resolution
* the repo still overclaims some generated/operator surfaces that are not actually materialized
* several control primitives are present mainly as file expectations or policy declarations, not as complete runtime behaviors

If Octon were only trying to prove a **design cutover**, this would be close. If Octon is claiming **implementation-complete operating behavior for long-running autonomous agents**, it is not there yet.

---

## 8. Exact remediation list

1. **Implement the missing read-model pipeline**

   * Add generated `Now / Next / Recent / Recover` mission summaries under `generated/cognition/summaries/missions/<mission-id>/`
   * Add operator digests under `generated/cognition/summaries/operators/`
   * Make those projections consume mission charter, mode state, intent register, receipts, directives, recovery state, and continuity
   * Treat these as derived only, never authoritative

2. **Publish authoritative schemas/templates for mission control files**

   * Add committed contracts or scaffolds for:

     * `lease.yml`
     * `mode-state.yml`
     * `intent-register.yml`
     * `directives.yml`
     * `schedule.yml`
     * `autonomy-budget.yml`
     * `circuit-breakers.yml`
     * `subscriptions.yml`
   * Put the contracts in the framework/runtime spec layer or equivalent
   * Wire the mission scaffold to create them

3. **Wire directives into runtime behavior**

   * Implement consumption of `pause_at_boundary`, `suspend_future_runs`, `reprioritize`, `narrow_scope`, `exclude_target`, `veto_next_promote`, and `block_finalize`
   * Emit control-plane evidence for each directive mutation
   * Reflect applied directive refs in receipts

4. **Wire schedule control into the orchestrator**

   * Implement:

     * future-run suspension
     * active-run pause
     * overlap policy
     * backfill policy
     * pause-on-failure triggers
   * Make scheduler behavior use the canonical schedule control record

5. **Build a real forward-intent pipeline**

   * Publish upcoming material slices into the intent register
   * Version them
   * Surface them in preview notices and `Next` views
   * Bind policy evaluation and operator previews to the same intent entries

6. **Make mission-autonomy policy actually drive runtime resolution**

   * Load and consume:

     * mode defaults
     * digest cadence defaults
     * overlap/backfill defaults
     * pause-on-failure defaults
     * recovery windows
     * safe interrupt boundary classes
     * autonomy-burn thresholds
     * breaker actions
     * ownership routing defaults
   * Stop treating `mission-autonomy.yml` primarily as an existence-checked policy blob

7. **Automate autonomy burn and breaker state transitions**

   * Derive burn from receipts, incidents, rollbacks, compensations, retries, vetoes, and denials
   * Persist resulting state under mission control truth
   * Trip and reset breakers deterministically
   * Route breaker state into oversight mode changes and safing

8. **Derive rollback/recovery metadata from policy, not hardcoded fallbacks**

   * Recovery windows should come from action class / reversibility policy and mission policy
   * Rollback/compensation handles should come from actual recovery primitives
   * Finalize blockers should be reflected in mission state and summaries

9. **Align mission charter v2 with orchestration readers**

   * Update orchestration readers to consume `owner_ref`
   * Add compatibility shim if older `owner` artifacts still exist
   * Add regression tests so summaries do not silently degrade

10. **Add retained control-plane evidence emitters**

    * Write directives, authorize-updates, schedule mutations, breaker trips, safing transitions, and break-glass activations to `state/evidence/control/execution/**`
    * Keep run evidence and control evidence separate

11. **Implement scenario resolution as a derived resolver**

    * Do **not** add a new authoritative scenario registry
    * Compute effective scenario behavior from mission class + action class + reversibility + phase + posture + incident/breaker state
    * Materialize the result into a generated route artifact and use it consistently in scheduler + read models

12. **Add the missing integration/conformance suite**

    * required scenarios:

      * housekeeping
      * long refactor
      * dependency patch
      * release maintenance
      * infra drift
      * cost cleanup
      * migration/backfill
      * external sync
      * observe-only monitoring
      * incident containment
      * high-volume repetitive work
      * destructive irreversible work
      * absent human
      * late feedback
      * conflicting directives
      * breaker/safing
      * finalize blocking

13. **Deprecate overclaiming docs until implementation matches**

    * If generated summaries or scenario routing remain incomplete, either finish them or soften the claims in `.octon/README.md`
    * The canonical docs should not imply a more complete operator experience than the repo actually provides

[1]: https://github.com/jamesryancooper/octon/tree/main/.octon "octon/.octon at main · jamesryancooper/octon · GitHub"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/orchestration/missions/_scaffold/template/mission.yml "raw.githubusercontent.com"
[3]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/policy-interface-v1.md "raw.githubusercontent.com"
[4]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json "raw.githubusercontent.com"
[5]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json "raw.githubusercontent.com"
[6]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/ownership/registry.yml "raw.githubusercontent.com"
[7]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/mission-autonomy.yml "raw.githubusercontent.com"
[8]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json "raw.githubusercontent.com"
[9]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml "raw.githubusercontent.com"
[11]: https://github.com/jamesryancooper/octon/tree/main/.octon/instance/orchestration/missions "octon/.octon/instance/orchestration/missions at main · jamesryancooper/octon · GitHub"
[12]: https://github.com/jamesryancooper/octon/tree/main/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy "octon/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy at main · jamesryancooper/octon · GitHub"
[13]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/generated/cognition/projections/definitions/cognition-runtime-surface-map.yml "raw.githubusercontent.com"
