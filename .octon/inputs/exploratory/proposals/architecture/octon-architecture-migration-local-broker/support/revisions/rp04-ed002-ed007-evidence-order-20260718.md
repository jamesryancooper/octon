revision_id: octon-architecture-migration-local-broker-revision-20260718T154257Z
source_review_id: octon-architecture-migration-local-broker-review-20260718T153501Z
revision_timestamp: 2026-07-18T15:42:57Z
revision_route: revise-packet
status: in-review
change_profile: atomic
release_state: pre-1.0
post_revision_digest: sha256:c90d305325345affe72d2ddc2febe413aa954ed3cb51d3cc16b7a153fc3e3a47
remaining_blocking_count: 0
parent_scope_changed: false
provider_scope_changed: false
credential_acquired_or_mutated: false
implementation_performed: false

addressed_finding_ids:

- `RP04-ED002-MECHANISM-001`
- `RP04-ED007-SURFACE-CENSUS-002`
- `RP04-IMPLEMENTATION-EVIDENCE-CYCLE-003`

changed_packet_files:

- `README.md`
- `architecture/acceptance-criteria.md`
- `architecture/current-state-gap-map.md`
- `architecture/file-change-map.md`
- `architecture/implementation-plan.md`
- `architecture/target-architecture.md`
- `architecture/validation-plan.md`
- `navigation/artifact-catalog.md`
- `resources/broker-ipc-keychain-design-and-dependency-receipt.yml`
- `resources/packet-contract.yml`
- `resources/traceability.yml`
- `resources/workflow-visible-surface-census.yml`
- `support/implementation-grade-completeness-review.md`
- `support/revisions/rp04-ed002-ed007-evidence-order-20260718.md`

# RP-04 Correction Receipt

## ED-002 Mechanism

The design now pins arm64 macOS 26.5.2/build 25F84 and MacOSX26.5 SDK. It
selects a root-owned LaunchDaemon under a dedicated `_octon` non-login identity,
launchd XPC Mach service, mutual peer code-signing requirements, root-owned
installed files/config, non-synchronizing System Keychain item restricted to
the installed broker, a no-echo enrollment pipe, bounded replay envelope,
one-shot HMAC-SHA256 handle, explicit macOS FFI, and pinned Rust dependencies.
Unsupported hosts, signing absence, ACL drift, dependency failure, or any
same-user attack failure deny and reopen design; no weaker fallback is allowed.

The receipt truthfully records selected-not-installed-not-executed. It does not
acquire signing credentials, resolve Cargo, install a service, create an account
or Keychain item, open XPC, or prove any attack.

## ED-007 Census

Ten surface families now have exact owners/dispositions. The existing policy
grant helper remains RP-01-owned and unrepurposed; global doctor/status,
connector admission, effect-token validators, material-effect inventory,
generated-effective publication, mission-autonomy policy, new broker templates,
and downstream adapters retain their owners. RP-04 adds one normal command
concept, `octon broker`, with bounded lifecycle subcommands and no raw-effect
surface.

## Evidence Order

Accepted proposal design may authorize creation of its exact implementation.
RP-01/RP-02/RP-03 implementation verification, ED-001, and exact Cargo/SDK/
signing/install/Keychain/fixture preflight gate source entry. UE-003 and all
dynamic IPC, credential, handle, writer, crash, scratch, recovery, lifecycle,
conformance, and drift evidence gate completion, cutover, support, and
promotion. No future result is used as present proof.

## Scope and Next Gate

All 51 promotion targets remain unchanged and exactly equal the parent entry;
no parent revision is required. Packet completeness now passes. A fresh
independent architecture/proposal re-review at the corrected digest is the next
canonical action; implementation remains forbidden in this sequence.
