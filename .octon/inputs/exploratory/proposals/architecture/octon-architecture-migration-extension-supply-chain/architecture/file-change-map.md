# File Change Map

The manifest declares 53 exhaustive `.octon/**` promotion targets. Directory
and shared-file ownership is limited to the exact extension supply-chain
entries/functions described here.

| # | Promotion target | Planned RP-12 change | Ownership boundary |
| ---: | --- | --- | --- |
| 1 | `.octon/framework/engine/governance/extensions/README.md` | Document signed private import and retained desired/actual/generated split. | Governance explanation; no authority grant. |
| 2 | `.octon/framework/engine/governance/extensions/boundary-contract.md` | Define envelope, untrusted staging, retained signed release, and runtime raw-path prohibition. | Extension boundary only. |
| 3 | `.octon/framework/engine/governance/extensions/trust-and-compatibility.md` | Specify source/signer/revocation/pin/compatibility/capability and restore rules. | Consumes ROD-004/RP-07; does not select keys itself. |
| 4 | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md` | Explain signed-envelope placement and retained release roles. | Raw inputs remain non-authoritative. |
| 5 | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-pack.schema.json` | Require exact signed-envelope ref/digest for private/external origin and bind content identity. | Bundled conditional bridge retained. |
| 6 | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-signed-envelope.schema.json` | Add strict canonical signed release contract. | New RP-12 contract; no grants. |
| 7 | `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-compatibility-profile.schema.json` | Bind compatibility declaration identity to envelope/import admission. | Compatibility facts only. |
| 8 | `.octon/framework/cognition/_meta/architecture/instance/extensions/README.md` | Document desired source/signer/revocation/pin ownership. | Desired state only. |
| 9 | `.octon/framework/cognition/_meta/architecture/instance/extensions/schemas/instance-extensions.schema.json` | Add strict approved sources, nonsecret signer refs, revocations, and exact private pins. | Governed configuration values under the accepted ROD-004 baseline. |
| 10 | `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/README.md` | Clarify generated family signature/source binding and non-authority. | Publisher projection only. |
| 11 | `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-effective-catalog.schema.json` | Bind exact availability/envelope/payload/import/transition identities. | Generated projection, not availability or selection. |
| 12 | `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-generation-lock.schema.json` | Bind trust-policy, signed release/dependency closure, transition receipt, and restore posture. | Generated lock only. |
| 13 | `.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-artifact-map.schema.json` | Bind every published artifact to exact signed payload/generation. | Generated artifact lookup only. |
| 14 | `.octon/framework/cognition/_meta/architecture/state/control/schemas/extension-active-state.schema.json` | Add current envelope/payload/pin/transition and revocation observation refs. | Actual published truth. |
| 15 | `.octon/framework/cognition/_meta/architecture/state/control/schemas/extension-quarantine-state.schema.json` | Add signer/source/release/payload/dependency revocation and import failure identities. | Actual quarantine truth. |
| 16 | `.octon/framework/cognition/_meta/architecture/state/control/schemas/extension-availability-state.schema.json` | Add verified exact release availability/restorability contract. | Actual candidate state; cannot select. |
| 17 | `.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-compatibility-receipt.schema.json` | Bind compatibility result to exact envelope/payload/trust policy. | Evidence only. |
| 18 | `.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-import-receipt.schema.json` | Add signed-source/content/materialization/admission result contract. | Evidence only; import cannot authorize. |
| 19 | `.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas/extension-generation-transition-receipt.schema.json` | Add activation, revocation, disable, and revalidated restore transition contract. | Evidence only; publisher remains writer. |
| 20 | `.octon/framework/engine/runtime/spec/extension-publication-handle-v1.md` | Require exact signed generation and current actual/generated cross-check. | Runtime handle remains non-authoritative. |
| 21 | `.octon/instance/extensions.yml` | Encode the accepted ROD-004 baseline and later governed nonsecret source/signer/revocation updates and exact desired pins. | Governed desired state; no secret keys. |
| 22 | `.octon/instance/governance/contracts/extension-publication-policy.yml` | Require verified availability/current trust and revalidated restore through one publisher. | Existing publication policy only. |
| 23 | `.octon/framework/scaffolding/runtime/templates/octon/instance/extensions.yml` | Align default desired schema with safe deny posture and exact private fields. | Template; no live operator choice. |
| 24 | `.octon/framework/scaffolding/runtime/templates/octon/state/control/extensions/active.yml` | Align empty/current active state schema. | Template only. |
| 25 | `.octon/framework/scaffolding/runtime/templates/octon/state/control/extensions/quarantine.yml` | Align quarantine reason/source identity schema. | Template only. |
| 26 | `.octon/framework/scaffolding/runtime/templates/octon/state/control/extensions/available.yml` | Add empty verified-availability state template. | Template only; not desired state. |
| 27 | `.octon/framework/scaffolding/runtime/templates/octon/generated/effective/extensions/catalog.effective.yml` | Align empty generated catalog source/receipt bindings. | Template projection. |
| 28 | `.octon/framework/scaffolding/runtime/templates/octon/generated/effective/extensions/artifact-map.yml` | Align generated artifact provenance bindings. | Template projection. |
| 29 | `.octon/framework/scaffolding/runtime/templates/octon/generated/effective/extensions/generation.lock.yml` | Align empty generation trust/source/transition binding. | Template projection. |
| 30 | `.octon/framework/scaffolding/runtime/templates/octon/state/evidence/validation/compatibility/extensions/README.md` | Document import/compatibility receipt placement and secret exclusion. | Evidence template documentation. |
| 31 | `.octon/framework/scaffolding/runtime/templates/octon/state/evidence/validation/publication/extensions/README.md` | Document generation transition/restore receipt placement. | Evidence template documentation. |
| 32 | `.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh` | Add canonical envelope/tree hashing, safe path checks, trust/revocation, availability, and exact pin helpers. | Shared extension helpers only; no authority/publisher duplication. |
| 33 | `.octon/framework/orchestration/runtime/_ops/scripts/import-signed-extension-pack.sh` | Add bounded explicit verify-to-availability import transaction. | Import writer cannot reach desired/active/generated/authority. |
| 34 | `.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh` | Require verified exact pins/current trust, bind signed identities, and implement staged transition/restore. | Single existing publisher; no second control plane. |
| 35 | `.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh` | Verify current exact generation/lock/active state before route result. | Read-only generated consumer; no selection. |
| 36 | `.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh` | Verify current exact generation and signed payload bindings before prompt resolution. | Read-only generated consumer. |
| 37 | `.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh` | Preserve exact signed envelope/payload/dependency identities in trust-agnostic pack-bundle export. | Export does not confer trust or selection. |
| 38 | `.octon/framework/engine/runtime/crates/runtime_resolver/src/handles.rs` | Extend exact extension functions to verify availability/import/trust/transition refs against active/lock. | RP-11 retains generic handles; RP-12 owns extension-specific fields only. |
| 39 | `.octon/framework/engine/runtime/crates/runtime_resolver/src/lib.rs` | Carry verified signed extension generation identity into RP-11 input and deny stale/revoked generations. | No Harness compiler/authority changes. |
| 40 | `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh` | Validate private-origin envelope conditional and exact content identity. | Assurance only. |
| 41 | `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh` | Validate desired/availability/active/quarantine/generated/receipt identity coherence. | Assurance only. |
| 42 | `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-active-state-compactness.sh` | Keep availability/active state bounded and prevent raw payload/detail embedding. | Compactness/retention assurance. |
| 43 | `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-supply-chain.sh` | Add complete signer/source/content/non-authority/revocation/restore gate. | New assurance entry; no implementation authority. |
| 44 | `.octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh` | Require envelope/payload/dependency identity preservation for pack-bundle export. | Transfer remains trust-agnostic. |
| 45 | `.octon/framework/assurance/runtime/_ops/tests/test-validate-extension-pack-contract.sh` | Add signed/unsigned origin and envelope binding fixtures. | Test only. |
| 46 | `.octon/framework/assurance/runtime/_ops/tests/test-validate-extension-publication-state.sh` | Add exact pin, availability, transition, revocation, and restore fixtures. | Test only. |
| 47 | `.octon/framework/assurance/runtime/_ops/tests/test-extension-quarantine-hard-gate.sh` | Add signer/source/release/payload/dependency quarantine hard-gate cases. | Test only. |
| 48 | `.octon/framework/assurance/runtime/_ops/tests/test-extension-compatibility-cache.sh` | Bind cached compatibility to exact signed envelope/payload/trust-policy identity. | Test only. |
| 49 | `.octon/framework/assurance/runtime/_ops/tests/test-extension-supply-chain.sh` | Add hostile import, non-authority, revocation, and revalidated restore matrix. | New RP-12 proof fixture. |
| 50 | `.octon/framework/assurance/runtime/_ops/tests/test-resolve-extension-route.sh` | Deny stale/revoked/wrong-generation route resolution. | Test only. |
| 51 | `.octon/framework/assurance/runtime/_ops/tests/test-resolve-extension-prompt-bundle.sh` | Deny stale/revoked/wrong-payload prompt resolution. | Test only. |
| 52 | `.octon/framework/assurance/runtime/_ops/tests/test-validate-export-profile-contract.sh` | Prove exact signed round trip and mutation rejection. | Test only. |
| 53 | `.octon/state/evidence/validation/proposals/octon-architecture-migration-extension-supply-chain/` | Retain bounded ROD-004, import, negative, binding, revocation, restore, UX, and review evidence. | Evidence only; no private keys/unbounded payloads. |

## Affected Outputs, Not Promotion Targets

- `.octon/inputs/additive/.incoming/**` untrusted staging;
- normalized or retained extension payload instances under additive input and
  archive boundaries;
- `.octon/state/control/extensions/**` live actual-state instances;
- `.octon/generated/effective/extensions/**` live generated instances;
- per-import/compatibility/publication/transition receipts outside the retained
  proposal proof bundle;
- RP-11 per-run Harness manifests and compile receipts;
- `.octon/generated/proposals/registry.yml`.

These are written, rebuilt, retained, or observed only through their canonical
owners. They cannot substitute for authored contracts, desired state, or
authority.

## Shared-File Integration Rule

The trusted integration lane serializes publisher, resolver, assurance, policy,
and template changes. RP-12 owns only extension source/signer/availability/
generation/restore entries and functions. RP-07 retains signer/evidence
semantics, RP-11 retains generic resolver/Harness semantics, and RP-13 retains
child behavior.
