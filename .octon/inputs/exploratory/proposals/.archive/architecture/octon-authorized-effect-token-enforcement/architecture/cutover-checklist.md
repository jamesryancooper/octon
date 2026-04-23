# Cutover Checklist

## Pre-cutover

- [ ] Confirm canonical append-only Run Journal is promoted or record blocker.
- [ ] Confirm proposal manifests validate.
- [ ] Confirm no mixed `.octon/**` and non-`.octon/**` promotion targets.
- [ ] Freeze material side-effect path inventory.
- [ ] Identify all material API owners.
- [ ] Identify current raw-path or ambient-grant material paths.
- [ ] Confirm support-target live universe remains unchanged.

## Contract cutover

- [ ] Add promoted token schema.
- [ ] Add promoted consumption schema.
- [ ] Update token doctrine doc.
- [ ] Update boundary coverage contract.
- [ ] Update material side-effect inventory schema.
- [ ] Add complete material side-effect inventory.
- [ ] Update execution request/grant/receipt schemas.
- [ ] Update runtime event or Run Journal item types.
- [ ] Update run lifecycle and evidence-store requirements.

## Runtime cutover

- [ ] Harden `authorized_effects` token metadata and verifier path.
- [ ] Add `VerifiedEffect<T>` or equivalent internal guard.
- [ ] Update authority engine minting.
- [ ] Emit token control records.
- [ ] Emit token evidence records.
- [ ] Append token journal events.
- [ ] Harden material API signatures.
- [ ] Remove or quarantine material bypass functions.

## Governance and support cutover

- [ ] Update repo-shell execution class token requirements.
- [ ] Update support-target proof requirements.
- [ ] Confirm generated support matrix remains derived-only.
- [ ] Confirm stage-only surfaces remain stage-only.

## Validation cutover

- [ ] Add validators.
- [ ] Add negative bypass tests.
- [ ] Add token consumption tests.
- [ ] Add inventory fixture tests.
- [ ] Retain evidence for all tests.
- [ ] Run two consecutive clean validation passes.

## Closeout

- [ ] Produce closure certification.
- [ ] Produce decision record or ADR if promotion changes durable contracts.
- [ ] Archive proposal after promoted outputs stand alone.
