prompt_id: proposal-program-execution-mode-normalization-implementation-20260623T162232Z
generated_at: 2026-06-23T16:22:32Z
generator: codex-manual-generate-packet-implementation-prompt-route
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
proposal_review_ref: .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization/support/proposal-review.md
implementation_authorized: yes
child_authority_preserved: yes

# Executable Implementation Prompt

## Objective

Implement the accepted child packet
`.octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization`.

The target end state is a single normalized proposal-program execution-mode
model across program manifests, child registries, lifecycle contract metadata,
planner code, validators, and tests. The legacy `sequenced-gated` vocabulary
must be either eliminated from active writable surfaces or explicitly aliased
to the canonical `gated-parallel` scheduler behavior with no semantic loss.

The implementation must preserve dependency gates and phase ordering. A parent
program summary, generated projection, archived correction prompt, or local
operator note must never replace child-owned receipts, validation verdicts, or
terminal lifecycle outcomes.

## Binding Scope

Implement only these approved promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Do not modify parent program receipts, unrelated child packets, generated
effective outputs by hand, proposal archive state, closeout state, cleanup
state, branch state, git history, external systems, or durable targets outside
the list above. If satisfying the acceptance criteria requires another durable
target, stop and route a child revision instead of widening scope silently.

At prompt generation time, the worktree already contained unrelated local
changes and local modifications to
`.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` and
`.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh`.
Reconfirm live state before editing and preserve unrelated work.

## Required Workstreams

1. Re-read this child packet's `proposal.yml`, `architecture-proposal.yml`,
   `architecture/target-architecture.md`, `architecture/implementation-plan.md`,
   `architecture/acceptance-criteria.md`, `validation-plan.md`,
   `support/implementation-grade-completeness-review.md`,
   `support/pre-integration-architecture-review.yml`, and
   `support/proposal-review.md`.
2. Re-run the proposal review gate before durable edits:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization --require-implementation-authorization
   ```

3. In `lifecycle_program.rs`, introduce or reuse one canonical normalization
   path for proposal-program execution modes. Apply it wherever the planner
   parses or compares child-registry `execution_mode`, and wherever manifest
   `program_execution_mode` is read or reconciled if that field is added to
   the planner path. Avoid scattered raw-string alias checks.
4. Treat `sequenced-gated` as an explicit legacy alias of canonical
   `gated-parallel` behavior unless the implementation proves all active
   writable manifests and registries can be safely migrated without losing the
   archived planner recovery use case. The alias must not create a new
   scheduler mode and must not bypass dependency gates, phase ordering,
   write-scope serialization, approval blockers, or child terminal gates.
5. Keep `registry.execution_mode` and manifest `program_execution_mode` from
   creating contradictory planner signals. If both are present for a program,
   normalize both to their canonical values and fail closed when they disagree
   after alias resolution.
6. In `validate-proposal-program-structure.sh`, add execution-mode validation
   for `resources/child-packet-index.yml`. The validator must accept canonical
   supported modes, accept `sequenced-gated` only through the same documented
   alias semantics, and reject unknown modes with a recovery diagnostic that
   points at `resources/child-packet-index.yml#execution_mode`.
7. In `proposal-program.contract.yml`, document the canonical execution modes
   and the `sequenced-gated -> gated-parallel` alias boundary without weakening
   existing recovery, closeout, archive, generated-output, or human-boundary
   constraints. Keep `program.supported_execution_modes` canonical unless the
   lifecycle contract validator is updated through an authorized target; do
   not require out-of-scope edits to `validate-lifecycle-contracts.sh`.
8. Add focused regression coverage. The Rust test surface may live in
   `lifecycle_program.rs`; shell coverage may extend existing tests under
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`.
   Extend existing tests when that is the smallest robust surface.

## Required Regression Behavior

Include or preserve tests named or equivalent to:

- `program_execution_mode_aliases_preserve_dependency_semantics`
- `program_structure_accepts_sequenced_gated_alias`
- `program_structure_rejects_unknown_execution_mode`

The tests must prove:

- `sequenced-gated` normalizes to `gated-parallel`;
- runnable-child selection for the alias is identical to `gated-parallel`;
- dependency gates and phase ordering remain enforced;
- manifest `program_execution_mode` and registry `execution_mode` cannot
  silently disagree after normalization;
- unknown execution modes fail closed in the planner and structure validator;
- parent program summaries cannot satisfy child-owned evidence;
- generated outputs remain derived-only and are not hand-edited.

## Evidence And Receipts

After durable implementation changes land, create or update these child-owned
receipts under this packet:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

`support/implementation-run.md` must include at least `verdict`,
`implemented_at`, `promotion_evidence_count`, the promotion targets changed,
and implementation evidence refs. The conformance and drift/churn reviews must
state whether all approved promotion targets are covered, whether generated
outputs were changed by hand, whether proposal inputs remained
non-authoritative, whether parent summaries remained non-substitutive, and
whether the execution-mode alias preserves dependency-gated scheduling.

Retain validation evidence under a canonical validation evidence root when the
implementation route produces retained logs, for example
`.octon/state/evidence/validation/proposals/proposal-program-execution-mode-normalization/<timestamp>/`.
Retained logs are evidence only; they do not authorize closeout, archive,
publication, cleanup, branch mutation, or delivery.

## Validation Commands

Run these packet gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization --require-implementation-authorization
```

Run the implementation validators from the packet, adapting only fixture paths
where the tests create temporary proposal programs:

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel lifecycle_program::tests::program_execution_mode_aliases_preserve_dependency_semantics
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <fixture-program>
octon lifecycle plan --lifecycle proposal-program --target <fixture-program>
```

The packet records the historical command spelling
`cargo test -p kernel lifecycle_program::tests::program_execution_mode_aliases_preserve_dependency_semantics`.
The current Rust package name is `octon_kernel`; record the package-name
adaptation in `support/validation.md`.

Then run the required post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
```

## Rollback Posture

Rollback is limited to this child packet's approved promotion targets. Revert
or supersede only the execution-mode normalization logic, program-structure
validator changes, proposal-program contract updates, and tests made for this
child, then rerun the packet gates and implementation validators.

Do not delete protected retained evidence. Evidence artifacts created by the
implementation route must be superseded or cleaned only through an explicit
governed cleanup route.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted` after implementation. Refuse closeout
and archive claims, and do not claim `implemented`, `cleaned`, delivery-ready,
or parent-program-complete state while `support/implementation-run.md`,
`support/implementation-conformance-review.md`,
`support/post-implementation-drift-churn-review.md`, `support/validation.md`,
or either post-implementation validator is missing, stale, failing,
unresolved, or outside this child packet's authority.
