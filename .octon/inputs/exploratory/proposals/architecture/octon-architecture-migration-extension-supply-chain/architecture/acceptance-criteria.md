# Acceptance Criteria

## Entry Criteria

- RP-07 has exited with frozen signer/revocation, authentic receipt/checkpoint,
  bounded capacity, and retention interfaces.
- RP-11 has exited with a frozen exact extension-generation Harness input and
  deterministic launch binding.
- The accepted ROD-004 baseline is durably encoded: one operator-controlled
  signer family, immutable refs/digests, explicit capability grants, empty
  initial source allowlist, and deny-by-default unknown/invalid posture.
- Every current extension source, desired, actual, generated, publisher,
  resolver, export, and evidence writer/reader is inventoried.

## Target Criteria

| ID | Required condition | Proof |
| --- | --- | --- |
| RP12-AC-001 | Every private/external release has one strict canonical signed envelope binding immutable source, manifest/payload/dependency identity, capabilities, compatibility, signer, and signature. | Schema positives/negatives, canonical-byte fixture, and signature verification. |
| RP12-AC-002 | Unsigned, unknown/wrong-key, forged, tampered, revoked, mutable-ref, replay/downgrade, or dependency-substituted imports reject or quarantine. | Complete hostile signer/source/content matrix. |
| RP12-AC-003 | Archive traversal, absolute path, symlink/hardlink escape, duplicate/case-colliding entries, device nodes, and byte/file/depth abuse reject before normalized availability. | Hostile archive extraction fixtures and sentinel checks. |
| RP12-AC-004 | Import changes only retained raw availability/control evidence; desired selection, grants, active/generated state, routes, Harness, and execution remain byte-identical. | Before/after digests and attempted import-to-execution bypass tests. |
| RP12-AC-005 | Desired, raw retained, actual availability, actual active/quarantine, generated, and evidence layers each have one declared writer and no reverse authority edge. | Writer/call-path census and mutation-denial tests. |
| RP12-AC-006 | Enabled private packs use exact source/version/payload pins and complete independently signed dependency closure; floating/unapproved alternatives never auto-select. | Pin/dependency solver matrix and generated catalog inspection. |
| RP12-AC-007 | Compatibility or requested-capability mismatch blocks availability/publication as specified by ROD-004 and cannot create a grant. | Compatibility/capability negative matrix and authority before/after comparison. |
| RP12-AC-008 | Active state, generated catalog/artifact map/generation lock, runtime resolver, and RP-11 Harness bind the same exact generation and source/envelope/payload/receipt digests. | End-to-end identity comparison and stale-field mutation matrix. |
| RP12-AC-009 | Signer/source/release/payload revocation invalidates availability, quarantines affected closure, blocks new resolution/compile/launch, and produces authentic evidence. | Revocation propagation and race fixtures. |
| RP12-AC-010 | A retained prior generation restores only after current source/signer/revocation/content/dependency/compatibility/capability/pin checks and publishes a new atomic generation/receipt. | Valid restore, revoked prior, corrupt prior, incompatible prior, broader-capability prior, and interruption fixtures. |
| RP12-AC-011 | When no prior release passes, the extension disables without breaking core Octon or falling back unsigned/stale. | No-valid-generation recovery and core smoke tests. |
| RP12-AC-012 | Pack-bundle export preserves exact signed envelope/payload/dependency identities and reimport still verifies; transfer alone remains trust-agnostic. | Export/import round trip and changed-envelope/payload negatives. |
| RP12-AC-013 | The accepted ROD-004 configuration is exact, current, nonsecret, and its digest is bound into availability/publication/restore evidence; unknown policy denies. | Configuration/schema validation and policy-drift invalidation. |
| RP12-AC-014 | Operator can import, inspect available/selected/active status, quarantine/revoke, and restore with concise commands and no marketplace/control-plane administration. | CLI golden outputs, timing/burden observation, and surface census. |
| RP12-AC-015 | Existing bundled-first-party packs remain functional, while no unsigned private/external release is grandfathered. | Bundled regression suite and private-origin conditional-schema negatives. |
| RP12-AC-016 | No public marketplace, discovery/search, auto-update, arbitrary-source fetch, general package manager, second publisher, daemon, scheduler, store, or authority surface is introduced. | Architecture/filesystem/process/network/symbol scan. |

## Proof Obligation

Passing RP12-AC-001 through RP12-AC-016 satisfies PO-FD-021 and
PG-12-SIGNED-CATALOG. UE-012 closes only when the adversarial results and exact
implementation identities are retained. Import, catalog, signature, or restore
evidence cannot itself promote a support claim.

## Exit Criteria

- the accepted ROD-004 configuration and RP-07/RP-11 dependency receipts are exact and current;
- all schema, hostile import, non-authority, pin, revocation, generation,
  export, restore, recovery, and regression tests pass at one implementation;
- evidence is retained at the declared proposal-validation root;
- architecture, implementation conformance, and post-implementation
  drift/churn reviews pass;
- generated projections are current through their owner; and
- no durable target depends on this proposal path.

These are future gates. None is claimed as executed by this draft.
