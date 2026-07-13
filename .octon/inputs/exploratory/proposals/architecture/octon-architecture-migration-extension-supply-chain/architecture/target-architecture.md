# Target Architecture

## Decision

Implement FD-021 by extending the current extension intake, publication,
quarantine, generated-catalog, and generation-lock system. Add authenticity,
exact private-release availability, revocation, and recoverable generation
transitions without adding a marketplace, package manager, authority source,
or publication control plane.

## Accepted ROD-004 Trust Boundary

ROD-004 is accepted with this initial baseline:

- one operator-controlled signer family;
- immutable release references and payload digests;
- explicit capability grants;
- an empty deny-by-default source allowlist until intentional admission; and
- denial of unknown, unsigned, revoked, incompatible, capability-mismatched, or
  mutable-source material.

RP-12 must encode and prove that baseline. Exact future source additions, public
signer material, pins, rotations, recovery changes, and capability/compatibility
updates are governed configuration changes, not remaining architecture
decisions. Until an intentional admission is durably configured and every gate
passes, every private/external import denies; bundled-first-party packs continue
under their existing repository-integrity boundary.

The desired config stores only nonsecret source identities, key IDs or public
fingerprints/verification refs, policy versions, pins, and revocations. Private
signing material never enters the repository. RP-07 supplies authentic
signer/revocation receipt and bounded retention mechanisms; RP-12 does not
create a second signer or evidence system.

## Canonical Signed Envelope

Every private/external release has one strict canonical envelope binding:

- envelope schema and canonicalization version;
- pack ID, version, origin class, and source ID;
- approved source URI plus immutable Git commit/release asset identity;
- pack manifest ref and digest;
- canonical payload-tree digest, file count, byte bounds, and allowed roots;
- dependency IDs, exact or allowed ranges as policy permits, and their signed
  envelope/payload identities;
- requested capability profiles and concrete capability declarations;
- framework/extension API, required-contract, host, and compatibility profile
  requirements;
- signer key ID/fingerprint, signature profile/algorithm, signed-at and expiry
  semantics allowed by the accepted ROD-004 baseline, and revocation-check identity; and
- the signature over the canonical unsigned envelope body and payload root.

Unknown fields reject. The pack's self-declared trust hints never select a
trusted key or source. A signature authenticates the bound release; it cannot
grant a capability or make compatibility true.

## Explicit Import Pipeline

`octon extension import` is an admin/internal one-command flow after the accepted
ROD-004 baseline is encoded and proved:

1. require an operator-approved source and immutable ref/digest;
2. fetch or accept into `.octon/inputs/additive/.incoming/**`, which remains
   untrusted and unavailable;
3. enforce archive byte/file/depth limits and reject traversal, absolute paths,
   symlink/hardlink escape, device nodes, duplicates, and case collisions;
4. parse the strict envelope and reconstruct its canonical signed bytes;
5. verify source identity, signer trust/current revocation, signature, manifest,
   payload tree, pack schema, dependency envelopes, and exact immutable refs;
6. evaluate compatibility and requested-capability admission against ROD-004
   and current Octon contracts;
7. retain the exact envelope/payload as a content-addressed historical release
   under the existing additive archive boundary and create/update one verified
   availability entry; and
8. emit an authentic bounded import receipt or quarantine record.

The import transaction writes no desired selection, active generation,
generated projection, capability grant, Harness, route, or runtime state. A
crash before availability publication leaves only discardable staging. A
crash after immutable release retention but before availability update leaves
an unreferenced recovery candidate that is reverified before adoption.

## Desired, Actual, and Generated State

| Layer | Canonical surface | Writer | Meaning |
| --- | --- | --- | --- |
| Desired | `.octon/instance/extensions.yml` | Operator/governed repo change | Approved source/signer/revocation policy, enabled/disabled selection, exact version/source/payload pins |
| Raw retained source | normalized bundled packs and content-addressed signed releases under additive input/archive boundaries | Import/normalization tooling | Non-authoritative immutable input; never read directly by runtime |
| Actual availability | `.octon/state/control/extensions/available.yml` | Import verifier/reconciler | Exact verified releases presently available or restorable under a recorded verification result |
| Actual active/quarantine | `.octon/state/control/extensions/active.yml` and `quarantine.yml` | Existing extension publisher/reconciler | Current published generation and rejected/withdrawn subjects |
| Generated | `.octon/generated/effective/extensions/**` | Existing extension publisher only | Rebuildable catalog, artifact map, generation lock, and published pack views |
| Evidence | import/compatibility/publication/transition/restore receipts | RP-12 producers using RP-07 identity/retention | Proof and diagnosis; never desired, actual, or authority |

No layer is a database service. The current repo-owned file model and single
publisher remain. Generated output is never edited to select or restore a
release.

## Availability, Selection, and Publication

Availability entries are keyed by pack ID, source ID, exact version, immutable
source ref, and payload digest. Each entry points to its signed envelope,
import receipt, current signer/revocation observation, compatibility result,
requested capability set, dependencies, and retained payload. An availability
row is a candidate, not a selection.

Desired enabled private packs use exact source/version/payload pins. The
existing publisher resolves an enabled pin only when:

- the exact release is in verified availability;
- the source and signer remain approved and unrevoked;
- envelope, manifest, payload, dependency, and import-receipt digests match;
- compatibility and capability admission still pass;
- every dependency is independently signed, available, pinned/resolved under
  policy, and coherent; and
- no active/quarantine or native-capability collision invalidates the set.

The publisher stages the complete active/quarantine/generated family, writes a
generation-transition receipt, and atomically exposes one generation. A failed
set quarantines affected releases or publishes the coherent surviving set only
where existing policy permits; it never opportunistically selects a different
private version.

## Harness Binding

The generated generation lock adds exact source-envelope, signer-policy,
payload, dependency, import, compatibility, and transition receipt digests.
The RP-11 Harness compiles the exact generation ref/digest as one immutable
input. A desired, trust, revocation, availability, actual, or generated change
invalidates a future compile/launch; the Harness cannot refresh, select, or
repair extensions itself.

Runtime route and prompt resolvers consume the verified generated generation
and cross-check active state/lock through the existing runtime resolver. Raw
and archived paths, availability rows, or receipts cannot be direct runtime
inputs.

## Revocation

A signer, key, source, release, or payload revocation updates the operator-owned
desired trust policy through its canonical route. Reconciliation then:

1. invalidates affected availability entries;
2. records quarantine with the exact revocation identity and affected
   dependency closure;
3. blocks new publication, resolution, Harness compile, and launch for the
   affected generation;
4. atomically publishes a coherent generation without the extension when
   permitted; and
5. retains authentic revocation/transition evidence.

RP-12 does not decide how an already-running provider process is terminated;
existing authority/recovery owners handle active-run response. It does ensure
the generation is never silently replaced inside that run.

## Prior-Generation Restore

Restore is not a file copy or pointer rewind. A canonical rollback/recovery
request names an exact retained generation or release. The existing publisher:

1. verifies the retained signed envelope and payload bytes;
2. rechecks current source/signer/revocation policy;
3. rechecks current framework/API/contract/host compatibility;
4. rechecks requested capabilities and the complete signed dependency closure;
5. confirms the desired/rollback authorization and exact pin supplied by its
   existing owner;
6. stages a new generated family derived from those retained inputs;
7. atomically publishes it with a new generation ID and transition/restore
   receipt; and
8. lets later Harnesses bind the new exact generation.

If any check fails, the prior release remains quarantined/unavailable and the
extension is disabled. Rollback cannot restore a revoked signer, stale
compatibility, changed payload, or broader capability set.

## Bundled-First-Party Bridge

Current bundled-first-party packs remain within the repository release and
integrity boundary while private import activates. Their manifest/payload
digests, compatibility, desired selection, publication, active/quarantine, and
generation-lock checks remain. No unsigned private/external pack is
grandfathered. A later proposal may unify bundled signing, but RP-12 does not
force churn across all bundled pack payloads to close FD-021.

## Availability and Degraded Operation

Missing/unavailable private sources do not affect an already retained valid
generation. Unknown trust/revocation state, missing retained payload, corrupt
availability, or digest disagreement blocks new affected publication/restore
and preserves the last certified generation only while it remains unrevoked
and policy-valid. Generated corruption is rebuilt from desired plus actual
state. If no valid generation exists, the extension disables and core Octon
continues.

## Unsupported Remainder

No public marketplace, public discovery/catalog, ratings, payments, arbitrary
URL install, automatic update, unpinned private selection, transitive fetch
from unapproved sources, install-and-run, extension-defined authority,
extension-defined capability grants, general package management, background
catalog daemon, or second publication/control plane is supported.
