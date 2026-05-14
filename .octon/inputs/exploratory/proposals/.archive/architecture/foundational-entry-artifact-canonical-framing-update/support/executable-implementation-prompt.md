# Executable Implementation Prompt

prompt_id: foundational-entry-artifact-canonical-framing-update-implementation-2026-05-14
packet: .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
route_id: run-packet-implementation
generated_for: Foundational Entry-Artifact Canonical Framing Update
generated_at: 2026-05-14

## Authority Posture

You are implementing an accepted proposal packet. The packet is an
implementation aid, not durable authority. Durable authority may land only in
the declared promotion targets outside the proposal path and only after
validation, retained evidence, and post-implementation receipts support the
claim.

Before any durable edit, rerun both gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
```

If either command fails, stop. Record the blocker with command output and do not
edit durable targets.

Keep `proposal.yml#status` as `accepted`. The later `promote-proposal`
lifecycle route owns the implemented-status rewrite. Do not claim the packet is
implemented, closed out, or archive-ready while `support/implementation-run.md`,
`support/implementation-conformance-review.md`, or
`support/post-implementation-drift-churn-review.md` is missing, failing,
unresolved, blocked, or stale.

Refuse closeout and block archive-ready claims until those implementation,
conformance, and drift/churn receipts exist, pass, and have no unresolved
items.

## Target End State

The seven approved `.octon/**` entry artifacts introduce Octon as a
Constitutional Engineering Harness whose execution core is a Governed Workflow
Runtime. The durable wording must make these points stand alone without
depending on this packet path:

- Workflow state owns control flow. Agents do not.
- Each admitted workflow receives a task-specific execution harness.
- Agents participate only as bounded, evidenced activity nodes.
- Engine-owned authorization, typed effect tokens, context packs, retained
  evidence, replay, rollback, and closeout control consequential work.
- Generated projections, raw inputs, chat, host state, tool availability, MCP
  availability, Durable Object state, and external workflow dashboards are not
  authority, permission, policy, retained evidence, or closeout truth.
- Future workflow-statechart, agent-node, replay, connector, MCP, Durable
  Object, and external workflow-engine work is signposted only as future work.

## In Scope

Only these durable promotion targets are in scope:

- `.octon/README.md`
- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/_meta/terminology/glossary.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`

Packet-local receipt updates are also required after durable changes land:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Retained validation and promotion evidence must live outside the proposal path,
under a canonical evidence root such as:

- `.octon/state/evidence/validation/proposals/foundational-entry-artifact-canonical-framing-update/<timestamp>/`
- `.octon/state/evidence/migration/foundational-entry-artifact-canonical-framing-update/<timestamp>/`

## Out Of Scope

Do not edit these surfaces for this packet:

- repo-root `README.md`, repo-root `AGENTS.md`, or `CLAUDE.md`
- runtime crates or runtime behavior
- workflow statechart schemas
- task-specific execution harness schemas
- agent-node schemas
- workflow history, replay, idempotency, retry, or compensation implementation
- connector operation admission
- Durable Object integration
- MCP integration
- external workflow-engine integration
- support-target admissions, connector admissions, governance exclusions, or
  support matrices
- generated outputs, except a publication script's own retained receipt if an
  already-existing validator requires it

Repo-root `README.md` and `AGENTS.md` are linked repo-local companion scope.
Changing them requires a separate approved repo-local proposal.

## Ordered Workstreams

### 0. Preflight And Diff Boundary

1. Read the repo ingress, constitutional kernel, workspace charter pair,
   proposal manifests, target architecture, implementation plan, validation
   plan, acceptance criteria, file-change map, cutover checklist, rollback
   plan, risk register, and current live target files.
2. Record a Profile Selection Receipt in the implementation run notes:
   `release_state=pre-1.0`, `change_profile=atomic`,
   `transitional_exception_note=not required`.
3. Confirm the current worktree status. Preserve unrelated existing edits.
4. Confirm the strict review gate and implementation-readiness gate pass.
5. Create a retained evidence directory for command logs, diffs, and review
   receipts before durable edits begin.

### 1. `.octon/README.md`

Add governed workflow runtime framing immediately after the super-root identity
and before agent-centered language. Preserve:

- Constitutional Engineering Harness as the whole-system identity.
- the class-root table and non-authority rules.
- the registry-backed orientation role.
- generated and input non-authority rules.

Use packet wording as source material, but fit it to the live README:

```text
Octon's core runtime is best understood as a Governed Workflow Runtime:
workflow state, run contracts, authorization, evidence, replay, rollback, and
closeout own execution control. Agents participate only as bounded, evidenced
activity nodes inside admitted execution harnesses.
```

Do not imply the workflow statechart or task-specific harness schemas already
exist if they are still future packet work.

### 2. `.octon/AGENTS.md`

Preserve the adapter-only role and the pointer to
`/.octon/instance/ingress/AGENTS.md`. Keep the text terse. Replace the
agent-first behavioral sentence with bounded workflow-participation framing:

```text
Enable reliable workflow participation by bounded agents inside Octon-governed
execution boundaries. Workflow state owns control flow. Agents do not.
```

Do not add detailed runtime policy to this adapter. Do not edit repo-root
`AGENTS.md` in this packet.

### 3. Ingress And Bootstrap

Update `.octon/instance/ingress/AGENTS.md` without changing mandatory read
order, conditional orientation, human-led blocked roots, adapter parity targets,
or closeout workflow pointers.

Add a workflow-first operational rule near the opening:

```text
Octon's runtime posture is workflow-first: workflow state, run contracts,
authorization, evidence, rollback posture, and closeout own consequential
control flow. Agents participate only as bounded, evidenced activity nodes
inside admitted execution boundaries.
```

Add a concise agent boundary rule:

```text
Agents may produce candidate artifacts, summaries, reviews, classifications,
patches, repair suggestions, or exception recommendations. They may not
authorize effects, own workflow state, schedule themselves indefinitely, mutate
control truth, admit connectors, or close work.
```

Update `.octon/instance/bootstrap/START.md` near the canonical goal or
Authority Map so bootstrapping binds workflow/run authority before agent action.
Preserve the existing boot sequence, Authority Map, operator flows, publication
model, human-led zone, and minimal next actions.

Include the non-authority boundary for generated summaries, raw inputs, chat,
model memory, host UI state, tool availability, MCP server availability,
Durable Object state, and external workflow dashboards.

### 4. Terminology Glossary

Update `.octon/framework/cognition/_meta/terminology/glossary.md` so canonical
terms and compatibility terms are explicit.

Add or refine definitions for:

- Governed Workflow Runtime
- task-specific execution harness
- bounded agent node
- evidenced activity node
- deterministic governed workflow
- admitted connector operation

Constrain existing compatibility terms:

- Governed Agent Runtime remains compatibility language for the runtime core
  during transition, and must be explained as workflow runtime with bounded
  agent nodes.
- Harness must not mean prompt, model, framework, or orchestrator.
- Orchestrator remains a role/component term, not the system name.
- Autonomy must stay bounded, governed, evidenced, and support-target scoped.

Add discouraged or forbidden wording where appropriate:

- "orchestrator of agents"
- "autonomous agent worker"
- "ambient tool access"
- "Durable Object authority"

### 5. Architecture Specification And Registry

Update `.octon/framework/cognition/_meta/architecture/specification.md` with a
short "Canonical Runtime Framing" section near Purpose or Structural
Invariants:

```text
Octon's core runtime is a Governed Workflow Runtime for consequential software
work. It compiles the execution harness for each admitted workflow and allows
agents to participate only as bounded, evidenced activity nodes. Workflow state
owns control flow; agents do not.
```

Preserve the current class-root and surface-class model. Do not create a rival
control plane or new runtime contract.

Inspect `.octon/framework/cognition/_meta/architecture/contract-registry.yml`.
Change it only if the live doc-target metadata or path-family descriptions must
mention the new framing to stay aligned with the specification. If no registry
change is needed, record the no-change rationale in
`support/implementation-run.md` and in the conformance review.

### 6. Scope And Downstream References

Search the durable targets for:

- agent-first claims that make agents sound like control owners
- future-packet claims presented as live support
- proposal-path dependencies in durable text
- generated or input surfaces described as authority
- connector, tool, MCP, Durable Object, or external dashboard availability
  described as permission

Fix only occurrences inside approved durable targets. For any same-pattern issue
outside approved targets, record it as out-of-scope drift or linked companion
work instead of editing it.

### 7. Evidence, Receipts, And Gate Reviews

After durable edits land, create or update `support/implementation-run.md` with
at least:

```text
verdict: pass|blocked|fail
implemented_at: <RFC3339 timestamp>
promotion_evidence_count: <integer count of retained evidence artifacts outside the proposal path>
```

Also include:

- changed durable targets
- approved targets intentionally left unchanged, with rationale
- validation commands run and retained evidence paths
- rollback posture
- known blockers or `none`
- explicit statement that `proposal.yml#status` remains `accepted`

Then create or update `support/implementation-conformance-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count: 0` for a passing receipt
- sections required by
  `validate-proposal-implementation-conformance.sh`: Blockers, Checked
  Evidence, Promotion Target Coverage, Implementation Map Coverage, Validator
  Coverage, Generated Output Coverage, Rollback Coverage, Downstream Reference
  Coverage, Exclusions, and Final Closeout Recommendation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
```

Then create or update `support/post-implementation-drift-churn-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count: 0` for a passing receipt
- sections required by
  `validate-proposal-post-implementation-drift.sh`: Blockers, Checked Evidence,
  Backreference Scan, Naming Drift, Generated Projection Freshness, Manifest And
  Schema Validity, Repo-Local Projection Boundaries, Target Family Boundaries,
  Churn Review, Validators Run, Exclusions, and Final Closeout Recommendation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
```

Do not treat the proposal-local support files as implementation proof. They are
receipts and operational aids. Proof must point to durable target diffs and
retained evidence outside the proposal path.

## Validation Commands

Run the minimum validation floor below and retain stdout/stderr in the evidence
directory. A failure blocks implementation unless it is explicitly recorded as a
blocked gate outcome with no implemented claim.

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
```

Verify the reviewed packet files listed in `SHA256SUMS.txt` from the packet
directory:

```sh
cd .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
shasum -a 256 -c SHA256SUMS.txt
cd -
```

Run durable target validators from the repo root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh
```

If `.octon/framework/cognition/_meta/architecture/contract-registry.yml` is
changed, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-contract-registry.sh
```

Run local diff checks:

```sh
git diff --check -- .octon/README.md .octon/AGENTS.md .octon/instance/ingress/AGENTS.md .octon/instance/bootstrap/START.md .octon/framework/cognition/_meta/terminology/glossary.md .octon/framework/cognition/_meta/architecture/specification.md .octon/framework/cognition/_meta/architecture/contract-registry.yml
git status --short -- .octon/README.md .octon/AGENTS.md .octon/instance/ingress/AGENTS.md .octon/instance/bootstrap/START.md .octon/framework/cognition/_meta/terminology/glossary.md .octon/framework/cognition/_meta/architecture/specification.md .octon/framework/cognition/_meta/architecture/contract-registry.yml README.md AGENTS.md CLAUDE.md .octon/framework/engine/runtime/crates .octon/generated
```

Run the post-implementation gates after receipt updates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update
```

Known live validation risk: during prompt generation, the live
`validate-framing-alignment.sh` validator still required the old
`Enable reliable agent execution...` control-point text in ingress/bootstrap
surfaces. If the target implementation causes that validator to fail and the
validator itself is not an approved promotion target, stop and record a blocked
gate outcome. Do not silently edit validators, widen promotion targets, or
claim implementation success.

## Evidence Outputs

Retain at minimum:

- preflight review-gate and readiness logs
- target-file before/after diff
- validator stdout/stderr logs
- checksum verification log
- post-implementation conformance validator log
- post-implementation drift/churn validator log
- implementation-run receipt
- rollback notes or rollback-readiness note
- any blocked-gate report if validation cannot pass inside approved scope

Evidence must be outside the proposal path. Generated outputs are not evidence.
Transport-only terminal output is not evidence unless retained under a canonical
evidence root.

## Rollback Posture

Rollback is textual and reversible. If promoted wording creates ambiguity,
overclaims runtime capability, violates adapter parity, or conflicts with live
contracts:

1. Revert only the durable wording changes made by this packet.
2. Retain rollback evidence under a canonical state/evidence root.
3. Leave the proposal packet as lineage only.
4. Record the reason and any narrower successor wording needed.

Do not roll back runtime contracts. This packet must not change runtime
behavior.

## Delegation Posture

Delegation is optional and not a control requirement. If used, keep an
integration owner and assign disjoint write scopes, for example:

- target-doc worker: `.octon/README.md`, `.octon/AGENTS.md`,
  `.octon/instance/ingress/AGENTS.md`, `.octon/instance/bootstrap/START.md`
- terminology/architecture worker:
  `.octon/framework/cognition/_meta/terminology/glossary.md`,
  `.octon/framework/cognition/_meta/architecture/specification.md`,
  `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- verification owner: validation commands and retained evidence

Workers are not alone in the codebase. They must not revert unrelated edits,
must not broaden scope, and must not edit outside their assigned write scopes.

## Terminal Criteria

This implementation may report success only when all are true:

- Every durable target declared in `proposal.yml#promotion_targets` is either
  updated or explicitly inspected with a no-change rationale.
- No repo-root companion target or runtime behavior was changed by this packet.
- Durable target wording stands alone without proposal-path dependencies.
- Future packets remain future work and are not described as live capability.
- Generated projections, raw inputs, chat, host state, tools, MCP, Durable
  Objects, and external dashboards remain non-authority.
- Required validation commands either pass or the run reports a blocked gate
  outcome without implementation success.
- `support/implementation-run.md` exists with `verdict`, `implemented_at`, and
  `promotion_evidence_count`.
- `support/implementation-conformance-review.md` exists, has no unresolved
  passing items, and its validator has been run.
- `support/post-implementation-drift-churn-review.md` exists, has no unresolved
  passing items, and its validator has been run.
- `proposal.yml#status` remains `accepted`.

If any terminal criterion is not met, report `blocked` or `fail` with evidence
and do not claim implemented, closeout, or archive-ready status.
