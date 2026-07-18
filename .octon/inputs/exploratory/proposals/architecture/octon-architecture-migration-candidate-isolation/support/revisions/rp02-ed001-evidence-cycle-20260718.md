revision_id: rp02-ed001-evidence-cycle-20260718
source_review_id: octon-architecture-migration-candidate-isolation-review-20260718T144600Z
revision_route: revise-packet
revised_at: 2026-07-18T15:05:00Z
finding_ids:
  - RP02-ED001-MECHANISM-001
  - RP02-IMPLEMENTATION-EVIDENCE-CYCLE-002
remaining_finding_count: 0
post_revision_digest: sha256:d7efee3d86bfa0fdbd85469472da8d77f726862ce960611d5a544b1b09bbe6de
catalog_refresh: "navigation/artifact-catalog.md includes the ED-001 design and revision receipt"
registry_refresh: "generated proposal registry refreshed through its owning generator; parent write scope is unchanged"

# RP-02 Revision Receipt

## Corrections Applied

`RP02-ED001-MECHANISM-001` is corrected by the exact engineering disposition
in `resources/engineering-disposition-ed001.yml`. The initial envelope is
arm64 macOS 26/Darwin 25, root-owned exact-digest `/usr/bin/sandbox-exec`, a
rendered digest-bound default-deny SBPL profile, an absolute exact-digest and
version OpenAI Codex CLI, and `loopback-capability-relay-v1`. The trusted relay
runs outside the candidate sandbox/process group, consumes a pre-existing
authenticated upstream transport, exposes inference operations only, and
issues one random 256-bit run/process/model/budget/listener/deadline-bound
candidate bearer. Any unavailable or unproved element denies without ambient
credential, direct-provider, alternate-loopback, or RP-04 fallback.

The resource assigns exact new types/methods and narrow existing integration
symbols. Static fitness rejects ambient PATH, raw/direct provider spawning,
non-default-deny profiles, and effect-capable relay surfaces. Dynamic fitness
requires useful work and the full credential/host/Git/FD/process/IPC/
filesystem/network/relay lifecycle matrix.

`RP02-IMPLEMENTATION-EVIDENCE-CYCLE-002` is corrected by separating complete
design authorization from implementation entry and exact-implementation proof.
RP-00 verification and exact preflight remain mandatory before candidate
launch. UE-003 and all dynamic proof remain mandatory before conformance,
completion, cutover, support claim, promotion, or archive, but no longer block
authorization to create their implementation subject.

## Ownership and Parent Scope

RP-02 owns isolation preparation, the inference-only relay, native launch,
exact export, retirement, and their evidence. RP-01's final guard, RP-04's
effect credentials/broker, RP-06 routing, and RP-11 generic adapter semantics
remain outside RP-02. The ordered 17 promotion targets are unchanged and still
equal the parent registry, so no `revise-program` action is required.

## Evidence Posture

The ED-001 selection is reviewed proposal design, not executed feasibility
proof. The observed host identity and broken shell Codex wrapper are current
preflight observations only; native enforcement, provider usefulness, UE-003,
rollback, and adversarial proof remain `UNVERIFIED`. No implementation,
sandbox, provider, credential, candidate, Git export, publication, promotion,
archive, or cleanup effect occurred.
