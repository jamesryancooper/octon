---
source_id: SRC-011
source_type: conversation-turn
sequence: 11
supplied_at: "2026-07-09T19:18:29.000Z"
turn_id: "019f4851-3633-7d61-ae67-8170b511440d"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-011: Delivery decision resolution and self-hosting migration

## User Message

# Octon Delivery Model Decision Resolution and Self-Hosting Migration Plan

Act as a principal Octon architecture, security-boundary, developer-experience, and release-engineering architect.

## Objective

Resolve the remaining open architectural questions for the Octon Public Distribution and Core Update Model, then produce an implementation-ready roadmap for migrating the current Octon project to the approved model.

Do not simply restate prior recommendations. Verify implementation-critical assumptions against the current repository, challenge weak conclusions, and distinguish decisions that can be resolved architecturally from those requiring sponsor, maintainer, security, release-operations, or legal authority.

## Required Distinction

The current Octon project is the private, self-hosting development workspace. It is not an ordinary downstream consumer.

Its target policy may therefore be broader than downstream defaults:

- It must continue tracking and developing canonical `.octon/framework/**` source.
- It owns its repository-specific `.octon/instance/**` authority.
- It should reduce unnecessary Git tracking of high-churn state, generated output, raw evidence, logs, caches, host projections, and local residue.
- It must produce the public distribution only through the validated, allowlist-based `portable_dropin` export.
- It must never publish workspace Git history or treat the workspace repository as the public distribution source tree.

Do not apply the downstream “retrieve framework from a lock and cache” policy to the framework-development workspace without accounting for this self-hosting role.

## Established Direction

Preserve these decisions unless current repository evidence proves them infeasible or contradictory:

- The private Octon workspace and public Octon distribution are separate repositories.
- The public repository is populated only from a generated and validated `portable_dropin` export.
- Downstream projects normally commit an exact core lock and retrieve a verified release artifact into machine-local storage.
- Vendored framework snapshots are an explicit exception for offline, air-gapped, or policy-constrained environments.
- Core updates may modify only core-owned paths.
- Repository-specific instance authority, inputs, state, evidence, generated outputs, and host projections are project-owned and must not be silently changed by a core update.
- Operational state, raw evidence, generated outputs, caches, logs, and host projections remain outside Git by default unless an explicit collaboration, governance, release, recovery, or retention requirement justifies hosting them.
- Compact, classified receipts and immutable pointers replace raw evidence in hosted Git wherever possible.
- The base public distribution ships with zero additive packs.
- All framework content requires publication, provenance, sensitivity, and license clearance before first release.

## Open Questions to Resolve

For each question, provide:

- the recommended decision;
- supporting repository evidence;
- alternatives considered;
- security, operational, and compatibility tradeoffs;
- the responsible decision authority;
- whether the issue is resolved or still requires approval;
- implementation consequences and acceptance criteria.

Address at least:

1. Public repository identity, ownership, branch protections, release authorization, and publication credentials.
2. Artifact signing trust root, provenance format, checksum policy, and key or identity rotation.
3. External operational-state and immutable-evidence storage, including access control, retention, recovery, and pointer durability.
4. Whether the first public release should contain the complete publication-cleared framework or a smaller dependency-closed runtime package.
5. Offline and air-gapped behavior, cache retention, internal mirrors, and vendored-mode support.
6. Cross-platform bootstrap, update transactions, rollback, and interrupted-update recovery.
7. Whether existing hosted workspace history requires a separate sensitivity or exposure review.
8. The source and ownership of public-repository-only CI files that must not be installed into downstream projects.
9. The minimum target-local instance, ingress, state-root, and generated-output initialization contract.
10. Any remaining legal, security, maintainer, sponsor, or release-operations decisions that cannot be resolved architecturally.

## Current Octon Migration

Define how the current self-hosting Octon project moves from its existing tracking and release posture to the target model.

The roadmap must cover:

- repository-role policy for the private workspace;
- continued tracking of canonical framework source;
- classification of current instance, input, state, evidence, generated, and host-projection material;
- prevention of new high-churn or sensitive material entering Git by default;
- migration of private raw evidence to external immutable storage where appropriate;
- retention of compact publishable evidence and required governance records;
- generated-output and host-projection regeneration;
- introduction of `portable_dropin`;
- replacement or narrowing of unsafe export behavior;
- public repository creation and controlled population;
- core lock, resolver, cache, bootstrap, update, migration, and rollback implementation;
- CI, pre-commit, pre-push, publication, and public-tree validation;
- handling of existing tracked material through forward migration without assuming history rewriting;
- pilot adoption in representative public, private, and offline downstream projects.

## Required Deliverables

1. Final decision register for all open questions.
2. Confirmed current-state and target-state topology.
3. Normative `portable_dropin` specification.
4. Downstream installation and update specification.
5. Private Octon workspace storage and Git policy.
6. Public distribution repository policy.
7. Current-to-target migration matrix for every major repository surface.
8. Phased roadmap with dependencies, owners, file-level work areas, risks, and measurable acceptance criteria.
9. Rollback and interrupted-migration strategy for each phase.
10. Required validation, security, provenance, publication, and supply-chain gates.
11. Pilot and rollout plan.
12. Remaining decisions that require explicit human authority.
13. Recommended normative policy wording.

Label every conclusion as:

- **Confirmed evidence**
- **Sponsor decision**
- **Recommendation**
- **Assumption**
- **Open question**

## Constraints

- Begin read-only.
- Do not modify files, Git configuration, history, remotes, or publication settings.
- Do not publish, push, delete, externalize, or migrate material during this review.
- Do not inspect human-led ideation content.
- Do not expose sensitive content in the report.
- Do not assume private hosting makes material safe or appropriate to track.
- Do not assume non-authoritative or generated material is safe to publish.
- Do not eliminate evidence required for collaboration, governance, release, recovery, or auditability.
- Do not make legal or intellectual-property conclusions without explicit evidence.
- Do not use workspace Git history as a public-distribution mechanism.
- Do not migrate the framework-development workspace as though it were an ordinary downstream consumer.

## Definition of Done

The result must be precise enough to create tracked implementation work without reconstructing intent from prior conversations.

Every phase must have:

- explicit scope and ownership;
- dependencies and ordering;
- measurable acceptance criteria;
- validation and negative controls;
- rollback behavior;
- security and publication implications;
- unresolved authority dependencies.

The final plan must show a credible path from the current self-hosting Octon workspace to a fast, updateable, low-churn development model that safely produces the separate public `portable_dropin` distribution.

## Assistant Message 1 (commentary)

I’ll treat the prior review as a hypothesis set, not the decision record. I’m rechecking the current repository for release identity, evidence backends, cross-platform bootstrap/update primitives, public-only CI ownership, and self-hosting write paths before resolving what can be decided architecturally.

## Assistant Message 2 (commentary)

The first decision boundary is already clear: “private workspace” is a repository role, not a guarantee supplied by directory naming. I’m checking the actual hosted visibility and protections because that determines whether history review is merely prudent or an immediate exposure-response requirement.

## Assistant Message 3 (commentary)

The hosted-state check found a material contradiction: `jamesryancooper/octon` is currently public, with secret scanning and push protection disabled. Therefore the “private self-hosting workspace” target is not the current hosted reality, and a repository-history sensitivity/exposure review is now a required P0 control, not an optional future question. I will keep the architecture plan non-destructive and separate remediation authority from the technical recommendation.

## Assistant Message 4 (commentary)

The architecture can now resolve most defaults, but two approvals remain unavoidable: security/legal disposition of already-public history, and organizational ownership of the new repositories and signing identity. Everything else can be specified as implementation contracts with those approvals as gates rather than left architecturally ambiguous.

## Assistant Message 5 (commentary)

The evidence review is complete. The decisive issue is that the current hosted repository is already public, so the migration must begin with exposure triage and repository-role separation before any new distribution pipeline is treated as safe.

## Assistant Message 6 (commentary)

The target model is now internally consistent: the self-hosting workspace remains source-authoritative for the framework, while downstream projects consume verified artifacts through a lock and local materialization. The roadmap starts with containment because export engineering cannot undo material already present in public Git history.

## Assistant Message 7 (final_answer)

**Architectural Verdict**

**Confirmed evidence:** Octon is **partly aligned but not publication-ready**. Its five-root architecture correctly separates portable framework, repository authority, inputs, runtime state, and generated output ([shared-foundation.md](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/shared-foundation.md:30)). That architectural boundary is suitable.

**Confirmed evidence:** The current release, export, initialization, Git, evidence-storage, and update implementations do not enforce the intended distribution boundary. More critically, the current origin is already public, with secret scanning and push protection reported disabled as of July 9, 2026 ([GitHub repository API](https://api.github.com/repos/jamesryancooper/octon)).

**Sponsor decision:** Separate workspace and public repositories, allowlist-only `portable_dropin`, exact downstream locks, zero base packs, and project-local operational material remain sound.

**Recommendation:** Treat first publication as blocked until exposure triage, framework clearance, deterministic export, protected publication, and transactional installation are implemented.

## Decision Register

| ID | Evidence and recommended decision | Alternatives and tradeoffs | Authority, status, acceptance |
|---|---|---|---|
| ODM-001 Critical: repository identity | **Confirmed evidence:** The hosted workspace is public and current releases tag workspace history. **Recommendation:** Establish an organization-owned private workspace identity and a new public distribution repository with synthetic, unrelated history. Freeze and disposition the current repository as legacy. | Changing visibility may help containment but cannot undo prior exposure. Reusing or rewriting this history as the public distribution violates the boundary. | **Open question:** Sponsor, Security, and Release Operations approve names, ownership, legacy disposition, protections, and contribution model. **Acceptance:** distinct repository IDs; no public workspace remote or credential; public tree has no workspace ancestry. |
| ODM-002 High: signing and credentials | **Confirmed evidence:** [`release-please.yml`](/Users/jamesryancooper/Projects/octon/.github/workflows/release-please.yml:100) uses a long-lived PAT and publishes from the workspace; runtime releases lack checksums, SBOMs, and attestations. **Recommendation:** Use a repository-scoped GitHub App for export PRs and protected public CI for SHA-256 manifests, SBOMs, and signed provenance. GitHub documents expiring installation tokens and signed artifact attestations with offline verification ([App authentication](https://docs.github.com/en/enterprise-cloud%40latest/apps/creating-github-apps/authenticating-with-a-github-app/authenticating-as-a-github-app-installation), [artifact attestations](https://docs.github.com/en/enterprise-cloud%40latest/actions/concepts/security/artifact-attestations), [offline verification](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/verify-attestations-offline)). | Static signing keys aid some air-gapped deployments but add custody and rotation risk. Use them only as a second offline signature. | **Open question:** Security owns trust policy and rotation; Release Operations owns credentials and environments. **Acceptance:** online/offline verification, overlap rotation, revocation, and anti-rollback tests pass. |
| ODM-003 High: operational and evidence storage | **Confirmed evidence:** The retention contract distinguishes private raw evidence from compact receipts ([evidence-disclosure-tiers-v1.yml](/Users/jamesryancooper/Projects/octon/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml:17)), but [`write-run.sh`](/Users/jamesryancooper/Projects/octon/.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh:1079) constructs synthetic digest/locator fields without uploading immutable objects. **Recommendation:** Keep operational state local in V1; implement a real encrypted, content-addressed immutable evidence backend before external migration. | Git, LFS, and transient CI artifacts do not provide the required access, retention, or recovery semantics. A shared control-state service can follow when multi-operator coordination is needed. | **Open question:** Security, Legal, and Operations select provider, ACLs, retention, residency, recovery objectives, and deletion authority. **Acceptance:** upload, digest, reachability, authorization, retention, and restore tests pass. |
| ODM-004 Release blocker: first-release scope | **Confirmed evidence:** No root license/notice or file-level framework clearance ledger exists; no dependency-closure mechanism supports safe manual minimization. **Recommendation:** Publish the complete publication-cleared **portable framework closure after reclassification**, not every file currently under `framework/**`. Build platform binaries from the public commit. | Blindly publishing the path is unsafe; manually selecting a smaller runtime risks missing dependencies. A minimized package should follow machine-verified dependency closure. | **Open question:** Sponsor, Maintainers, Security, and Legal approve the first closure. **Acceptance:** every exported file has provenance, sensitivity, license, and component disposition; zero unresolved entries. |
| ODM-005: offline behavior | **Confirmed evidence:** Existing host-tool provisioning already establishes a versioned `$OCTON_HOME` precedent. **Recommendation:** Exact lock plus content-addressed cache is the default; mirrors are untrusted transports; air-gap bundles carry payload, checksums, SBOM, attestation bundle, and trusted roots. Vendoring remains an explicit exception. | Submodules/subtrees couple repository lifecycle and trust to Git remotes. Unlocked package retrieval is not deterministic. Vendoring increases churn but improves reviewability and offline recovery. | **Recommendation:** Architecturally resolved; Operations approves cache retention and mirrors. **Acceptance:** online, mirror, offline-cache, air-gap, and vendored installs resolve the same digest. |
| ODM-006 High: cross-platform update | **Confirmed evidence:** Bootstrap is Bash-oriented while runtime releases target five OS/architecture combinations ([runtime-binaries.yml](/Users/jamesryancooper/Projects/octon/.github/workflows/runtime-binaries.yml:1)); no transactional core updater exists. **Recommendation:** Implement compiled `octon core` commands with minimal POSIX and Windows wrappers. | Script-only updates have weaker transaction, locking, and recovery behavior. | **Recommendation:** Maintainer-owned and architecturally resolved. **Acceptance:** install, dry-run, update, interruption, resume, and rollback pass on all supported targets. |
| ODM-007 Critical: existing exposure | **Confirmed evidence:** Public history, tags, releases, workflow artifacts, issues, and PR attachments may already contain excluded material. **Recommendation:** Perform a full exposure review before further releases; revoke credentials before cleanup if any secret is found. | Scanning only the current tree misses removed or transformed material. History rewriting cannot retract previously fetched data. | **Open question:** Security and Legal own incident classification; Sponsor owns legacy disposition. **Acceptance:** signed exposure register and remediation disposition. |
| ODM-008 High: public-only CI | **Confirmed evidence:** Current workflows are workspace-specific and [`CODEOWNERS`](/Users/jamesryancooper/Projects/octon/CODEOWNERS:1) contains placeholder owners. **Recommendation:** Maintain reviewed public-repository templates as an `installable: false` component; export them only to `public_tree/.github/**`. | Editing the mirror directly causes canonical-source drift. | **Open question:** Sponsor must choose issue/patch intake because direct public-source PRs conflict with the mirror model. **Acceptance:** install payload contains no public CI; real owners and protected checks govern the public tree. |
| ODM-009 High: initialization | **Confirmed evidence:** The template manifest requires files absent from its template tree ([manifest.json](/Users/jamesryancooper/Projects/octon/.octon/framework/scaffolding/runtime/templates/octon/manifest.json:8)); initialization also writes target configuration into framework-owned paths. **Recommendation:** Replace this with a neutral, complete initialization contract. | Retaining partial templates produces installations that cannot be independently validated or safely updated. | **Recommendation:** Maintainer-owned. **Acceptance:** clean initialization is neutral, zero-pack, validation-complete, and does not modify framework source. |
| ODM-010 High: Git churn | **Confirmed evidence:** HEAD tracks roughly 40,000 state files, 5,700 inputs, and 1,800 generated files; current [`.gitignore`](/Users/jamesryancooper/Projects/octon/.gitignore) intentionally re-includes several high-churn roots. **Recommendation:** Introduce role-aware Git policy and migrate forward without rewriting history. | Ignoring everything loses required authority and receipts; retaining everything preserves churn and leak risk. | **Recommendation:** Sponsor approves policy; Maintainers execute it. **Acceptance:** default-local roots cannot be newly committed without an explicit classification override. |

## Target Topology

**Confirmed evidence, current state:**

```text
public GitHub workspace history
  <- framework + instance + inputs + state + evidence + generated + host projections
  <- release workflow tags and publishes from that same history
```

**Recommendation, target state:**

```text
private framework workspace commit
  -> clean allowlist staging
  -> portable_dropin/{public_tree, install_payload, metadata}
  -> protected public-repository PR
  -> public commit builds signed release assets
  -> verified local cache
  -> downstream .octon/framework materialization

project authority -> downstream Git
operational state/generated/hosts -> machine-local storage
raw evidence -> immutable external store -> compact classified Git pointer/receipt
```

## Normative `portable_dropin`

**Recommendation:**

- Source an exact protected private commit using tracked-tree enumeration, never working-tree `cp -R`; the current exporter does the latter ([export-harness.sh](/Users/jamesryancooper/Projects/octon/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh:91)).
- Produce `public_tree/`, `install_payload/`, and `metadata/` components.
- Allow `install_payload/` to contain only a neutral `.octon/octon.yml`, publication-cleared framework closure, core wrappers, schemas, and neutral bootstrap templates.
- Add reviewed root documentation, license/notice/security files, real `CODEOWNERS`, and public-only `.github/**` only to `public_tree/`.
- Deny `.octon/{instance,inputs,state,generated}/**`, additive packs, live `.octon/AGENTS.md`, `.codex/**`, `.claude/**`, `.cursor/**`, evidence, logs, reports, archives, caches, `.git/**`, unknown roots, and initially symlinks.
- Emit a per-file path/mode/size/SHA-256/component/clearance manifest, checksums, SBOM, provenance, and attestations.
- Require deterministic double-build equality, fail-closed unknown-file handling, no source mutation, and exact public-tree digest equality.
- Retain `bootstrap_core`, `repo_snapshot`, and `pack_bundle` as internal profiles. None is suitable publicly: they include instance material, packs, omit core, or lack publication controls ([octon.yml](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:33)).

## Downstream Installation and Update

**Recommendation:** Downstream Git tracks `.octon/octon.yml`, a generated `.octon/core.lock.yml`, project-owned `.octon/instance/**`, classified durable inputs, and root adapters. The framework is materialized locally from `$OCTON_HOME/core/sha256/<digest>`; vendored mode is explicit.

The lock must record version, artifact and manifest digests, sources, profile, install mode, compatibility, SBOM/provenance references, signature bundle, and trust-policy version. It must contain no credential-bearing URL.

Core owns the local framework materialization, neutral root manifest, wrappers, and intentional lock update. Project-specific settings move to `instance/**`. The updater must refuse framework replacement when repository role is `framework-development`.

Updates require: resolve, download, verify, compatibility check, dry-run, project-owned path hash, exclusive lock, same-volume staging, journal, core-only atomic swap, lock write last, validation, and explicit generated/host reconciliation. Interrupted operations resume or restore the previous cached digest; updates never commit automatically.

Initialization creates target-local manifests, charter/bootstrap/ingress authority, governance support and ownership declarations, empty extension configuration, `.octon/AGENTS.md`, root adapters, local state/evidence/continuity roots, and generated roots. Host projections remain opt-in.

## Surface Migration Matrix

**Recommendation:** Every row below is target policy; `hosted-*` refers to the owning project repository, not the public distribution.

| Surface | Private self-hosting workspace | Public distribution | Downstream default / owner |
|---|---|---|---|
| `.octon/octon.yml`, core lock | Track; remove repo-specific commit defaults; lock not used to replace source framework | Neutral manifest only; installer writes lock | `hosted-required`; core-owned and reviewable |
| `.octon/framework/**` | `hosted-required`; canonical source; classify and clear | Cleared component closure only | Local cache/materialization; core-owned; vendored exception |
| `.octon/instance/**` | Track durable authority after sensitivity classification | Excluded | `hosted-required`; project-owned |
| Additive `.incoming/**` | `local-by-default` | Excluded | Local; project-owned |
| Additive `.archive/**` | `external-with-pointer` when retention is required | Excluded | External with classified pointer |
| Normalized extensions | Host only after classification | Zero base packs | `hosted-optional-after-classification` |
| Ideation | Local; content was not inspected | Excluded | `local-by-default` |
| Proposals and lineage | Host compact active governance records; externalize raw lineage | Excluded | Optional after classification |
| Plans, syntheses, reports | Local by default; publish only reviewed derivatives | Excluded | Optional after classification |
| `state/control/**` | Local; shared coordination later requires a real service | Excluded | `local-by-default` |
| `state/evidence/**` | Raw evidence external; compact receipts may be hosted | Excluded from base artifact | `external-with-pointer`; classified receipt optional |
| `state/continuity/**` | Local; compact handoff optional | Excluded | Local by default |
| All `generated/**` classes | Regenerate; move genuine golden fixtures into framework tests | Excluded | `generated-on-demand` |
| `.octon/AGENTS.md`, root adapters | Track project projection | Template only | `hosted-required`; project-owned |
| `.codex/**`, `.claude/**`, `.cursor/**` | Regenerate locally | Excluded | `generated-on-demand` |
| `.github/**` | Track private-workspace CI | Generated public-only CI component | Project-owned CI, never installed by Octon |
| Logs, caches, build trees, archives | Local or external | Only signed release assets outside Git | Local/external; explicitly published reports are exceptions |

Forward migration should inventory and secure each tracked object before staged `git rm --cached` changes. Existing public history remains a separate exposure problem.

## Implementation Roadmap

**Recommendation:** Each phase is independently gated and reversible.

| Phase | Owner, scope, files | Acceptance and negative controls | Rollback / authority |
|---|---|---|---|
| P0 Contain | Security, Sponsor, GitHub Admin, Legal: freeze release activity; inventory history, refs, releases, artifacts, caches, issues, PRs, credentials | Signed exposure register; no sensitive content reproduced in reports | Lift freeze only after disposition; incident decisions remain human-owned |
| P1 Establish roles | Architecture/Release: create repository identities; add repository-role schema and private/public policies | Public repo has synthetic history; workspace has no public write credential; real owners/protections | Keep current repository read-only until replacement is proven |
| P2 Clear and export | Maintainers/Security/Legal: update `octon.yml`, profile validator, exporter, clearance ledger, public-repo templates | Deterministic clean export; denylist and ignored/untracked/symlink injection tests; zero uncleared paths | Disable `portable_dropin`; retain old profiles internally |
| P3 Publish securely | Release/Security: public-tree PR automation, protected environment, signed release pipeline, SHA-pinned actions | Tree parity, checksums, SBOM, attestations, offline verification, excluded-root CI rejection | Before GA recreate repo; after GA issue a new corrected version, never move tags |
| P4 Core delivery | Runtime Maintainers: lock schema, resolver, cache, `octon core` CLI, transaction journal, migration engine | Five-platform tests; ownership hashes unchanged; fault injection after every transaction state | Restore previous lock and cached core tree |
| P5 Init and Git policy | Scaffolding/DX: complete neutral templates, role-aware ignore policy, managed hooks, validators | Fresh public/private/offline projects initialize and rebuild without live state in artifact | Pin prior template version |
| P6 Evidence backend | Security/Ops: repair writer/schema; implement immutable storage adapter, ACLs, retention, restore | Real content digest and reachable object; denied-access and restore drills | Keep local evidence authoritative until every durability gate passes |
| P7 Forward workspace migration | Maintainers: classify current instance/input/state/generated/host material; externalize eligible evidence; remove high-churn tracking | Clean-clone rebuild works; required authority/receipts retained; commit gate rejects prohibited additions | Retain inventories and local/external copies; no history rewrite required |
| P8 Pilot and cut over | Release/DX/project owners: public cached, private collaborative, and offline vendored pilots | Two successful release cycles; reproducible digest, warm/cold install, rollback, interruption, and zero project-owned changes | Pin previous release and stop rollout |

## Mandatory Gates

**Recommendation:**

1. Workspace exposure clearance and pre-push rejection of public remotes.
2. Exact-commit, empty-stage, allowlist-only deterministic export.
3. Denylisted-path, unknown-file, secret, sensitive-content, dependency, binary, WASM, executable, license, and provenance checks.
4. Public-tree digest/diff validation and rejection of manual drift or excluded roots.
5. Protected credentials, release authorization, action digest pinning, checksums, SBOM, attestations, and offline verification.
6. Compatibility, safe extraction, file ownership, dry-run, rollback, anti-downgrade, and interrupted-update tests.
7. Real evidence-object integrity, access, retention, pointer durability, and restore validation.
8. `.gitignore` plus pre-commit/pre-push controls as hygiene; server-side CI remains authoritative.

## Human Decisions

**Open question:** Sponsor must approve organization/repository names, current-repository disposition, public contribution intake, supported platforms, and first-release scope.

**Open question:** Security, Legal, and Release Operations must approve exposure findings, publication license/notice, provenance exceptions, trademark posture, trust roots, storage provider, retention, credential model, and release authorization. Architecture cannot resolve these by itself.

## Normative Policy Wording

**Recommendation:**

> The Octon framework-development workspace is the private source authority for canonical framework development and project-local governance. Public Octon is produced only as a validated `portable_dropin` export into a separate repository with unrelated Git history. Downstream projects pin verified releases, materialize core-owned framework files locally, and retain project authority, operational state, evidence, generated output, and host projections under project-controlled policies.

**Coverage:** Requested architecture, profiles, exporter, bootstrap, evidence contracts and writer, Git tracking, workflows, repository settings, and host projections were reviewed. Human-led ideation content and sensitive file contents were not inspected. A full history exposure scan and framework clearance were not performed; they are P0/P2 implementation work.

No files, Git settings, remotes, or publication surfaces were modified.

