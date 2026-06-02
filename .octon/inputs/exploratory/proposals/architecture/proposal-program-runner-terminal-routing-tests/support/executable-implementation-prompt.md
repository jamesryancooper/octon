# Executable Implementation Prompt

generated_at: 2026-06-02T03:01:26Z
proposal_path: `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests`
proposal_id: `proposal-program-runner-terminal-routing-tests`
route: `run-packet-implementation`

## Authority And Gate

Implement only this accepted proposal packet. The packet is an operational input,
not durable authority. Durable changes may land only in the declared promotion
targets below, and retained validation evidence must live under Octon evidence
roots, not inside generated output or proposal-local support files.

Before making durable changes, re-run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
```

Stop with a blocked gate outcome if either command fails, if the proposal review
is stale, if `implementation_prompt_authorized: yes` is absent, or if any open
blocking finding appears.

Leave `proposal.yml#status` as `accepted`. The separate `promote-proposal`
lifecycle route owns any implemented-status rewrite.

## Target End State

The proposal-program runner has regression coverage for the complete terminal
routing and recovery failure pattern:

- duplicate workflow run-id retry behavior and fail-closed archive observation;
- route-created handoff checkpoints without manual handoff loops;
- aggregate child terminal blockers and recovery taxonomy evidence;
- child-bound promotion evidence and parent non-authority boundaries;
- generated publication freshness preflight and recovery routing;
- parent review churn suppression and digest-scope preservation;
- replay divergence, cancellation/timeout, lock cleanup, and lifecycle residue
  handling;
- integrated handoff-only proposal-program lifecycle behavior after child
  packets are reviewed and prompts are generated.

Tests should fail against the old behavior and pass after the related behavior
packets are implemented. Negative controls must prove authority boundaries fail
closed before executor dispatch or before mock side effects where applicable.

## In Scope

Owned durable write families:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/kernel/tests/`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Use existing fixture styles:

- Rust temporary fixture repos in
  `.octon/framework/engine/runtime/crates/kernel/tests/proposal_program_cli.rs`;
- lifecycle executor adapter fixtures in
  `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs`;
- shell fixture assertions under `.octon/framework/assurance/runtime/_ops/tests/`;
- extension validation test scripts under
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`.

Read-only lineage and coordination inputs include the parent program packet at
`.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening`
and its `resources/child-packet-index.yml`. Use these only to select validation
context. They do not authorize changes outside this child packet's promotion
targets.

## Out Of Scope

Do not mutate these without routing back to packet revision or a linked
proposal:

- proposal manifests, child registries, parent program manifests, closeout,
  archive, cleanup, or promotion receipts except this packet's required support
  receipts after implementation;
- `.octon/generated/**` as direct proof or authority;
- lifecycle contracts, prompts, workflow definitions, runtime specs, source
  crates, or scripts outside the five declared target families;
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/scenarios/**`
  unless the packet is revised to add that family as a promotion target;
- git branch cleanup, repo-hygiene deletion, archive authorization, promotion
  authorization, or hosted provider effects.

Do not weaken fail-closed behavior, required evidence gates, child-owned
receipts, child promotion targets, or generated/input non-authority rules to
make tests pass.

## Workstreams

1. Reconnaissance and mapping

   - Re-read the packet files, parent child registry, existing Rust tests, shell
     lifecycle tests, and extension validation tests.
   - Map each new or updated test to at least one packet acceptance claim and,
     where useful, to the fixture matrix source ids already used by the
     repository: `R005`, `R006`, `R009`, `R016`, `R018`, `R019`, `R024`,
     `R033`, `R060`, `R061`, and `R062`.
   - Record the existing surfaces reused. Do not add a new helper or fixture
     format when an existing fixture writer or shell-test pattern is adequate.

2. Kernel proposal-program tests

   - Extend `.octon/framework/engine/runtime/crates/kernel/tests/` coverage for
     default handoff, `--execute-routes`, max-step bounded execution, route
     selection, child dependency behavior, aggregate blockers, parent
     non-authority, child-owned promotion evidence, replay/resume observations,
     and lock or residue cleanup boundaries.
   - Use `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
     only for testable helpers, unit tests, or narrowly required behavior
     assertions within the declared terminal-routing architecture.
   - Add negative controls showing parent `phase_id`, parent receipts, generated
     projections, and program summaries do not replace child packet lifecycle
     contract routes or child-owned receipts.

3. Lifecycle executor tests

   - Extend `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`
     for duplicate workflow run-id retries, workflow terminal files, archive
     observation blockers, pre-dispatch required input failures, missing or
     failing evidence gates, cancellation, timeout, mutation-before-failure, and
     promotion evidence binding.
   - Keep negative controls fail-closed before executor dispatch when authority,
     required receipts, required inputs, or evidence gates are missing.

4. Assurance shell tests

   - Extend existing tests in `.octon/framework/assurance/runtime/_ops/tests/`
     for lifecycle runner terminal routing, proposal implementation conformance,
     post-implementation drift/churn, residue fingerprinting, generated
     freshness gates, and lifecycle contract validation.
   - Prefer focused additions to existing test files over creating broad new
     scripts. New shell tests are allowed only inside the declared target family
     and must be listed in validation evidence.

5. Extension validation tests

   - Update
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`
     so the proposal-program runner fixture matrix catches drift in coverage
     classes, source id mapping, route resolution, and authority boundaries.
   - Treat validation scenarios as read-only unless the packet is revised. If a
     scenario file must change to make the tests meaningful, stop and report
     `needs-packet-revision`.

6. Integrated handoff-only check

   - After all related child packets are reviewed and executable prompts exist,
     run or record the handoff-only proposal-program lifecycle check against:

     ```sh
     cargo run --quiet --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon -- lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening --run-id proposal-program-terminal-routing-tests-handoff --executor codex
     ```

   - This must remain handoff-only validation evidence. It must not execute
     durable child routes, promote, close out, archive, clean residue, mutate
     generated state, or satisfy child-owned receipts. If the parent or children
     are not ready, record the blocker and do not claim this criterion passed.

## Required Validation

Run the focused suite that matches the touched surfaces:

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --test proposal_program_cli
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_lifecycle_executor --test adapter
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-residue-fingerprint.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-implementation-conformance.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-post-implementation-drift.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh
```

Also run the packet and post-implementation validators after durable changes
and support receipts are written:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
```

If generated freshness or publication tests reveal real stale generated
effective outputs, run only the canonical publication or registry refresh
script implicated by that failure and retain publication evidence. Otherwise
record generated/runtime publication as `not required`.

## Evidence And Receipts

After durable changes land, create or update
`support/implementation-run.md` with at least:

```yaml
verdict: pass|blocked|fail
implemented_at: <UTC ISO-8601 timestamp>
promotion_evidence_count: <integer>
```

Use `verdict: pass` only when all declared durable target changes are present,
validation evidence exists, and promotion evidence can be counted. The receipt
must summarize:

- changed promotion targets;
- validators run and outcomes;
- retained evidence paths or why retained evidence was not required for a
  local fixture-only validator;
- generated/runtime publication posture;
- blockers, if any.

Then create or update `support/implementation-conformance-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count: <integer>`
- sections named `Blockers`, `Checked Evidence`, `Promotion Target Coverage`,
  `Implementation Map Coverage`, `Validator Coverage`,
  `Generated Output Coverage`, `Rollback Coverage`,
  `Downstream Reference Coverage`, `Exclusions`, and
  `Final Closeout Recommendation`.

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
```

Then create or update `support/post-implementation-drift-churn-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count: <integer>`
- sections named `Blockers`, `Checked Evidence`, `Backreference Scan`,
  `Naming Drift`, `Generated Projection Freshness`,
  `Manifest And Schema Validity`, `Repo-Local Projection Boundaries`,
  `Target Family Boundaries`, `Churn Review`, `Validators Run`,
  `Exclusions`, and `Final Closeout Recommendation`.

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-tests
```

Refuse implemented, closeout, archive-ready, or promotion-ready claims while
either post-implementation receipt is missing, failing, unresolved, blocked, or
not validator-clean.

## Rollback Posture

Rollback is patch reversal of test and fixture additions inside the declared
promotion target families, plus reversal of this packet's implementation-run,
conformance, and drift/churn support receipts if the implementation is backed
out before promotion. If any generated publication refresh was required, record
the corresponding rollback or re-publication path in the receipts. Do not
delete unrelated local state/control/evidence artifacts as part of this packet.

## Delegation

Delegation is optional. If used, assign disjoint write scopes:

- kernel owner: `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
  and `.octon/framework/engine/runtime/crates/kernel/tests/`;
- executor owner:
  `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`;
- assurance owner: `.octon/framework/assurance/runtime/_ops/tests/`;
- extension validation owner:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`.

One integration owner must reconcile results, run validation, write receipts,
and ensure no worker widens scope or reverts unrelated work.

## Terminal Criteria

The implementation route is complete only when:

- all durable edits stay within the five declared promotion target families;
- negative controls prove authority boundaries fail closed;
- focused Rust, shell, extension validation, and packet validators pass or a
  blocked outcome records exact failing evidence;
- `support/implementation-run.md` exists with required fields;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh` passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh` passes;
- generated/runtime publication posture is recorded;
- rollback posture and remaining limitations are recorded;
- `proposal.yml#status` remains `accepted`.
