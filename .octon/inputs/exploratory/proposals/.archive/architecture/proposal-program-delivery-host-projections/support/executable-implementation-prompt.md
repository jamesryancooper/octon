# Executable Implementation Prompt

prompt_id: proposal-program-delivery-host-projections-implementation-20260701T031042Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections
route: run-packet-implementation
generator: octon-proposal-lifecycle-generate-packet-implementation-prompt
review_receipt_ref: support/proposal-review.md
pre_integration_architecture_review_ref: support/pre-integration-architecture-review.yml
implementation_authorization_gate: validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections --require-implementation-authorization
authorized_review_digest: sha256:994c7182a33aaefce42940664468ab345023e92df5b77af326f1fe53dc2051ee
implementation_authorized: yes

## Objective

Implement the accepted child packet by adding or correcting repo-local `.codex`
host projections for accepted proposal delivery wrappers. The implementation
must make operator-facing Codex command and skill discovery match canonical
`.octon` delivery surfaces without creating independent lifecycle authority.

This packet is a repo-local host projection child. It does not authorize changes
to canonical `.octon` runtime authority, product catalog claims, validators,
lifecycle contracts, generated/effective outputs, archive behavior, cleanup
behavior, Git mutation behavior, parent program closeout, or terminal proof.

## Authorized Write Set

Durable implementation edits are limited to the accepted promotion targets:

- `.codex/skills/proposal-program-delivery/`
- `.codex/skills/proposal-packet-delivery/`
- `.codex/skills/proposal-packet-terminal-closeout/`
- `.codex/commands/`

Packet-local implementation evidence may be written under:

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections/support/post-implementation-drift-churn-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections/support/validation.md`

Do not edit `.octon/framework/**`, `.octon/instance/**`, `.octon/generated/**`,
`.octon/state/control/**`, `.claude/**`, `.cursor/**`, or unrelated `.codex/**`
files from this child. If implementation discovers that a canonical `.octon`
manifest, product catalog entry, validator, or generated publication route must
change before a projection is truthful, do not make that edit here. Record an
explicit narrowing or blocker in packet-local evidence and route the `.octon`
change to an owning `.octon`-scoped child.

## Current Repository Inventory

This inventory was observed during prompt generation and must be rechecked by
the implementer before editing:

- Canonical command sources exist:
  - `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
  - `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
  - `.octon/framework/capabilities/runtime/commands/proposal-packet-terminal-closeout.md`
- Canonical skill sources exist:
  - `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
  - `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
  - `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-terminal-closeout/SKILL.md`
- `.codex/commands/proposal-program-delivery.md` exists and matched the
  canonical command content when this prompt was generated.
- `.codex/commands/proposal-packet-terminal-closeout.md` exists.
- `.codex/commands/proposal-packet-delivery.md` was absent.
- `.codex/skills/proposal-program-delivery/`,
  `.codex/skills/proposal-packet-delivery/`, and
  `.codex/skills/proposal-packet-terminal-closeout/` were absent.
- `.codex/commands/octon-proposal-run-program-delivery.md` and
  `.codex/commands/octon-proposal-run-packet-delivery.md` exist as
  operator-facing aliases. Adjust them only if they are stale against canonical
  sources and remain within `.codex/commands/`.

Do not treat this inventory as authority. Re-run `find`, `rg`, and direct file
reads against current repository state before deciding what to create, update,
or explicitly narrow.

## Workstreams

1. Rebind prerequisites.
   - Read repo ingress instructions and the packet source-of-truth map.
   - Confirm `release_state=pre-1.0` and `change_profile=atomic`.
   - Run the implementation authorization gate before editing.
   - Inspect `git status --short` and partition unrelated existing changes.

2. Resolve canonical source surfaces.
   - Compare the three canonical command files to any existing `.codex`
     command projections.
   - Compare the three canonical operations skill files to any existing
     `.codex/skills/<delivery-id>/SKILL.md` projections.
   - Use workflow files under
     `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`,
     `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`,
     and
     `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
     only as source references for projection wording.

3. Publish or correct `.codex` projections.
   - Create or refresh `.codex/commands/proposal-packet-delivery.md` if the
     current canonical source supports a truthful Codex command projection.
   - Refresh `.codex/commands/proposal-program-delivery.md` and
     `.codex/commands/proposal-packet-terminal-closeout.md` only if they have
     drifted from canonical source behavior.
   - Create or refresh:
     - `.codex/skills/proposal-program-delivery/SKILL.md`
     - `.codex/skills/proposal-packet-delivery/SKILL.md`
     - `.codex/skills/proposal-packet-terminal-closeout/SKILL.md`
   - Keep skill names, descriptions, route references, required checks,
     outputs, and boundaries aligned with the canonical `.octon` operations
     skill for the same delivery id.
   - Keep aliases under `.codex/commands/octon-proposal-run-*.md` as aliases
     only. They must not claim independent lifecycle contracts.

4. Bind non-authority notices in every projection.
   - Each projection must cite its canonical `.octon` source path.
   - Each projection must state that it is a host discovery/operator
     convenience surface only.
   - Each projection must state that it does not authorize delivery, closeout,
     archive, cleanup, generated publication, Git mutation, branch cleanup,
     terminal proof, parent/program outcome claims, or replacement of
     target-owned receipts.
   - Each projection must preserve the canonical profile, run-id, route, and
     evidence requirements. Do not weaken required inputs for convenience.

5. Add deterministic projection inventory evidence.
   - Record the expected `.codex` projection set in `support/validation.md`.
   - For each expected projection, record whether it exists or is intentionally
     narrowed.
   - For each created or refreshed projection, record the canonical source path
     it cites.
   - Include negative-control checks showing that projection text does not
     claim independent authority, direct archive, cleanup, Git mutation,
     generated publication, terminal proof, or source receipt replacement.
   - If any projection is intentionally not created, record the reason and the
     owning follow-up route. Do not leave a silent missing surface.

6. Produce packet-local implementation receipts.
   - Write `support/implementation-run.md` with the write set, files changed,
     current inventory, source references, validation commands, validation
     results, and rollback posture.
   - Write `support/implementation-conformance-review.md` with `verdict: pass`
     only if accepted promotion targets, source binding, non-authority notices,
     validation evidence, generated-output coverage, rollback coverage, and
     downstream reference checks are complete.
   - Write `support/post-implementation-drift-churn-review.md` with
     `verdict: pass` only if the implementation did not create unauthorized
     `.octon` authority changes, duplicate wrappers, unsupported aliases,
     stale projections, or unrelated churn.

## Validation Commands

Run from the repository root before any success claim:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections --mode pre-integration-architecture-review --require-pass
```

Run projection-specific checks after implementation. At minimum, prove the
expected files either exist or have explicit narrowing evidence:

```sh
test -f .codex/commands/proposal-program-delivery.md
test -f .codex/commands/proposal-packet-delivery.md
test -f .codex/commands/proposal-packet-terminal-closeout.md
test -f .codex/skills/proposal-program-delivery/SKILL.md
test -f .codex/skills/proposal-packet-delivery/SKILL.md
test -f .codex/skills/proposal-packet-terminal-closeout/SKILL.md
rg -n "canonical|Canonical|\\.octon/framework/" .codex/commands/proposal-program-delivery.md .codex/commands/proposal-packet-delivery.md .codex/commands/proposal-packet-terminal-closeout.md .codex/skills/proposal-program-delivery/SKILL.md .codex/skills/proposal-packet-delivery/SKILL.md .codex/skills/proposal-packet-terminal-closeout/SKILL.md
rg -n "non-authoritative|does not authorize|does not create an independent|does not replace" .codex/commands/proposal-program-delivery.md .codex/commands/proposal-packet-delivery.md .codex/commands/proposal-packet-terminal-closeout.md .codex/skills/proposal-program-delivery/SKILL.md .codex/skills/proposal-packet-delivery/SKILL.md .codex/skills/proposal-packet-terminal-closeout/SKILL.md
```

Then run the required post-implementation packet gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections
git diff --check
```

If a projection is intentionally narrowed, replace the corresponding `test -f`
expectation with an explicit packet-local evidence check that identifies the
missing projection, reason, source authority blocker, and owning follow-up
route.

## Evidence Requirements

Retain child-owned evidence only. Parent program evidence, aggregate delivery
receipts, generated prompts, generated outputs, host state, chat state, model
memory, and local dashboards do not satisfy this child packet's acceptance
criteria.

Required packet-local receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Where applicable, retain projection publication or freshness evidence under
the canonical `.octon/state/evidence/**` evidence roots, but do not invent a
new evidence schema for this child. If projections are generated rather than
hand-authored, generation must run through the owning publisher or generator
and cite retained publication evidence. Do not hand-edit `.octon/generated/**`.

## Rollback Posture

Rollback is a file-level revert or supersession of only this child packet's
`.codex` projection edits plus packet-local implementation receipts. Retained
evidence must be preserved or superseded through the owning evidence/cleanup
route. Do not delete repo hygiene residue, archive packets, mutate proposal
status, stage, commit, push, create pull requests, land branches, or clean
branches from this implementation route.

## Delegation Boundaries

No subagent or external connector delegation is authorized by this prompt. The
implementer may use local shell search, file reads, focused edits, and local
validators. Escalate or block instead of delegating if a required `.octon`
authority, product catalog, generated publication, or validator change is
discovered.

## Terminal Criteria

Implementation is complete only when all of the following are true:

- The implementation stayed within the authorized `.codex` projection write
  set and packet-local evidence files.
- Each expected `.codex` projection exists or has explicit narrowing evidence.
- Every created or refreshed projection cites its canonical `.octon` source.
- Every created or refreshed projection includes an explicit non-authority
  notice.
- Projection names, descriptions, usage examples, required inputs, and
  boundaries match the accepted canonical delivery input contracts.
- Product catalog coherence is not silently widened by this child.
- Parent program evidence is not used to satisfy this child acceptance
  criteria.
- `support/implementation-conformance-review.md` exists with a passing verdict
  and `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections`
  passes.
- `support/post-implementation-drift-churn-review.md` exists with a passing
  verdict and `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-host-projections`
  passes.

Refuse closeout, archive, terminal readiness, cleaned delivery, parent program
delivery, generated publication, Git mutation, branch cleanup, cleanup deletion,
or final success claims while either post-implementation receipt is missing,
stale, failing, unresolved, or outside the authorized child scope.
