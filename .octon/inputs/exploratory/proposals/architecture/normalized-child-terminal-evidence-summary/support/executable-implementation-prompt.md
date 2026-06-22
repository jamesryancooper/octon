prompt_id: normalized-child-terminal-evidence-summary-implementation-20260622T014605Z
generated_at: 2026-06-22T01:46:05Z
generator: codex-manual-generate-packet-implementation-prompt-route
proposal_path: .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary
proposal_review_ref: .octon/inputs/explatory/proposals/architecture/normalized-child-terminal-evidence-summary/support/proposal-review.md
implementation_authorized: yes
child_authority_preserved: yes

# Executable Implementation Prompt

## Objective

Implement the accepted child packet
`.octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary`.

The target end state is a normalized terminal evidence summary for proposal
program children, including archived implemented children, without allowing a
parent program summary to replace child-owned manifests, receipts, validation
verdicts, closeout evidence, archive metadata, retained evidence indexes, or
lifecycle outcomes.

## Binding Scope

Implement only these approved promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/product/contracts/proposal-child-terminal-evidence-summary-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

Do not modify parent program receipts, unrelated child packets, generated
effective outputs by hand, proposal archive state, closeout state, cleanup
state, branch state, git history, or external systems. Do not add durable
targets outside this list. If satisfying the acceptance criteria requires a
new durable target outside this list, stop and route a child packet revision.

At prompt generation time, the worktree already contained local modifications
to `lifecycle_program.rs` and `proposal-program.contract.yml`, and the schema
target did not exist. Reconfirm live state before editing, preserve existing
unrelated work, and complete or reconcile existing implementation rather than
duplicating it.

## Required Workstreams

1. Re-read this child packet's `proposal.yml`, `architecture-proposal.yml`,
   `architecture/target-architecture.md`, `architecture/implementation-plan.md`,
   `architecture/acceptance-criteria.md`, `validation-plan.md`,
   `support/implementation-grade-completeness-review.md`,
   `support/pre-integration-architecture-review.yml`, and
   `support/proposal-review.md`.
2. Re-run the proposal review gate before durable edits:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary --require-implementation-authorization
   ```

3. In `lifecycle_program.rs`, add or reconcile the normalized child terminal
   evidence computation so program planning and terminal closeout can represent
   these facts consistently:

   - child id, lifecycle id, child target, required/deferred posture, final
     verdict, selected route, terminal outcome, and blocker state;
   - whether the child is active implemented, archived implemented, rejected,
     or otherwise non-terminal;
   - child-owned implementation run, implementation conformance,
     post-implementation drift/churn, proposal closeout, terminal closeout,
     validation, archive metadata, promotion evidence, and retained evidence
     index status;
   - authority boundaries proving parent summaries are diagnostic only and do
     not satisfy child receipts.

4. Preserve the key behavior:

   - archived implemented children may satisfy terminal readiness through
     archive metadata plus child closeout, conformance, drift, validation, and
     retained evidence index evidence;
   - active non-archived implemented children still require strict
     implementation-run fields before terminal handling;
   - parent summaries never replace child-owned receipts or child-owned
     terminal lifecycle outcomes.

5. Create `.octon/framework/product/contracts/proposal-child-terminal-evidence-summary-v1.schema.json`.
   The schema must validate the normalized summary shape, require explicit
   source refs and digests for child-owned evidence, include fail-closed
   freshness behavior, and encode non-authority boundaries:

   - parent summary does not satisfy child receipts;
   - proposal inputs are non-authoritative;
   - generated outputs are derived-only;
   - retained evidence remains evidence-only unless a higher control artifact
     independently grants authority.

6. Update `validate-proposal-program-child-readiness.sh` so the child readiness
   gate recognizes archived implemented terminal evidence through the same
   normalized evidence rules, while keeping active implemented children on the
   strict implementation-run path.
7. Update `validate-proposal-program-readiness-projection.sh` so readiness
   projections can validate normalized child terminal evidence and retained
   evidence indexes without claiming dispatch, implementation, archive,
   closeout, correction, or generated publication authority.
8. Update `proposal-program.contract.yml` only as needed to declare the
   normalized terminal evidence summary, deterministic preflight, source-ref,
   validation binding, failure behavior, or authority boundary. Do not weaken
   existing recovery, closeout, archive, generated-output, or human-boundary
   constraints.
9. Add focused regression coverage inside approved targets. The Rust test
   surface may live in `lifecycle_program.rs`; do not create or modify separate
   test files unless a child revision authorizes that additional durable target.

## Required Regression Behavior

Include or preserve tests named or equivalent to:

- `archived_implemented_child_terminal_evidence_replaces_legacy_run_receipt_repair`
- `active_implemented_child_still_requires_strict_implementation_run_fields`

The first test must prove archived implemented children no longer enter legacy
receipt-repair loops when child-owned terminal evidence is present. The second
test must prove active implemented children still fail closed when strict
implementation-run fields are missing.

Add negative controls for missing or stale child evidence, parent-summary-only
evidence, missing archive promotion evidence, and generated-output authority
claims where the existing target files provide an appropriate test surface.

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
state whether all approved promotion targets are covered, whether any generated
outputs were changed by hand, whether proposal inputs remained
non-authoritative, and whether parent summaries remained non-substitutive.

Retain validation evidence under a canonical validation evidence root when the
implementation route produces retained logs, for example
`.octon/state/evidence/validation/proposals/normalized-child-terminal-evidence-summary/<timestamp>/`.
Retained logs are evidence only; they do not authorize closeout or archive.

## Validation Commands

Run these packet gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary --require-implementation-authorization
```

Run the implementation validators from the packet, adapting only fixture paths
and using the repository's actual Rust package name if needed:

```sh
cargo test -p octon_kernel lifecycle_program::tests::archived_implemented_child_terminal_evidence_replaces_legacy_run_receipt_repair
cargo test -p octon_kernel lifecycle_program::tests::active_implemented_child_still_requires_strict_implementation_run_fields
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <fixture-program>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package <fixture-program> --require-terminal-evidence
```

If the implementation keeps the packet's historical command spelling
`cargo test -p kernel ...`, first verify that package alias exists. If it does
not, use `octon_kernel` and record the adaptation in `support/validation.md`.

Then run the required post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary
```

## Rollback Posture

Rollback is limited to this child packet's approved promotion targets. Revert
or supersede only the normalized terminal evidence summary logic, schema,
validator changes, and proposal-program contract changes made for this child,
then rerun the proposal gates and implementation validators.

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
