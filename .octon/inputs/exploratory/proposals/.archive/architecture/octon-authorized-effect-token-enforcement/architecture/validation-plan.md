# Validation Plan

## 1. Structural validation

Required checks:

- `proposal.yml` and `architecture-proposal.yml` validate against proposal standards.
- `authorized-effect-token-v2.schema.json` validates fixtures for all effect classes.
- `authorized-effect-token-consumption-v1.schema.json` validates allow/reject/consume fixtures.
- `material-side-effect-inventory.yml` validates against inventory schema.
- every inventory entry has owner, effect kind, affected root, support posture, token requirement, negative bypass test, and evidence refs.
- no promotion target depends on this proposal path.
- no generated path is listed as authority.

## 2. Runtime / control validation

Required checks:

- direct material API call without token fails closed.
- direct material API call with hand-constructed token not backed by canonical token record fails closed.
- wrong-kind token fails closed.
- wrong-run or wrong-request token fails closed.
- expired token fails closed.
- revoked token fails closed.
- consumed single-use token fails closed on second use.
- out-of-scope token fails closed.
- token whose grant no longer resolves to current authority evidence fails closed.
- valid token in the right lifecycle state consumes successfully and writes receipt.

## 3. Run Journal validation

Required checks after canonical Run Journal promotion:

- token mint event/item exists for each minted token.
- token consumption request event/item exists before or at effect attempt.
- token consumed/rejected event/item exists.
- revocation and expiry events/items exist when applicable.
- replay can reconstruct token lifecycle without repeating live side effects.

Interim behavior if Run Journal is not yet promoted:

- use `runtime-event-v1` as a temporary token-event sink only if explicitly allowed by the sequencing decision;
- do not claim full closure until canonical Run Journal integration exists.

## 4. Evidence retention validation

Required checks:

- token records are under `state/control/execution/runs/<run-id>/effect-tokens/**`.
- consumption receipts are under `state/evidence/runs/<run-id>/receipts/effect-tokens/**`.
- execution receipts cite token and consumption refs for material effects.
- evidence-store completeness checks fail when material effects lack token proof.
- transport artifacts alone do not satisfy token proof.

## 5. Support-target validation

Required checks:

- live repo-shell and CI-control-plane support tuples include token enforcement proof requirements.
- stage-only/browser/API/frontier tuples remain non-live.
- generated support-target matrix cannot widen claims.
- proof bundles include at least one negative control per material family.

## 6. Assurance validators

Proposed validators:

- `validate-authorized-effect-token-enforcement.sh`
- `validate-authorization-boundary-coverage.sh`
- `validate-material-side-effect-inventory.sh`

Proposed tests:

- `test-authorized-effect-token-negative-bypass.sh`
- `test-authorized-effect-token-consumption.sh`
- `test-material-side-effect-coverage-fixtures.sh`

## 7. Closure validation

Closure requires:

- two consecutive clean validation passes;
- no uncovered material path families;
- no direct runtime reads from generated/effective raw paths;
- no runtime/policy dependency on proposal paths;
- retained closure evidence;
- operator-readable disclosure that explains token enforcement coverage and any residual stage-only paths.
