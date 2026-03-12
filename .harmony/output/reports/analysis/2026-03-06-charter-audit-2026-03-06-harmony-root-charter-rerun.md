# Charter Audit Report

- Run ID: `2026-03-06-harmony-root-charter-rerun`
- Charter path: `.harmony/CHARTER.md`
- Parameters: `severity_threshold=all`, `include_rewrites=true`, `include_scores=true`
- Method: Closed-book audit using only `.harmony/CHARTER.md`

## Overall Verdict

**Partially aligned.** The charter is internally strong on identity, scope, precedence, accountability, routing, bootstrap gating, and structural governance. Its pitch, purpose, primary objective, and operating model largely reinforce the same thesis: Harmony is a governed autonomous engineering harness that binds execution to objective contracts, bounded authority, fail-closed behavior, and durable evidence. The document stops short of fully standing on its own because several charter-level promises remain only partially operationalized inside the charter text: `same-change approval evidence` is relied on but undefined, baseline evidence-artifact requirements are scattered rather than normalized, Section 13 mixes per-run, per-change, and per-period success-signal scopes, and core claims around privacy preservation, append-only continuity, and tool or vendor portability are stronger than the in-charter measurement and enforcement hooks that back them.

Canonical statements extracted from `.harmony/CHARTER.md`:

- Elevator pitch: "Harmony turns a target directory into a governed autonomous engineering workspace by binding execution to explicit objectives, bounded authority, fail-closed controls, and durable evidence." (`.harmony/CHARTER.md:15-17`)
- Vision: "Enable a target directory to become a trusted autonomous engineering environment through a defined bootstrap process, with clear contracts, bounded authority, durable learning, and explicit safety, security, privacy, and policy constraints." (`.harmony/CHARTER.md:66-68`)
- Unique Value Proposition: "Harmony's unique value is delivery speed with governance integrity: objective-bound execution, deterministic routing, fail-closed controls, reversible operations, and durable continuity memory that remain portable across projects, environments, tools, and vendors." (`.harmony/CHARTER.md:70-72`)
- Purpose: reliable, safe, secure, privacy-preserving, reversible, recoverable, fail-closed autonomy; standardized delivery; bounded autonomy; durable continuity; portability and stack-agnostic operation (`.harmony/CHARTER.md:74-82`)
- Primary Objective: portable autonomous operation that is deterministic, observable, safe, privacy-preserving, reversible, recoverable, fail-closed, and bounded by approved objectives and authority surfaces (`.harmony/CHARTER.md:84-92`)
- Direct `what`: a portable harness, execution control plane, and contract-and-evidence system (`.harmony/CHARTER.md:42-48`)
- Direct `does`: objective binding, deterministic routing, authority-surface enforcement, evidence emission, and bootstrap or structure standardization (`.harmony/CHARTER.md:50-56`)
- Direct `why`: delivery speed with governance integrity, bounded autonomy, durable continuity, and portability (`.harmony/CHARTER.md:64-117`)
- Direct `how`: precedence ladder, accountability map, `PLAN -> SHIP -> LEARN`, objective-contract rules, boundary routing, bootstrap gating, domain and surface models, success signals, change control, and fail-closed normative-reference fallbacks (`.harmony/CHARTER.md:180-423`)

## Coverage Matrix

| Dimension (What/Does/Why/How) | Key Charter Claim | Supporting Sections | Gap? | Notes |
| --- | --- | --- | --- | --- |
| What | Harmony is a cross-domain constitutional harness inside a managed filesystem boundary. | Sections 1, 2, 5 (`.harmony/CHARTER.md:27-62`, `.harmony/CHARTER.md:158-178`) | No | Identity, scope, and non-goals are explicit. |
| Does | Harmony binds material execution to an explicit objective contract and routes material work before side effects occur. | Sections 2, 8, 9 (`.harmony/CHARTER.md:50-56`, `.harmony/CHARTER.md:229-288`) | No | The core control loop and routing behavior are concrete. |
| Why | Harmony exists to deliver speed with governance integrity, bounded autonomy, durable continuity, safety, privacy, and portability. | Section 3 and Section 13 (`.harmony/CHARTER.md:64-117`, `.harmony/CHARTER.md:356-380`) | Yes | Privacy, append-only continuity, and tool or vendor portability are claimed more strongly than they are measured. |
| How | Harmony resolves authority through a precedence ladder, explicit owner selection, and fail-closed ambiguity handling. | Sections 6 and 7 (`.harmony/CHARTER.md:180-227`) | No | Decision, execution, and escalation ownership are mostly explicit. |
| How | Harmony governs execution through `PLAN -> SHIP -> LEARN`, per-material-run requirements, and bootstrap gating. | Sections 8, 9, 10 (`.harmony/CHARTER.md:229-303`) | No | This is the strongest operational part of the charter. |
| How | Harmony constrains repository structure through domain classes, special profiles, and canonical surface roles. | Sections 11 and 12 (`.harmony/CHARTER.md:305-354`) | No | Domain and surface boundaries are clear and mostly enforceable. |
| How | Harmony measures success and changes itself through measurement records, change control, and normative-reference fallback rules. | Sections 13, 14, 15 (`.harmony/CHARTER.md:356-423`) | Yes | Signal scope, evidence normalization, and some critical terms remain underspecified. |

## Contradiction/Conflict Log

| ID | Sections in tension | Conflict description | Severity (High/Med/Low) | Why it matters | Precedence outcome |
| --- | --- | --- | --- | --- | --- |
| C1 | Section 13 opening sentence vs Success-signal rows (`.harmony/CHARTER.md:358-380`) | The section says the listed conditions hold "for every material run and each active reporting period," but `Recovery readiness` is material-change scoped while `Delivery efficiency` and `Portability` are reporting-period scoped. | Med | Audit scope and pass or fail units can vary by reader. | No precedence rule resolves this; the section needs a scope rewrite. |
| C2 | Section 3 core claims vs Section 13 measurement hooks (`.harmony/CHARTER.md:68-117`, `.harmony/CHARTER.md:361-380`) | Privacy preservation, append-only continuity, and portability across tools or vendors are part of the charter's core value framing, but they do not receive dedicated success signals or explicit evidence checks. | Med | Core promises read like charter obligations without equivalent operational controls. | No precedence conflict exists; the claims remain partially unsupported until operationalized or narrowed. |
| C3 | Section 7 accountability exhaustiveness vs Section 14 equivalence path (`.harmony/CHARTER.md:207-223`, `.harmony/CHARTER.md:385-399`) | Section 7 says the accountability map is exhaustive for charter-governed flows, but Section 14 allows an "equivalent governance review" without mapping the decision, execution, and escalation owners for that equivalence call. | Low | Change-control substitutions may be decided inconsistently. | Section 7 default-owner language implies the charter owner for escalation, but the full flow is still implicit. |
| C4 | Sections 8, 9, 13, and 14 (`.harmony/CHARTER.md:241-299`, `.harmony/CHARTER.md:358-399`) | Decision artifacts, continuity artifacts, measurement records, and linked approval evidence are central enforcement surfaces, but the charter never normalizes a minimum artifact contract across them. | Med | Two compliant readers can produce incompatible evidence structures and still claim conformance. | No internal precedence rule resolves this; a baseline artifact contract is needed. |

## Normative Clause Audit

| Clause reference | Normative keyword | Requirement text (short) | Clear? | Testable? | Conflict risk | Fix |
| --- | --- | --- | --- | --- | --- | --- |
| `.harmony/CHARTER.md:40` | MUST | Cross-domain Harmony surfaces must satisfy this charter's minimum rules unless a higher-precedence charter rule applies. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:134` | MUST | If the charter owner is a group label, each approval, denial, or escalation must name the acting human delegate in the decision artifact. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:190` | MAY / MUST NOT | Domain governance may specialize this charter for its domain but may not weaken or contradict it. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:200` | MAY | Workspace-local artifacts may set local values only inside slots allowed by higher-precedence governance. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:201` | MAY / MUST NOT | Higher-precedence governance may narrow or strengthen a specific decision but may not imply a waiver elsewhere. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:202` | MUST | If owner ambiguity remains after the precedence ladder, Harmony must fail closed, use the charter owner for escalation, and require a decision artifact naming the resolved owner. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:203` | MUST | If the ladder cannot resolve the governing source for a material decision, Harmony must fail closed and escalate. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:207` | MUST | Every listed accountability flow must have explicit decision, execution, and escalation owners, and new charter-governed flows must be added to the map or delegated. | Partial | Partial | Med | Add missing implied flows or narrow the exhaustiveness claim. |
| `.harmony/CHARTER.md:241-248` | MUST | Every material run must identify the objective contract, validate inputs and authority, route before side effects, fail closed on missing prerequisites, stay within bounds, and emit reconstructable evidence. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:250-256` | MUST | Every material change must record routing and execution markers plus rollback owner, steps, and trigger. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:274` | MUST | The active intent contract must expose a unique `id` and `version`. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:275` | MUST | Material runs must use the approved and effective intent-contract version. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:276` | MUST | Objective brief and intent contract must be updated in the same change when the governed objective changes materially. | Partial | Partial | Med | Define `same-change approval evidence`. |
| `.harmony/CHARTER.md:277` | MUST | Objective-contract changes must record rationale, approving authority, and evidence links in decision or continuity artifacts. | Yes | Partial | Med | Add baseline artifact fields. |
| `.harmony/CHARTER.md:278` | MUST | If either objective artifact is missing, invalid, unavailable, or inconsistent, Harmony must fail closed for material execution. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:279` | MUST | On divergence, Harmony must limit the intent contract to read-only planning, block material autonomy, and require reconciliation evidence before material execution resumes. | Partial | Partial | Med | Define reconciliation evidence and whether human-assisted material execution is equally blocked via the same artifact. |
| `.harmony/CHARTER.md:283` | MUST | Every material run must emit exactly one route before side effects and record a comparable routing marker. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:287` | MUST NOT | Intent binding may not bypass routing or other authority controls. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:288` | MUST | If routing logic or intent validation cannot be completed deterministically, Harmony must fail closed and escalate. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:292-297` | MUST | Bootstrap must establish the listed entry artifacts before the first autonomous material run. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:299` | MUST | An equivalent assurance entrypoint must record approver, review date, rationale, and evidence links before it counts as bootstrap evidence. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:301` | MAY | Bootstrap may create assistant-specific alias files only when local-tool-required, non-destructive, and justified in a decision artifact. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:303` | MUST / MUST NOT | Before bootstrap is valid, Harmony must stay in setup-safe behavior and may not perform material side effects. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:327` | MUST NOT | Special-profile domains may not be reclassified or forced into bounded surfaces without governed change control. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:329` | MUST | The domain-profile mirror must remain consistent with the charter, and divergence must block automated classification-dependent material execution. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:349` | MAY / MUST NOT | `practices/` may describe operation within policy but may not override charter or governance. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:350` | MUST NOT | `_meta/` documents may not be treated as normative authority. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:351` | MUST NOT | `_ops/` content may not be treated as canonical runtime or policy authority. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:352` | MUST / MUST NOT | Discovery metadata must resolve to canonical runtime surfaces and may not route canonical runtime behavior through `_ops/`. | Yes | Partial | Low | None |
| `.harmony/CHARTER.md:353` | MUST | Discovery-metadata conformance must be verifiable by validation rule, assurance check, or decision artifact. | Partial | Partial | Med | Define the minimum evidence contract for the proof artifact. |
| `.harmony/CHARTER.md:358` | MUST / MUST / MUST NOT | Each reporting period must begin with approved measurement records naming owner, evidence, method, and targets, and missing inputs must count as governance gaps rather than passing signals. | Partial | Partial | Med | Separate per-run, per-change, and per-period signal scope and normalize measurement-record fields. |
| `.harmony/CHARTER.md:374` | MUST | Objective binding must verify `intent_ref.id` and `intent_ref.version` against approved effective intent and approval evidence. | Partial | Partial | Med | Define linked approval evidence. |
| `.harmony/CHARTER.md:375` | MUST | Routing determinism and fail-closed enforcement must compare routing evidence with side-effect or blocked-state markers. | Yes | Partial | Med | Normalize marker format and blocked-state evidence. |
| `.harmony/CHARTER.md:376` | MUST | Recovery readiness must verify rollback owner, minimum steps, and trigger before execution starts. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:377` | MUST | Traceability must verify decision, execution, assurance, and continuity evidence exist and link to the same run. | Partial | Partial | Med | Define a shared run identifier and linkage contract. |
| `.harmony/CHARTER.md:378` | MUST | Governance stability must compare observed behavior against approved policy and record drift evidence. | Partial | Partial | Med | Define observation method and drift artifact minimums. |
| `.harmony/CHARTER.md:379` | MUST | Delivery efficiency must name the approved workspace target and reporting artifact. | Yes | Partial | Med | Clarify whether the signal is reporting-period only. |
| `.harmony/CHARTER.md:380` | MUST | Portability must name support targets and the checks used to determine pass or fail. | Yes | Partial | Med | Align this signal with broader tool or vendor portability claims. |
| `.harmony/CHARTER.md:390-399` | MUST | Charter changes must be charter-owner approved and include rationale, consistency checks, affected-reference updates, PR review, assurance gates, material-framing linkage, metadata updates, approver data, and exception evidence linkage. | Yes | Partial | Low | Clarify who can approve an "equivalent governance review." |
| `.harmony/CHARTER.md:401-407` | MUST | Approved charter exceptions must identify approver, scope, rationale, review or expiry date, and linked evidence. | Yes | Yes | Low | None |
| `.harmony/CHARTER.md:413` | MUST | If a normative reference is unavailable or inconsistent when needed, Harmony must treat the charter as policy meaning, fail closed for unresolved machine dependencies, and escalate unless another safe fallback is explicit. | Yes | Yes | Low | None |

## Authority/Accountability Map

| Flow/Decision | Decision owner | Execution owner | Escalation owner | Explicit in Charter? | Gap |
| --- | --- | --- | --- | --- | --- |
| Policy authorship and policy exceptions | Applicable policy owner | Human or agent acting under approved change control | Applicable policy owner | Yes | None |
| Objective-contract approval and version activation for material runs | Applicable policy owner | Runtime and agents using the approved effective intent contract | Applicable policy owner | Yes | None |
| Expansion of authority surfaces | Applicable policy owner | Human or agent applying the approved authority change | Applicable policy owner | Yes | None |
| Break-glass and irreversible high-risk actions | Applicable policy owner | Human or agent executing the approved break-glass action | Applicable policy owner | Yes | None |
| Autonomy-mode suspension or reduction for emergency containment | Applicable policy owner | Human or agent performing the approved containment action | Applicable policy owner | Yes | None |
| Compliance or legal interpretation when policy cannot decide deterministically | Applicable policy owner, with any required compliance or legal authority | Human implementing the resulting decision | Applicable policy owner | Yes | None |
| Objective-contract divergence adjudication and approved reconciliation | Applicable policy owner | Runtime blocks material execution; human or agent applies the approved reconciliation | Applicable policy owner | Yes | None |
| Bootstrap equivalence approval for an alternative assurance entrypoint | Applicable policy owner | Human or agent establishing bootstrap with the approved equivalent assurance entrypoint | Applicable policy owner | Yes | None |
| Reporting-period success-signal measurement configuration and target approval | Applicable policy owner | Human or agent maintaining the approved measurement record and reporting artifacts | Applicable policy owner | Yes | None |
| Charter changes and approved charter exceptions | Charter `owner` | Human or agent implementing the approved change | Charter `owner` | Yes | None |
| Routine planning, implementation, verification, and continuity updates within approved bounds | Agents operating within the active objective contract and authority surfaces | Agents | Applicable policy owner | Yes | Decision ownership is role-class based rather than tied to a named human, which is acceptable only because scope is explicitly bounded. |
| Materiality classification before routing | Not explicit | Runtime or agents implied | Applicable policy owner implied | No | Core gating logic depends on what counts as a material run, but no explicit flow owner or artifact is named. |
| Equivalent governance review selection for charter changes | Charter owner implied | Human or agent running the substitute review | Charter owner implied | No | Section 14 permits equivalence without mapping the substitution decision as a named accountability flow. |

## Enforceability Matrix

| Requirement/Claim | Enforcement mechanism | Evidence artifact | Verifiable (Y/N) | Gap |
| --- | --- | --- | --- | --- |
| Objective-bound execution | Sections 8 and 9 require validated objective-contract binding before material execution. | Objective brief, intent contract, decision artifacts, continuity artifacts | Y | `same-change approval evidence` and linked approval evidence are not defined. |
| Deterministic routing before side effects | Section 9 requires exactly one `allow`, `escalate`, or `block` outcome before any material side effect. | Decision artifact with routing marker; first-side-effect marker | Y | Marker format and canonical linkage are not normalized. |
| Fail-closed behavior under missing prerequisites | Sections 8, 9, 10, and 15 require blocking or escalation when required evidence is absent or nondeterministic. | Decision artifact, blocked-state evidence, bootstrap evidence | Y | Blocked-state evidence is referenced but not normalized. |
| Bounded authority-surface execution | Sections 8 and 9 constrain execution to approved authority surfaces and policy bounds. | Intent contract, authority-change decision artifacts | Y | No baseline authority-surface evidence schema is given. |
| Traceable reconstructable runs | Sections 8 and 13 require decision, execution, assurance, and continuity artifacts sufficient to reconstruct the run. | Linked run artifacts across all four evidence classes | Y | Shared run identifier and minimum link fields are not explicitly required. |
| Recovery readiness before material change | Sections 8 and 13 require rollback or recovery owner, steps, and trigger before execution. | Decision and execution evidence | Y | Strongest single evidence contract in the charter. |
| Zero unapproved governance drift | Section 13 requires comparison of observed behavior against approved policy and drift recording. | Measurement record and drift evidence | N | Observation method, evidence location, and escalation path for detected drift are not normalized. |
| Portability across declared support targets | Section 13 requires named support targets and passing bootstrap or assurance checks. | Measurement record plus bootstrap or assurance reports | Y | The signal does not directly cover the charter's broader project, tool, or vendor portability claim. |
| Privacy-preserving autonomous operation | Vision, purpose, and objective claim privacy preservation as a core property. | No dedicated charter-level privacy evidence artifact is named. | N | The claim is not operationalized in success signals or enforcement clauses. |
| Append-only continuity for historical integrity | Operating philosophy asserts append-only continuity. | Continuity artifacts | N | No charter rule or success signal verifies append-only behavior or exception handling. |

## Terminology Consistency Log

| Term | Definition present? | Consistent usage? | Drift/ambiguity | Fix |
| --- | --- | --- | --- | --- |
| `objective contract` | Yes | Yes | No material drift detected. | None |
| `objective brief` | Yes | Yes | No material drift detected. | None |
| `intent contract` | Yes | Yes | No material drift detected. | None |
| `material side effect` | Yes | Mostly | The definition is broad, but the charter never names who classifies borderline cases before routing. | Add a materiality-classification rule and owner. |
| `material run` | Yes | Mostly | "Can produce" is conceptually clear but operationally open-ended without a pre-run classifier. | Add classification evidence requirements. |
| `applicable policy owner` | Yes | Mostly | The term is defined well, but owner resolution still depends on external documents naming explicit humans or roles. | Add a default resolution artifact path or procedure. |
| `same-change approval evidence` | No | No | Used to decide divergence and same-change updates, but never defined. | Define the term and its minimum fields. |
| `decision artifact` | Yes | Mostly | It is central to enforcement but lacks a normalized minimum field set. | Add a baseline artifact contract. |
| `continuity artifact` | Yes | Mostly | The charter promises append-only continuity but does not define append-only behavior at the artifact level. | Add explicit append-only requirements and exception handling. |
| `measurement record` | Yes | Mostly | Scope, canonical placement, and minimum linkage to reporting artifacts are not fully normalized. | Add `scope` and artifact-link requirements. |
| `alignment-check` | No | Partial | Bootstrap-critical assurance entrypoint is named but not defined in-charter. | Add a minimum behavior definition or a mandatory characteristics list. |
| `approved workspace conventions` | No | Partial | Section 13 relies on this phrase without defining whether it points only to `.harmony/conventions.md` or a broader slot. | Define the canonical artifact slot for measurement records. |
| `support target` | Yes | Mostly | The definition covers repository, operating system, and toolchain combinations, but not the broader tool or vendor portability claim. | Narrow the claim or broaden the definition and measurement rules. |
| `routing prerequisites` | No | Partial | Named in Section 8 output requirements but not defined. | Add a definition listing the minimum routing inputs. |

## Success Signal Operability

| Success signal | Observable indicator | Measurement method | Threshold/condition | Gap |
| --- | --- | --- | --- | --- |
| Objective binding | Material runs cite a valid, approved, effective intent version. | Verify `intent_ref.id` and `intent_ref.version` against the approved effective intent contract and linked approval evidence. | `100%` of material runs | Linked approval evidence is required but undefined. |
| Routing determinism | Material runs emit one auditable route before side effects. | Compare routing-decision evidence with the first material-side-effect marker. | `100%` of material runs | Marker format and artifact linkage are not normalized. |
| Fail-closed enforcement | Missing prerequisite evidence yields `block` or `escalate` before side effects. | Compare routing evidence with first-side-effect or blocked-state evidence. | `100%` of missing-evidence cases | Blocked-state evidence schema is unstated. |
| Recovery readiness | Material changes have rollback or recovery posture before execution. | Verify rollback owner, minimum steps, and trigger before execution starts. | `100%` of material changes | The section intro wrongly scopes all signals to every material run. |
| Traceability | Decision, execution, assurance, and continuity artifacts can be linked to the same run. | Verify all four evidence classes exist and cross-link to the same material run. | `100%` of material runs | No shared run-identifier contract is stated. |
| Governance stability | Unapproved governance drift remains zero for the reporting period. | Compare observed behavior against approved policy and record drift evidence. | `0` unapproved drift per reporting period | Observation method and reporting artifact are not normalized. |
| Delivery efficiency | Lead time or cycle time meets or improves the approved workspace target without increased drift. | Name the workspace target and reporting artifact used for the calculation. | Meets or improves active workspace target with no increased unapproved drift | The target is external to the charter, which is acceptable, but the charter does not define scope explicitly as reporting-period only. |
| Portability | Declared support targets pass bootstrap or assurance checks. | Name each support target and the checks used to determine pass or fail. | `100%` of declared support targets passing per reporting period | This measures support-target portability, not the full projects, tools, and vendors portability claim. |

## Dependency Resilience

| Referenced artifact/dependency | Role in Charter logic | Criticality | If missing, what breaks? | Needed mitigation text |
| --- | --- | --- | --- | --- |
| `AGENTS.md` and the applicable agency governance chain | Higher-precedence governance when explicitly in scope (`.harmony/CHARTER.md:418`) | High | Precedence questions and explicit permissions cannot be resolved from the higher-precedence layer. | Clarify in Section 15 that pre-bootstrap absence of higher-precedence files leaves the charter as temporary policy meaning but still blocks material execution until bootstrap evidence exists. |
| `/.harmony/cognition/governance/domain-profiles.yml` | Machine-readable mirror of Section 11 domain classifications (`.harmony/CHARTER.md:419`) | High | Automated classification-dependent material execution must block when mirror divergence or absence prevents trusted classification. | Add a mandatory periodic mirror-consistency validation checkpoint. |
| `/.harmony/engine/runtime/spec/intent-contract-v1.schema.json` | Validator for the intent contract (`.harmony/CHARTER.md:420`) | High | Material runs that require schema validation must block because intent validity cannot be verified deterministically. | State whether any manual fallback is ever permitted; if not, say so directly. |
| `/.harmony/agency/governance/delegation-boundaries-v1.yml` and `/.harmony/agency/governance/delegation-boundaries-v1.schema.json` | Machine-readable support for routing `allow`, `escalate`, and `block` (`.harmony/CHARTER.md:421`) | High | Material runs requiring deterministic routing must block if routing support is absent. | Clarify whether charter-only manual routing is ever acceptable or always insufficient for material runs. |
| `/.harmony/cognition/governance/principles/principles.md` | Protected constitutional principles authority (`.harmony/CHARTER.md:422`) | Medium | Protected-governance edits remain blocked without explicit human override; the charter gives no wider operational failure. | Add text making clear that the dependency is critical for governance edits, not for unrelated routine execution. |

## Gap Log

| ID | Missing or weak area | Impact | Severity | Proposed fix |
| --- | --- | --- | --- | --- |
| G1 | `same-change approval evidence` is required but undefined. | Divergence adjudication and same-change objective updates can be interpreted inconsistently. | Medium | Define the term in Section 4 and require minimum fields in the reconciliation evidence path. |
| G2 | Baseline evidence-artifact requirements are scattered instead of normalized. | Auditability weakens because different artifact structures can still claim compliance. | Medium | Add a shared minimum contract for decision, execution, assurance, continuity, and measurement artifacts. |
| G3 | Success-signal scope mixes per-run, per-change, and per-period obligations. | Readers can audit the same signal set using incompatible units of analysis. | Medium | Rewrite Section 13 to attach explicit scope to each signal and update the measurement-record definition. |
| G4 | Core claims on privacy preservation, append-only continuity, and broad portability exceed current measurement hooks. | The charter promises more than it can independently verify or enforce. | Medium | Add dedicated success signals and measurement rules or narrow the claims to match current controls. |
| G5 | Materiality classification and routing prerequisites are not assigned as an explicit accountability flow. | Borderline operations can be scoped or routed inconsistently. | Low | Add a flow for pre-run materiality and routing-input determination. |
| G6 | `alignment-check` and `approved workspace conventions` are bootstrap- or measurement-critical but undefined in-charter. | A new reader cannot tell the minimum content required for bootstrap assurance or measurement records from this charter alone. | Low | Add minimum behavior or artifact-slot definitions for both terms. |

## Rewrite Pack

### R1 (`G1`)

Current text (`.harmony/CHARTER.md:141`):

```text
| `divergence`                  | A condition where the objective brief and intent contract widen, narrow, omit, or contradict one another on objective scope, material constraints, approved authority surfaces, or acceptance context without same-change approval evidence.                                   |
```

Proposed text:

```text
| `same-change approval evidence` | A decision artifact created in the same approved change that records the changed fields, approving authority, review date, effective version, and links to the paired objective-brief and intent-contract updates. |
| `divergence`                   | A condition where the objective brief and intent contract widen, narrow, omit, or contradict one another on objective scope, material constraints, approved authority surfaces, or acceptance context without linked same-change approval evidence. |
```

### R2 (`G2`)

Current text (`.harmony/CHARTER.md:250-256`):

```text
For every material change, the decision and execution evidence MUST include:

- the routing decision time or sequence marker,
- the execution-start time or sequence marker for the first material side effect,
- the rollback or recovery owner,
- the minimum rollback or recovery steps,
- the trigger or condition for invoking rollback or recovery.
```

Proposed text:

```text
For every material run, every decision, execution, assurance, and continuity artifact MUST include a shared run identifier, artifact type, producing actor, creation time or sequence marker, linked intent-contract reference, and links to related evidence artifacts.

For every material change, the decision and execution evidence MUST also include:

- the routing decision time or sequence marker,
- the execution-start time or sequence marker for the first material side effect,
- the rollback or recovery owner,
- the minimum rollback or recovery steps,
- the trigger or condition for invoking rollback or recovery.
```

### R3 (`G3`)

Current text (`.harmony/CHARTER.md:358`):

```text
Harmony is successful when the following conditions hold for every material run and each active reporting period unless an approved exception explicitly narrows the scope. Before a reporting period starts, the applicable policy owner MUST approve a measurement record in approved workspace conventions for each success signal below. Each measurement record MUST name the measurement owner, evidence artifact, measurement method, and any required `workspace target` or `support target`. If a required target, measurement record, or evidence artifact is missing, the affected success signal MUST be treated as a governance gap and MUST NOT be counted as passing.
```

Proposed text:

```text
Harmony is successful when each success signal below holds at its stated scope: per material run, per material change, or per reporting period, unless an approved exception explicitly narrows that scope. Before a reporting period starts, the applicable policy owner MUST approve a measurement record in approved workspace conventions for each success signal below. Each measurement record MUST name the measurement owner, evidence artifact, measurement method, scope, and any required `workspace target` or `support target`. If a required target, measurement record, or evidence artifact is missing, the affected success signal MUST be treated as a governance gap and MUST NOT be counted as passing.
```

### R4 (`G4`)

Current text (`.harmony/CHARTER.md:361-380`):

```text
| Success signal          | Observable condition                                                                                                                                   |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Objective binding       | 100% of material runs are bound to a valid, approved, and effective intent contract version.                                                           |
| Routing determinism     | 100% of material runs emit an auditable `allow`, `escalate`, or `block` outcome before any material side effect occurs.                                |
| Fail-closed enforcement | 100% of missing required objective, boundary, approval, or policy evidence results in `block` or `escalate` before material side effects occur.        |
| Recovery readiness      | 100% of material changes have documented rollback or recovery posture before execution.                                                                |
| Traceability            | 100% of material runs produce decision, execution, assurance, and continuity evidence sufficient to reconstruct objective, route, action, and outcome. |
| Governance stability    | Unapproved governance drift remains zero for the reporting period.                                                                                     |
| Delivery efficiency     | Reported lead time or cycle time meets or improves the active workspace target without increasing unapproved governance drift.                         |
| Portability             | 100% of declared support targets remain passing under bootstrap and assurance checks for the reporting period.                                         |
```

Proposed text:

```text
| Success signal          | Observable condition                                                                                                                                   |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Objective binding       | 100% of material runs are bound to a valid, approved, and effective intent contract version.                                                           |
| Routing determinism     | 100% of material runs emit an auditable `allow`, `escalate`, or `block` outcome before any material side effect occurs.                                |
| Fail-closed enforcement | 100% of missing required objective, boundary, approval, or policy evidence results in `block` or `escalate` before material side effects occur.        |
| Recovery readiness      | 100% of material changes have documented rollback or recovery posture before execution.                                                                |
| Traceability            | 100% of material runs produce decision, execution, assurance, and continuity evidence sufficient to reconstruct objective, route, action, and outcome. |
| Governance stability    | Unapproved governance drift remains zero for the reporting period.                                                                                     |
| Delivery efficiency     | Reported lead time or cycle time meets or improves the active workspace target without increasing unapproved governance drift.                         |
| Portability             | 100% of declared support targets remain passing under bootstrap and assurance checks for the reporting period.                                         |
| Privacy preservation    | 100% of material runs handling governed data stay within approved privacy constraints or record an approved exception before material side effects.     |
| Continuity integrity    | 100% of continuity artifacts preserve append-only history or record an approved exception with rationale and evidence.                                 |
| Tool and vendor portability | 100% of declared tool or vendor substitutions needed for the workspace portability claim are covered by an approved support target or exception.    |
```

Add these measurement rules after the current Section 13 rules:

```text
- `Privacy preservation` MUST verify the governing privacy constraints for the run, any approved exception, and the linked evidence showing the constraint was satisfied before material side effects occurred.
- `Continuity integrity` MUST verify that continuity artifacts append new history without overwriting prior approved records unless an approved exception records why the overwrite is safe.
- `Tool and vendor portability` MUST name the declared tool or vendor substitution paths covered during the reporting period and the checks or approved exceptions that justify the portability claim.
```

## Final Scores

| Category | Score |
| --- | ---: |
| Internal alignment | 86 |
| Contradiction-free coherence | 88 |
| Normative integrity | 78 |
| Authority/accountability clarity | 81 |
| How operational sufficiency | 76 |
| Enforceability/auditability | 74 |
| Standalone clarity | 82 |
| Overall stands on its own score | 80 |
