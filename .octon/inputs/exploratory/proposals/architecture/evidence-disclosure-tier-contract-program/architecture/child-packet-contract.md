# Child Packet Contract

_Status: In-review parent-program contract_

Each child packet remains a normal manifest-governed proposal packet. The
parent coordinates dependency order and aggregate evidence only.

## Authority Boundaries

- Parent coordinates only.
- Child manifests remain child-owned.
- Child subtype manifests remain child-owned.
- Child acceptance criteria remain child-owned.
- Child validation verdicts remain child-owned.
- Child promotion targets remain child-owned.
- Child archive metadata remains child-owned.
- Parent evidence may summarize but never satisfy child receipts.
- Proposal-local files may inform work but never become runtime, policy,
  evidence, support, or closeout authority.

## Common Child Requirements

Each required child must:

1. Declare one `change_profile`.
2. Declare explicit promotion targets outside the proposal workspace.
3. Preserve `inputs/**` as non-authoritative lineage.
4. Preserve `generated/**` as derived-only.
5. Preserve current retained evidence roots unless the child explicitly
   proposes, validates, and receives accepted review for a replacement.
6. Include implementation-grade completeness review before implementation.
7. Include implementation conformance and drift/churn receipts after promotion.
8. Include validators or negative-control tests for overclaim prevention.
9. State whether local-only evidence is required, optional, or forbidden for
   hosted/shared closeout.

## Child-Specific Gates

### `evidence-disclosure-tier-contracts`

Must define exactly four tiers: private raw evidence, publishable claim
evidence, operator/release disclosure, and generated read models.

### `local-evidence-store-boundary`

Must prove `.octon/state/evidence/local/**` is local-only and ignored by
default through `.octon/state/evidence/.gitignore`, without violating active
proposal target-family rules.

### `publishable-evidence-receipts`

Must define claim-sufficient receipt fields, redaction declarations,
limitations, validation summary, local evidence references, and rollback or
discard posture.

### `disclosure-and-read-model-alignment`

Must keep disclosure subordinate to publishable evidence and generated read
models subordinate to canonical evidence and authority.

### `evidence-tier-validator-gates`

Must enforce path rules, tier metadata, publishable evidence concision, local
tracking denial, and hosted closeout independence from local-only artifacts.

### `closeout-repo-hygiene-evidence-flow`

Must update closeout and repo-hygiene behavior so raw logs remain local and
published receipts are concise, complete, and publication-safe.

### `evidence-residue-migration-closeout`

Must run last. It must inventory current residue, preserve rollback posture,
and avoid deleting, moving, or replacing evidence without child-owned safety
evidence.
