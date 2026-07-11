# Target Architecture

## Boundary

Pilot automation may use disposable repositories and an approved separate public checkout. Any live GitHub setup or publication action requires the parent external-effects gate and maintainer approval.

## Proposed Components

- Disposable public-style, private, and offline pilot fixtures.
- Tier 1 and preview Tier 2 test matrix.
- Deterministic fault-injection points for every update transaction boundary.
- Project-owned before/after hash proof.
- Public candidate, asset, attestation, and setting verification.
- Aggregate first-release readiness receipt with blocker ownership.

## File-Level Work Areas

- `.octon/framework/assurance/runtime/_ops/scripts/validate-public-distribution-release-readiness.sh` — new deterministic release-readiness validator that checks the aggregate receipt, blocker-group status, and candidate evidence.
- `.octon/framework/assurance/runtime/_ops/tests/test-public-distribution-release-readiness.sh` — new test harness exercising the readiness validator's positive, negative, and boundary fixtures.
- `.octon/framework/assurance/runtime/_ops/fixtures/public-distribution-release-readiness/` — new leaf fixture directory holding disposable public-style, private, and offline pilot fixtures plus fault-injection and stale-evidence cases.
- `.octon/framework/engine/runtime/release-targets.yml` — existing shared runtime target catalog; this packet adds tier metadata additively (see below) and changes nothing else in the file.
- `.octon/framework/orchestration/runtime/_ops/scripts/run-public-distribution-pilots.sh` — new pilot orchestration entry point that provisions disposable projects and runs the lifecycle and fault matrix.
- `.octon/state/evidence/validation/proposals/public-distribution-pilot-release-readiness/` — child-owned evidence root for retained validation receipts.

## Release Target Tier Metadata (Existing Shared File)

`.octon/framework/engine/runtime/release-targets.yml` already exists and is
shared: it currently declares five targets (`linux-x64`, `linux-arm64`,
`windows-x64`, `macos-x64`, `macos-arm64`), all with `shippable_release: true`
and no tier field. This packet adds a `tier` field to each existing target
entry as strictly additive metadata; no existing key, value, target, or
ordering changes, so current consumers that read only the existing keys are
unaffected. The compatibility check re-runs the file's current consumers —
`.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-target-parity.sh`
(with `_ops/tests/test-validate-runtime-target-parity.sh`),
`.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`,
and the `.github/workflows/runtime-binaries.yml` matrix derivation — against
the amended file before the change is accepted.

Per adopted decision PD-012 (three Tier 1 targets block release; two Tier 2
targets are preview), the five existing targets map explicitly as:

- `linux-x64` — Tier 1 (blocking)
- `macos-arm64` — Tier 1 (blocking)
- `windows-x64` — Tier 1 (blocking)
- `linux-arm64` — Tier 2 (preview, non-blocking)
- `macos-x64` — Tier 2 (preview, non-blocking)

Revert route (satisfies the registry `rollback_posture: rollback-route`): the
tier-metadata change lands as a single revertible commit touching only
`release-targets.yml`; reverting that one commit restores the exact prior
file, after which the same consumer validation set above is re-run to confirm
consumers are unaffected by the revert.

## Ownership

- Child packets own their implementation and conformance evidence.
- This packet owns integrated pilot orchestration and aggregate readiness only.
- The maintainer approves use of any live public checkout and explicit platform demotion.
- Final publication remains outside readiness automation.

## Security And Publication Implications

- Fixtures contain no real secrets, private evidence, or workspace history.
- Private pilot logs remain local unless compactly classified.
- Public candidate validation rejects extra files and untrusted workflow privilege.
- Offline validation uses preverified artifacts and recorded digests.

## Automation Allocation

### Deterministic Automation

- Provision disposable projects and execute the full lifecycle matrix.
- Inject failures at each update journal transition.
- Compare project-owned hashes and export/public-tree manifests.
- Aggregate child evidence without substituting for child receipts.

### AI-Assisted Review

- Summarize failures and cluster repeated platform issues.
- Draft the maintainer readiness decision from deterministic receipts.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Approve any live public-repository pilot operation.
- Explicitly demote a failing Tier 1 target or block release.
- Review the final exact-commit readiness packet and separately authorize publication.

## Negative Controls

- No test fixture includes workspace Git history or sensitive local data.
- No Tier 1 failure is converted to success by retry-only logic.
- No aggregate receipt overwrites or replaces child-owned evidence.
- No readiness workflow publishes a release.
- No project-owned hash drift is tolerated.

## Deferred Work And Triggers

- Tier 2 release gating activates after reliable lifecycle results on those platforms.
- Large adopter compatibility matrix activates after real downstream diversity exists.
- Long-running soak testing activates after update frequency or user count makes it valuable.

## Residual Risks

- CI runners do not perfectly reproduce every local filesystem and security product.
- A small pilot set can miss downstream repository conventions.
- Platform services can change after a readiness run.

