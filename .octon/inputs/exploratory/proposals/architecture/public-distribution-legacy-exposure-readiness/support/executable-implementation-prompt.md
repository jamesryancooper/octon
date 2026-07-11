# Executable Implementation Prompt — Public Distribution Legacy Exposure Readiness

prompt_id: `public-distribution-legacy-exposure-readiness-implementation-20260710T235633Z`  
generated_at: `2026-07-10T23:56:33Z`  
generated_by_route: `generate-packet-implementation-prompt`  
generation_run_id: `20260710-public-distribution-clean-worktree-01-legacy-exposure`  
prompt_set_id: `octon-proposal-lifecycle-generate-packet-implementation-prompt`  
prompt_bundle_sha256: `sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6`  
proposal_path: `.octon/inputs/exploratory/proposals/architecture/public-distribution-legacy-exposure-readiness`  
artifact_class: `operational-aid`  
authority: `non-authoritative`  
next_lifecycle_route: `run-packet-implementation`

> **Classification.** This proposal-local prompt is an operational aid. It does
> not authorize implementation, an exposure scan, a credential action, a Git or
> GitHub mutation, publication, closeout, or archive. The current repository,
> constitutional and instance authority, the parent program registry, this
> packet's `proposal.yml`, and its one `architecture-proposal.yml` remain
> controlling within their declared classes. Stop if this prompt conflicts with
> any of them.

## 1. Goal And Target End State

Implement the accepted phase-1 child as one atomic, additive readiness
mechanism:

- a strict JSON Schema for compact redacted exposure and disposition receipts;
- a deterministic, read-only validator for exact Git-object coverage, hosted
  surface coverage, known-writer/name-reuse readiness, and maintainer decision
  completeness;
- hermetic sanitized fixtures and positive, negative, determinism, redaction,
  and no-mutation tests;
- a credential revoke-first and legacy-disposition response runbook; and
- compact, non-sensitive child-owned validation evidence.

The implemented mechanism may prove readiness or fail closed. It must never
perform the transition it evaluates. No repository rename, archive or
visibility change, remote update, push, history rewrite, credential revocation
or rotation, evidence deletion, public-tree import, or release publication is
part of this child.

## 2. Prompt-Generation And Profile Selection Receipt

Prompt-generation gates passed at the reviewed packet digest
`sha256:be63abffeaf57c922b027d13299bf811db5fabf53219bf7fbc35c71f5720475c`:

- `support/implementation-grade-completeness-review.md`: `verdict: pass`, zero
  unresolved questions, no clarification required;
- `support/proposal-review.md`: `verdict: accepted`,
  `implementation_prompt_authorized: yes`, zero open blocking findings;
- `support/pre-integration-architecture-review.yml`: `verdict: pass`, zero
  unresolved items, fresh packet digest; and
- `validate-proposal-review-gate.sh --require-implementation-authorization`:
  `errors=0 warnings=0`.

Profile Selection Receipt:

- `release_state`: `pre-1.0`;
- `change_profile`: `atomic`;
- rationale: the schema, validator, fixtures/tests, runbook, and evidence form
  one fail-closed safety boundary; a partial live mechanism could imply
  readiness without complete coverage or human gates;
- `transitional_exception_note`: none authorized; and
- rollback posture: `manual`, additive, evidence-preserving.

This receipt supports prompt generation only. Implementation still requires a
fresh child dispatch through the dependency-governed parent program and a
valid run authority boundary.

## 3. Program Position, Live Signals, And Entry Blocker

- Parent program: `octon-public-distribution-model`.
- Registry position: required `phase-1 / exposure-readiness` child, no child
  dependencies, `dependency_gate: verification`, `rollback_posture: manual`.
- It may run in parallel with `public-distribution-repository-role-contracts`
  only while their exact file leases remain disjoint.
- All six declared promotion targets were absent at prompt-generation time.
  Reinspect them at implementation start; present repository state wins over
  this observation.
- The enclosing program uses `worktree_baseline_lease: explicit-dirty-start`.
  Inventory and partition the live worktree. Preserve every unrelated change;
  do not reset, stash, delete, commit, reclassify, or claim it as child work.
- `README.md` still presents an older in-review narrative. `proposal.yml` and
  the accepted review control lifecycle state. Do not repair reviewed packet
  prose during implementation; route any required correction through packet
  revision and refresh review evidence.

Known fail-closed entry blocker at prompt generation: the mandatory full
`validate-proposal-standard.sh --package ...` gate exits nonzero because the
global proposal-registry projection cannot synchronize with unrelated proposal
corpus residue, including a duplicate-path candidate named
`octon-trustworthy-autonomy-solo-developer-revision-2 2`. The packet-local
diagnostic with `--skip-registry-check` passes with only the six expected
absent-target warnings, but it does not satisfy the parent child-dispatch
contract.

Before durable implementation, rerun the full gate. If it still fails, record
the exact external blocker and return a blocked child outcome. Do not use the
skip flag as authorization, regenerate the registry by hand, or mutate the
unrelated proposal corpus from this child.

## 4. Mandatory Preflight

Run from the repository root with a route-owned evidence capture. `PACKET` is a
convenience variable, not authority:

```sh
PACKET=.octon/inputs/exploratory/proposals/architecture/public-distribution-legacy-exposure-readiness

bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
  --package "$PACKET"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
  --package "$PACKET"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
  --receipt "$PACKET/support/pre-integration-architecture-review.yml" \
  --package "$PACKET" \
  --mode pre-integration-architecture-review \
  --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package "$PACKET" \
  --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh \
  --package "$PACKET"
```

Also confirm the parent review and child-readiness gates are fresh before the
parent dispatches this child. Stop on any stale digest, changed promotion
target, same-file lease overlap, unresolved ownership, missing run authority,
or full proposal-standard failure.

## 5. Exact Write Scope

The only durable promotion targets are the six values below, copied verbatim
from `proposal.yml#promotion_targets`:

1. `.octon/framework/assurance/runtime/_ops/scripts/validate-legacy-exposure-readiness.sh`
2. `.octon/framework/assurance/runtime/_ops/tests/test-legacy-exposure-readiness.sh`
3. `.octon/framework/assurance/runtime/_ops/fixtures/legacy-exposure-readiness/`
4. `.octon/framework/constitution/contracts/disclosure/legacy-exposure-readiness-v1.schema.json`
5. `.octon/framework/orchestration/governance/legacy-exposure-response-runbook.md`
6. `.octon/state/evidence/validation/proposals/public-distribution-legacy-exposure-readiness/`

Route-owned lifecycle updates may additionally create or refresh only these
packet support artifacts after implementation:

- `support/implementation-run.md`;
- `support/validation.md`;
- `support/implementation-conformance-review.md`; and
- `support/post-implementation-drift-churn-review.md`.

Do not change `proposal.yml#status`; promotion owns the accepted-to-implemented
transition. Do not edit the parent, siblings, generated proposal registry,
GitHub workflows, remotes, credentials, or any undeclared contract, script,
test, fixture, runbook, state, generated, or repo-root path. If a required
durable change falls outside this list, stop and route packet revision.

## 6. Ordered Workstreams

### WS0 — Re-ground And Reuse Existing Conventions

Re-read the live packet, parent child registry entry, child-packet contract,
external-effects boundary, disclosure contract family, nearby assurance shell
validators/tests, and evidence-disclosure conventions. Search before creating
helpers. Reuse existing shell validation style, portable SHA-256 handling,
JSON Schema Draft 2020-12 validation, temp-directory cleanup, and
positive/negative test harness patterns. Add no dependency; if an unavailable
tool appears necessary, stop and produce a Dependency Receipt rather than
silently widening the environment.

Record a Repository Reconnaissance Receipt naming searches, reusable surfaces,
rejected alternatives, exact new files, and why the declared targets are the
correct homes.

### WS1 — Define The Redacted Receipt Contract

Create
`.octon/framework/constitution/contracts/disclosure/legacy-exposure-readiness-v1.schema.json`
as strict Draft 2020-12 JSON Schema with `additionalProperties: false` at
closed record boundaries. The contract must distinguish tool observations from
maintainer-owned decisions and cover at least:

- schema/version identity, immutable repository identity, exact reviewed
  revision, ref-snapshot/scope digest, generation time, and deterministic
  result;
- Git inventory coverage and counts without object payloads;
- every required hosted-surface category and one explicit state per category:
  `scanned`, `absent`, `disabled`, `inaccessible`, or explicitly
  `dispositioned`;
- redacted finding classes for credential, private data,
  license/provenance, and publication restriction, using counts, opaque ids,
  digests, and paths only when safe—never matched content;
- unresolved-material-finding and incomplete/inaccessible coverage state;
- known clones, remotes, automation, webhooks, deploy keys, stored repository
  URLs, immutable repository ids, private-workspace cutover state, and a
  stale-endpoint negative-test evidence reference;
- residual unknown-clone risk and its explicit maintainer acceptance state;
  and
- the maintainer decision record required by AC-03: disposition, credential
  actions, timestamp, and reviewed revision. Disposition is limited to
  `public-archive`, `restricted`, or `deferred`.

The schema must make absent human decisions fail validation or readiness; the
tool must not synthesize approval, credential action, risk acceptance, or legal
interpretation. Include valid and invalid schema fixtures in the child fixture
root and exercise them with the repository's existing JSON Schema runtime.

### WS2 — Implement The Read-Only Validator

Create
`.octon/framework/assurance/runtime/_ops/scripts/validate-legacy-exposure-readiness.sh`
with a documented `--help`, strict input validation, deterministic output, and
nonzero fail-closed outcomes. Keep the default/test path hermetic and offline.
If a live hosted-metadata inspection mode is provided, it must be separately
explicit, bind the immutable expected repository id and pre-state, issue GET
requests only, complete pagination, and never become necessary for hermetic
tests.

Implement these boundaries:

1. Freeze and record the ref-to-object-id snapshot. Enumerate every blob
   reachable from every ref, including blobs reachable only from non-default
   branches or tags. Use Git objects, not the working tree, so ignored and
   untracked local residue is never read. Use stable locale/order and robust
   filename/object parsing; identical inputs must produce byte-identical
   normalized receipts and the same scope digest.
2. Apply composable credential, private-data, provenance/license, and
   publication-restriction classification without printing matched payloads.
   Output only redacted metadata permitted by the schema. Unsafe paths must be
   omitted or represented by a digest.
3. Account explicitly for Git refs/blobs, releases/assets, Actions
   runs/logs/artifacts/caches, issues and pull-request discussion, deployments
   and environments, packages, LFS objects, attachments, wiki, and Pages.
   Missing categories, incomplete pagination, API errors, or an inaccessible
   enabled surface block a clean verdict; zero items is still an explicit
   scanned/absent result.
4. Validate a caller-supplied inventory of known clones, remotes, automation,
   webhooks, deploy keys, and stored URLs. Require known writers to be bound to
   the private workspace identity before original-name reuse. The validator
   may validate a stale-endpoint negative-test record, but this implementation
   run must not perform any network push.
5. Reject unresolved material findings, revision or repository-id mismatch,
   stale/incomplete coverage, missing required maintainer-decision fields,
   missing credential action, incomplete writer cutover, a non-failing stale
   endpoint test, or missing residual-risk acceptance.
6. Write final receipts atomically. An interrupted run leaves no authoritative
   partial receipt; temporary material is restrictive, cleaned on exit, and
   never retained as a successful result.

Add a static and behavioral no-mutation guard. The validator must not invoke
Git/GitHub writes, pushes (including a live dry-run push), remote mutation,
credential stores, settings changes, cleanup, or deletion. It must not use
`set -x` or echo secrets, request bodies, environment credentials, or raw API
payloads.

### WS3 — Build Sanitized Fixtures And Tests

Create
`.octon/framework/assurance/runtime/_ops/fixtures/legacy-exposure-readiness/`
and
`.octon/framework/assurance/runtime/_ops/tests/test-legacy-exposure-readiness.sh`.
Fixtures must be synthetic and inert; never copy current repository findings,
tokens, private data, hosted payloads, or local scan output into the repo.

Cover at least:

- a clean multi-ref history and a blob reachable only from a branch/tag;
- an ignored/untracked sentinel proving local residue is not read;
- representative fake credential/private/restricted markers whose payloads
  never appear in stdout, stderr, receipts, or retained logs;
- repeated and shuffled-input runs proving byte-identical normalized output
  and digest stability;
- all hosted-surface categories, zero-item categories, disabled categories,
  inaccessible enabled surfaces, missing categories, API failure, and
  incomplete pagination;
- complete and incomplete maintainer decisions;
- `public-archive`, `restricted`, and `deferred` dispositions, with no
  retraction claim;
- repository-id/revision mismatch, unresolved findings, incomplete writer
  inventory, writers still on the old identity, stale-endpoint test success
  when failure is required, and missing unknown-clone-risk acceptance;
- interruption/partial-output handling and output-path safety; and
- before/after proofs that refs, objects, worktree, remotes, configuration,
  credentials, and mocked GitHub state did not change.

The test must fail if a sensitive sentinel appears anywhere outside its
private temporary fixture payload or if the validator contains or executes a
mutating command path.

### WS4 — Author The Maintainer Runbook

Create
`.octon/framework/orchestration/governance/legacy-exposure-response-runbook.md`
with a dry-run-first sequence and explicit authority handoffs:

1. bind the exact revision and immutable repository identity;
2. inventory Git and all enabled hosted surfaces without publishing raw
   findings;
3. classify and retain raw evidence as local-private, with only a compact
   redacted derivative eligible for the child evidence root;
4. require immediate maintainer-led revoke or rotation before repository
   cleanup when a credential is confirmed exposed;
5. require an explicit maintainer disposition of `public-archive`,
   `restricted`, or `deferred` and never claim that prior public copies were
   recalled or made confidential;
6. inventory known writers and repository URLs, bind workspace/legacy/public
   repositories by immutable id, move every known writer to the private
   workspace identity, consume a separately authorized stale-endpoint negative
   proof, and require explicit acceptance of residual unknown-clone risk before
   original-name reuse; and
7. hand any rename, archive, visibility change, remote update, credential
   action, push, repository creation, or publication to a separate exact,
   maintainer-approved apply plan and invocation.

Ambiguous legal ownership, provenance, name conflict, or material exposure the
maintainer cannot evaluate triggers specialist review; it is never auto-cleared.

### WS5 — Retain Evidence And Complete Child Receipts

Create the exact evidence target
`.octon/state/evidence/validation/proposals/public-distribution-legacy-exposure-readiness/`.
Retain compact evidence mapped to AC-01 through AC-07: command, cwd, start/end
time, exit code, evidence class, bounded non-sensitive result, reviewed
revision, input/output digests, negative-control result, and full-log digest or
reference when available.

Raw findings remain local-private and outside repo-publishable evidence. A
publishable derivative may retain only redacted counts, classifications,
digests, safe identifiers, limitations, and a digest-backed local evidence
reference. The child evidence root, parent summary, generated registry, prompt,
and support reviews do not authorize a transition and cannot substitute for
raw local evidence or a maintainer decision.

After target-specific validation passes, create/update
`support/implementation-run.md` with at least `verdict`, `implemented_at`, and
`promotion_evidence_count`; record commands and retained refs in
`support/validation.md`; then replace the existing `not-run` placeholders in
the two post-implementation reviews with evidence-backed results.

## 7. Validation Floor

Run the focused implementation suite first:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-legacy-exposure-readiness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-family-version-coherence.sh
```

The focused suite must validate the new JSON Schema against positive and
negative fixtures and exercise the validator's exact CLI. Do not weaken an
existing validator or alter unrelated fixtures to obtain a pass.

Then rerun the structural and authorization preflight from §4, including the
full proposal-standard gate without `--skip-registry-check`. Capture scoped
diff proof showing only declared targets and route-owned support receipts
changed, plus a sensitive-sentinel scan of all publishable output.

After authoring `support/implementation-conformance-review.md`, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh \
  --package .octon/inputs/exploratory/proposals/architecture/public-distribution-legacy-exposure-readiness
```

After that passes and
`support/post-implementation-drift-churn-review.md` is complete, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh \
  --package .octon/inputs/exploratory/proposals/architecture/public-distribution-legacy-exposure-readiness
```

Both receipts and both commands must pass. A parent or sibling receipt cannot
satisfy either child-owned gate.

## 8. Acceptance And Terminal Criteria

All of the following must be evidenced on the exact reviewed implementation
revision:

- **AC-01:** every blob reachable from every ref is deterministically covered,
  with no undeclared exclusion or ignored local-residue read;
- **AC-02:** representative sensitive fixtures fail closed and no matched
  payload leaks;
- **AC-03:** the transition-readiness path proves no mutation and rejects
  unresolved findings or an incomplete maintainer decision;
- **AC-04:** the runbook makes credential revoke/rotation precede cleanup;
- **AC-05:** disposition is constrained and no retraction claim is made;
- **AC-06:** every required hosted surface has an explicit coverage state and
  inaccessible/incomplete enabled coverage blocks clean readiness;
- **AC-07:** known writers and stale endpoints are covered, private cutover is
  required, and residual unknown-clone risk requires explicit maintainer
  acceptance; and
- the aggregate evidence identifies behavior proof, boundary proof, negative
  controls, exact revision, and retained receipts—not merely “tests pass.”

Terminal implementation readiness additionally requires the target-specific
suite, structural gates, full proposal-standard/registry synchronization,
fresh authorization, scoped-diff and non-leakage proof, passing conformance,
and passing post-implementation drift/churn validation.

Leave `proposal.yml#status` as `accepted`. The later `promote-proposal` route
owns the implemented transition after evidence is complete. Technical
readiness does not mean that a live exposure scan, credential action, legacy
disposition, repository transition, name reuse, push, or publication occurred.

## 9. Closeout Refusal And Blocker Posture

Refuse implementation dispatch while the full proposal-standard gate, parent
dispatch gate, review freshness, write lease, or run authority is missing or
failing. During implementation, stop and report the exact blocked criterion if
complete Git/hosted coverage, safe redaction, deterministic behavior,
no-mutation proof, schema enforcement, writer cutover semantics, or human-gate
separation cannot be achieved inside the declared targets.

Refuse any `implemented`, closeout, archive, or archive-ready claim while
`support/implementation-conformance-review.md` or
`support/post-implementation-drift-churn-review.md` is missing, still
`not-run`, failing, unresolved, stale, or blocked. Also refuse while raw
sensitive material appears in publishable output, any enabled hosted surface
is inaccessible or incompletely inventoried, any material finding is
undispositioned, required maintainer fields are absent, known writers remain on
the legacy/public identity, or residual unknown-clone risk is unaccepted.

An external blocker is not permission to widen scope or fabricate a pass.
Retain bounded evidence and return the owning lifecycle route.

## 10. Rollback And Interrupted-Run Posture

Rollback is manual and additive. Revert the authored schema, validator,
fixtures/tests, and runbook together; never leave a partial mechanism that can
emit a clean readiness result. Retain validation and rollback evidence rather
than deleting it. If a downstream consumer has bound to the schema or
validator, coordinate rollback through the parent program instead of silently
stranding that consumer.

If the validator leaks sensitive content, cannot prove read-only behavior, or
produces nondeterministic scope/results, fail closed immediately, quarantine
the publishable output, preserve only appropriately classified local evidence,
and remove the unsafe additive implementation through the governed rollback
route. Interrupted scans produce no authoritative partial receipt and restart
from the same frozen ref snapshot.

## 11. Delegation Boundary

One accountable child orchestrator owns integration and final evidence.
Delegation is optional and limited to read-only reconnaissance, disjoint
fixture/schema review, or independent verification under explicit file leases.
No delegate may access or reproduce live sensitive payloads, operate GitHub or
credentials, write the same file as another delegate, expand promotion scope,
approve findings, accept risk, or issue a terminal verdict. The orchestrator
must re-read and validate every delegated output before it enters the atomic
child change.

---

When this prompt is retained, the reviewed digest remains fresh, and the parent
program can satisfy every entry gate—including the currently blocked full
proposal-standard gate—the next canonical lifecycle route is
`run-packet-implementation`.
