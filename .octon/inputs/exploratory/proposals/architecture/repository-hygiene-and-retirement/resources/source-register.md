# Source Register

This register lists every user-provided source and every live repo artifact
used materially in the packet.

| Register ID | Category | Origin | Why it matters | How it is used in this packet |
| --- | --- | --- | --- | --- |
| USR-01 | user input | `resources/source_inputs/01_user_request_rust_shell_cleanup.md` | establishes the Rust + Shell cleanup problem | source items SI-001 through SI-005 |
| USR-02 | user input | `resources/source_inputs/02_user_request_transitional_surfaces.md` | adds migration leftovers, shims, and transitional residue | source item SI-006 |
| USR-03 | user input | `resources/source_inputs/03_user_request_repo_hygiene_capability_spec.md` | defines the desired capability-family semantics and constraints | source items SI-007 through SI-011 |
| USR-04 | user input | `resources/source_inputs/04_user_request_proposal_packet_generation.md` | defines the packet contract and archive-ready delivery expectations | source items SI-012 through SI-014 |
| REP-01 | repo authority | `AGENTS.md`, `/.octon/instance/ingress/AGENTS.md` | canonical ingress read order and pre-1.0 atomic default | cutover receipt, source-of-truth map, packet authority order |
| REP-02 | repo authority | `/.octon/framework/constitution/CHARTER.md`, `charter.yml` | supreme repo-local constitutional regime | boundary rules, target invariants, current-state baseline |
| REP-03 | repo authority | `/.octon/framework/constitution/obligations/fail-closed.yml` | fail-closed route contract | action model and fail-closed conditions |
| REP-04 | repo authority | `/.octon/framework/constitution/obligations/evidence.yml` | retained-evidence obligations | evidence plan and closure burden |
| REP-05 | repo authority | `/.octon/framework/constitution/precedence/{normative,epistemic}.yml` | normative and factual precedence order | conflict resolution and evidence priority |
| REP-06 | repo authority | `/.octon/framework/constitution/ownership/roles.yml` | ownership ambiguity posture and human-governance role boundaries | ownership expectations and fail-closed routing |
| REP-07 | repo authority | `/.octon/framework/constitution/contracts/registry.yml` | constitutional contract registry anchor | confirms contract family grounding |
| REP-08 | repo authority | `/.octon/instance/charter/workspace.{md,yml}` | active workspace objective pair | proposal scope and ingress grounding |
| REP-09 | repo authority | `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md` | kernel execution profile surface | ingress-grounded profile context |
| REP-10 | repo authority | `/.octon/README.md` | super-root classes and authority rules | target architecture, boundary map, current-state baseline |
| REP-11 | repo authority | `/.octon/framework/cognition/_meta/architecture/specification.md` | placement and overlay contract | target architecture and file-change map |
| REP-12 | repo authority | `/.octon/octon.yml` | root manifest, generated defaults, fail-closed hooks | artifact-bloat handling and evidence planning |
| REP-13 | repo proposal contract | `/.octon/inputs/exploratory/proposals/README.md` | packet path, authority order, non-canonical rule | packet manifests and scope split |
| REP-14 | repo proposal contract | `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | base manifest contract and mixed-target rule | `proposal.yml`, README, source-of-truth map |
| REP-15 | repo proposal contract | `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | architecture subtype contract | `architecture-proposal.yml` and required docs |
| REP-16 | repo validator | `/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh` | validator-backed proposal expectations | packet readiness and artifact completeness |
| REP-17 | repo validator | `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh` | minimum architecture proposal checks | packet readiness |
| REP-18 | repo governance | `/.octon/instance/governance/support-targets.yml` | admitted support universe and workload classes | support-bounded implementation design |
| REP-19 | repo governance | `/.octon/instance/governance/capability-packs/registry.yml` | governance pack registry | support and pack boundedness |
| REP-20 | repo runtime projection | `/.octon/instance/capabilities/runtime/packs/registry.yml` | admitted runtime pack projections and evidence requirements | command mode design |
| REP-21 | repo runtime lane | `/.octon/instance/capabilities/runtime/commands/README.md` | repo-native command lane purpose | implementation shape |
| REP-22 | repo runtime lane | `/.octon/instance/capabilities/runtime/commands/manifest.yml` | current empty command manifest | current-state gap and target changes |
| REP-23 | repo runtime lane | `/.octon/instance/capabilities/runtime/skills/manifest.yml` | current empty skill manifest | rejects skill-first implementation shape |
| REP-24 | repo governance | `/.octon/instance/governance/contracts/retirement-policy.yml` | build-to-delete policy | governance reuse |
| REP-25 | repo governance | `/.octon/instance/governance/contracts/retirement-registry.yml` | live transitional/historical registry | governance reuse and same-change registration |
| REP-26 | repo governance | `/.octon/instance/governance/retirement-register.yml` | human-facing retained-surface register | same-change rationale updates |
| REP-27 | repo governance | `/.octon/instance/governance/contracts/{retirement-review,drift-review,adapter-review,support-target-review,ablation-deletion-workflow,closeout-reviews}.yml` | review and ablation contract set | validation and closure plans |
| REP-28 | repo governance | `/.octon/instance/governance/retirement/claim-gate.yml` | claim-readiness gate | closure planning |
| REP-29 | repo governance | `/.octon/instance/governance/disclosure/release-lineage.yml` | active vs superseded release protection | never-delete and claim-adjacent handling |
| REP-30 | repo principle | `/.octon/framework/cognition/governance/principles/deny-by-default.md` | fail-closed routing doctrine | action model |
| REP-31 | repo principle | `/.octon/framework/cognition/governance/principles/autonomous-control-points.md` | ACP levels and rollback posture | mode mapping |
| REP-32 | repo principle | `/.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md` | safe interrupt boundaries and stage-only posture | cutover and workflow design |
| REP-33 | repo runtime | `/.octon/framework/engine/runtime/crates/Cargo.toml` | live Rust workspace path and members | detector toolchain |
| REP-34 | repo CI | `/.github/workflows/architecture-conformance.yml` | existing architecture workflow | dependent repo-local integration planning |
| REP-35 | repo CI | `/.github/workflows/closure-certification.yml` | existing closure workflow | dependent repo-local integration planning |
| REP-36 | repo proposal evidence | active and archived proposal workspace observations | informs packet shape selection without overriding standards | packet design notes |

## Packet-local evidence shortcuts

Supporting excerpts are copied or summarized under `resources/repo_evidence/**`.
Those files are convenience evidence for reviewers; the live repo artifacts
listed above remain authoritative.
