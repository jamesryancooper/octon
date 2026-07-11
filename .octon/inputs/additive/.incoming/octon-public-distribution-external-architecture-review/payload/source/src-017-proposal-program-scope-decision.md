---
source_id: SRC-017
source_type: conversation-turn
sequence: 17
supplied_at: "2026-07-09T21:17:00.000Z"
turn_id: "019f48bd-b743-7f71-9f5d-142045a83068"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-017: Proposal-program scope decision

## User Message

Should we create a proposal program for all of the work related to the implementation of the Public Distribution Model?


## Assistant Message 1 (final_answer)

**Yes.** A proposal program is the correct work unit because the Public Distribution Model spans architecture, export tooling, runtime installation, repository policy, CI, security, migration, and cross-platform validation.

It should **not** be one large proposal packet. Use one program containing bounded, dependency-ordered packets.

## Recommended Program

**Program:** `octon-public-distribution-model`

**Objective:** Implement and verify the private-workspace, generated-public-mirror, and downstream core-delivery model through release-candidate readiness.

| Order | Proposed packet | Primary outcome |
|---:|---|---|
| 0 | `legacy-exposure-and-transition-readiness` | Inventory current public exposure and produce the human disposition checkpoint for `octon-legacy`. |
| 1 | `repository-role-and-distribution-contracts` | Define workspace, public mirror, downstream roles, ownership boundaries, and normative `portable_dropin` semantics. |
| 2 | `publication-clearance-and-portable-base` | Establish component, dependency, license, provenance, sensitivity, and publication-clearance manifests for the smallest portable base. |
| 3 | `portable-dropin-export` | Implement exact-commit, deterministic, allowlist-only export with denylist and tree-parity validation. |
| 4 | `downstream-core-delivery` | Implement core lock, artifact verification, local cache/materialization, initialization, update, interruption recovery, and rollback. |
| 5 | `local-storage-and-evidence-posture` | Establish local-private evidence semantics, retention classes, Git defaults, and removal of false external-storage claims. |
| 6 | `public-repository-scaffold-and-controls` | Create public-only workflows, documentation, security settings automation, ruleset definitions, release-candidate building, SBOMs, checksums, and attestations. |
| 7 | `self-hosting-workspace-forward-migration` | Stop new high-churn tracking, preserve required authority and receipts, and migrate current workspace behavior forward without rewriting history. |
| 8 | `distribution-pilots-and-release-readiness` | Validate public, private, local-artifact, and all Tier 1 install/update/rollback scenarios; produce the final readiness decision. |

Packets 4 and 5 can proceed in parallel after Packet 1. Packet 6 depends on the exporter. Packet 8 depends on all implementation packets.

## Program Boundary

The program should implement:

- Repository-local code, schemas, policies, templates, and documentation
- Exporter, installer, updater, rollback, and validation tooling
- License and provenance inventory mechanisms
- GitHub configuration scripts with dry-run and verification modes
- Public-repository scaffolding and workflows
- Exposure scanning and decision summaries
- Migration tooling and Tier 1 pilots
- Operator runbooks and exact commands

The program may prepare, but must not autonomously authorize:

- Final exposure disposition
- Ambiguous publication rights
- Trademark conflict acceptance
- Destructive evidence deletion
- GitHub account security changes
- Repository creation, rename, archive, or visibility changes without a checkpoint
- First public-tree push
- Final public release

## External-Effects Checkpoints

Use three explicit human gates:

1. **Legacy disposition:** approve whether `octon-legacy` remains public or becomes restricted.
2. **Repository transition:** approve the exact GitHub operations plan before Codex creates, renames, archives, or configures repositories.
3. **Publication:** personally authorize the first public-tree push and final release.

Codex can execute approved GitHub API operations after Gate 2. The final release action remains maintainer-invoked.

## Definition Of Done

The program should complete when:

- All six first-release blocker groups pass
- The private and public repository roles are established and verified
- `portable_dropin` is deterministic and leak-tested
- The portable base has zero unresolved clearance entries
- Tier 1 installation, update, interruption, and rollback tests pass
- The public repository builds a verified draft release candidate
- The self-hosting workspace follows the new forward-looking Git posture
- An operator runbook and rollback procedure have been exercised
- A final readiness receipt identifies the exact releasable commit and artifact digest

The program should stop at **release-ready**, not silently publish. Final publication remains a separate maintainer action.

