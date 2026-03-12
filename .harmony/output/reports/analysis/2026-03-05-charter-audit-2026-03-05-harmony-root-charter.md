# Charter Audit

- Run ID: `2026-03-05-harmony-root-charter`
- Skill: `audit-charter`
- Charter Path: `.harmony/CHARTER.md`
- Severity Threshold: `all`
- Include Rewrites: `true`
- Include Scores: `true`
- Method: `closed-book audit using only .harmony/CHARTER.md as evidence`

## Overall Verdict

Partially aligned

The charter is internally strong on framing, scope, precedence, and baseline control posture: the pitch, purpose, primary objective, and operating model all point to the same objective-bound, fail-closed governance model, and the authority ladder plus accountability map remove most ambiguity for routine operation. No direct contradictions were found in `.harmony/CHARTER.md`. The charter stops short of fully standing on its own because several core controls are only partially operationalized from charter text alone: objective-contract consistency is not testable without extra criteria, bootstrap allows an `equivalent` assurance entrypoint without an equivalence test, and several success signals depend on external targets or unspecified measurement methods. Those gaps weaken standalone enforceability and auditability even though the governing direction is coherent.

Canonical statements extracted from the charter:

- Elevator pitch: "Harmony turns a target directory into a governed autonomous engineering workspace by binding execution to explicit objectives, bounded authority, fail-closed controls, and durable evidence." (`.harmony/CHARTER.md:15-17`)
- Vision: "Enable a target directory to become a trusted autonomous engineering environment through a defined bootstrap process, with clear contracts, bounded authority, durable learning, and explicit safety, security, privacy, and policy constraints." (`.harmony/CHARTER.md:66-68`)
- Unique Value Proposition: "Harmony's unique value is delivery speed with governance integrity... portable across projects, environments, tools, and vendors." (`.harmony/CHARTER.md:70-72`)
- Purpose: reliable, bounded, portable, auditable autonomous execution with standardized delivery and durable continuity (`.harmony/CHARTER.md:74-82`)
- Primary Objective: portable autonomous operation that is deterministic, observable, safe, reversible, recoverable, fail-closed, and bounded by approved policy/objective contracts (`.harmony/CHARTER.md:84-92`)
- `What`: a portable drop-in harness, execution control plane, and contract/evidence system for governed autonomous engineering work (`.harmony/CHARTER.md:42-48`)
- `Does`: binds execution to an objective contract, routes material work, enforces bounded authority, emits evidence, and standardizes workspace structure (`.harmony/CHARTER.md:50-56`)
- `Why`: to make long-running autonomy reliable, safe, bounded, portable, and continuity-preserving (`.harmony/CHARTER.md:76-104`)
- `How`: through precedence, accountability, `PLAN -> SHIP -> LEARN`, objective-contract gating, bootstrap controls, surface separation, change control, and fail-closed dependency handling (`.harmony/CHARTER.md:172-383`)

## Coverage Matrix

| Dimension (What/Does/Why/How) | Key Charter Claim | Supporting Sections | Gap? | Notes |
| --- | --- | --- | --- | --- |
| What | Harmony is a portable, governed, filesystem-based autonomous engineering harness and control plane. | `§2`, `§4`, `§5` (`.harmony/CHARTER.md:42-56`, `.harmony/CHARTER.md:119-147`, `.harmony/CHARTER.md:150-170`) | No | Definitions and scope support the framing and keep Harmony distinct from product logic. |
| Does | Harmony binds execution to objective contracts, routes material work via `allow`/`escalate`/`block`, emits durable evidence, and standardizes bootstrap/domain surfaces. | `§2`, `§8-12`, `§15` (`.harmony/CHARTER.md:50-56`, `.harmony/CHARTER.md:217-329`, `.harmony/CHARTER.md:371-383`) | Yes | The mechanism set is explicit, but some evidence contracts remain implied rather than formally specified. |
| Why | Harmony exists to make autonomy reliable, bounded, portable, and auditable while concentrating humans on policy authorship, exceptions, and escalation. | `§3`, `§13` (`.harmony/CHARTER.md:64-117`, `.harmony/CHARTER.md:331-346`) | Yes | Framing is aligned, but some success signals depend on external targets or undefined measurement methods. |
| How | Harmony governs execution through a precedence ladder, accountability map, `PLAN -> SHIP -> LEARN`, objective-contract gating, bootstrap prerequisites, surface roles, change control, and fail-closed dependency handling. | `§6-15` (`.harmony/CHARTER.md:172-383`) | Yes | The charter explains the control model well, but objective consistency tests, bootstrap equivalence, and key audit hooks are underdefined. |

## Contradiction/Conflict Log

No direct contradictions were found. The material issues are latent conflicts and self-sufficiency gaps.

| ID | Sections in tension | Conflict description | Severity (High/Med/Low) | Why it matters | Precedence outcome |
| --- | --- | --- | --- | --- | --- |
| C1 | `§1. Charter Role` vs `§13. Success Signals` | The charter says it defines how success is measured, but several success signals still depend on external workspace targets, support targets, or unspecified measurement methods. | Med | A new reader cannot execute the scorecard closed-book for all signals. | `§6` permits workspace-local artifacts to fill allowed slots, but absent those artifacts the charter should be treated as incomplete for those signals rather than self-sufficient. |
| C2 | `§2. What Harmony Does` vs `§10. Bootstrap Contract` | Harmony claims to standardize bootstrap, yet bootstrap permits an `equivalent assurance entrypoint` without defining what makes an alternative equivalent. | Med | Different implementations can approve different bootstrap gates while still claiming conformance. | No internal precedence rule resolves equivalence; the decision falls to local policy authority by inference, which is a gap rather than a deterministic rule. |
| C3 | `§9. Objective Contract and Boundary Routing` | The objective contract is defined as both artifacts together, but `mutually consistent` and `diverge` are not defined, so implementations can disagree on when the fallback state starts. | Med | Material execution can be blocked safely, but read-only planning authority and reconciliation behavior are not testable from charter text alone. | `§9:257` safely blocks material autonomy once divergence is detected; the unresolved part is the detection rule itself. |
| C4 | `§6. Authority and Precedence` vs `§7. Accountability Model` | Unresolved conflicts escalate to the `applicable policy owner`, but the charter does not operationalize how to choose the applicable owner when multiple explicit owners plausibly apply. | Low | Escalations can stall or fork in multi-domain cases. | `§7:200` defaults to the charter owner only when no narrower owner is explicitly named; otherwise owner selection remains dependent on external governance. |

## Normative Clause Audit

| Clause reference | Normative keyword | Requirement text (short) | Clear? | Testable? | Conflict risk | Fix |
| --- | --- | --- | --- | --- | --- | --- |
| `§1:40` | `MUST` | Cross-domain Harmony surfaces satisfy charter minimum rules. | Yes | Partial | Low | Add a conformance evidence artifact if stronger auditability is needed. |
| `§4:133` | `MUST` | Group-labeled charter owner actions name the acting human delegate. | Yes | Yes | Low | None |
| `§6:182a` | `MAY` | Domain governance may specialize the charter. | Yes | Yes | Low | None |
| `§6:182b` | `MUST NOT` | Domain governance must not weaken or contradict the charter. | Yes | Partial | Low | None |
| `§6:192` | `MAY` | Workspace-local artifacts may specify local boundaries, standards, support targets, and objectives within allowed slots. | Yes | Partial | Low | None |
| `§6:193a` | `MAY` | Higher-precedence governance may narrow or strengthen charter requirements for a specific decision. | Yes | Partial | Low | None |
| `§6:193b` | `MUST NOT` | Narrowing or strengthening for one decision is not an implicit waiver elsewhere. | Yes | Partial | Low | None |
| `§6:194` | `MUST` | Unresolved same-decision conflicts fail closed and escalate. | Yes | Partial | Low | None |
| `§7:198a` | `MUST` | Each listed flow has explicit decision, execution, and escalation owners. | Yes | Yes | Low | None |
| `§7:198b` | `MUST` | New charter-governed flows are added to the map or explicitly delegated before execution. | Partial | Partial | Low | Define how new-flow detection is triggered. |
| `§8:229-236` | `MUST` | Every material run completes the six listed control steps. | Yes | Partial | Low | See Rewrite Pack `R4`. |
| `§9:252` | `MUST` | Active intent contract exposes a unique `id` and `version`. | Yes | Yes | Low | None |
| `§9:253` | `MUST` | Material runs use the approved and effective intent-contract version. | Yes | Partial | Low | Add minimum approval-evidence fields if stronger auditability is needed. |
| `§9:254` | `MUST` | Objective brief and intent contract update in the same change when the governed objective changes materially. | Partial | Partial | Med | See Rewrite Pack `R1`. |
| `§9:255` | `MUST` | Objective-contract changes record rationale and approval evidence. | Yes | Partial | Low | Add minimum evidence fields if stronger auditability is needed. |
| `§9:256` | `MUST` | Missing, invalid, unavailable, or not mutually consistent objective artifacts fail closed for material execution. | Partial | Partial | Med | See Rewrite Pack `R1`. |
| `§9:257a` | `MUST` | On divergence, the intent contract governs read-only planning only. | Partial | Partial | Med | See Rewrite Pack `R1`. |
| `§9:257b` | `MUST` | On divergence, material autonomy is blocked. | Partial | Partial | Med | See Rewrite Pack `R1`. |
| `§9:257c` | `MUST` | Resuming material execution requires approved reconciliation evidence. | Yes | Partial | Low | Add minimum reconciliation evidence fields if stronger auditability is needed. |
| `§9:261` | `MUST` | Every material run produces exactly one routing outcome before any material side effect. | Yes | Partial | Med | See Rewrite Pack `R4`. |
| `§9:265` | `MUST NOT` | Intent binding cannot bypass routing or authority controls. | Yes | Partial | Low | None |
| `§9:266` | `MUST` | Non-deterministic routing or intent validation fails closed and escalates. | Yes | Partial | Low | None |
| `§10:270-275` | `MUST` | Bootstrap establishes the listed entry artifacts before the first autonomous material run. | Partial | Partial | Med | See Rewrite Pack `R2`. |
| `§10:277` | `MAY` | Bootstrap may create assistant-specific alias files when safe and non-destructive. | Partial | Partial | Low | Define `safe` and `non-destructive` if stricter control is required. |
| `§10:279a` | `MUST` | Before bootstrap is valid, behavior stays limited to setup-safe work. | Yes | Partial | Low | None |
| `§10:279b` | `MUST NOT` | Before bootstrap is valid, no material side effects occur. | Yes | Yes | Low | None |
| `§11:303` | `MUST NOT` | Special-profile domains cannot be reclassified without governed charter-consistent change control. | Yes | Yes | Low | None |
| `§11:305a` | `MUST` | Domain-profiles mirror remains consistent with the charter. | Yes | Yes | Low | None |
| `§11:305b` | `MUST` | Classification-dependent material execution is blocked until the mirror is reconciled. | Yes | Yes | Low | None |
| `§12:325a` | `MAY` | `practices/` may describe how to operate within policy. | Yes | Yes | Low | None |
| `§12:325b` | `MUST NOT` | `practices/` cannot override charter or governance requirements. | Yes | Yes | Low | None |
| `§12:326` | `MUST NOT` | `_meta/` documents are not normative authority. | Yes | Yes | Low | None |
| `§12:327` | `MUST NOT` | `_ops/` content is not canonical runtime or policy authority. | Yes | Yes | Low | None |
| `§12:328a` | `MUST` | Discovery metadata resolves to canonical runtime surfaces. | Partial | Partial | Med | Add required resolution evidence or lint rule reference. |
| `§12:328b` | `MUST NOT` | Discovery metadata must not route canonical runtime behavior through `_ops/`. | Yes | Yes | Low | None |
| `§14:350a` | `MUST` | Charter changes are approved by the charter owner. | Yes | Yes | Low | None |
| `§14:350b-359` | `MUST` | Charter changes include rationale, consistency, reference updates, PR review, assurance gates, ADR linkage, metadata updates, approver/review date/evidence links, and continuity linkage. | Partial | Partial | Med | Define `affected references`, `standard assurance gates`, and minimum exception-linkage fields. |
| `§14:361-367` | `MUST` | Approved charter exceptions identify approver, scope, rationale, review or expiry date, and evidence. | Yes | Yes | Low | None |
| `§15:373a` | `MUST` | When a normative reference is unavailable or inconsistent, the charter remains the governing text for policy meaning. | Yes | Partial | Low | None |
| `§15:373b` | `MUST` | Unresolved machine validation or routing dependency failures are fail-closed. | Yes | Yes | Low | None |
| `§15:373c` | `MUST` | Unresolved dependency failures escalate unless the charter states another safe fallback. | Yes | Yes | Low | None |

## Authority/Accountability Map

| Flow/Decision | Decision owner | Execution owner | Escalation owner | Explicit in Charter? | Gap |
| --- | --- | --- | --- | --- | --- |
| Policy authorship and policy exceptions | Applicable policy owner | Human or agent acting under approved change control | Applicable policy owner | Yes | None |
| Objective-contract approval and version activation for material runs | Applicable policy owner | Runtime and agents using the approved effective intent contract | Applicable policy owner | Yes | None |
| Expansion of authority surfaces | Applicable policy owner | Human or agent applying the approved authority change | Applicable policy owner | Yes | None |
| Break-glass and irreversible high-risk actions | Applicable policy owner | Human or agent executing the approved break-glass action | Applicable policy owner | Yes | None |
| Autonomy-mode suspension or reduction for emergency containment | Applicable policy owner | Human or agent performing the approved containment action | Applicable policy owner | Yes | None |
| Compliance or legal interpretation when policy cannot decide deterministically | Applicable policy owner, with any required compliance or legal authority | Human implementing the resulting decision | Applicable policy owner | Yes | The escalation recipient is clear, but the acting legal/compliance decider can still be multi-party and should be named in the decision artifact. |
| Charter changes and approved charter exceptions | Charter `owner` | Human or agent implementing the approved change | Charter `owner` | Yes | Because the metadata owner is a group label, the acting human delegate must be named per `§4:133`. |
| Routine planning, implementation, verification, and continuity updates within approved bounds | Agents operating within the active objective contract and authority surfaces | Agents | Applicable policy owner | Yes | None |
| Success-signal target setting and reporting-period review | Not explicit | Not explicit | Not explicit | No | No owner is assigned for defining or validating workspace targets, portability pass criteria, or periodic metric review. |
| Bootstrap equivalence determination for alternative assurance entrypoints | Not explicit | Not explicit | Applicable policy owner only by inference | No | `Equivalent` is bootstrap-critical but has no named approver or charter-local test. |
| Objective-contract consistency adjudication when brief and intent diverge | Applicable policy owner for approval by inference | Runtime can block material autonomy; initial consistency adjudication is not explicitly assigned | Applicable policy owner by inference | Partial | Reconciliation approval is required, but who decides that inconsistency exists and what evidence is sufficient is underdefined. |

## Enforceability Matrix

| Requirement/Claim | Enforcement mechanism | Evidence artifact | Verifiable (Y/N) | Gap |
| --- | --- | --- | --- | --- |
| Material execution is objective-bound. | Objective contract requires both artifacts; missing or inconsistent artifacts fail closed; intent contract exposes `id` and `version`. | `/OBJECTIVE.md`, `/.harmony/cognition/runtime/context/intent.contract.yml`, decision or continuity artifacts (`§4`, `§9`) | Y | Minimum consistency criteria are not defined. |
| Routing happens before material side effects. | Exactly one `allow`/`escalate`/`block` outcome is required before side effects; non-determinism fails closed and escalates. | Decision artifact plus execution evidence (`§8`, `§9`) | N | The charter does not specify the ordering or timestamp fields needed to prove `before`. |
| Execution stays within approved authority surfaces. | Material runs validate approved authority surfaces and may not bypass routing or authority controls. | Authority-change decision artifacts and run evidence (`§8`, `§9`) | N | No named authority-surface inventory artifact or approval schema is defined in the charter. |
| Bootstrap gates the first autonomous material run. | Required entry artifacts must exist before the first autonomous material run; otherwise behavior stays setup-safe and non-material. | `AGENTS.md`, `alignment-check` or equivalent, `.harmony/scope.md`, `.harmony/conventions.md` (`§10`) | N | `Equivalent assurance entrypoint` is undefined. |
| Domain classification integrity is preserved. | Domain-profiles mirror must remain consistent with the charter; divergence blocks classification-dependent material execution. | `/.harmony/cognition/governance/domain-profiles.yml` and the charter (`§11`, `§15`) | Y | None |
| Surface authority hygiene is preserved. | `governance/` is normative authority; `practices/`, `_meta/`, and `_ops/` cannot override or become canonical authority. | Surface layout and discovery metadata (`§6`, `§12`) | Y | Runtime lint or validation artifacts are implied rather than named. |
| Charter changes stay under formal control. | Owner approval and the listed change bundle are mandatory. | PR record, metadata update, ADR or decision record, evidence links (`§14`) | N | `Standard assurance gates` and `affected references` are undefined. |
| Dependency failure degrades safely. | Missing or inconsistent normative references preserve charter policy meaning and block unresolved machine validation or routing. | Decision artifact recording missing dependency and block/escalation outcome (`§15`) | Y | None |
| Success signals are operable each reporting period. | Success table plus reporting-period, support-target, and workspace-target definitions. | Periodic metrics and approved workspace conventions (`§4`, `§13`) | N | Measurement owner, method, and mandatory artifact paths are missing. |
| Recovery readiness exists before execution. | `SHIP` requires rollback or recovery posture for every material change, and success signals require 100% coverage. | Run artifact describing rollback or recovery posture (`§8`, `§13`) | N | Minimum posture fields and artifact location are missing. |

## Terminology Consistency Log

| Term | Definition present? | Consistent usage? | Drift/ambiguity | Fix |
| --- | --- | --- | --- | --- |
| `objective contract` | Yes | Yes | Stable two-artifact usage across `§4` and `§9`. | None |
| `policy owner` / `applicable policy owner` | Partial | Partial | `policy owner` is defined, but `applicable policy owner` is used operationally without a separate selection rule for competing candidates. | Add explicit owner-resolution fallback. |
| `charter owner` | Yes | Yes | Group-label nuance and delegate naming requirement are explicit. | None |
| `material run` / `material autonomy` | Partial | Partial | `material run` is defined, but `material autonomy` appears as an operational subtype without its own definition. | Define `material autonomy` or normalize the wording. |
| `mutually consistent` / `diverge` | No | Partial | These terms gate objective-contract enforcement but are never defined. | Add minimum consistency criteria. |
| `equivalent assurance entrypoint` | No | No | A bootstrap-critical term is never defined. | Add equivalence criteria and approval path. |
| `standard assurance gates` | No | Partial | Required in change control but not specified internally. | Define a minimum gate set or point to a charter-local checklist. |
| `reporting period` / `workspace target` / `support target` | Yes | Partial | Defined, but the charter does not require who sets them or where measurement records live when success signals depend on them. | Add owner and evidence requirements. |
| `fail closed` | Yes | Yes | Used consistently as the safe fallback across sections. | None |

## Success Signal Operability

| Success signal | Observable indicator | Measurement method | Threshold/condition | Gap |
| --- | --- | --- | --- | --- |
| Objective binding | All material runs carry a valid, approved, and effective intent reference. | Inspect all material-run evidence for `intent_ref.id` and `intent_ref.version` against the approved effective contract. | `100%` | Approval-evidence location is implied but not standardized. |
| Routing determinism | Every material run has one auditable routing outcome before any material side effect. | Compare routing artifact timing or sequence evidence with execution-start evidence. | `100%` | The charter requires the outcome but not the ordering fields needed to prove `before`. |
| Fail-closed enforcement | Every missing required input produces `block` or `escalate` before side effects. | Review blocked or escalated cases where objective, boundary, approval, or policy evidence is absent. | `100%` | Negative-test evidence source is not specified. |
| Recovery readiness | Every material change has documented rollback or recovery posture before execution. | Inspect run evidence for rollback or recovery posture prior to execution. | `100%` | Minimum posture fields and artifact placement are missing. |
| Traceability | Decision, execution, assurance, and continuity evidence can reconstruct the run. | Check each material run for all four evidence classes. | `100%` | Evidence classes are named, but required fields are not standardized. |
| Governance stability | Unapproved governance drift remains zero for the reporting period. | Compare observed runtime or operator behavior to the approved policy and contract baseline. | `Zero drift` | No measurement owner, artifact, or comparison procedure is defined. |
| Delivery efficiency | Lead time or cycle time meets or improves the active workspace target without added drift. | Measure lead time or cycle time against the approved workspace target and drift record. | `Meets or improves target` | The charter does not require where the target is declared or how the metric is recorded. |
| Portability | Declared support targets pass bootstrap and assurance checks for the period. | Run bootstrap and assurance checks across each declared support target. | `100% passing` | Required check suite and pass criteria are not defined inside the charter. |

## Dependency Resilience

| Referenced artifact/dependency | Role in Charter logic | Criticality | If missing, what breaks? | Needed mitigation text |
| --- | --- | --- | --- | --- |
| `AGENTS.md` and the applicable agency governance chain | Higher-precedence governance for explicitly overlapping decisions | High | Precedence questions cannot be fully resolved for those decisions; waiver and narrowing logic becomes ambiguous. | Add a charter-local fallback stating that unresolved owner or waiver questions default to charter-owner escalation. |
| `/OBJECTIVE.md` | Human-readable half of the objective contract | High | Material execution must fail closed; planning context becomes incomplete. | Existing fail-closed behavior is correct; add minimum reconciliation fields for planning-only fallback. |
| `/.harmony/cognition/runtime/context/intent.contract.yml` | Machine-readable runtime authority for objective binding | High | Material execution must fail closed; routing cannot bind an approved objective. | Existing fail-closed behavior is correct; add explicit required evidence fields for the approved effective version. |
| `/.harmony/cognition/governance/domain-profiles.yml` | Mirror of domain classification rules | Medium | Automated classification-dependent material execution must be blocked. | Existing mitigation is sufficient; keep explicit block behavior. |
| `/.harmony/engine/runtime/spec/intent-contract-v1.schema.json` | Validator for intent-contract correctness | High | Material runs requiring schema validation must be blocked. | Existing mitigation is sufficient; keep explicit block behavior. |
| `/.harmony/agency/governance/delegation-boundaries-v1.yml` | Machine-readable routing support for `allow`/`escalate`/`block` | High | Deterministic routing for affected material runs breaks. | Existing mitigation is sufficient; keep explicit block behavior. |
| `/.harmony/agency/governance/delegation-boundaries-v1.schema.json` | Validator for delegation-boundary routing data | High | Deterministic routing for affected material runs breaks. | Existing mitigation is sufficient; keep explicit block behavior. |
| `/.harmony/cognition/governance/principles/principles.md` | Protected constitutional principles authority | Medium | Protected-governance edit restrictions lose a referenced authority text, though the no-edit stance still remains in the charter. | Keep the no-edit default explicit in charter text even when the reference is unavailable. |
| `.harmony/scope.md` | Local boundary exclusions and human-led zones during bootstrap | Medium | Local exclusions or human-led zones may be missing or stale, making bootstrap validity hard to prove. | Add an explicit rule that missing scoped exclusions after bootstrap invalidates material execution where local exclusions are required. |
| `.harmony/conventions.md` | Local standards, support targets, and compatibility constraints | Medium | Support targets and workspace targets can become implicit or unmeasurable. | Add mandatory declaration rules for support targets, workspace targets, and reporting evidence. |
| `alignment-check` or equivalent assurance entrypoint | Bootstrap assurance gate | High | Bootstrap validity cannot be established before the first autonomous material run. | Define equivalence criteria, minimum outputs, and the approval path for alternatives. |

## Gap Log

| ID | Missing or weak area | Impact | Severity | Proposed fix |
| --- | --- | --- | --- | --- |
| G1 | Objective-contract consistency criteria are missing for `mutually consistent` and `diverge`. | Different implementations can disagree on when material execution must block or when planning-only fallback starts. | Medium | Define minimum comparison fields and reconciliation evidence. |
| G2 | Bootstrap permits an `equivalent assurance entrypoint` without an equivalence test or approver. | Bootstrap conformance and portability can vary across workspaces without a charter-local basis. | Medium | State the minimum outputs and named approval path for equivalent entrypoints. |
| G3 | Success signals for governance stability, delivery efficiency, and portability rely on external targets or unspecified methods. | The charter cannot be fully audited or scored closed-book by a new reader. | Medium | Add owner, measurement method, and evidence artifact requirements. |
| G4 | Routing-before-side-effects and recovery readiness are required, but the charter does not define the evidence fields needed to prove sequencing or posture. | Core fail-closed and rollback claims are only partially testable. | Medium | Require ordering markers and minimum rollback or recovery posture fields in run evidence. |
| G5 | `Applicable policy owner` is used operationally without a deterministic owner-selection rule for competing explicit owners. | Escalations can stall or fork in multi-domain governance conflicts. | Low | Add owner-selection fallback and escalation default. |
| G6 | `Affected references` and `standard assurance gates` are required in change control but undefined. | Change-control completeness can be interpreted differently across operators. | Low | Define minimum reference-update scope and assurance gate set. |

## Rewrite Pack

### R1 - Objective-contract consistency criteria

Current text:

> - The objective contract consists of both artifacts together.
> - The active intent contract MUST expose a unique `id` and `version` so material execution can bind `intent_ref.id` and `intent_ref.version` to the approved effective contract.
> - Material runs MUST use the approved and effective intent-contract version.
> - The objective brief and intent contract MUST be updated in the same change whenever the governed objective changes materially.
> - Objective-contract changes MUST record rationale and approval evidence in decision or continuity artifacts.
> - If either objective artifact is missing, invalid, unavailable, or not mutually consistent, Harmony MUST fail closed for material execution.
> - If the objective brief and intent contract diverge, Harmony MUST treat the intent contract as the runtime authority for read-only planning only, MUST block material autonomy, and MUST require approved reconciliation evidence before material execution resumes.

Proposed text:

> - The objective contract consists of both artifacts together.
> - The objective brief and intent contract are `mutually consistent` only when they agree on objective scope, material constraints, approved authority surfaces, and acceptance context at the level required for material execution.
> - A `divergence` exists when either artifact widens, narrows, or contradicts any of those four elements without same-change approval evidence.
> - The active intent contract MUST expose a unique `id` and `version` so material execution can bind `intent_ref.id` and `intent_ref.version` to the approved effective contract.
> - Material runs MUST use the approved and effective intent-contract version.
> - The objective brief and intent contract MUST be updated in the same change whenever the governed objective changes materially.
> - Objective-contract changes MUST record rationale, approving authority, and evidence links in decision or continuity artifacts.
> - If either objective artifact is missing, invalid, unavailable, or not mutually consistent, Harmony MUST fail closed for material execution.
> - If the objective brief and intent contract diverge, Harmony MUST treat the intent contract as the runtime authority for read-only planning only, MUST block material autonomy, and MUST require approved reconciliation evidence that names the changed fields, the approving authority, and the effective version before material execution resumes.

### R2 - Bootstrap equivalence criteria

Current text:

> - `alignment-check` or an equivalent assurance entrypoint required by the active workspace,
>
> Bootstrap MAY create assistant-specific compatibility alias files when a local tool requires them and creation is safe and non-destructive.

Proposed text:

> - `alignment-check` or a policy-owner-approved equivalent assurance entrypoint that, at minimum, validates bootstrap completeness, objective-contract presence, scoped exclusions or human-led zones, and fail-closed behavior,
>
> Bootstrap MAY create assistant-specific compatibility alias files when a local tool requires them and creation is safe and non-destructive only after the active workspace records the equivalence decision, named approver, and evidence links in a decision artifact.

### R3 - Success-signal operability

Current text:

> Harmony is successful when the following conditions hold for every material run and each active reporting period unless an approved exception explicitly narrows the scope:

Proposed text:

> Harmony is successful when the following conditions hold for every material run and each active reporting period unless an approved exception explicitly narrows the scope. Before a reporting period starts, the active workspace MUST record the measurement owner, evidence artifact, and measurement method for each success signal in approved workspace conventions. If a signal depends on a `workspace target` or `support target`, that target MUST be declared in the same approved conventions artifact for the same reporting period; otherwise the signal is not measurable and Harmony MUST treat it as a governance gap rather than a passing result.

### R4 - Routing-order and recovery-readiness evidence

Current text:

> | `SHIP`  | Bound execution, assurance outcomes, decision artifacts, and rollback or recovery posture for every material change. |
>
> - Every material run MUST produce exactly one routing outcome of `allow`, `escalate`, or `block` before any material side effect occurs.

Proposed text:

> | `SHIP`  | Bound execution, assurance outcomes, decision artifacts with routing-order evidence, and rollback or recovery posture for every material change. Each material-change record MUST include the routing decision time or sequence marker, the execution-start time or sequence marker, the rollback or recovery owner, the minimum rollback or recovery steps, and the trigger for invoking them. |
>
> - Every material run MUST produce exactly one routing outcome of `allow`, `escalate`, or `block` before any material side effect occurs, and the decision artifact MUST record a time or sequence marker that can be compared with the first material side effect.

## Final Scores

| Category | Score |
| --- | --- |
| Internal alignment | 86 |
| Contradiction-free coherence | 88 |
| Normative integrity | 78 |
| Authority/accountability clarity | 81 |
| How operational sufficiency | 76 |
| Enforceability/auditability | 74 |
| Standalone clarity | 82 |
| Overall stands on its own score | 80 |
