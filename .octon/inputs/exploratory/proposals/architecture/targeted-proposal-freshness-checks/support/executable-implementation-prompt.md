prompt_id: targeted-proposal-freshness-checks-implementation-20260622T024356Z
generated_at: 2026-06-22T02:43:56Z
generator: codex-manual-generate-packet-implementation-prompt-route
proposal_path: .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks
proposal_review_ref: .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks/support/proposal-review.md
implementation_authorized: yes
child_authority_preserved: yes

# Executable Implementation Prompt

## Objective

Implement the accepted child packet
`.octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks`.

The target end state is a safe targeted freshness path that can validate one
proposal, its generated proposal artifact bundle, declared child or dependency
refs, and cited retained evidence indexes without rerunning the full proposal
registry on every small proposal-local mutation. The full proposal registry
check must remain required for final publication, delivery, and terminal gates.

## Binding Scope

Implement only these approved promotion targets:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/assurance/runtime/_ops/tests/`

Do not modify parent program receipts, unrelated child packets, proposal archive
state, closeout state, cleanup state, branch state, git history, generated
effective outputs, generated proposal artifacts by hand, external systems, or
any durable target outside the list above. If satisfying the acceptance
criteria requires a durable target outside this child packet's approved
promotion scope, stop and route a child revision instead of widening scope
silently.

At prompt generation time, the worktree already contained unrelated local
changes and a local modification to
`.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`.
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
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks --require-implementation-authorization
   ```

3. In `validate-proposal-lifecycle-terminal-freshness.sh`, add a targeted mode
   for scoped proposal freshness. The targeted mode must validate the target
   proposal manifest, generated artifact index, proposal artifact spine, and
   any generated child handoff capsule when present.
4. Make targeted dependency coverage explicit. It must include declared
   child/dependency refs from the selected packet, including child file inputs
   already accepted by the validator and proposal-local dependency refs such as
   `related_proposals` or generated artifact dependency metadata where the
   existing generator exposes them. Missing, stale, or unparsable dependency
   refs must fail closed.
5. Preserve full-registry final gates. Targeted mode may avoid full registry
   traversal for narrow freshness checks, but final publication, delivery, and
   terminal routes must still require `generate-proposal-registry.sh --check`
   or an equivalent full-registry validator path.
6. Update `generate-proposal-registry.sh` only as needed to support targeted
   freshness safely. Any targeted behavior must be explicitly separate from
   the existing full `--check` behavior, must not weaken duplicate-key checks
   for full mode, and must not let a generated registry projection replace
   proposal manifests or child-owned receipts.
7. Update `generate-proposal-artifact-index.sh` only as needed to emit or check
   dependency/source metadata required by the targeted validator. Generated
   proposal artifacts remain derived-only and must be refreshed only through
   this canonical generator.
8. Update `proposal-program.contract.yml` only as needed to declare targeted
   freshness semantics, final full-registry gate requirements, source-ref or
   digest behavior, and authority boundaries. Do not weaken existing recovery,
   closeout, archive, generated-output, or human-boundary constraints.
9. Add focused regression coverage under `.octon/framework/assurance/runtime/_ops/tests/`.
   Extend existing tests when that is the smallest robust surface.

## Required Regression Behavior

Include or preserve tests named or equivalent to:

- `targeted_terminal_freshness_validates_scoped_proposal_and_dependencies`
- `targeted_terminal_freshness_fails_on_stale_generated_artifact`
- `targeted_terminal_freshness_does_not_replace_full_registry_gate`

The tests must prove:

- targeted mode validates one selected proposal plus declared dependencies;
- stale or missing generated proposal artifact output fails closed;
- parent summaries cannot satisfy child-owned evidence;
- generated proposal artifacts remain derived-only;
- the final full registry check remains mandatory and still fails on global
  registry drift or duplicate proposal keys.

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
whether full-registry gates remain mandatory for final routes.

Retain validation evidence under a canonical validation evidence root when the
implementation route produces retained logs, for example
`.octon/state/evidence/validation/proposals/targeted-proposal-freshness-checks/<timestamp>/`.
Retained logs are evidence only; they do not authorize closeout, archive,
publication, cleanup, or delivery.

## Validation Commands

Run these packet gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks --require-implementation-authorization
```

Run the implementation validators from the packet, adapting only fixture paths
where the tests create temporary proposal packets:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-terminal-freshness.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-proposal-registry.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal <fixture> --targeted
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Then run the required post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks
```

## Rollback Posture

Rollback is limited to this child packet's approved promotion targets. Revert
or supersede only the targeted freshness validator, registry generator,
artifact index generator, proposal-program contract, and tests changed for this
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
