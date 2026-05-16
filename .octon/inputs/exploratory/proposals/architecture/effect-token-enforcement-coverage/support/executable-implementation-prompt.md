# Executable Implementation Prompt

implementation_prompt_id: effect-token-enforcement-coverage-implementation-prompt-2026-05-15
proposal_path: .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-15T21:54:10Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.

Durable authority may land only in the declared promotion targets outside the
proposal path. Proposal-local support files, source conversations, generated
proposal registry entries, chat history, host state, tool availability, MCP
state, Durable Object state, external workflow-engine state, and generated
projections are implementation input or derived context only. They are not
runtime, policy, control, support, permission, or closeout authority.

## Prompt Generation Gate Receipt

This implementation prompt was generated only after this gate passed from the
repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`. The gate
confirmed `verdict: accepted`, `implementation_prompt_authorized: yes`,
`open_blocking_findings_count: 0`, a fresh reviewed packet digest, and coverage
for all approved promotion targets.

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and the constitutional kernel;
- proposal workspace rules and the architecture proposal standard;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `validation-plan.md`;
- `RISK-REGISTER.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- live Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token
  v1, Authorized Effect Token v2 schema, Authorized Effect Token Consumption
  v1 schema, Context Pack Builder v1, Evidence Store v1, support-target,
  fail-closed, authorization-boundary, material-side-effect inventory, runtime
  crate, assurance-validator, control-state, evidence-state, continuity, and
  generated non-authority surfaces that this packet touches.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization
```

Refuse implementation unless both commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

Use this profile selection:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent effect-token coverage implementation across the
  approved target families, with no partial live state and with post-cutover
  validation before any success claim
- transitional exception: not authorized by this packet

The declared dependency
`workflow-statechart-task-specific-execution-harness` must be treated as a live
baseline only where durable repository state proves it. It does not widen this
packet beyond its own promotion targets.

## Repository Grounding Finding

Live repository grounding found existing candidate effect-token surfaces in the
approved target families, including material-side-effect inventory files,
authorization-boundary coverage files, Authorized Effect Token schemas,
runtime crate token issuance and verification code, token enforcement
validators, and bypass/consumption tests.

Do not duplicate those surfaces. First reconcile them against this packet's
target state. If they already satisfy part of the packet, preserve and verify
them. If they are incomplete, strengthen the existing homes. If live state
contradicts the packet in a way that cannot be resolved inside the approved
target architecture, stop and record a `needs-packet-revision` blocked outcome
with evidence.

## Target End State

The implemented end state is complete, retained, validator-backed coverage of
typed `AuthorizedEffect<T>` token verification for every supported material
side-effect path before mutation. Each supported material path either:

- requires the correct typed `AuthorizedEffect<T>` transport value;
- verifies it into an internal `VerifiedEffect<T>` guard before mutation;
- records a token consumption receipt and journal/evidence refs for successful
  verification and rejection;
- appears in the material side-effect inventory and authorization-boundary
  coverage map with an owner, token type, consumer API ref, denial reason,
  negative controls, and tests; or
- is explicitly non-live, stage-only, unsupported, or denied with retained
  evidence and no support claim.

The durable implementation must establish all of these facts:

- `authorize_execution` remains the engine-owned authorization boundary;
- arbitrary runtime callers cannot mint or fabricate valid effect tokens;
- material APIs cannot rely on ambient `GrantBundle` access, raw path inputs,
  generated/read-model projections, proposal files, host state, or model output
  as authority;
- `AuthorizedEffect<T>` remains a transport artifact, while `VerifiedEffect<T>`
  is the mutation guard;
- verification fails closed for missing, forged, stale, expired, revoked,
  already-consumed, wrong-class, wrong-run, wrong-route, wrong-support-tuple,
  unsupported-tuple, excluded-tuple, wrong-capability-pack, wrong-scope,
  missing-approval, missing-exception, rollback-not-ready, budget-exceeded,
  egress-denied, and non-allow-decision cases;
- execution receipts expose `authorized_effects` with token id, token type,
  effect kind, scope ref, token record ref, consumption receipt ref, and
  journal event refs;
- runtime event schemas cover token requested, minted, denied, consumption
  requested, consumed, rejected, expired, and revoked events;
- validators and tests prove both valid-token acceptance and bypass denial;
- no support-target, connector-permission, runtime cutover, or governed
  workflow runtime support claim widens before retained evidence and promotion
  receipts prove it.

Existing run lifecycle, execution authorization, context-pack, effect-token,
evidence-store, support-target, fail-closed, generated-derived, and
inputs-non-authority contracts remain canonical unless a later validated
promotion explicitly replaces them.

## In Scope

Durable edits may touch only these promotion target families:

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/crates/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

Expected durable outputs may include the smallest coherent set of updates in
those families, such as:

- `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`
  and its schema, when inventory classes or path bindings need correction;
- `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml`
  and related coverage specs/schemas, when path mediation or negative controls
  need correction;
- `.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md`,
  `authorized-effect-token-v2.schema.json`,
  `authorized-effect-token-consumption-v1.schema.json`,
  `runtime-event-v1.schema.json`, and `execution-receipt-v3.schema.json`, only
  where they need bounded clarification or schema alignment for the declared
  coverage;
- runtime crate code in `authorized_effects`, `authority_engine`, `kernel`,
  `runtime_bus`, or other existing runtime crates only when required to enforce
  token verification, receipt persistence, journal refs, or path mediation;
- existing or new focused validators under
  `.octon/framework/assurance/runtime/_ops/scripts/`, preferably by updating
  `validate-authorized-effect-token-enforcement.sh`,
  `validate-material-side-effect-inventory.sh`, and
  `validate-authorization-boundary-coverage.sh` rather than creating duplicate
  validators;
- existing or new focused tests under
  `.octon/framework/assurance/runtime/_ops/tests/`, including token bypass,
  token consumption, and material side-effect coverage tests.

After durable edits land, packet-local receipt updates are required:

- `.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage/support/post-implementation-drift-churn-review.md`

Retained validation and promotion evidence must live outside `inputs/**`,
preferably under:

- `.octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` when a lifecycle runner
  creates run evidence
- `.octon/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/**`
  only when updating the existing authorization-boundary evidence root is the
  correct canonical evidence home

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/framework/assurance/runtime/_ops/fixtures/**`, unless the packet is
  revised to add that family as a promotion target;
- `.octon/framework/constitution/**`
- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/exclusions/**`
- `.octon/instance/governance/connector-admissions/**`
- `.octon/instance/governance/connectors/**`
- `.octon/instance/governance/capability-packs/**`
- `.octon/state/control/**`, except through a separately authorized lifecycle
  run that records its own control evidence;
- `.octon/generated/**`, including `.octon/generated/effective/**`
- `.github/**`
- root `README.md`, root `AGENTS.md`, `CLAUDE.md`, or repo-local projection
  adapters
- external workflow engines, Durable Object adapters, MCP integrations,
  connector operation admission behavior, support-target declarations, or
  capability-pack admissions

Do not change `proposal.yml#status`; leave it as `accepted`. The
`promote-proposal` lifecycle route owns the later rewrite to `implemented`.

If implementation requires any out-of-scope durable file, new authority class,
support claim, runtime cutover, generated/effective publication, connector
admission, target-family widening, or replacement of Execution Authorization
v1 or Authorized Effect Token v1 rather than bounded alignment, stop and
report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory implementation-readiness and strict review gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for existing effect-token, material side-effect,
   authorization-boundary, runtime event, execution receipt, runtime crate,
   validator, test, generated, state/control, state/evidence, and continuity
   surfaces.
6. Record the live-baseline finding: existing candidate surfaces must be
   reconciled, not duplicated.

### 1. Material Side-Effect Inventory And Coverage Map

Reconcile the material side-effect inventory and authorization-boundary
coverage map so every live material path has:

- path id and class id;
- owner ref and consumer API ref;
- correct `AuthorizedEffect<T>` token type;
- `token_required: true` for material live paths;
- consumption receipt requirement and journal event requirement;
- coverage state;
- deterministic denial reason code;
- token bypass negative control;
- validator/test refs.

At minimum, evaluate the current path families:

- service invocation: `kernel-tool-invoke`, `stdio-service-run`;
- executor launch: `kernel-studio-launch`;
- repo mutation: `kernel-service-scaffold`, `kernel-service-build`,
  `workflow-stage-run`;
- control mutation: `authority-execution`, `workflow-pipeline-run`;
- evidence mutation: `authority-phases`, `orchestration-report-write` where
  live coverage declares it;
- generated effective publication: runtime route bundle, pack routes, and
  support target matrix publication;
- extension and capability activation paths;
- protected CI check path;
- connector admin and connector live-effect paths, which must stay stage-only
  or denied unless separately admitted.

Do not claim "all repo code paths" are covered. The claim is limited to the
declared material side-effect inventory and authorization-boundary coverage
surface.

### 2. Runtime Token Verification

Strengthen existing runtime crate code instead of creating parallel token
systems.

Required behavior:

- issue typed `AuthorizedEffect<T>` values only from the authorization boundary
  or engine-owned projections of a successful grant;
- verify token records against canonical control/evidence state before
  mutation;
- convert only verified transport tokens into internal `VerifiedEffect<T>`
  guards;
- require mutation helpers to accept the verified guard, not raw grants or raw
  paths alone;
- persist `authorized-effect-token-consumption-v1` receipts for both accepted
  and rejected verification attempts;
- append token journal event refs where the run journal is available;
- include token refs in execution receipts through the existing
  `authorized_effects` field;
- preserve single-use semantics and reject already-consumed tokens;
- fail closed if receipt or journal persistence cannot be completed before or
  at the effect attempt.

Use existing homes such as:

- `.octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/stdio.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/side_effects/mod.rs`

Do not add dependencies unless a separate Dependency Receipt proves that no
existing crate, standard library feature, or local helper is adequate.

### 3. Validators, Fixtures, And Tests

Make validation prove behavior, not just prose.

Required validator behavior:

- `validate-material-side-effect-inventory.sh` proves inventory schema,
  material flags, owner refs, risk tiers, token type presence, and coverage
  receipt binding;
- `validate-authorization-boundary-coverage.sh` proves coverage receipt
  schema, path files, required patterns, token mediation, denial reason codes,
  negative controls, tests, and runtime-enforcement detection;
- `validate-authorized-effect-token-enforcement.sh` proves token contracts,
  runtime event names, execution receipt token refs, fixture case mapping,
  inventory path coverage, and backing Rust tests;
- architecture conformance continues to call the relevant effect-token checks
  without turning proposal-local files into proof.

Required negative cases include:

- missing token;
- decision not allow;
- wrong effect class;
- wrong run;
- wrong route;
- stale token;
- wrong support tuple;
- support envelope blocked;
- unsupported tuple;
- excluded tuple;
- wrong capability pack;
- wrong scope;
- expired token;
- revoked token;
- missing approval;
- missing exception;
- rollback not ready;
- budget exceeded;
- egress denied;
- already consumed;
- missing token type in inventory;
- missing token mediation or token bypass negative control in coverage map.

Tests may use temporary fixtures. Durable fixture edits under
`.octon/framework/assurance/runtime/_ops/fixtures/**` are out of scope unless
the packet is revised.

### 4. Generated And Runtime Publication Posture

This packet does not authorize manual edits under `.octon/generated/**` and
does not require generated/effective publication as a promotion target.

If a validation or runtime publication wrapper must be exercised to prove
effect-token enforcement for generated/effective publication paths, use the
existing runtime-mediated wrapper and retain the resulting evidence outside
`inputs/**`. Do not claim generated-output freshness or live publication
success unless retained publication receipts exist under the canonical evidence
roots.

### 5. Evidence And Receipts

After durable changes land, create or update
`support/implementation-run.md` with at least:

- `verdict`;
- `implemented_at`;
- `promotion_evidence_count`;
- profile selection receipt;
- worktree baseline and changed-file summary;
- implementation map from promotion targets to changed durable files;
- validation commands run and retained evidence refs;
- generated/runtime publication posture;
- rollback posture;
- blocker outcome, if any.

This support receipt is packet-local. It is not implementation proof by
itself. Retained evidence must live outside `inputs/**`.

Then create or update `support/implementation-conformance-review.md` with the
validator-required sections:

- `Blockers`
- `Checked Evidence`
- `Promotion Target Coverage`
- `Implementation Map Coverage`
- `Validator Coverage`
- `Generated Output Coverage`
- `Rollback Coverage`
- `Downstream Reference Coverage`
- `Exclusions`
- `Final Closeout Recommendation`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
```

Then create or update
`support/post-implementation-drift-churn-review.md` with the
validator-required sections:

- `Blockers`
- `Checked Evidence`
- `Backreference Scan`
- `Naming Drift`
- `Generated Projection Freshness`
- `Manifest And Schema Validity`
- `Repo-Local Projection Boundaries`
- `Target Family Boundaries`
- `Churn Review`
- `Validators Run`
- `Exclusions`
- `Final Closeout Recommendation`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
```

Refuse closeout or archive claims, and do not claim implemented,
closeout-ready, or archive-ready status, while either post-implementation
receipt is missing, failing, unresolved, placeholder-like, or blocked.

## Required Validation Commands

Run these from the repository root after implementation. Capture command,
exit code, key output, and retained evidence path.

Packet and review gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization
```

Packet checksum:

```sh
cd .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage && shasum -a 256 -c SHA256SUMS.txt
```

Effect-token enforcement validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
```

Effect-token enforcement tests:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh
```

Runtime crate tests:

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine --lib
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon
```

Post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
```

If any command fails, keep `proposal.yml#status` as `accepted`, record the
blocked gate outcome with evidence, and stop or correct within the approved
target architecture. Do not bypass a failing validator by broadening scope.

## Rollback Posture

Rollback must be explicit and evidence-backed:

- revert only this packet's durable changes inside the approved promotion
  targets;
- preserve retained validation evidence for the failed attempt;
- if token checks block established supported tuples incorrectly, either fix
  the token binding inside the approved target architecture or mark the
  affected path unsupported/denied with retained evidence;
- if bypasses are not denied, remove the success claim and keep the packet
  blocked until negative controls pass;
- do not remove unrelated existing effect-token surfaces unless deletion is
  separately justified and validated.

## Terminal Criteria

Implementation may be reported as ready for the `promote-proposal` lifecycle
route only when all criteria are true:

- durable changes are limited to the approved promotion targets;
- retained evidence outside `inputs/**` proves inventory coverage, token
  enforcement, bypass denial, valid-path acceptance, runtime crate tests, and
  packet validation;
- `support/implementation-run.md` exists with `verdict`, `implemented_at`, and
  `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists, has `verdict: pass`,
  `unresolved_items_count: 0`, contains no scaffold placeholders, and passes
  `validate-proposal-implementation-conformance.sh`;
- `support/post-implementation-drift-churn-review.md` exists, has
  `verdict: pass`, `unresolved_items_count: 0`, contains no scaffold
  placeholders, and passes `validate-proposal-post-implementation-drift.sh`;
- generated outputs, if any were exercised by runtime publication wrappers,
  have retained freshness or publication receipts;
- no active proposal-path backreferences remain in durable promotion targets;
- explicit exclusions remain honored;
- `proposal.yml#status` remains `accepted`.

If any criterion is not true, report a blocked gate outcome with evidence and
refuse closeout or archive claims. Do not claim implemented, closeout-ready,
archive-ready, or live Governed Workflow Runtime support.
