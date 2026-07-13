# Validation Plan

All implementation validation is future work. Draft structural checks prove
packet form only and cannot satisfy FD-021, UE-012, or encode and prove the
accepted ROD-004 baseline.

## Layer 0 — Lifecycle, Configuration, and Ownership

- Run proposal-standard, architecture, implementation-readiness, and review
  gates against one stable packet digest.
- Require exact RP-07/RP-11 dependency receipts.
- Validate the accepted ROD-004 schema, nonsecret configuration, governed
  update identity, and digest.
- Compare all 53 promotion targets and shared publisher/resolver symbols against
  the parent program ownership matrix.

Required result: accepted lifecycle gates, encoded accepted ROD-004 configuration, and no RP-07,
RP-11, RP-13, authority, or runtime-store ownership overlap.

## Layer 1 — Contract and Template Matrix

Validate every signed-envelope, pack, compatibility, desired config,
availability, active, quarantine, catalog, artifact-map, generation-lock,
import/compatibility/transition receipt, publication handle, policy, and
template artifact. Run unknown-field, missing-field, wrong-type, wrong-version,
conditional private-origin, and mirror/template drift negatives.

Required result: strict current schemas agree and unsigned/unpinned private
origin cannot validate.

## Layer 2 — Canonical Signature and Source Verification

Create one valid operator-approved private Git/release fixture and test:

- identical canonical envelope bytes across clean processes;
- unsigned, unknown key, wrong key, forged signature, changed signed metadata,
  changed manifest/payload/dependency, revoked/expired key, revoked release,
  disallowed source, mutable tag/ref, source-ref substitution, duplicate
  pack/version identity, and downgrade/replay;
- trust-policy/key rotation between fetch, verify, availability commit, desired
  selection, publication, and Harness compile; and
- signature/profile algorithm/version denial outside ROD-004.

Required result: only the exact currently trusted immutable release verifies;
every other case rejects/quarantines with authentic evidence.

## Layer 3 — Safe Materialization and Resource Bounds

Exercise traversal, absolute path, symlink/hardlink escape, case collision,
duplicate archive entry, device node, socket/FIFO, unsupported metadata,
overlong path, excessive depth/file count/bytes/compression ratio, interrupted
download, truncated content, and staging replacement attacks.

Required result: no sentinel outside staging changes; failed content never
enters availability; partial staging is discardable; retained content exactly
matches the verified payload digest.

## Layer 4 — Import Non-Authority and Writer Separation

Record digests of desired config, capability/authority sources, active state,
generated family, routes, Harness inputs, mission/run state, and execution
evidence. Run valid import and every rejected import, then attempt to inject an
availability row/import receipt/raw path as selection, grant, generated state,
or authority.

Required result: only retained raw availability/quarantine/import evidence may
change; selection, grants, active/generated state, route, Harness, and
execution remain unchanged. Import writer call paths cannot reach publisher or
authority writers.

## Layer 5 — Pin, Publication, Resolver, and Harness Binding

- Test exact and floating pins, wrong source/version/payload, unavailable pin,
  independently signed dependencies, missing/revoked/substituted dependency,
  cycles, compatibility drift, and requested-capability expansion.
- Compare desired pin, availability, active/quarantine, generated catalog,
  artifact map, generation lock, publication/transition receipts, runtime
  resolver, and RP-11 Harness identities.
- Mutate each source/envelope/trust/payload/dependency/receipt field and attempt
  route, prompt resolution, Harness compile, and launch.

Required result: one coherent exact generation publishes and binds; every
mismatch denies; no alternative version or broader capability auto-selects.

## Layer 6 — Revocation and Retained-Generation Restore

Revoke a signer, source, release, payload, and dependency independently at each
transition. Exercise a valid prior generation plus prior releases that are
missing, corrupt, signer-revoked, release-revoked, incompatible with current
API/contracts/host, capability-expanded, dependency-incomplete, or no longer
desired. Kill the publisher before/after each staged/actual/generated/receipt
write and rerun.

Required result: affected new use blocks/quarantines; valid prior content is
fully revalidated and published as a new atomic generation; invalid prior
content never restores; no valid prior yields extension-disabled core-safe
state; retries converge without split generation.

## Layer 7 — Export/Import and Compatibility Bridge

- Export exact private pack/dependency closure and reimport under the same and a
  different trust set.
- Alter/drop envelope, payload, dependency, or source identity after export.
- Run all bundled-first-party extension publication, route, prompt, local test,
  and compact-state regressions.

Required result: unchanged export round trips and revalidates; transfer itself
does not confer trust; mutations reject; bundled packs remain functional; no
unsigned external pack is grandfathered.

## Layer 8 — UX, Burden, and Architecture Negatives

Verify one explicit import command, concise available/selected/active/
quarantined status, revoke/repair/restore actions, preserved work, and clear
deny reasons. Scan commands, network destinations, processes, schedules,
stores, writers, generated backreferences, and normal concepts for marketplace,
auto-update, arbitrary fetch, general package-manager, or second-control-plane
behavior.

Required result: bounded solo operation with no routine prompt after an
intentional governed ROD-004 admission,
no hidden authority edge, and no unsupported surface.

## Planned Command Floor

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-extension-supply-chain
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-extension-supply-chain
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-extension-supply-chain
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-extension-supply-chain
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-active-state-compactness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-supply-chain.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-extension-supply-chain.sh
```

All other mapped existing extension/resolver/export tests are mandatory. New
hostile import and restore fixtures cannot be replaced by static schema checks.

## Retained Evidence

Retain exact implementation commit, accepted ROD-004 configuration and dependency digests, validator
and schema versions, canonical envelopes/signatures/nonsecret fingerprints,
source/manifest/payload/dependency identities, import/quarantine receipts,
writer-boundary digests, desired/actual/generated/Harness identity matrices,
revocation and restore traces, export round trips, operator outputs, and
architecture scan under the declared root. Private signing material and
unbounded payload/log copies are prohibited.

## Promotion Gate

PO-FD-021 and PG-12-SIGNED-CATALOG pass only when Layers 1 through 8 pass at
the same exact implementation/trust-policy identity. Accepted ROD-004
configuration and dependency gates precede activation. Support promotion remains claim-scoped and
separate.
