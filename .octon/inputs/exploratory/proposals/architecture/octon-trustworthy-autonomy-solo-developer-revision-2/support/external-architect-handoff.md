# External Architect Handoff — Revision 2

## Purpose

This handoff requests an independent architecture review of the proposed
**Octon Trustworthy Autonomy Without Solo-Developer Bureaucracy — Revision 2**.

The packet is deliberately `in-review` and non-authoritative. It does not
authorize implementation, provider mutation, credential changes, merge,
deployment, release, or trust-root activation.

The requested outcome is an independent disposition of the twelve architecture
decisions and the nine open implementation-readiness findings below. The
architect should challenge the design, not merely edit its prose.

## Product Objective

> Enable a solo developer to delegate substantial, focused, long-running
> engineering work without surrendering control and without turning normal
> software development into a governance bureaucracy.

The proposed operating principle is:

> Broad autonomy inside a focused, reversible execution envelope, with strong
> controls concentrated at durable, external, irreversible, or trust-root
> boundaries.

Safety and development throughput are coequal requirements.

## Current Review Disposition

**Revision required before implementation approval.**

The overall direction is coherent, and the packet resolves most of the
Revision 2 assignment. The final adversarial review found nine material issues
that prevent an implementation-grade completeness receipt. They are bounded
primarily to evidence capacity and completeness, migration ordering, activation
recovery, privileged-writer accounting, and a few enforcement-owner semantics.

No implementation or provider changes were made during this review.

## Recommended Architecture in One Page

1. `authorize_execution` is the sole normal producer of authorization decisions
   and `GrantBundle` records.
2. The authority issuer signs exact typed issuance requests. A separate
   capability ledger registers/exposes, reserves, and irreversibly spends them.
3. The evidence store and capability ledger gate attempt start before a broker
   adapter receives a non-cloneable invocation guard.
4. Every lifecycle or child-agent launch requires a typed `ExecutorLaunch`.
5. Class A candidate work runs autonomously in a disposable, credentialless,
   project-scoped sandbox.
6. Class B durable-but-reversible work is automatically brokered when policy,
   exact-target provenance, evidence, and rollback requirements pass.
7. Class C irreversible, externally consequential, or trust-root transitions
   require explicit operator activation or a separately configured
   high-assurance policy.
8. Durable merge uses a PR-bound exact-SHA verifier identity separated from the
   effect App. Direct-main/no-PR is not admitted by Revision 2.
9. Evidence uses producer-origin facts, a transactional evidence store,
   independent final signing, external anchoring, reconciliation, and bounded
   retention.
10. Trust-root changes land inert, are verified by a previously trusted
    version, and activate separately with exact rollback.
11. Failure blocks only the unavailable consequential transition; sound local
    candidate work continues.
12. Workspace Project and Governed Harness Factory artifacts compile and bind
    inputs but never authorize execution.

## Supported Current-State Findings

The evidence appendix supports these important findings:

- `lifecycle_executor::authorize_before_dispatch` currently validates
  self-described lifecycle fields and writes a delegation proof; it does not
  verify a canonical `GrantBundle` or `ExecutorLaunch` capability.
- `mode: unattended`, `authority_ref`, declared scope, and evidence-gate fields
  can influence current dispatch without canonical grant binding.
- Current typed effects provide useful in-process defense in depth but not a
  complete host isolation or credential boundary.
- Current token/journal persistence has statically credible concurrency and
  crash-ordering gaps; those gaps were not misrepresented as dynamically
  proven races.
- An ordinary Git worktree does not independently isolate the shared Git object
  and ref database.
- A re-chainable, unanchored local journal does not independently prove
  adversarial tamper evidence, authenticity, completeness, non-repudiation, or
  truthfulness.
- The observed GitHub ruleset was active with four strict required checks and
  no configured bypass actors. Satisfying those checks still does not prove the
  full Octon lifecycle provenance tuple.
- Existing PR automation executes candidate-controlled code in a context with
  provider-write authority. This must be retired before new TCB candidate PRs
  rely on that route.
- The current Project Profile and task-harness surfaces are useful descriptive
  inputs but are not durable multi-project identity or authorization systems.

Repository facts, provider configuration, observed session behavior, and
architectural inference are classified separately in the evidence appendix.

## Open Implementation-Readiness Findings

| ID | Severity | Finding | Required architectural disposition |
| --- | --- | --- | --- |
| EXT-01 | Blocker | `EvidenceCapacityLease` is not yet propagated consistently through decisions, harness bindings, implementation phases, receipt fields, provenance, and acceptance tests. Its release protocol also has race and retention gaps. | Define an atomic ledger transition that makes future consume impossible before issuing a one-shot capacity-release permit; after consume, bind allocation to the outbox/operation. Define terminal downsizing to actual retained usage, legal-hold/pending-finalization behavior, and protected capacity for invalidation, rollback, stop, and revocation obligations. |
| EXT-02 | Blocker | Producer high-watermark protection against a compromised evidence store presenting a plausible stale prefix currently appears only in the TCB inventory. | Either define producer-owned monotonic sequence/prior-digest state, independently fetched signed high-watermarks, signer restart/rotation rules, required producer-head sets, and explicit gap handling throughout the normative protocol, or narrow all completeness claims accordingly. |
| EXT-03 | Blocker | Migration defers removal of the current PR-head provider-write credential until the later merge-provenance phase. Early TCB candidates would traverse the unsafe path. | Add a Phase 1B repo-local/provider safety Change that disables privileged PR-head execution before any new TCB candidate PR. Use a provider-safe/manual temporary merge lane until the separated Apps are installed. |
| EXT-04 | Blocker | Trust activation can change the active pointer before rollback authority is durably available. | Pre-register the exact old/new one-shot rollback obligation and its evidence capacity before activation. The installer consumes only the activation guard; target observation activates/confirms rollback readiness, and reconciliation resolves an unknown pointer outcome. |
| EXT-05 | High | Several canonical stores possess durable write privilege while their TCB rows say effect authority is `None`. | Account explicitly for narrow physical effect authority under authenticated typed transitions or invocation guards while preserving that stores have no decision, grant, or general business-effect authority. Audit the identity and release registries under the same rule. |
| EXT-06 | High | Some residual wording assigns capability/obligation consumption to an App, installer, or monitor, or conflates the validation attestor with the provenance verifier. | Normalize every path to issuer signature → ledger registration/reservation/consume → evidence/ledger attempt gate → adapter consumes invocation guard. The validation attestor emits only its signed validation result; the independent provenance verifier alone emits the full-tuple verdict and emission request. |
| EXT-07 | High | A provider check can become green before its publication evidence is successfully finalized and anchored. | Bind a short publication-finalization deadline and missing-anchor event into the pre-registered invalidation template. Failure to finalize by the deadline must drive the check to definitive `failure` through the one-shot invalidation path. |
| EXT-08 | High | The privileged Git adapter design does not explicitly disable repository-controlled hooks, config includes, filters, credential helpers, submodules, fsmonitor, or external diff/merge drivers. | Require sanitized plumbing-only Git execution, an explicit safe configuration, no candidate code under broker privilege/credentials, and negative controls for every executable Git extension point. |
| EXT-09 | Medium | First-adoption performance excludes trust enrollment, which can hide the largest solo-administration cost. | Add an end-to-end secure install/enrollment target covering sandbox/VM runtime, brokers, keys/vault, anchor, Apps, and ruleset, plus a recurring monthly maintenance/rotation target. |

## Questions for the External Architect

The response should answer these questions directly:

1. Is the single authority/issuer/ledger/attempt-gate/broker model internally
   coherent, or does it contain a hidden second authorization or effect plane?
2. Is an `EvidenceCapacityLease` necessary before consume? If yes, what is the
   smallest crash-safe cross-store protocol that avoids both quota races and
   stranded allocations?
3. What bounded completeness claim is defensible against a compromised
   evidence store? Is producer high-watermark state worth its added TCB and
   operational cost?
4. Is the default rootless-OCI/VM-backed sandbox plus local broker topology a
   credible solo-developer default across macOS, Linux, and Windows?
5. Are the proposed Class A/B/C boundaries correctly placed? Identify any
   effect that is over-governed or under-governed.
6. Does the PR-bound verifier/App design prove the necessary provenance without
   creating an impractical merge bottleneck?
7. Are first-epoch bootstrap, previously trusted verification, and two-phase
   activation sufficient for solo-operated self-development?
8. Does the migration sequence ever expose a new trusted component to a
   candidate-controlled credential or same-change verifier/gate?
9. Does the layered TCB honestly include every identity and code path capable
   of durable mutation?
10. Can a solo developer meet the proposed interruption and latency targets
    without becoming the system's full-time governance administrator?
11. Which of AD-01 through AD-12 can be approved now, which require amendment,
    and which should be rejected?
12. What additional evidence or fault injection is required before any
    implementation Change is authorized?

## Requested Review Method

Use an independent, hostile-system review posture:

- distinguish current repository facts from proposed target behavior;
- treat repository governance and contracts as analyzable artifacts, not proof
  that enforcement exists;
- trace every privileged transition to its sole owner, credential, durable
  state, and recovery path;
- test proposer/authorizer/performer/evidence separation for credential
  shortcuts;
- challenge crash points, concurrent actors, replay, revocation, partial
  persistence, external disagreement, and dependency outage;
- challenge both security cost and solo-developer operational cost;
- do not accept a mechanism merely because it is more restrictive;
- do not describe static or inferred findings as dynamically proven.

## Required Response Contract

Use `support/external-architect-review-response-template.md` or provide an
equivalent response containing:

1. overall verdict: `approve`, `approve-with-required-changes`, `revise`, or
   `reject`;
2. one disposition for every AD-01 through AD-12;
3. one disposition for every EXT-01 through EXT-09;
4. new findings with stable IDs, severity, evidence, consequence, minimum
   repair, and acceptance test;
5. explicit keep-as-is decisions;
6. residual risks and assumptions;
7. a minimum safe implementation order;
8. a statement of whether the packet is implementation-decision-ready after
   the architect's required changes.

## Reading Order

Minimum review path:

1. `support/external-architect-handoff.md`
2. `architecture/target-architecture.md`
3. `architecture/authority-and-failure-model.md`
4. `architecture/governance-and-enforcement.md`
5. `architecture/trusted-computing-base.md`
6. `architecture/identity-evidence-merge-self-development.md`
7. `architecture/decisions.md`
8. `architecture/acceptance-criteria.md`
9. `architecture/implementation-plan.md`
10. `resources/evidence-appendix.yml`
11. `support/implementation-grade-completeness-review.md`

Consult `navigation/source-of-truth-map.md` for topic ownership and
`navigation/artifact-catalog.md` for the complete packet inventory.

## Evidence and Validation Status

- Repository commit examined:
  `eff350fcfec641e59665e74544f104f2e5bc6a4d`.
- The checkout was materially dirty before packet creation; unrelated changes
  were preserved and are described in the evidence appendix.
- Evidence appendix: 23 findings; schema, repository-commit, local-path,
  file-reference, and current-file digest bindings pass.
- Focused current implementation tests: 153 passed across authority,
  lifecycle-executor, and runtime-bus crates.
- Proposal-standard validator: passed.
- Architecture-proposal validator: passed.
- Packet coverage/completeness gate: intentionally not passing until the open
  findings are resolved and a final artifact-set digest is recorded.

These results establish packet structure and retained evidence. They do not
prove the proposed broker, sandbox, signer, anchor, verifier, or crash-recovery
architecture is implemented.

## Handoff Boundary

The architect is being asked to review and recommend. Any repository edits,
provider changes, credential operations, implementation prompts, or lifecycle
advancement require a separate explicit authorization after the review is
received and dispositioned.
