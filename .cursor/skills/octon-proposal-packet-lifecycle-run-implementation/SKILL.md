---
name: octon-proposal-packet-lifecycle-run-implementation
description: Run the proposal packet implementation bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-05"
  updated: "2026-05-05"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/framework/*) Write(/.octon/instance/*) Write(/.octon/state/*) Write(/.octon/generated/*)
---

# Proposal Packet Lifecycle Run Implementation

Run implementation for one accepted proposal packet by executing the packet's
`support/executable-implementation-prompt.md` against durable repository
surfaces.

This bundle is the lifecycle bridge between implementation prompt generation
and post-implementation verification. It executes promotion work, but it does
not make proposal-local material authoritative.

## Preconditions

Resolve exactly one proposal packet path before taking implementation action.
Refuse implementation when:

- `proposal.yml` or the subtype manifest is missing or invalid;
- `status` is not `accepted`;
- `support/proposal-review.md` is missing, stale, not accepted, has open
  blocking findings, or does not authorize implementation;
- `validate-proposal-review-gate.sh --package <proposal_path>
  --require-implementation-authorization` fails;
- `support/implementation-grade-completeness-review.md` is missing, failing,
  has `unresolved_questions_count` other than `0`, or has
  `clarification_required` other than `no`;
- `support/executable-implementation-prompt.md` is missing;
- implementation-readiness validation fails;
- the implementation prompt asks for work outside declared promotion targets
  without an explicit packet revision or linked proposal route;
- the packet would treat `inputs/**`, generated outputs, chat, host state, or
  proposal-local analysis as runtime, policy, support, or closure authority.

If the proposal is still `in-review`, do not infer approval from packet
existence or operator intent. Route to `review-proposal-packet` or
`revise-proposal-packet` until a fresh accepted review receipt authorizes
implementation.

## Required Execution Flow

1. Read `proposal.yml`, the subtype manifest, `navigation/source-of-truth-map.md`,
   `navigation/artifact-catalog.md`, `architecture/implementation-plan.md`
   when present, `architecture/acceptance-criteria.md` when present,
   `support/implementation-grade-completeness-review.md`, and
   `support/executable-implementation-prompt.md`.
2. Run or confirm the structural, subtype, implementation-readiness, and strict
   proposal-review gate validators required by the packet.
3. Execute only the durable promotion work described by the executable
   implementation prompt and declared promotion targets.
4. Preserve Octon class boundaries:
   - durable doctrine, schemas, workflows, validators, and docs belong under
     `framework/**` when the packet declares Octon-internal promotion;
   - instance enablement belongs under `instance/**`;
   - mutable control and retained evidence remain under `state/**`;
   - generated outputs are refreshed only through the appropriate publication
     or registry mechanism and remain derived-only;
   - proposal packet paths may remain only as provenance, not as runtime
     dependencies.
5. Update post-implementation packet support material:
   - `support/implementation-run.md`;
   - `support/implementation-conformance-review.md`;
   - `support/post-implementation-drift-churn-review.md`;
   - `support/validation.md`;
   - `support/SHA256SUMS.txt`, when the packet maintains checksums.
6. Leave `proposal.yml#status` as `accepted`; this bundle writes the
   implementation evidence that enables the separate `promote-proposal`
   lifecycle route to rewrite status to `implemented`. Report `blocked` or
   `deferred` when implementation cannot be completed cleanly.
7. Run the post-implementation conformance and drift/churn validators before
   any implemented, closeout, or archive-ready claim.

## Required Validators

Run the packet's declared validators plus, at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <proposal_path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <proposal_path> --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <proposal_path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <proposal_path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <proposal_path>
```

For architecture packets, also run the architecture proposal validator.

## Closeout Boundary

This command may report implementation complete only when the durable
repository state, conformance receipt, drift/churn receipt, and validators all
support that claim. It must not promote or archive the packet. After successful
implementation, route to the `promote-proposal` lifecycle route, then to:

```text
octon-proposal-packet-lifecycle-generate-verification-prompt
```

If implementation is blocked, route to:

```text
octon-proposal-packet-lifecycle-generate-correction-prompt
```

or to packet revision when the blocker changes promotion scope, authority
ownership, product semantics, or irreversible churn.
