# External Tool Integrity Amendment Change Closeout

- Run ID: `external-tool-integrity-amendment-20260719T193436Z`
- Recorded at: `2026-07-19T19:34:36Z`
- Release state: `pre-1.0`
- Change profile: `atomic`
- Selected route: `branch-pr`
- Target lifecycle outcome: `published`

## Candidate Preservation

The amendment was reconstructed in the clean worktree
`/private/tmp/octon-external-tool-integrity-20260719` from
`origin/main@72391b18d9341bce4e7ba109ec8db11ef2389f92` on branch
`chore/external-tool-integrity`.

The implementation surface contains 70 amendment paths: 66 tracked files and
four new files. It is limited to the constitutional charter and registries,
workspace/ingress policy, execution guidance, proposal and architecture-review
contracts, workflow guides, validator wiring, and tests described by the
retained 2026-07-16 change manifest. Three additional paths contain the fresh
closed-book charter-audit report, execution log, and log-index entry.

The reconstructed candidate plus charter-audit evidence has digest
`sha256:88c39435049a5ab0148d49287200aa83667d98c9931c0b517bc59c189082c8ff`.
No proposal packet, generated projection, runtime implementation, provider,
credential, publication, or production state is included.

## Collision Resolution

- The current `origin/main` external-tool constraint row was retained without
  duplication.
- The new `external_tool_integrity_policy` contract-registry entry was added
  while preserving the newer `owner_lane_authority_contracts` block.
- All unrelated canonical-main residue, older RP-00/closeout changes, proposal
  inputs, state residue, and generated output remain excluded.

## Validation

Passing checks:

- `validate-external-tool-integrity.sh`: errors=0.
- `test-validate-external-tool-integrity.sh`: pass, including three negative controls.
- `validate-alignment-profile-registry.sh`: errors=0.
- `test-architectural-review-validators.sh`: pass, including the current-receipt negative control.
- `validate-architectural-review-workflows.sh`: errors=0.
- `validate-create-architecture-proposal-workflow.sh`: errors=0.
- `validate-audit-architecture-proposal-workflow.sh`: errors=0.
- `test-validate-proposal-review-gate.sh`: 20 passed, 0 failed.
- `test-validate-proposal-program-child-readiness.sh`: 13 passed, 0 failed.
- `test-proposal-operation-workflow-runners.sh`: 11 passed, 0 failed.
- bootstrap ingress, developer context, context overhead, audit-subsystem alignment,
  authoritative-document triggers, subordinate-owner identifiers, and
  constitutional-family live-model checks: pass.
- changed shell syntax: pass.
- changed YAML parse: pass.
- `git diff --check`: pass.

Broad observation:

- `validate-framing-alignment.sh` retains two unrelated pre-existing findings in
  `public-distribution-portable-base-clearance`; neither path is changed by this
  amendment.

## Independent Charter Audit

The closed-book audit at
`.octon/state/evidence/validation/analysis/2026-07-19-charter-audit-2026-07-19-external-tool-integrity-amendment.md`
reports `Partially aligned`, zero direct contradictions, four latent conflicts,
zero high-severity gaps, four medium gaps, and two low gaps. The amendment is
coherent with the charter's authority, adapter, support, and fail-closed model.
The medium findings concern pre-existing standalone accountability,
terminology, precedence, and measurement gaps and are not newly introduced by
the amendment.

## Route And Rollback

`branch-pr` is selected because the operator explicitly authorized a fresh
protected-main PR reconstruction. `closeout-change` preserves the candidate;
`closeout-pr` owns the draft PR publication. Before landing, rollback means
retaining the branch without integration. After any future protected squash
merge, rollback requires a revert through a new protected-main PR.

The dirty canonical `main` worktree and every other retained worktree remain
untouched. Cleanup and worktree removal remain deferred under SI-00.
