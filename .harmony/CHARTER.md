---

title: Harmony Charter
description: Foundational charter for Harmony's identity, purpose, operating model, authority, scope, and governance as a portable agent-first filesystem harness.
status: Active
version: "1.4.0"
owner: Harmony governance
review_cadence: Quarterly or per minor release
effective_date: 2026-03-06

---

# Harmony Charter

Harmony is an agent-first, system-governed engineering harness that operates inside a filesystem. It provides the governing structure for how work is scoped, approved, executed, verified, and learned inside the directory where it is installed.

Elevator pitch:

Harmony turns a target directory into a governed autonomous engineering workspace by binding execution to explicit objectives, bounded authority, fail-closed controls, and durable evidence.

Marketable pitch:

Harmony is the operating layer for AI-powered software delivery, helping teams move faster while keeping work safe, accountable, and aligned to clear goals.

Executive pitch:

Harmony gives teams the speed of autonomous AI execution with the guardrails of real governance, so work gets done faster without creating chaos.

## 1. Charter Role

This charter is Harmony's cross-domain constitutional document within its scope.

It defines:

- what Harmony is and is not,
- what Harmony does,
- why Harmony exists,
- how Harmony governs execution,
- which authority rules, boundaries, and evidence requirements apply,
- how success and change control are measured.

Within the managed filesystem boundary, this charter sets the minimum cross-domain rules that Harmony domains, runtimes, workflows, capabilities, adoption artifacts, and operating practices MUST satisfy unless a higher-precedence rule defined in this charter applies.

## 2. What Harmony Is

Harmony is:

- a portable drop-in harness for governed autonomous engineering operations,
- an execution control plane for `PLAN -> SHIP -> LEARN` loops,
- a contract and evidence system for deterministic, observable, reversible, recoverable, fail-closed, policy-bounded work.

Harmony does:

- bind material execution to an explicit objective contract,
- route material work through deterministic `allow`, `escalate`, or `block` decisions before side effects occur,
- enforce bounded authority surfaces and fail-closed behavior when required evidence or approvals are missing,
- produce execution, assurance, decision, and continuity evidence that can be audited and reused,
- standardize bootstrap, domain structure, surface roles, and governance boundaries across managed workspaces.

Harmony is not:

- product or runtime business logic,
- a replacement for application or product architecture decisions,
- a bypass around governance, assurance, policy ownership, or explicit human authority.

## 3. Why Harmony Exists

### Vision

Enable a target directory to become a trusted autonomous engineering environment through a defined bootstrap process, with clear contracts, bounded authority, durable learning, and explicit safety, security, privacy, and policy constraints.

### Unique Value Proposition

Harmony's unique value is delivery speed with governance integrity: objective-bound execution, deterministic routing, fail-closed controls, reversible operations, and durable continuity memory that remain portable across projects, environments, tools, and vendors.

### Purpose

Harmony exists to:

1. Make long-running autonomous execution reliable, safe, secure, privacy-preserving, reversible, recoverable, and fail-closed under policy uncertainty.
2. Standardize delivery across direction-setting, planning, implementation, verification, governance, and continuity.
3. Keep autonomy bounded by policy, objective contracts, authority surfaces, evidence, and escalation controls.
4. Preserve durable continuity so decisions, tradeoffs, and outcomes remain auditable and reusable across managed work contexts.
5. Stay portable and stack-agnostic without requiring a single IDE, model vendor, or operating system.

### Primary Objective

Harmony's primary objective is to deliver portable autonomous operation that is:

- deterministic enough to trust,
- observable enough to debug and audit,
- safe, secure, and privacy-preserving,
- reversible, recoverable, and fail-closed under policy uncertainty,
- governed enough to run unattended only within explicit policy bounds, authority surfaces, and approved objective contracts.

### Core Goals

1. Increase delivery speed without losing safety, security, or privacy.
2. Enforce governance by default.
3. Preserve durable continuity across managed work contexts.
4. Remain portable across supported repository, operating system, and toolchain targets.
5. Favor minimal sufficient complexity and the smallest robust solution.
6. Require explicit objective binding for autonomous execution.
7. Ensure material actions are observable, attributable, reversible, recoverable, and fail-closed when required evidence or approval is missing.
8. Maintain interoperability across tools, vendors, and technology stacks.
9. Keep human effort concentrated on policy authorship, exceptions, and escalation authority rather than routine execution steps.

### Operating Philosophy

Harmony is governed by these non-negotiable concepts:

- agent-first execution with system-governed control,
- single source of truth and contract-first design,
- progressive disclosure for discovery and routing,
- deny-by-default permissions and no silent material side effects,
- objective-bound autonomy through explicit intent contracts, deterministic provenance, and fail-closed behavior under policy uncertainty,
- assurance-first tradeoff ordering: `Assurance > Productivity > Integration`,
- minimal sufficient complexity and the smallest robust solution,
- append-only continuity for historical integrity.

## 4. Definitions

| Term | Meaning |
| ---- | ------- |
| `objective contract` | The required two-artifact objective source for material autonomy: the objective brief and the active intent contract. |
| `objective brief` | The human-readable objective statement stored at `/.harmony/OBJECTIVE.md`. It explains goals, scope, constraints, and acceptance context for the workspace. |
| `intent contract` | The machine-readable artifact stored at `/.harmony/cognition/runtime/context/intent.contract.yml`. It is the runtime authority for evaluating scope, binding execution, and validating autonomous material runs. |
| `material side effect` | Any write, delete, permission change, authority-surface change, external integration action, durable state mutation, destructive operation, or irreversible state transition. |
| `material run` | Any autonomous or human-assisted execution that can produce one or more material side effects. |
| `materiality classification` | The determination of whether a proposed operation is a material run by comparing its expected behavior against the `material side effect` definition and the governing objective or policy bounds. |
| `material autonomy` | The autonomous subset of material runs whose execution can continue without a fresh human step after the routing outcome is determined. |
| `material change` | An approved change set or execution outcome that contains one or more material side effects. |
| `managed filesystem boundary` | The filesystem root containing `/.harmony/` and its descendant paths, excluding any paths explicitly excluded by policy or marked as human-led zones. |
| `human-led zone` | A path explicitly designated by policy as requiring human-directed operation. Autonomous material side effects in that path are blocked unless an approved exception says otherwise. |
| `authority surface` | Any granted write root, permission, external integration scope, or other bounded capability through which Harmony can cause material side effects. |
| `charter owner` | The governance authority named in this charter's metadata. If the charter `owner` is a group label rather than an individual, each approval, denial, or escalation response issued under that authority MUST name the acting human delegate in the relevant decision artifact. |
| `policy owner` | The accountable human authority for a governed decision in the active workspace or domain. If no narrower owner is explicitly named, the charter owner is the default policy owner. |
| `applicable policy owner` | The narrowest explicit policy owner named by the highest-precedence source that governs the decision under Section 6. If multiple explicit owners remain tied after applying Section 6, Harmony fails closed and escalates the ambiguity through the charter owner until one owner is recorded in a decision artifact. |
| `approved` | Explicitly approved by the applicable policy owner. |
| `effective` | The latest approved version that has not been revoked, superseded, or suspended. |
| `valid` | Satisfying the required schema and remaining consistent with active policy bounds, scope constraints, and authority surfaces. |
| `mutually consistent` | For the objective brief and intent contract, agreement on objective scope, material constraints, approved authority surfaces, and acceptance context at the level required for material execution. |
| `same-change approval evidence` | The linked decision-artifact evidence created in the same approved change that records the changed fields, approving authority, effective version, review date, and links to the paired artifact updates being reconciled or approved. |
| `linked approval evidence` | The approval record linked from a decision, continuity, or measurement artifact that identifies the approving authority, approved version or scope, review date, and evidence links sufficient to verify the approval being relied on. |
| `divergence` | A condition where the objective brief and intent contract widen, narrow, omit, or contradict one another on objective scope, material constraints, approved authority surfaces, or acceptance context without linked same-change approval evidence. |
| `equivalent assurance entrypoint` | A bootstrap assurance mechanism other than `alignment-check` that has explicit policy-owner approval, satisfies the minimum bootstrap checks required by Section 10, and produces the minimum bootstrap evidence required by Section 10. |
| `equivalent governance review` | A charter-change review other than rerunning the charter audit that the charter owner explicitly approves as meeting the same decision need, evidence expectations, and review rigor required by Section 14. |
| `fail closed` | Block material execution and allow only planning, drafting, inspection, orientation, and other explicitly read-only or setup-safe behavior until the missing requirement is satisfied. |
| `governance drift` | Any unapproved divergence between required policy or contract behavior and actual runtime or operator behavior. |
| `routing prerequisites` | The minimum inputs required to determine `allow`, `escalate`, or `block` deterministically: materiality classification, objective-contract status, applicable authority surfaces, applicable policy-owner resolution, and any required approvals or validation inputs. |
| `alignment-check` | The default bootstrap assurance entrypoint. Unless a higher-precedence rule requires additional checks, it verifies bootstrap completeness, objective-contract presence and consistency, scoped boundary exclusions or human-led zones, discovery-metadata conformance needed for routing, and fail-closed behavior when prerequisites are missing. |
| `decision artifact` | A durable record that captures an approval, exception, routing outcome, blocked-state result, escalation, or governing rationale. |
| `continuity artifact` | A durable record that preserves cross-run context, outcomes, follow-on work, or learned constraints in append-only history unless an approved exception records another behavior. |
| `blocked-state evidence` | The evidence showing a requested material run remained fail-closed, including the controlling requirement, blocking reason, producing actor, and time or sequence marker of the blocked state. |
| `measurement record` | The record stored in approved workspace conventions for a success signal. It names the measurement owner, evidence artifact, method, scope, threshold or condition, any required targets, and the linked reporting artifact used to publish the result. |
| `approved workspace conventions` | The effective workspace-local conventions artifact allowed by Section 6. By default this is `/.harmony/conventions.md` unless higher-precedence governance explicitly approves another artifact in the same slot. |
| `affected references` | Charter-controlled cross-references, mirrors, or cited requirement descriptions that would become incorrect, stale, or misleading if a charter change landed without corresponding updates. |
| `standard assurance gates` | The minimum review and validation requirements for a charter change: repository-level review requirements that apply to the change, a rerun of the charter audit or a charter-owner-approved equivalent governance review against the updated charter, and any checks needed to prove affected references remain consistent. |
| `support target` | A repository, operating system, and toolchain combination that the active workspace claims Harmony can support. |
| `reporting period` | The interval used to assess reporting-period success signals. By default it is the charter `review_cadence` unless approved workspace conventions declare a narrower measurement interval. |
| `workspace target` | The active delivery or operational target declared for the workspace and reporting period in approved workspace conventions or governing metrics. |
| `allow` | Proceed autonomously within the active objective contract, authority surfaces, and policy bounds. |
| `escalate` | Suspend material execution and require a policy-owner decision before continuing. |
| `block` | Deny the requested material execution and remain fail-closed until governing conditions change. |

## 5. Applicability and Scope

This charter applies to:

- the managed filesystem boundary,
- autonomous and human-assisted operations that use Harmony contracts, workflows, capabilities, or assurance gates,
- cross-domain governance questions that require a Harmony-wide answer.

In scope:

- governed engineering operations inside the managed filesystem boundary,
- autonomous orchestration with policy and assurance controls,
- evidence-backed change, continuity, and learning,
- workspace bootstrap needed before autonomous material runs.

Out of scope:

- replacing application or product architecture decisions by fiat,
- unconstrained autonomous access to human-led zones,
- ungoverned side effects outside the managed filesystem boundary except for explicitly approved authority surfaces,
- silent policy bypasses or ungated destructive operations.

## 6. Authority and Precedence

Harmony resolves conflicts using the following precedence ladder:

| Order | Authority source                                                                                                                           | Effect                                                                                                                                             |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Applicable law and other non-waivable external obligations                                                                                 | Always controls.                                                                                                                                   |
| 2     | Repository-root ingress and agency governance that explicitly governs the same decision, including repo-root `AGENTS.md` as the ingress surface for `/.harmony/AGENTS.md` and the agency contract chain | Overrides this charter only for that explicitly governed decision. Silence, implication, or looser wording does not displace charter requirements. |
| 3     | This charter                                                                                                                               | The highest Harmony-wide cross-domain authority within the managed filesystem boundary after higher-precedence rules.                              |
| 4     | Domain `governance/` contracts                                                                                                             | MAY specialize this charter for a domain but MUST NOT weaken or contradict it.                                                                     |
| 5     | Domain `runtime/` contracts and executable runtime artifacts                                                                               | Implement behavior required by this charter and domain governance.                                                                                 |
| 6     | Domain `practices/` documents and workspace adoption artifacts such as `/.harmony/scope.md`, `/.harmony/conventions.md`, and `/.harmony/OBJECTIVE.md` | Supply local operating values and standards within the slots allowed by higher-precedence rules.                                                   |
| 7     | Informative documentation, including `_meta/` and root-level orientation documents                                                         | Explain or orient; never create competing authority.                                                                                               |
| 8     | `_ops/` scripts and mutable operational state                                                                                              | Execute operations or hold mutable state; never become canonical policy or runtime authority.                                                      |

Additional precedence rules:

- `governance/` is the sole normative policy authority for its domain, subject to higher-precedence rules in the ladder above.
- Workspace-local artifacts MAY specify local boundaries, standards, support targets, and objectives only within the slots this charter and higher-precedence governance allow.
- Higher-precedence repository-root or agency governance MAY narrow or strengthen charter requirements for a specific decision, but it MUST NOT be treated as an implicit waiver of charter obligations outside that explicitly governed decision.
- The `applicable policy owner` for a material decision is the narrowest explicit owner named by the highest-precedence source that governs that decision. If multiple explicit owners remain at the same precedence level and the ladder still does not resolve the ambiguity, Harmony MUST fail closed, treat the charter owner as the escalation owner for the ambiguity, and require a decision artifact naming the resolved owner before material execution resumes.
- If two sources appear to govern the same material decision and the ladder does not resolve the conflict deterministically, Harmony MUST fail closed and escalate to the applicable policy owner.

## 7. Accountability Model

The accountability map below is the minimum required and exhaustive set for charter-governed flows named in this document. Each listed flow MUST have an explicit decision owner, execution owner, and escalation owner. Any new charter-governed flow that can approve, deny, widen, suspend, or materially constrain autonomy MUST be added to this map or explicitly delegated by domain governance before execution.

If no narrower policy owner is explicitly named for a flow, the charter owner is the default decision and escalation owner. If owner selection remains ambiguous after applying Section 6, the charter owner is the escalation owner for resolving that ambiguity until a decision artifact records the applicable policy owner.

| Flow or decision                                                                              | Decision owner                                                               | Execution owner                                                 | Escalation owner        |
| --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------- | ----------------------- |
| Policy authorship and policy exceptions                                                       | Applicable policy owner                                                      | Human or agent acting under approved change control             | Applicable policy owner |
| Objective-contract approval and version activation for material runs                          | Applicable policy owner                                                      | Runtime and agents using the approved effective intent contract | Applicable policy owner |
| Expansion of authority surfaces                                                               | Applicable policy owner                                                      | Human or agent applying the approved authority change           | Applicable policy owner |
| Break-glass and irreversible high-risk actions                                                | Applicable policy owner                                                      | Human or agent executing the approved break-glass action        | Applicable policy owner |
| Autonomy-mode suspension or reduction for emergency containment                               | Applicable policy owner                                                      | Human or agent performing the approved containment action       | Applicable policy owner |
| Compliance or legal interpretation when policy cannot decide deterministically                | Applicable policy owner, with any required compliance or legal authority     | Human implementing the resulting decision                       | Applicable policy owner |
| Materiality classification and routing-prerequisite determination for a proposed run          | Agents operating within the active objective contract and higher-precedence policy bounds | Runtime and agents evaluating the proposed run | Applicable policy owner |
| Objective-contract divergence adjudication and approved reconciliation                        | Applicable policy owner                                                      | Runtime blocks material execution; human or agent applies the approved reconciliation | Applicable policy owner |
| Bootstrap equivalence approval for an alternative assurance entrypoint                        | Applicable policy owner                                                      | Human or agent establishing bootstrap with the approved equivalent assurance entrypoint | Applicable policy owner |
| Reporting-period success-signal measurement configuration and target approval                 | Applicable policy owner                                                      | Human or agent maintaining the approved measurement record and reporting artifacts | Applicable policy owner |
| Equivalent governance review selection for charter changes                                    | Charter `owner`                                                              | Human or agent running the approved equivalent governance review | Charter `owner` |
| Charter changes and approved charter exceptions                                               | Charter `owner`                                                              | Human or agent implementing the approved change                 | Charter `owner`         |
| Routine planning, implementation, verification, and continuity updates within approved bounds | Agents operating within the active objective contract and authority surfaces | Agents                                                          | Applicable policy owner |

Humans supervise Harmony through policy, approvals, exceptions, and evidence review. Agents own routine execution only within approved boundaries, authority surfaces, and objective contracts.

## 8. Operating Model

Harmony operates as a controlled `PLAN -> SHIP -> LEARN` loop.

| Stage   | Required outputs                                                                                                     |
| ------- | -------------------------------------------------------------------------------------------------------------------- |
| `PLAN`  | Explicit objective, scope, constraints, materiality classification where needed, authority assumptions, and routing prerequisites. |
| `SHIP`  | Bound execution, assurance outcomes, decision artifacts with routing-order evidence, and rollback or recovery posture for every material change. |
| `LEARN` | Continuity artifacts, outcomes, follow-on work, and objective or policy updates when new constraints are discovered. |

Unless a higher-precedence source requires stronger fields, every decision, execution, assurance, continuity, and measurement artifact used to satisfy this charter MUST include:

- the identifier of the material run or reporting period it governs,
- the artifact type,
- the producing actor,
- the creation time or sequence marker,
- the governing objective, measurement, or approval reference that makes the artifact applicable,
- links to related evidence artifacts relied on by the artifact.

Before routing a proposed operation whose materiality is not already fixed by higher-precedence governance or the active objective contract, Harmony MUST determine whether the operation is a material run. The resulting classification evidence MUST identify the deciding actor, the controlling rule, and the routing prerequisites produced by that classification.

For every material run, Harmony MUST:

1. identify the active objective contract,
2. validate that required approvals, routing prerequisites, and authority surfaces are present and valid,
3. determine a routing outcome of `allow`, `escalate`, or `block` before material side effects occur,
4. fail closed if required evidence, validation, or approval is missing,
5. execute only within the active objective contract and approved authority surfaces,
6. emit decision, execution, assurance, and continuity evidence that use the baseline artifact fields above and are sufficient to reconstruct what happened and why.

For every material change, the decision and execution evidence MUST include the baseline fields above and:

- the routing decision time or sequence marker,
- the execution-start time or sequence marker for the first material side effect,
- the rollback or recovery owner,
- the minimum rollback or recovery steps,
- the trigger or condition for invoking rollback or recovery.

When a material run is blocked or escalated before execution, the decision evidence MUST serve as blocked-state evidence by recording the controlling requirement, blocking reason, producing actor, and the time or sequence marker at which Harmony remained fail-closed.

Continuity artifacts MUST preserve append-only history unless an approved exception identifies the approving authority, scope, rationale, review or expiry date, and linked evidence.

## 9. Objective Contract and Boundary Routing

Harmony uses the following objective-contract artifacts:

| Artifact        | Location                                                  | Role                                                                                   |
| --------------- | --------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Objective brief | `/.harmony/OBJECTIVE.md`                                  | Human-readable objective source for goals, scope, constraints, and acceptance context. |
| Intent contract | `/.harmony/cognition/runtime/context/intent.contract.yml` | Machine-readable runtime authority for binding and evaluating material autonomy.       |

Objective-contract rules:

- The objective contract consists of both artifacts together.
- The objective brief and intent contract are `mutually consistent` only when they agree on objective scope, material constraints, approved authority surfaces, and acceptance context at the level required for material execution.
- A `divergence` exists when either objective artifact widens, narrows, omits, or contradicts any of those four elements without linked same-change approval evidence.
- The active intent contract MUST expose a unique `id` and `version` so material execution can bind `intent_ref.id` and `intent_ref.version` to the approved effective contract.
- Material runs MUST use the approved and effective intent-contract version.
- The objective brief and intent contract MUST be updated in the same approved change whenever the governed objective changes materially.
- Same-change approval evidence MUST record the changed fields, approving authority, effective version, review date, and links to both updated objective artifacts.
- Objective-contract changes MUST record rationale, approving authority, and evidence links in decision or continuity artifacts using the baseline artifact fields required by Section 8.
- If either objective artifact is missing, invalid, unavailable, or not mutually consistent, Harmony MUST fail closed for material execution.
- If the objective brief and intent contract diverge, Harmony MUST treat the intent contract as the runtime authority for read-only planning only, MUST block material execution, and MUST require approved reconciliation evidence naming the changed fields, approving authority, effective version, linked approval evidence, blocked-state evidence, and the linked decision artifact before material execution resumes.

Boundary-routing rules:

- Every material run MUST produce exactly one routing outcome of `allow`, `escalate`, or `block` before any material side effect occurs, and the decision artifact MUST record the routing prerequisites used, a routing decision time or sequence marker, and the evidence links needed to compare that marker with the first material side effect or blocked-state evidence.
- `allow` authorizes execution only within the active objective contract, approved authority surfaces, and current policy bounds.
- `escalate` requires a policy-owner decision before material execution continues.
- `block` denies the requested material execution and keeps Harmony fail-closed.
- Intent binding MUST NOT bypass boundary routing or other authority controls.
- If materiality classification, boundary-routing logic, or intent validation cannot be completed deterministically, Harmony MUST fail closed and escalate.

## 10. Bootstrap Contract

Before the first autonomous material run in a target filesystem, bootstrap initialization MUST establish the minimum entry artifacts below:

- canonical `/.harmony/AGENTS.md` rendered from Harmony scaffolding bootstrap assets plus repo-root ingress adapters (`AGENTS.md` and `CLAUDE.md`),
- `alignment-check` or a policy-owner-approved equivalent assurance entrypoint,
- scoped updates to `.harmony/scope.md` for local boundary exclusions and human-led zones,
- scoped updates to `.harmony/conventions.md` for local standards, support targets, compatibility constraints, and any measurement records required by Section 13.

`alignment-check` is the default bootstrap assurance entrypoint. Unless a higher-precedence rule requires additional checks, it MUST validate bootstrap completeness, objective-contract presence and mutual consistency, scoped boundary exclusions or human-led zones, discovery-metadata conformance needed for routing, and fail-closed behavior when required prerequisites are missing.

An equivalent assurance entrypoint MUST satisfy the same minimum check set as `alignment-check`, MUST be explicitly approved by the applicable policy owner before it is treated as valid bootstrap evidence, and MUST record its named approver, review date, rationale, evidence links, and substituted check set in a decision artifact.

Bootstrap MAY create assistant-specific compatibility alias files only when a local tool requires them, the alias does not remove, rename, or weaken canonical governance or runtime artifacts, and the bootstrap decision artifact records the approving authority, why the alias is safe and non-destructive, and how canonical artifacts remain authoritative.

Until bootstrap artifacts are present and valid, Harmony MUST remain limited to orientation, planning, drafting, inspection, and other setup-safe behavior, and MUST NOT perform material side effects.

## 11. Domain Model

Harmony uses the following domain classes:

### Bounded-surface domains

- `agency`
- `capabilities`
- `cognition`
- `orchestration`
- `scaffolding`
- `assurance`
- `engine`

These domains use explicit `runtime/`, `governance/`, and `practices/` distinctions as defined by this charter.

### Special-profile domains

- `continuity` (`state-tracking`)
- `ideation` (`human-led`)
- `output` (`artifact-sink`)

Special-profile domains MUST NOT be reclassified into bounded-surface domains or required to adopt bounded `runtime/`, `governance/`, or `practices/` surfaces unless their profile is changed through governed charter-consistent change control.

`/.harmony/cognition/governance/domain-profiles.yml` is the machine-readable mirror of the domain classifications defined in this section and MUST remain consistent with this charter. If the mirror diverges from this charter, the charter governs and automated classification-dependent material execution MUST be blocked until the mirror is reconciled.

## 12. Surface Model

Harmony uses the following surface roles:

| Surface       | Role                                                                | Authority status                                              |
| ------------- | ------------------------------------------------------------------- | ------------------------------------------------------------- |
| `runtime/`    | Executable and discoverable runtime artifacts and runtime contracts | Canonical execution surface                                   |
| `governance/` | Normative policy and contract authority                             | Canonical policy surface                                      |
| `practices/`  | Operating standards and runbooks                                    | Operational guidance only; cannot override governance         |
| `_meta/`      | Explanatory architecture and reference documentation                | Informative only                                              |
| `_ops/`       | Operational scripts and mutable state                               | Operational only; never canonical runtime or policy authority |

Surface rules:

- `governance/` is the sole normative policy authority for its domain, subject to the higher-precedence rules in Section 6.
- `runtime/` implements the behavior required by this charter and applicable governance.
- `practices/` MAY describe how to operate within policy, but MUST NOT override charter or governance requirements.
- `_meta/` documents MUST NOT be treated as normative authority.
- `_ops/` content MUST NOT be treated as canonical runtime behavior or normative policy authority.
- Discovery metadata such as `manifest.yml`, `registry.yml`, and equivalent indexes MUST resolve to canonical runtime surfaces and MUST NOT route canonical runtime behavior through `_ops/`.
- Discovery metadata conformance MUST be verifiable through an approved validation rule, assurance check, or decision artifact that records the canonical runtime surfaces the metadata resolves to using the baseline artifact fields required by Section 8.
- Root-level framing artifacts in `/.harmony/` provide orientation and local constraints within the slots allowed by this charter; they do not replace governance or runtime contracts.

## 13. Success Signals

Harmony is successful when each success signal below holds at its stated scope unless an approved exception explicitly narrows that scope. The valid scopes are `per material run`, `per material change`, and `per reporting period`. Before a reporting period starts, the applicable policy owner MUST approve a measurement record in approved workspace conventions for each success signal below. Each measurement record MUST name the measurement owner, evidence artifact, measurement method, scope, threshold or condition, any required `workspace target` or `support target`, and the linked reporting artifact used to publish the result. If a required target, measurement record, evidence artifact, reporting artifact, or linked exception decision artifact is missing, the affected success signal MUST be treated as a governance gap and MUST NOT be counted as passing.

| Success signal | Scope | Observable condition |
| -------------- | ----- | -------------------- |
| Objective binding | `per material run` | 100% of material runs are bound to a valid, approved, and effective intent contract version. |
| Routing determinism | `per material run` | 100% of material runs emit an auditable `allow`, `escalate`, or `block` outcome before any material side effect occurs. |
| Fail-closed enforcement | `per material run` | 100% of missing required objective, boundary, approval, or policy evidence results in `block` or `escalate` before material side effects occur. |
| Recovery readiness | `per material change` | 100% of material changes have documented rollback or recovery posture before execution. |
| Traceability | `per material run` | 100% of material runs produce decision, execution, assurance, and continuity evidence sufficient to reconstruct objective, route, action, and outcome. |
| Governance stability | `per reporting period` | Unapproved governance drift remains zero for the reporting period. |
| Delivery efficiency | `per reporting period` | Reported lead time or cycle time meets or improves the active workspace target without increasing unapproved governance drift. |
| Portability | `per reporting period` | 100% of declared support targets remain passing under bootstrap and assurance checks for the reporting period. |
| Privacy preservation | `per material run` | 100% of material runs subject to explicit privacy constraints remain within approved privacy constraints or record an approved exception before material side effects occur. |
| Continuity integrity | `per reporting period` | 100% of continuity artifacts created in the reporting period preserve append-only history or record an approved exception with rationale and linked evidence. |
| Tool and vendor portability | `per reporting period` | 100% of declared tool or vendor substitution paths needed to support Harmony's portability claim are covered by approved support targets, passing assurance checks, or approved exceptions. |

Success-signal measurement rules:

- `Objective binding` MUST verify `intent_ref.id` and `intent_ref.version` against the approved effective intent contract and linked approval evidence.
- `Routing determinism` and `Fail-closed enforcement` MUST compare routing-decision evidence with the first material-side-effect marker or blocked-state evidence for the same material run.
- `Recovery readiness` MUST verify the rollback or recovery owner, minimum steps, and trigger before execution starts.
- `Traceability` MUST verify that decision, execution, assurance, and continuity evidence exist, use the baseline artifact fields required by Section 8, and can be linked to the same material run.
- `Governance stability` MUST compare observed behavior against the approved policy and contract requirements in force for the reporting period, record any drift evidence, and link the reporting artifact that publishes the result.
- `Delivery efficiency` MUST name the approved workspace target and the reporting artifact used to calculate lead time or cycle time.
- `Portability` MUST name each declared support target and the bootstrap or assurance checks used to determine pass or fail.
- `Privacy preservation` MUST verify the privacy constraints that apply to the run, any approved exception, and the linked evidence showing the constraint was satisfied before material side effects occurred.
- `Continuity integrity` MUST verify that continuity artifacts append new history without overwriting prior approved records unless an approved exception records why the overwrite is safe.
- `Tool and vendor portability` MUST name the declared substitution paths covered during the reporting period and the checks or approved exceptions that justify the portability claim.

## 14. Change Control

For charter change control:

- `affected references` are any charter-controlled cross-references, mirrors, or cited requirement descriptions that would become incorrect, stale, or misleading if the charter change landed without corresponding updates.
- `standard assurance gates` are the repository-level review and validation requirements that apply to the change, a re-run of the charter audit or equivalent governance review against the updated charter, and any checks needed to prove affected references remain consistent.

Charter changes MUST be approved by the charter `owner` and MUST include:

- explicit rationale and impact statement,
- consistency with higher-precedence repository and agency governance,
- same-change updates to affected references when required for correctness,
- PR-based review and standard assurance gates,
- explicit charter-owner approval of any equivalent governance review used instead of rerunning the charter audit or another required governance review, including the substituted review, rationale, review date, and evidence links,
- ADR or decision-record linkage for material charter framing changes,
- same-change updates to charter metadata, including `effective_date` and version,
- named approver, review date, and evidence links,
- append-only continuity evidence linkage for approved exceptions.

Approved charter exceptions MUST identify:

- the approving human authority,
- the scope of the exception,
- the rationale,
- the review or expiry date,
- linked evidence.

This charter does not override the protected change-control rules for `/.harmony/cognition/governance/principles/principles.md`.

## 15. Normative References

The references below validate or mirror rules already stated in this charter. They do not replace the minimum governing behavior stated here. If a normative reference is unavailable or inconsistent with this charter when it is needed for material execution, Harmony MUST treat this charter as the governing text for policy meaning, MUST fail closed for any unresolved machine validation or routing dependency, and MUST escalate unless this charter explicitly states another safe fallback.

| Reference                                                                                                                         | Role                                                                        | If unavailable                                                                           |
| --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `AGENTS.md` and the applicable agency governance chain                                                                            | Higher-precedence governance for the same decision when explicitly in scope | Before bootstrap completes, use this charter as temporary policy meaning only and block material execution until bootstrap evidence exists. Do not infer missing permissions or approvals; escalate unresolved precedence questions. |
| `/.harmony/cognition/governance/domain-profiles.yml`                                                                              | Machine-readable mirror of the domain classifications in Section 11         | Use the classifications in this charter and block automated reclassification.            |
| `/.harmony/engine/runtime/spec/intent-contract-v1.schema.json`                                                                    | Validator for the intent contract                                           | Block material runs that require schema validation. Manual review MAY support read-only planning, but it is not sufficient for material execution. |
| `/.harmony/agency/governance/delegation-boundaries-v1.yml` and `/.harmony/agency/governance/delegation-boundaries-v1.schema.json` | Machine-readable support for routing `allow`, `escalate`, and `block`       | Block material runs that require deterministic routing. Charter-only manual interpretation MAY guide planning, but it is not sufficient to authorize material execution. |
| `/.harmony/cognition/governance/principles/principles.md`                                                                         | Protected constitutional principles authority                               | Protected-governance edits remain disallowed unless explicit human override is provided. Missing or inaccessible principles text does not expand authority for unrelated non-governance execution. |

## 16. Informative References

The references below are explanatory or orienting only. They can help readers understand Harmony, but they do not create normative authority.

- `/.harmony/START.md`
- `/.harmony/cognition/_meta/architecture/specification.md`
- `/.harmony/cognition/_meta/architecture/runtime-vs-ops-contract.md`
