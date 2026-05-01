# Current-State Gap Map

- proposal: `octon-proposal-packet-lifecycle-automation`

## Current Coverage

Octon already has strong proposal infrastructure:

- manifest-governed proposal workspace rules,
- base and subtype proposal standards,
- canonical proposal templates,
- create, validate, promote, and archive workflows,
- proposal validators and deterministic registry generation,
- concept-integration prompt bundles for source-to-packet, packet refresh, and packet implementation,
- helper extension packs for impact mapping, drift triage, and hygiene packet drafting.

## Gaps

| Gap | Current state | Required change |
| --- | --- | --- |
| Manual prompt lifecycle | Proposal creation, explanation, implementation prompt generation, verification prompt generation, correction prompt generation, and closeout prompt generation are still user-authored prompts. | Publish reusable lifecycle prompt bundles under one extension pack. |
| End-to-end routing | Existing routes cover parts of source-to-packet and packet-to-implementation, but not the whole manual lifecycle. | Add a dispatcher and route contract for the full lifecycle. |
| Source context preservation | Manual prompts ask for audits/evaluations in `resources/**`, but placement is not enforced by a reusable automation contract. | Add shared source-context and packet artifact contracts. |
| Generated prompt placement | Implementation, verification, correction, and closeout prompts are manually named and placed. | Standardize support artifacts under packet `support/**`. |
| Verification correction loop | Manual process asks for follow-up verification and correction, but no reusable route captures stable finding IDs and repeated convergence. | Add verification-and-correction loop bundle. |
| Closeout scope | Manual closeout spans proposal archival, housekeeping, staging, commit, PR, CI, review conversations, merge, branch cleanup, and sync. | Add closeout generation and closeout execution bundles with explicit GitHub/CI boundaries. |
| Multi-packet programs | Octon supports related proposals, but there is no reusable parent program pattern for sequencing child proposal packets without nesting them. | Add Proposal Program pattern, program prompt routes, child index contract, sequence contract, and validation fixtures. |
| Validation fixtures | Existing extension packs have local validation, but no full proposal lifecycle scenario matrix. | Add pack-local validation scenarios covering all manual lifecycle prompt classes. |

## Whole-Universe Scope Decision

This proposal intentionally covers the full lifecycle rather than a narrow MVP.
The first implementation may sequence work internally, but merge readiness
requires all lifecycle route families and validation fixtures to exist and be
published coherently.
