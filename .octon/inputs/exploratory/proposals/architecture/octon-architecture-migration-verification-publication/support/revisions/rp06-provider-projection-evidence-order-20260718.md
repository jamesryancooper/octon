revision_id: octon-architecture-migration-verification-publication-revision-20260718T161222Z
source_review_id: octon-architecture-migration-verification-publication-review-20260718T160333Z
revision_timestamp: 2026-07-18T16:12:22Z
revision_route: revise-packet
status: in-review
change_profile: atomic
release_state: pre-1.0
post_revision_digest: sha256:c98b86b59a105a6995e20284418e4144a38b36689e05fc3f001763e6d4654114
remaining_blocking_count: 0
parent_scope_changed: false
provider_scope_changed: false
provider_or_credential_mutated: false
workflow_projection_mutated: false
implementation_performed: false

addressed_finding_ids:

- `RP06-ED004-VERIFIER-MECHANISM-001`
- `RP06-PROJECTION-OWNERSHIP-002`
- `RP06-PR-MERGE-MECHANISM-003`
- `RP06-IMPLEMENTATION-EVIDENCE-CYCLE-004`

# RP-06 Correction Receipt

## Verifier And Provider Mechanism

The design now selects a base-owned two-job workflow: a fresh secretless macOS
RP-02 compute job treats `S` as hostile data and emits one bounded canonical
JSON result; a separate fresh emitter never checks out or executes `S`, validates
the handoff, and uses a one-operation token for a checks-only GitHub App.
Rulesets accept the exact check only from that App/installation. A distinct
publisher App has PR-write but no checks-write or verifier-secret access.

Protected PR uses `enqueuePullRequest(expectedHeadOid=S, jump=false)` into an
ALLGREEN, squash, single-entry, no-bypass merge queue whose `merge_group` SHA
must pass the expected-App verdict and substantive checks. Direct merge and
check-then-merge are unreachable. Missing provider capability/configuration
keeps automated merge disabled and preserves work.

## Projection Ownership

The exhaustive census freezes all 42 current workflows and their dispositions.
The selected `.octon` source contains a manifest, two templates, token-gated
publisher, validator, and receipt schema. It may publish only the two declared
workflow outputs and must bind source/output digests and publisher identity.
No `.github` file was changed by this revision.

## Evidence Order

Accepted review may authorize creation of only this design. Dependency
implementation verification and exact provider/App/environment/ruleset/queue/
runner/scratch preflight gate source entry. UE-006/015 and every dynamic attack,
race, provider, projection, conformance, and drift result gate completion,
publication, enablement, support, or promotion. RP-07 supplies the live role
key downstream; RP-06 verifies its interface with fixtures without a DAG cycle.

## Scope And Next Gate

All 19 promotion targets remain unchanged and exactly equal the parent entry;
no parent revision is required. A fresh independent proposal/architecture
re-review at the corrected digest is next. No implementation or provider effect
occurred.
