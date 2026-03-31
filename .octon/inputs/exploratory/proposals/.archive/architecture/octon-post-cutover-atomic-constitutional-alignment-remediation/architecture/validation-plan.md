# Validation Plan

## Validation posture

Use a mix of deterministic checks and explicit human review. Deterministic checks should catch structural drift; human review should confirm that narrowed claim language remains accurate and not misleading.

## Deterministic checks

### 1. Constitutional family live-model check

**Purpose:** prevent stale phase receipts from masquerading as the live model.

**Check:**

- parse `/.octon/framework/constitution/charter.yml#live_model.profile_selection_receipt_ref`
- parse every active `/.octon/framework/constitution/contracts/*/family.yml`
- fail if an active family's live selector differs without explicit lineage semantics

**Suggested script:**

- `validate-constitutional-family-live-model.sh`

### 2. Bootstrap authority-surface check

**Purpose:** prevent orientation docs from widening authority into raw inputs.

**Check:**

- inspect `/.octon/instance/bootstrap/START.md`
- optionally inspect other orientation docs under `.octon/**`
- fail if an authored-authority section includes any raw `inputs/**` path

**Suggested script:**

- `validate-bootstrap-authority-surfaces.sh`

### 3. Support-target live-claim check

**Purpose:** prevent published live support envelopes from outrunning retained proof.

**Check:**

- inspect every `support_status: supported`
- inspect every release HarnessCard claim summary
- verify the retained proof bundle exists for the exact claimed envelope
- fail when a supported envelope lacks proof or when the card text implies broader support

**Suggested script:**

- `validate-support-target-live-claims.sh`

### 4. Disclosure live-root check

**Purpose:** keep historical mirrors from becoming canonical live roots again.

**Check:**

- inspect disclosure family semantics
- fail if canonical live HarnessCard roots point back to lab-local historical mirrors

**Suggested script:**

- `validate-disclosure-live-roots.sh`

### 5. Subordinate owner identifier check

**Purpose:** remove placeholder owners from binding subordinate governance surfaces.

**Check:**

- scan `/.octon/framework/cognition/governance/**`
- fail on `@you` or `@teammate`

**Suggested script:**

- `validate-subordinate-owner-identifiers.sh`

## Workflow integration

### Developer path

Keep the normal operator path:

```text
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

and extend it to include the new validators.

### Publication path

Wire the same validators into:

```text
.octon/framework/assurance/runtime/_ops/scripts/assurance-gate.sh
```

so a publishable release cannot pass while these drift classes remain open.

## Retained receipts

Store validation receipts under an existing retained validation/publication surface, for example a dedicated constitutional-alignment family beneath:

- `/.octon/state/evidence/validation/publication/**`

The packet does not require a specific filename as long as receipts are retained, reviewable, and linked from the release candidate.

## Human review gates

A human reviewer must still verify:

1. the claim-language narrowing is semantically accurate
2. any demotion of support envelopes matches the real absence of retained proof
3. any decision to keep a broader envelope as live is accompanied by proof in the same change
4. repo-local follow-on items are explicitly tracked, not forgotten

## Success condition

Validation succeeds when deterministic checks pass, review confirms truthful narrowing, and the retained release disclosure packet matches the authored live claim exactly.
