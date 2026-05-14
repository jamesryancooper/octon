# Executable Implementation Prompt

implementation_prompt_id: framing-boundary-and-terminology-guardrails-implementation-prompt-2026-05-14
proposal_path: .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
route_id: run-packet-implementation
status: operational-aid

This prompt is an implementation aid for the accepted proposal packet. It does
not approve execution, widen promotion scope, create authority, or replace the
packet manifests, lifecycle gates, retained evidence, or promotion workflow.

## Mandatory Preflight

Before editing durable targets, re-read the repository ingress, constitutional
kernel, proposal workspace rules, proposal manifests, source-of-truth map,
target architecture, implementation plan, acceptance criteria, validation plan,
risk register, implementation-grade completeness review, and proposal review.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails --require-implementation-authorization
```

Refuse implementation unless both pass, the packet status is `accepted`, the
review verdict is `accepted`, `implementation_prompt_authorized: yes`, the
review digest is fresh, and `open_blocking_findings_count: 0`.

Use this profile selection:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent wording and guardrail update across the declared
  target set, with post-edit validation before any success claim

Do not use proposal-local files, generated projections, chat history, MCP/tool
availability, Durable Object state, or external workflow-engine state as
authority or implementation proof.

## Target End State

The durable target state is terminology and entry-artifact guardrails, not a
runtime replacement. Octon may describe the workflow-first direction while
preserving **Governed Agent Runtime** as compatibility language until durable
runtime contracts, validators, retained evidence, and cutover receipts prove a
replacement.

The implemented targets must make these boundaries clear:

- Octon as a whole remains **Constitutional Engineering Harness**.
- The runtime-core direction is **Governed Workflow Runtime**: workflow state,
  run contracts, authorization, evidence, replay, rollback, and closeout own
  control flow.
- Agents participate only as bounded, evidenced activity nodes or bounded
  agent nodes inside admitted execution boundaries.
- **Governed Agent Runtime** remains a compatibility phrase, not final retired
  terminology.
- Terminology changes must not imply live support for workflow-statechart
  schemas, agent-node contracts, task-specific execution harness schemas,
  connector admission changes, MCP integration, Durable Object adapters, or
  external workflow-engine integration.

## In Scope

Edit only these durable promotion targets when edits are needed:

- `.octon/framework/cognition/_meta/terminology/naming-constitution.md`
- `.octon/framework/cognition/_meta/terminology/glossary.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/README.md`
- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`

After durable edits land, create or update only these packet-local receipts:

- `.octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails/support/post-implementation-drift-churn-review.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/framing-boundary-and-terminology-guardrails/`

## Out Of Scope

Do not edit runtime crates, schemas, statecharts, connector contracts, MCP
surfaces, Durable Object adapters, external workflow-engine integrations,
support-target declarations, generated/effective outputs, generated proposal
registry projections, root `AGENTS.md`, `CLAUDE.md`, or any target outside the
approved promotion list.

Do not add or update validator scripts unless a separate accepted proposal
declares those validator files as promotion targets. This packet's validator
expectation can be satisfied by deterministic terminology scans and retained
review evidence. If durable validator changes are required for correctness,
stop and report `needs-packet-revision` instead of widening this packet.

Do not change `proposal.yml#status`; leave it as `accepted`. The
`promote-proposal` lifecycle route owns the later rewrite to `implemented`.

## Ordered Workstreams

1. Inventory live terminology in the declared targets.

   Run:

   ```sh
   rg -n "Governed Agent Runtime|Governed Workflow Runtime|bounded agent node|bounded, evidenced|workflow state|task-specific execution harness|Durable Object|MCP|external workflow-engine|connector admission|agent-node" .octon/framework/cognition/_meta/terminology/naming-constitution.md .octon/framework/cognition/_meta/terminology/glossary.md .octon/framework/cognition/_meta/architecture/specification.md .octon/README.md .octon/AGENTS.md .octon/instance/ingress/AGENTS.md
   ```

   Record the result in retained validation evidence. Treat current live files
   as stronger factual grounding than packet prose where packet labels are
   stale.

2. Align the terminology authority surfaces.

   In `naming-constitution.md`, make the naming rules internally consistent
   with the proposal target state:

   - preserve **Constitutional Engineering Harness** as the whole-system
     classification;
   - define **Governed Workflow Runtime** as the workflow-first runtime-core
     term for new durable wording;
   - keep **Governed Agent Runtime** as compatibility language until the later
     cutover packet proves replacement;
   - add or confirm proof-before-claim rules that block terminology from
     widening live support claims;
   - keep the naming constitution self-contained and free of proposal-path
     dependencies.

   In `glossary.md`, ensure definitions for **Governed Agent Runtime**,
   **Governed Workflow Runtime**, **Task-Specific Execution Harness**,
   **Bounded Agent Node**, **Admitted Connector Operation**, **Ambient Tool
   Access**, and **Durable Object Authority** agree with the naming
   constitution and do not imply excluded future work is live.

3. Align architecture and entry artifacts.

   In `architecture/specification.md`, `.octon/README.md`, and
   `.octon/instance/ingress/AGENTS.md`, preserve workflow-first framing only
   inside the packet boundary:

   - workflow state owns consequential control flow;
   - agents are bounded activity participants;
   - future statecharts, agent-node contracts, connector admission changes,
     MCP integration, Durable Object adapters, and external workflow engines
     remain separately governed future work.

   For `.octon/AGENTS.md`, keep it a thin ingress adapter. Do not add runtime,
   policy, or terminology exposition to the adapter. If implementation appears
   to require changes to root `AGENTS.md` or `CLAUDE.md` for adapter parity,
   stop and report a scope blocker because those files are outside this
   packet's promotion targets.

4. Run terminology and authority-boundary scans.

   Required scans:

   ```sh
   rg -n "\.octon/inputs/exploratory/proposals/(architecture/)?framing-boundary-and-terminology-guardrails" .octon/framework/cognition/_meta/terminology/naming-constitution.md .octon/framework/cognition/_meta/terminology/glossary.md .octon/framework/cognition/_meta/architecture/specification.md .octon/README.md .octon/AGENTS.md .octon/instance/ingress/AGENTS.md
   rg -n -i "agent-owned control plane|agents? own workflow state|ambient tool access|Durable Object Authority|live .*Durable Object|live .*MCP|live .*external workflow|supported .*agent-node|supported .*workflow-statechart" .octon/framework/cognition/_meta/terminology/naming-constitution.md .octon/framework/cognition/_meta/terminology/glossary.md .octon/framework/cognition/_meta/architecture/specification.md .octon/README.md .octon/AGENTS.md .octon/instance/ingress/AGENTS.md
   ```

   The first scan must return no active target backreferences to this proposal.
   The second scan may return banned-term definitions or explicit negative
   controls only when the surrounding text clearly denies live support or
   authority.

5. Run repository validators.

   Required proposal and subtype gates:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails --require-implementation-authorization
   ```

   Required target-family validators:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-active-doc-hygiene.sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-ingress-manifest-parity.sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
   ```

   Required packet checksum check:

   ```sh
   (cd .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails && shasum -a 256 -c SHA256SUMS.txt)
   ```

   If a command fails because this implementation prompt is a newly generated
   support artifact omitted from an existing packet inventory, record the
   warning or blocker separately. Do not edit reviewed packet artifacts merely
   to satisfy inventory churn if doing so would stale the accepted review
   digest.

6. Record retained evidence and packet-local receipts.

   Create a retained evidence note under
   `.octon/state/evidence/validation/proposals/framing-boundary-and-terminology-guardrails/`
   that includes:

   - implementation timestamp;
   - files changed;
   - exact validation commands and exit status;
   - terminology scan output or summary with paths;
   - diff summary for the six promotion targets;
   - explicit note that no runtime crates, generated/effective outputs,
     connectors, MCP surfaces, Durable Object adapters, or external workflow
     integrations were changed;
   - rollback posture.

   Then create or update `support/implementation-run.md` with at least:

   ```markdown
   # Implementation Run Receipt

   verdict: pass|fail
   implemented_at: <UTC timestamp>
   promotion_evidence_count: <number>
   retained_evidence:
   - <retained evidence path>

   ## Durable Changes
   ...

   ## Validators Run
   ...

   ## Blockers
   ...
   ```

   Use `verdict: pass` only when durable target edits have landed, retained
   evidence exists, and required validation has passed or has explicit
   non-blocking warnings. Otherwise use `verdict: fail` and report a blocked
   route outcome.

7. Make post-implementation gates executable.

   After durable changes and `support/implementation-run.md`, create or update
   `support/implementation-conformance-review.md` with:

   - `verdict: pass|fail`
   - `unresolved_items_count`
   - sections named `Blockers`, `Checked Evidence`, `Promotion Target
     Coverage`, `Implementation Map Coverage`, `Validator Coverage`,
     `Generated Output Coverage`, `Rollback Coverage`, `Downstream Reference
     Coverage`, `Exclusions`, and `Final Closeout Recommendation`

   Then run:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
   ```

   Next create or update
   `support/post-implementation-drift-churn-review.md` with:

   - `verdict: pass|fail`
   - `unresolved_items_count`
   - sections named `Blockers`, `Checked Evidence`, `Backreference Scan`,
     `Naming Drift`, `Generated Projection Freshness`, `Manifest And Schema
     Validity`, `Repo-Local Projection Boundaries`, `Target Family
     Boundaries`, `Churn Review`, `Validators Run`, `Exclusions`, and `Final
     Closeout Recommendation`

   Then run:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails
   ```

## Generated And Runtime Publication Posture

This packet does not authorize generated/effective publication, runtime crate
changes, support-target changes, or proposal registry status changes. Treat
generated output coverage as `not changed; explicitly excluded by packet
scope` unless a validator identifies a hard blocker. If generated/effective
publication or runtime-facing handle refresh becomes necessary, stop and route
to packet revision or a linked proposal.

## Rollback Posture

Rollback is text-only and target-scoped. If implementation creates ambiguity,
premature support claims, parity failures, or validation failures that cannot
be corrected inside the six promotion targets, revert only the task edits in
those targets, retain the failed validation evidence, write
`support/implementation-run.md` with `verdict: fail`, and report the route as
blocked or `needs-packet-revision`.

Do not revert unrelated worktree changes.

## Delegation Boundary

Delegation is optional. If used, split work by disjoint write scope:

- terminology worker: naming constitution and glossary;
- entry-artifact worker: architecture specification, `.octon/README.md`, and
  ingress surfaces;
- integration owner: final diff review, validators, retained evidence, and
  packet receipts.

Delegation does not change authority. The integration owner remains
accountable for scope, validation, receipts, and fail-closed decisions.

## Terminal Criteria

The implementation route may report success only when all of these are true:

- durable edits, if needed, are limited to the six approved promotion targets;
- no proposal-local support file is cited as durable implementation proof;
- retained validation evidence exists outside `inputs/**`;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, and a numeric `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails`
  passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails`
  passes;
- `proposal.yml#status` remains `accepted`;
- no closeout, archive-ready, or implemented-status claim is made by this
  route.

Refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, failing, unresolved, stale, or blocked.
The `promote-proposal`, verification/correction, closeout, and archive routes
own those later lifecycle claims.
