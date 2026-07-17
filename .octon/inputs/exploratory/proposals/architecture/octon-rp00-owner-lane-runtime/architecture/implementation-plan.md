# Implementation Plan

## Preconditions

- Work from an isolated branch rooted at exact current `origin/main`.
- Preserve the dirty primary worktree and frozen RP-00 candidate.
- Require the revision receipt, fresh passing architecture review, accepted
  proposal review, and implementation authorization at one packet digest.
- Perform no credential or provider effect during implementation or review.

## Workstream 1 — Correct contracts and digest graph

1. Add strict `owner-lane-credential-capture-metadata-v1` and
   `owner-lane-operation-plan-v1` schemas and register them.
2. Remove manifest and operation digests from pre-issuance authorization; bind
   the independent plan digest and the complete intended credential tuple.
3. Extend issuance, lifecycle, admission, manifest, attestation,
   completed-prefix, construction, and retirement schemas for staged lineage.
4. Require unknown-field rejection, RFC 8785-compatible values, exact digest
   domains, no upstream backreference, and no observation asserted before its
   stage.

## Workstream 2 — Implement staged runtime

1. Change `owner-lane execute` inputs to authorization, capture metadata,
   operation plan, evidence root, and credential FD.
2. Validate pre-capture inputs and tools, then read/close one credential FD.
3. Derive and durably write issuance and lifecycle artifacts before network
   access.
4. Execute and journal admission reads; generate the admission receipt from
   actual responses and trusted capture facts.
5. Generate the final manifest and realized attestation after admission.
6. Execute the prefix, reconcile exactly one PR, and generate the
   completed-prefix receipt.
7. Resolve strict typed suffix templates, emit construction receipts, execute
   the suffix, and retain retirement evidence.
8. Preserve current fixed-origin allowlisting, canonical tool verification,
   stdin/FIFO secret transport, no-resend journal, and secret census.

## Workstream 3 — Recovery and denial behavior

1. Make each artifact create-only or exact-byte idempotent; conflicting bytes
   deny without overwrite.
2. Permit same-credential resume only within the original one-attempt and
   replacement locks and existing request budget.
3. On admission or construction failure, skip all remaining repository
   mutations and execute only the inherited terminalization suffix.
4. Preserve unknown send outcomes and permanently deny request-digest replay.
5. Require exact create/reconcile PR agreement and refuse zero, multiple, or
   substituted PR identities.

## Workstream 4 — Contract, support, and proof refresh

1. Update the owner-lane execution contract and GitHub autonomy runbook with
   stage inputs, outputs, evidence timing, and trusted-capture limitations.
2. Refresh the existing material inventory and authorization coverage only if
   entrypoint identity changes.
3. Run a full staged hermetic protocol with provider-assigned PR identity,
   typed suffix construction, interruption, mismatch, replay, and leak cases.
4. Refresh the existing exact-operation admission, dossier, and proof bundle
   only after current proof passes.

## Validation and completion

Run schema syntax/registry checks, formatting, authorized-effects and authority
engine tests, kernel owner-lane and lifecycle tests, shell hermetic tests,
material/authorization coverage, support proof/live claim, dossier parity/depth,
proposal gates, conformance, drift, rollback, and `git diff --check`.

After implementation, refresh implementation-run, conformance, and drift
receipts with exact commit/tree and current evidence. Stop before credential
issuance or provider mutation. Landing this correction and rebasing/refreezing
RP-00 require their own governed Change steps.
