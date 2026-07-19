# Charter Audit Report

- Run ID: `2026-07-19-external-tool-integrity-amendment`
- Charter path: `.octon/framework/constitution/CHARTER.md`
- Parameters: `severity_threshold=all`, `include_rewrites=true`, `include_scores=true`
- Method: closed-book audit using only the charter named above

## Overall Verdict

**Partially aligned.** The charter is internally coherent around a bounded, fail-closed constitutional engineering harness, and the external-tool-integrity amendment reinforces its existing commitments to Octon-owned authority, replaceable adapters, supported boundaries, and explicit unsupported states. No direct contradiction is present. The charter does not fully stand alone, however: decisive controls are delegated to referenced artifacts; decision, execution, and escalation owners are usually unnamed; key terms such as `external tool`, `supported interface`, `material side effect`, and `live revocation` are not defined; and success conditions lack in-charter measures and thresholds. The amendment is therefore coherent and directionally enforceable, but the charter remains dependent on its referenced control system for deterministic operation.

Canonical framing extracted from the charter:

- Elevator pitch: a supreme repo-local constitutional regime for a Constitutional Engineering Harness that makes consequential autonomous engineering explicitly scoped, authorized, fail-closed, observable, reviewable, and recoverable (`CHARTER.md:8-16`, `CHARTER.md:36-38`).
- Vision: a portable, governed, evidence-backed execution environment with replaceable adapters and a finite admitted support universe (`CHARTER.md:18-34`).
- Unique value proposition: deterministic and observable governed execution that can evolve without allowing subordinate or generated surfaces to mint authority (`CHARTER.md:20-34`, `CHARTER.md:69-87`).
- Purpose: govern consequential autonomous engineering and keep live support claims bounded, runtime-real, validator-covered, proof-backed, disclosure-backed, and non-liminal (`CHARTER.md:28-38`).
- Primary objective: maintain one bounded admitted architecture in which authority, execution, evidence, support claims, and external-tool use remain explicit and fail closed (`CHARTER.md:50-89`).

## Coverage Matrix

| Dimension (What/Does/Why/How) | Key Charter Claim | Supporting Sections | Gap? | Notes |
| --- | --- | --- | --- | --- |
| What | Octon is an authored Constitutional Engineering Harness with a Governed Agent Runtime. | Purpose (`CHARTER.md:18-26`) | No | Identity and execution core are explicit. |
| Does | It scopes, authorizes, observes, reviews, and makes consequential work recoverable. | Purpose (`CHARTER.md:28-38`) | No | The verbs are aligned with the non-negotiables. |
| Why | Live support and autonomous engineering must be trusted without silent architectural debt or authority widening. | Purpose and Non-Negotiables (`CHARTER.md:28-38`, `CHARTER.md:56-77`) | No | The risk model is clear at a principle level. |
| How | Authored authority is partitioned, material effects require routing, evidence is retained, and unsupported states stay explicit. | Non-Negotiables (`CHARTER.md:50-89`) | Yes | Owners, control procedures, evidence shapes, and thresholds are mostly delegated. |
| How | External tools remain immutable and Octon adapts through supported interfaces in Octon-owned code. | Non-Goals, Non-Negotiables, Canonical References (`CHARTER.md:40-48`, `CHARTER.md:84-87`, `CHARTER.md:137-138`) | Yes | `external tool` and `supported interface` are not defined in-charter. |
| How | Amendments require human approval, aligned validators, rationale, rollback, and projection updates. | Amendment Policy (`CHARTER.md:144-151`) | Yes | The approving role, receipt, and failed-validation route are not named. |

## Contradiction/Conflict Log

| ID | Sections in tension | Conflict description | Severity (High/Med/Low) | Why it matters | Precedence outcome |
| --- | --- | --- | --- | --- | --- |
| C1 | Charter Scope and Canonical References (`CHARTER.md:10-16`, `CHARTER.md:107-142`) | The charter is supreme repo-local authority but is subordinate to three external control classes and operationally depends on many referenced artifacts; the charter does not itself order conflicts among those external classes. | Med | A live revocation, break-glass control, and external obligation could point in different directions. | No in-charter outcome beyond treating the charter as subordinate; a durable controlling decision is not specified. |
| C2 | Immutable external tools and replaceable adapters (`CHARTER.md:79-87`) | No direct contradiction exists, but `configure`, `contain`, and `wrap` can blur into modification without definitions of tool boundary and supported interface. | Med | Two reviewers could classify the same integration differently. | The stricter reading of immutable dependency and Octon-owned change should prevail, but the charter does not state that tie-breaker. |
| C3 | Generated projections are in scope but derived-only (`CHARTER.md:13-16`, `CHARTER.md:52-55`) | The charter governs generated projections while denying them authority, but it does not define which authored source wins when a projection conflicts. | Low | Drift handling depends on referenced precedence and validation artifacts. | Authored `framework/**` or `instance/**` authority logically prevails, though no same-section conflict rule is stated. |
| C4 | Runtime-real support claims and stage-only states (`CHARTER.md:28-34`, `CHARTER.md:93-105`) | The charter requires unsupported surfaces to remain explicit but gives no promotion or demotion decision owner or proof threshold. | Med | Admission and removal could vary across operators. | No deterministic in-charter precedence outcome; referenced support, evidence, and ownership controls are required. |

## Normative Clause Audit

| Clause reference | Normative keyword | Requirement text (short) | Clear? | Testable? | Conflict risk | Fix |
| --- | --- | --- | --- | --- | --- | --- |
| `CHARTER.md:10-12` | subordinate only | Charter is supreme repo-local authority except for named external control classes. | Partial | Partial | Med | Order conflicts among the external classes and require a controlling decision record. |
| `CHARTER.md:15-16` | may / may not | Subordinate surfaces may project but not redefine the charter. | Yes | Partial | Low | Name the drift check or evidence requirement. |
| `CHARTER.md:28-34` | must | Retained live surfaces must meet six conditions or leave the live claim explicitly. | Partial | Partial | Med | Define the admission evidence and decision owner. |
| `CHARTER.md:52-55` | preserve / keep | Preserve five classes; authored authority stays in two classes; generated and inputs remain non-authoritative. | Yes | Yes | Low | None. |
| `CHARTER.md:56-57` | fail closed | Missing ownership, evidence, supported claims, or resolved policy must block. | Yes | Partial | Low | Name the blocked-state evidence and escalation owner. |
| `CHARTER.md:58-60` | require | Support universe stays finite and material effects require authority routing. | Yes | Partial | Med | Define materiality and the routing receipt. |
| `CHARTER.md:61` | prohibit | Hidden human intervention and silent authority widening are prohibited. | Yes | Partial | Low | Define observable evidence for human intervention. |
| `CHARTER.md:62-64` | require | Recurring autonomy is mission-backed; compensating mechanisms have owner and retirement controls. | Yes | Partial | Low | Name required artifact fields. |
| `CHARTER.md:65-68` | allow only / require | Legacy shims must be explicit and behavioral claims require retained evidence. | Yes | Partial | Low | Define non-conflict and acceptable evidence thresholds. |
| `CHARTER.md:69-77` | keep / never / may not | Disclosure and host projections stay subordinate and deny-only cases stay out of support claims. | Yes | Partial | Low | Bind each to its referenced validator or receipt. |
| `CHARTER.md:78-83` | keep / treat / require | One orchestrator is default; adapters are replaceable and support claims are bounded. | Yes | Partial | Low | Name exception and conformance routes. |
| `CHARTER.md:84-87` | treat / may / must | External tools are immutable; supported uses are allowed; Octon requirements stay in Octon-owned code. | Partial | Partial | Med | Define external-tool boundary, supported interface, and insufficient-interface route. |
| `CHARTER.md:88-89` | require / exclude | Final disclosure states the admitted envelope and excludes unadmitted surfaces. | Yes | Yes | Low | None. |
| `CHARTER.md:93-105` | remain | Adoption claims and excluded states remain bounded by runtime and proof posture. | Partial | Partial | Med | Add proof cutoff and admission owner. |
| `CHARTER.md:146-147` | require | Amendments require human approval and aligned documentation and validators in one branch. | Partial | Yes | Med | Name approver evidence and validation outcome. |
| `CHARTER.md:148-151` | must | Amendments record rationale, rollback, live notes, and update projections in the same change. | Yes | Yes | Low | None. |
| `CHARTER.md:155-156` | review | Review on material change and at least quarterly. | Partial | Yes | Low | Name review owner, artifact, and overdue behavior. |

## Authority/Accountability Map

| Flow/Decision | Decision owner | Execution owner | Escalation owner | Explicit in Charter? | Gap |
| --- | --- | --- | --- | --- | --- |
| Material-side-effect authorization | Not named | One accountable orchestrator by default | Not named | Partial | Routing exists, but owners and evidence are not specified. |
| Support admission or removal | Not named | Not named | Not named | No | Conditions exist without an accountability flow. |
| External-tool interface sufficiency | Not named | Octon-owned architecture/code; executing role not named | Not named | Partial | Ownership class is not an accountable role. |
| Compensating-mechanism retirement | Mechanism owner | Not named | Not named | Partial | Owner is required, but decision and escalation flow are absent. |
| Constitutional amendment | Human governance, role unnamed | Subordinate-surface owners, unnamed | Not named | Partial | Approval class is explicit; accountable actors and receipt are not. |
| Break-glass, live revocation, or external-obligation conflict | External authority, unnamed | Not named | Not named | No | These outrank the charter but have no in-charter resolution flow. |
| Quarterly charter review | Not named | Not named | Not named | No | Cadence exists without accountability. |

## Enforceability Matrix

| Requirement/Claim | Enforcement mechanism | Evidence artifact | Verifiable (Y/N) | Gap |
| --- | --- | --- | --- | --- |
| Five-class authority partition | Path classes and subordinate projection rule | None named in-charter | Y | Validator and drift receipt are external references only. |
| Fail closed on missing prerequisites | Fail-closed non-negotiable and obligations reference | Fail-closed obligations, evidence obligations | Y | Blocked-state receipt is not specified. |
| Finite admitted support universe | Support-target declaration and schema | Support declaration plus proof and disclosure | Y | Admission threshold and approver are not stated. |
| Authority before material effects | Explicit routing requirement | None named in-charter | N | Materiality definition, route contract, and receipt are absent. |
| External tools remain unmodified | Non-goal, non-negotiable, policy reference | External-tool integrity policy | Y | Boundary definitions and conformance evidence are delegated. |
| Behavioral claims are proof-backed | Retained evidence requirement | Lab, replay, scenario, or shadow-run evidence | Y | Passing thresholds and freshness are not stated. |
| Final disclosure is bounded | Disclosure non-negotiables and contract family | RunCard/HarnessCard and disclosure contracts | Y | Exact verification procedure is delegated. |
| Amendment integrity | Same-branch approval, docs, validators, rationale, rollback, and projection updates | No amendment receipt named | Y | Human approver identity and pass criteria are unstated. |
| Quarterly review | Calendar cadence | No review artifact named | N | Owner, receipt, and overdue response are missing. |

## Terminology Consistency Log

| Term | Definition present? | Consistent usage? | Drift/ambiguity | Fix |
| --- | --- | --- | --- | --- |
| Constitutional Engineering Harness | Partial | Yes | Purpose is described, but no concise boundary definition exists. | Add a one-sentence definition. |
| Governed Agent Runtime | Partial | Yes | Qualities are listed; component boundary is not. | Define its authority and execution boundary. |
| bounded admitted finite universe | Partial | Mostly | Conditions recur, but admission unit and decision are delegated. | Define admitted tuple and admission evidence. |
| material side effect | No | Yes | Used once as a pivotal gate without a definition. | Define scope and classifier. |
| live revocation | No | Yes | Precedence-critical but undefined. | Define issuer, scope, duration, and evidence. |
| external tool | No | Yes | Could mean a dependency, service, client, or adapter. | Define the ownership boundary. |
| supported interface | No | Yes | `supported` has no source or evidence rule. | Define public/documented support and version evidence. |
| Octon-owned | Partial | Yes | Path authority classes imply ownership but do not identify accountable actors. | Distinguish repository ownership from accountability. |
| runtime-real | No | Yes | A core support condition lacks a test. | Define operational and validation criteria. |
| non-liminal | Partial | Yes | Explicit stage-only/unadmitted/reduced/unsupported states imply the meaning. | Add a concise definition. |

## Success Signal Operability

| Success signal | Observable indicator | Measurement method | Threshold/condition | Gap |
| --- | --- | --- | --- | --- |
| Bounded support universe | Every live surface maps to an admitted tuple and none is liminal. | Compare live claims to support declarations, proof, and disclosures. | Implied 100% | No review owner, freshness cutoff, or artifact is named. |
| Authority integrity | Authored authority remains in `framework/**` and `instance/**`. | Classify authoritative claims by path and projection role. | 100% | Validation mechanism is delegated. |
| Fail-closed execution | Missing prerequisite cases block before material effects. | Compare prerequisites, route, and first-effect evidence. | Implied 100% | Receipt and first-effect marker are absent. |
| Evidence-backed behavior | Every behavioral claim cites retained qualifying evidence. | Trace claims to lab, replay, scenario, or shadow-run evidence. | 100% | Evidence freshness and pass threshold are absent. |
| External-tool integrity | Each external tool remains unmodified and Octon owns required changes. | Inspect supported-interface evidence and changed ownership surfaces. | 100% | Tool/interface definitions and conformance receipt are absent. |
| Bounded final disclosure | Final disclosure excludes stage-only, unsupported, and unadmitted surfaces. | Compare disclosure to admitted support universe. | 100% | Exact artifact and validator are external. |
| Charter freshness | Review occurs on material amendments and quarterly. | Inspect dated review evidence. | Every material amendment and at least quarterly | Owner and overdue consequence are missing. |

## Dependency Resilience

| Referenced artifact/dependency | Role in Charter logic | Criticality | If missing, what breaks? | Needed mitigation text |
| --- | --- | --- | --- | --- |
| `/.octon/instance/governance/support-targets.yml` (`CHARTER.md:28-34`, `133-134`) | Declares the live support universe. | High | Live support cannot be bounded or audited. | Require fail-closed removal from live claims until restored and reviewed. |
| `/.octon/framework/constitution/charter.yml` (`CHARTER.md:109`) | Machine charter projection. | High | Machine checks cannot bind charter clauses. | Require drift block and human amendment review. |
| `/.octon/framework/constitution/precedence/normative.yml` (`CHARTER.md:110-112`) | Normative precedence. | High | Policy conflicts cannot resolve deterministically. | Require material execution to stop and a controlling decision record. |
| `/.octon/framework/constitution/precedence/epistemic.yml` (`CHARTER.md:112-113`) | Evidence precedence. | High | Conflicting evidence classes cannot resolve. | Require claims to remain unadmitted until restored. |
| `/.octon/framework/constitution/obligations/fail-closed.yml` (`CHARTER.md:114-115`) | Enumerates deny obligations. | High | Fail-closed routing loses machine definition. | Require material execution to block. |
| `/.octon/framework/constitution/obligations/evidence.yml` (`CHARTER.md:116-117`) | Defines evidence obligations. | High | Proof-backed claims cannot be admitted. | Require affected claims to become unsupported. |
| `/.octon/framework/constitution/ownership/roles.yml` (`CHARTER.md:118`) | Defines ownership roles. | High | Required owners cannot be resolved. | Require escalation to named human governance. |
| `/.octon/framework/constitution/contracts/registry.yml` (`CHARTER.md:119-120`) | Resolves contract families. | High | Contract discovery and validation become ambiguous. | Require material execution using unresolved contracts to block. |
| `/.octon/framework/constitution/contracts/authority/**` (`CHARTER.md:121-122`) | Governs authority contracts. | High | Material authority cannot be proven. | Require denial of affected effects. |
| `/.octon/framework/constitution/contracts/assurance/**` (`CHARTER.md:123-124`) | Governs assurance contracts. | High | Passing assurance cannot be proven. | Require affected claims to remain unadmitted. |
| `/.octon/framework/constitution/contracts/disclosure/**` (`CHARTER.md:125-126`) | Governs disclosure contracts. | High | Final claim envelopes cannot be verified. | Require disclosure to state the missing dependency and reduced claim. |
| `/.octon/framework/constitution/contracts/adapters/**` (`CHARTER.md:127-128`) | Governs replaceable adapter claims. | High | Adapter conformance cannot be established. | Remove affected adapter support claims. |
| `/.octon/framework/constitution/contracts/retention/**` (`CHARTER.md:129-130`) | Governs retained evidence. | High | Evidence durability cannot be trusted. | Block proof-backed promotion until restored. |
| `/.octon/framework/constitution/support-targets.schema.json` (`CHARTER.md:131-132`) | Validates support declarations. | High | Support tuples cannot be machine-validated. | Treat all affected tuples as unadmitted. |
| `/.octon/instance/governance/exclusions/action-classes.yml` (`CHARTER.md:135-136`) | Declares deny-only action classes. | High | Prohibited actions could be misclassified as support. | Deny uncertain action classes. |
| `/.octon/instance/governance/policies/external-tool-integrity.yml` (`CHARTER.md:137-138`) | Details external-tool integrity. | High | Boundary and supported-interface decisions lose operational definition. | Block external-tool-dependent recommendations until restored. |
| Naming constitution (`CHARTER.md:139-140`) | Governs canonical terminology. | Medium | Terms may drift across subordinate surfaces. | Flag drift and block authority-sensitive ambiguity. |
| Terminology glossary (`CHARTER.md:141-142`) | Supplies shared definitions. | Medium | Standalone ambiguity increases. | Keep critical charter terms defined in-charter. |

## Gap Log

| ID | Missing or weak area | Impact | Severity | Proposed fix |
| --- | --- | --- | --- | --- |
| G1 | External precedence classes lack a conflict-resolution order and decision artifact. | Break-glass, revocation, and external obligations can conflict without a deterministic outcome. | Medium | Add a fail-closed precedence-resolution clause and named decision evidence. |
| G2 | Authority and accountability flows are not assigned to named roles. | Core gates may be interpreted consistently but executed by different or unaccountable actors. | Medium | Add decision, execution, and escalation owners for material effects, support admission, amendments, and reviews. |
| G3 | External-tool boundary terms are undefined. | The same wrapper, patch, extension, or configuration can receive inconsistent treatment. | Medium | Define external tool, supported interface, modification, and insufficient-interface outcome. |
| G4 | Success conditions lack explicit measurement artifacts, freshness, and thresholds. | Claims can be declared passing without comparable proof. | Medium | Add a compact success-signal and review-receipt contract. |
| G5 | Generated-projection drift handling is implied, not explicit. | A conflicting projection may confuse a reader before external precedence rules are loaded. | Low | State that authored sources prevail and stale projections must not be used. |
| G6 | Quarterly review has no owner or overdue response. | Review cadence can lapse silently. | Low | Name the charter owner and require an overdue finding. |

## Rewrite Pack

### G1 — external precedence resolution

Current text (`CHARTER.md:10-12`):

> This charter is the supreme repo-local constitutional regime for `/.octon/**`, subordinate only to non-waivable external obligations, break-glass controls, and live revocations.

Proposed replacement:

> This charter is the supreme repo-local constitutional regime for `/.octon/**`, subordinate only to non-waivable external obligations, active break-glass controls, and live revocations. If those external controls conflict or their controlling order cannot be proven, material execution MUST stop until named human governance records the controlling authority, scope, effective time, and resolution in a durable decision artifact.

### G2 — accountable control flows

Current text (`CHARTER.md:60`, `CHARTER.md:78`, `CHARTER.md:146-147`):

> require explicit authority routing before material side effects
>
> keep one accountable orchestrator as the default execution role
>
> changes require human governance approval plus aligned doc and validator updates in the same branch

Proposed replacement:

> Before a material side effect, a named human governance owner or its explicitly delegated policy owner MUST approve the authority route; the accountable orchestrator MUST execute only within that route; unresolved or denied routes MUST escalate to the named human governance owner. Constitutional amendments and support-admission decisions MUST record the decision owner, execution owner, escalation owner, effective scope, and evidence reference in the same branch.

### G3 — external-tool boundary definitions

Current text (`CHARTER.md:84-87`):

> treat external tools as immutable dependencies: Octon may learn from them, configure them, contain them, wrap them, or invoke supported interfaces, but every Octon requirement must be satisfied by Octon-owned architecture and code without forking, patching, modifying, or reengineering the external tool

Proposed replacement:

> Treat an external tool—software whose release authority and maintained source are outside Octon—as an immutable dependency. Octon MAY learn from, configure, contain, or wrap it only through an interface documented and supported by that tool's release authority. Every required adaptation and enforcement change MUST remain in Octon-owned architecture and code. If no supported interface is sufficient, the requirement MUST be blocked or reduced in scope; Octon MUST NOT fork, patch, modify, privately derive, or reengineer the external tool.

### G4 — measurable constitutional claims

Current text (`CHARTER.md:155-156`):

> review on each material constitutional change
>
> review at least quarterly while the bounded admitted model remains active

Proposed replacement:

> The named charter owner MUST record a review receipt for each material constitutional change and at least once per calendar quarter while the bounded admitted model remains active. The receipt MUST identify the reviewed charter digest, live support declaration, open governance gaps, validator results, decision owner, and review time. A missing or stale receipt MUST be reported as a governance gap and MUST block any new or widened live support claim.

## Final Scores

| Category | Score |
| --- | ---: |
| Internal alignment | 88 |
| Contradiction-free coherence | 87 |
| Normative integrity | 80 |
| Authority/accountability clarity | 61 |
| How operational sufficiency | 72 |
| Enforceability/auditability | 70 |
| Standalone clarity | 75 |
| Overall stands on its own score | 76 |
