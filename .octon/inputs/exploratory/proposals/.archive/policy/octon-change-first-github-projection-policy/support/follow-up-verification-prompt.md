# Follow-Up Verification Prompt

## Verification Target

Verify the implemented proposal packet at:

```text
.octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
```

Packet identity:

- `proposal_id`: `octon-change-first-github-projection-policy`
- `proposal_kind`: `policy`
- `status`: `accepted`
- `promotion_scope`: `repo-local`

Act as an independent verifier. Re-ground against the current repository state
before judging the packet. Proposal-local files are lifecycle evidence and
operational aids only. Durable behavior must be proven through approved
`.github/**` promotion targets, retained validation evidence, current
repository state, and validators.

Return exactly one final route status:

- `clean`
- `needs-packet-revision`
- `blocked`
- `superseded`
- `explicitly-deferred`

Do not use ambiguous success language.
Use `corrections-needed` only as a nonterminal loop state when stopping to
materialize targeted correction prompts. It is not a terminal route status.

## Required Source Reading

Read these packet files before checking durable targets:

- `proposal.yml`
- `policy-proposal.yml`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `implementation/implementation-map.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/executable-implementation-prompt.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Then verify every `promotion_targets` entry in `proposal.yml` against the
repository.

Read the canonical Change-first authority contracts before judging GitHub
projection behavior:

- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`

## Implementation-Grade Completeness Gate

The packet declares this pre-implementation gate outcome:

- `support/implementation-grade-completeness-review.md`
- `verdict: pass`
- `unresolved_questions_count: 0`
- `clarification_required: no`

Treat the implementation-grade gate as satisfied only if the receipt still
exists, still records this outcome, and still aligns with the implemented
promotion targets.

## Implemented-Evidence Closeout Blockers

This packet has completed `run-packet-implementation` while
`proposal.yml#status` remains `accepted`. The verification route must not
rewrite status. The separate `promote-proposal` workflow route owns any future
rewrite to `implemented`.

For implemented-evidence verification, these receipts and validators are
mandatory blockers:

- `support/implementation-run.md` must exist, declare `verdict: pass`, and
  declare `unresolved_items_count: 0`.
- `support/implementation-conformance-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `support/post-implementation-drift-churn-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `validate-proposal-implementation-readiness.sh` must pass for this packet.
- `validate-proposal-implementation-conformance.sh` must pass for this packet.
- `validate-proposal-post-implementation-drift.sh` must pass for this packet.

If any of those checks are missing or failing, return `corrections-needed`
unless the failure proves the accepted packet itself is semantically
incomplete. In that case return `needs-packet-revision`.

## Closure-Certification Pass Depth

This packet does not declare a special multi-pass closure-certification
requirement. A clean verification result requires one retained clean pass after
all required checks run. If any correction is applied, rerun the full required
command set and confirm the rerun introduces no new finding.

## Stable Finding Identity

Use stable finding ids in the `OCFGPP-VFY` namespace:

- `OCFGPP-VFY-001`, `OCFGPP-VFY-002`, and so on.
- Reuse the same id across reruns for the same root cause.
- Do not renumber findings after one is resolved.
- Group issues only when they share one correction and one acceptance test.

Each finding must include:

- id
- severity: `P0`, `P1`, `P2`, or `P3`
- status: `open`, `resolved`, `blocked`, or `accepted-external`
- affected paths
- evidence
- expected behavior
- correction scope
- acceptance criteria
- deferral eligibility: `eligible` or `not-eligible`

No finding is deferrable if it concerns authority boundaries, implementation
conformance, post-implementation drift, required validator failure, workflow
syntax, proposal-path backreferences in approved `.github/**` targets, stale
PR-first naming, or GitHub projection authority claims.

## Evidence Requirements

For every command or deterministic check, record:

- exact command
- exit code
- relevant output summary
- affected paths
- retained evidence location
- whether the evidence is packet-local lifecycle evidence or retained Octon
  evidence

Retained evidence belongs under existing Octon evidence roots such as:

- `.octon/state/evidence/validation/**`
- `.octon/state/evidence/runs/skills/**`
- `.octon/state/evidence/runs/workflows/**`

Do not store retained evidence in `generated/**`. Proposal registry
projections, GitHub surfaces, CI state, chat context, tool availability, and
model memory are not Octon authority.

## Required Commands

Run these checks from the repository root:

```text
yq -e . .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy/proposal.yml
yq -e . .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy/policy-proposal.yml
rg -n "T[O]DO|T[B]D|F[I]XME|\\{\\{|\\[[D]escribe" .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh
ruby -e 'require "yaml"; Dir[".github/workflows/*.yml"].sort.each { |f| YAML.load_file(f); puts "ok #{f}" }'
git diff --check
```

For the `rg` placeholder scan, exit code `1` with no matches is a clean result.
Exit code `0` is clean only if every match is a documented false positive and
does not indicate a scaffold placeholder or unresolved implementation marker.

## Deterministic Checks

In addition to command output, verify these conditions directly:

- Every path in `promotion_targets` exists.
- Durable promoted targets do not cite this active proposal packet as runtime,
  policy, support, closure, generated, retained evidence, state/control,
  publication, host-projection, skill, or model authority.
- Approved `.github/**` targets contain no stale `PR-first`, `main-pr-first`,
  `required-pr-`, `Work Package`, or `Package Authority` naming.
- Direct-main and branch-no-pr route validation do not require PR metadata.
- GitHub labels, comments, checks, workflow outputs, and PR bodies remain
  projection evidence only and do not mint Change authority.
- PR review, stale-draft, clean-state, auto-merge, AI review, Codex review,
  and PR quality workflows remain branch-pr scoped.
- Generated effective outputs were not hand-edited by this implementation.
- Proposal registry projection remains synchronized with the current manifest.
- Retained validation evidence is kept under evidence roots, not generated
  output roots.
- `proposal.yml#status` remains `accepted` unless a separate
  `promote-proposal` route runs.

## Correction Scope

Allowed corrections are limited to the smallest change that resolves a stable
finding:

- packet support receipts, artifact catalog, validation notes, and source map;
- approved `.github/**` promotion targets named in `proposal.yml`;
- generated proposal registry refresh when validator output requires it;
- retained validation evidence under canonical evidence roots.

Do not edit durable Change-first authority contracts, support-target
admissions, governance exclusions, run-contract schemas, connector posture, or
generated effective outputs from this verification route.
