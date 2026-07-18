# Candidate Isolation Post-Remediation Architecture Audit

- run_id: `architecture-migration-candidate-isolation-post-remediation-20260718T151500Z`
- target_mode: `observed`
- domain_path: `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation`
- evidence_depth: `deep`
- severity_threshold: `medium`
- post_remediation: `true`
- reviewed_commit: `9c958ad4d609347377795c82249127117999eee6`
- reviewed_packet_digest: `sha256:3228da9b1a70c687878a2fd32324cd1fd8729360113024fae48221d66923cada`

## Outcome

RP-02 is architecture-ready for acceptance. ED-001 now selects a narrow exact
host/enforcement/client/relay design, assigns implementable symbols and proof,
and denies unavailable or unproved tuples. Dynamic evidence is correctly
post-authorization and remains mandatory before completion. Both prior blockers
are closed; no new finding at or above medium remains.

## Current Surface Map

| Surface | Responsibility | Evidence |
| --- | --- | --- |
| Candidate preparation | Independent repository, fresh HOME/env, closed descriptors | `CandidateIsolationRunner::prepare` design |
| Native enforcement | Exact root-owned sandbox executable and digest-bound default-deny SBPL | `resources/engineering-disposition-ed001.yml` |
| Provider session | Inference-only relay outside candidate state, one-run bounded bearer | ED-001 resource and target architecture |
| Spawn integration | RP-01 guard then RP-02 native spawn at named existing symbols | `architecture/file-change-map.md` |
| Export/retirement | Exact non-executing commit export, bearer revocation, cleanup/quarantine | target and rollback plans |
| Parent coordination | Exact target equality, source ownership, collision serialization | parent registry/ownership/collision artifacts |

## External Criteria Evaluation

| Criterion | Result | Assessment |
| --- | --- | --- |
| Modularity | pass | Isolation/relay state is cohesive; authority, effects, routing, and generic adapter semantics remain separate. |
| Discoverability | pass | One ED-001 resource exposes the support envelope, mechanisms, symbols, fitness, evidence order, and unsupported remainder. |
| Coupling | pass with controlled cost | The relay consumes only an upstream transport; shared code edits are named and parent-serialized. |
| Operability | pass for design | One exact tuple is automatic; missing/broken prerequisites deny before provider contact with no fallback. |
| Change safety | pass | Exact hashes/versions/listener/profile bind the admitted tuple and every drift invalidates it. |
| Testability | pass | Static dominance and inference-only checks plus useful-positive, negative, relay-lifecycle, fault, export, and cleanup matrices are explicit. |

## Critical Gaps

None at or above medium. The broken observed shell client and unexecuted native,
provider, UE-003, rollback, and adversarial proof remain implementation-entry
or completion gates, not missing design evidence.

## Recommended Changes

| Priority | Recommendation | Benefit | Tradeoff |
| --- | --- | --- | --- |
| P1 | Keep the relay inference-only and schema-reject any effect/admin operation. | Prevents an RP-04 dependency or privilege leak. | The relay cannot be reused for effects. |
| P1 | Bind every run to exact client, sandbox executable, rendered profile, listener, and host identities. | Makes drift and support claims falsifiable. | Every changed tuple requires fresh proof. |
| P1 | Execute UE-003 only against the separately authorized exact implementation. | Removes circularity without weakening proof. | Acceptance does not imply operational success. |

## Keep As-Is Decisions

- Keep RP-01 guard, RP-04 effect credentials/broker, RP-06 publication routing,
  and RP-11 generic adapters outside RP-02.
- Keep the initial support envelope to arm64 macOS 26/Darwin 25 and one primary
  provider client.
- Keep direct provider egress, other loopback services, ambient credentials,
  linked worktrees, and canonical Git prohibited.
- Keep proposal and retained evidence non-authoritative.

## Open Questions / Unknowns

- A working exact Codex CLI and upstream authenticated transport must exist at
  implementation entry; the observed shell wrapper is currently broken.
- `sandbox-exec`/SBPL enforcement and exact relay restriction must pass the
  full dynamic matrix on the admitted build.
- UE-003 and useful provider behavior remain unexecuted.

These unknowns fail closed and block launch or completion at their named gates;
they do not require a new product decision or block acceptance of the exact
design.

## Self-Challenge

- Challenged deprecated/native enforcement risk: support is one exact observed
  OS family and denies any unavailable or failed enforcement.
- Challenged whether the relay is an effect broker: its protocol contains only
  model inference and explicitly cannot expose RP-04 operations.
- Challenged candidate credential exposure: only a non-durable, one-run,
  tightly bound bearer is visible; upstream authentication remains outside.
- Challenged broad loopback/direct egress: exact listener is the sole admitted
  destination and negatives are mandatory.
- Challenged proof inflation: no dynamic result is claimed.

## Done Gate

Three controlled passes converge; both prior blockers and scope equality are
closed; no new medium-or-higher finding remains. Done gate:
`pass-qualified-local`.
