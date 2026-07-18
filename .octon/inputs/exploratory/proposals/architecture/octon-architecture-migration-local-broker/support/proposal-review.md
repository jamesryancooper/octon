review_id: octon-architecture-migration-local-broker-review-20260718T153501Z
reviewed_at: 2026-07-18T15:35:01Z
reviewer: octon-proposal-lifecycle-review-packet
verdict: revision-required
implementation_prompt_authorized: no
reviewed_packet_digest: sha256:4ffedf17bf81c9cece8e8227d6a3c48184c655ab0529454cd519190ca9f6381c
open_blocking_findings_count: 3
prior_review_id: none
final_route: revise-packet
final_route_target: octon-architecture-migration-local-broker

# RP-04 Independent Proposal Review

## Review Basis

Reviewed all 22 packet files at commit `3948ce913c`, the accepted parent and
RP-01/RP-02/RP-03 designs, current macOS 26.5.2/Xcode 26.5 SDK interfaces, and
the current broker-named, effect, credential, CLI, workflow, and policy
surfaces. No implementation or platform mutation was performed.

## Approved Promotion Targets

None while revision is required. The 51 proposed targets agree with the parent
registry but remain future implementation scope.

## Blocking Findings

### RP04-ED002-MECHANISM-001 — high

The architecture requires application identity stronger than same UID and
broker-bound Keychain custody, but leaves the service class, XPC/Mach endpoint,
peer code-signing requirements, installed ownership, signing baseline,
Keychain class/access rule, enrollment path, wire format, cryptographic handle,
and exact Rust/macOS dependency boundary unselected. The current SDK exposes
launchd Mach services and `xpc_connection_set_peer_code_signing_requirement`,
but the packet does not bind them or explain the unsupported-host route.

### RP04-ED007-SURFACE-CENSUS-002 — high

No exhaustive census dispositions current `policy-grant-broker.sh`, kernel
doctor/status and connector admission surfaces, effect-token validators,
generated-effective publication wrappers, material-effect inventory, instance
credential policy, and future `octon broker` commands. Without exact symbol and
surface ownership, the packet cannot prove one normal command concept or avoid
duplicating authority/effect workflows.

### RP04-IMPLEMENTATION-EVIDENCE-CYCLE-003 — high

The completeness and entry criteria require prerequisite implementation proof,
ED-001 useful-session proof, prototype attacks, and scratch-effect results
before proposal authorization. Those results require an authorized exact
implementation. Separate accepted dependency design from future implementation
verification: parent/child proposal acceptance may authorize creation, while
RP-01/RP-02/RP-03 implementation gates, ED-001/UE-003, and all dynamic attacks
must gate conformance, completion, or promotion.

## Nonblocking Findings

- The 51 ordered child targets exactly match the parent registry.
- All three dependency packets are now accepted; their implementation and
  verification remain future DAG entry gates, not proposal-review evidence.
- Same-user resistance may require root-owned installed state or another exact
  mechanism; the revision may select an engineering default but cannot weaken
  the accepted boundary.

## Exclusions

- No launch service, XPC endpoint, signing identity, Keychain item, credential,
  store connection, operation handle, effect, provider, publication, promotion,
  archive, cleanup, or implementation.
- No proposed SDK mechanism or planned test is represented as executed proof.

## Final Route Recommendation

Keep RP-04 `in-review` and run `revise-packet` to select ED-002 exactly, close
the ED-007 surface census, and correct evidence order. Then independently
re-review the final digest; do not implement RP-04 in this sequence.
