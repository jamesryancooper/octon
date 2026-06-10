# Executable Implementation Prompt

implementation_prompt_id: delegated-governance-inventory-and-vocabulary-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.

Durable authority may land only in the declared promotion targets. Proposal
files, generated proposal registry entries, generated projections, read models,
chat history, host state, tool availability, and model output are implementation
inputs or derived context only; they are not runtime, policy, permission,
support, or closeout authority.

## Prompt Generation Gate Receipt

The strict review gate passed before this prompt was written:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one complete inventory and vocabulary baseline for
  Octon-wide delegated governance migration domains
- transitional exception: not authorized

## Mandatory Preflight

Before durable edits, re-read the packet manifest, architecture proposal,
source-of-truth map, target architecture, implementation plan, acceptance
criteria, validation plan, risk register, implementation-grade review, and
proposal review. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
```

Refuse implementation unless all preflight commands pass, `proposal.yml#status`
is `accepted`, the review verdict is `accepted`, implementation is authorized,
and the reviewed packet digest is fresh.

## In Scope

Durable edits may touch only:

- `.octon/framework/constitution/contracts/authority/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/orchestration/governance/`
- `.octon/framework/capabilities/governance/policy/`

Expected durable work:

1. Search authority-engine, mission/runtime, connector, run-health, read-model,
   workflow, capability, validator, governance-doc, and lifecycle reference
   surfaces for approval/default-authority vocabulary.
2. Produce or update the smallest durable inventory surface in an existing
   approved home. Prefer strengthening an existing registry, spec, or policy
   file over creating a duplicate inventory.
3. Classify every discovered surface as exactly one of:
   `delegated-execution`, `typed-human-exception`, `deny-only`,
   `projection-only`, `generated-non-authority`, `grant-consumption`,
   `needs-more-evidence`, or `out-of-scope`.
4. Define the vocabulary baseline used by downstream child packets: delegated
   execution, new governance decision, typed human exception grant, proof-first
   posture, retained authorization proof, authority provenance, fail-closed
   evidence state, generated/read-model non-authority, and external irreversible
   effect.
5. Record why generic importance is not a sufficient human-only reason.

## Out Of Scope

Do not mutate runtime dispatch behavior, schema enforcement, connector
permissions, generated projections, or state/control truth in this packet.
Do not edit outside the four declared promotion targets. Do not change
`proposal.yml#status`; promotion remains a separate lifecycle route.

## Required Evidence And Receipts

Create retained evidence under:

```text
.octon/state/evidence/validation/proposals/delegated-governance-inventory-and-vocabulary/<timestamp>/
```

Retain:

- repository reconnaissance receipt with searches run and surfaces found;
- implementation inventory completeness receipt;
- vocabulary consistency receipt;
- validation command outputs;
- rollback posture note explaining how the inventory can be reverted without
  changing runtime behavior.

Update proposal-local support material after durable implementation:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run the packet validators and any new inventory/vocabulary checks added by the
implementation. At minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-inventory-and-vocabulary
```

## Rollback And Closeout Refusal

Rollback is file-level revert of the durable inventory/vocabulary changes plus
removal of any retained validation evidence created solely for the failed
attempt. Refuse closeout or archive if any discovered surface lacks a
classification, if generated/read-model outputs are treated as authority, if
downstream vocabulary remains ambiguous, if validation evidence is missing, or
if `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass.
