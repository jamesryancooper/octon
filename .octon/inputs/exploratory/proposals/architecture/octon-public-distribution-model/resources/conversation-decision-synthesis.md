# Conversation Decision Synthesis

This resource preserves non-authoritative planning lineage. It contains no
sensitive quotations and does not replace repository evidence or durable
authority.

## Attachment Inventory

The current task supplied the relevant planning history inline in one
conversation thread. No separate file attachment payload was visible to the
review runtime. The following stable attachment records identify the thread
segments reviewed:

| ID | Review input | Extracted role |
| --- | --- | --- |
| ATT-001 | Inputs-layer architecture review | Distinguished repo-specific input from durable authority |
| ATT-002 | Security and information-boundary review | Mapped sensitivity-bearing surfaces and leak paths |
| ATT-003 | Public portable distribution review | Established allowlist export and strict exclusions |
| ATT-004 | Sponsor distribution decisions | Separate public repository, zero packs, neutral templates |
| ATT-005 | Architecture-fit and planning briefs | Identified aligned class roots and implementation gaps |
| ATT-006 | Architectural-engineer handoff prompt | Consolidated evidence and deliverable expectations |
| ATT-007 | Hosted footprint and core update review | Established local-first storage and exact-lock delivery |
| ATT-008 | Delivery resolution and migration brief | Defined self-hosting and repository-transition requirements |
| ATT-009 | Human-decision and generated-mirror clarifications | Separated API-capable effects from human authority |
| ATT-010 | Solo-maintainer operating preferences | Set personal-account, platform, release, and evidence direction |
| ATT-011 | Final decision calibration | Simplified controls for one maintainer using AI |
| ATT-012 | Manual/API and proposal-program decisions | Confirmed proposal-program route and approval boundaries |
| ATT-013 | Current creation orchestration | Set authoritative creation scope, decomposition, and gates |
| ATT-014 | Independent external architecture review | Recorded AR findings and revised the parent plus all ten children |
| ATT-015 | Maintainer review and verification | Confirmed PD-025, narrowed MR scopes, and accepted the reviewed baseline |
| ATT-016 | Independent architecture re-review | Reverified accepted packets against current repository, hosted state, intake, and current GitHub behavior |

## Adopted Decisions

- **Sponsor decision:** Keep private workspace and public distribution in
  separate repositories.
- **Sponsor decision:** Populate public `octon` only from a validated,
  exact-commit, allowlist-generated `portable_dropin` tree.
- **Sponsor decision:** Use synthetic public history and never workspace
  ancestry.
- **Sponsor decision:** Ship the smallest cleared dependency closure, zero
  packs, Apache-2.0 core, and MIT-0 designated copy-out templates.
- **Sponsor decision:** Keep downstream project authority and operational roots
  project-owned and preserve them across updates.
- **Sponsor decision:** Use exact lock plus verified local materialization,
  transactional update, interruption recovery, and rollback.
- **Sponsor decision:** Keep raw evidence local-private with encrypted backup
  and host only classified compact receipts when needed.
- **Sponsor decision:** Use GitHub-native checksums, SBOM, attestations,
  protected tags, and immutable releases without a separate key.
- **Sponsor decision:** Keep final public push and release publication as
  deliberate maintainer actions.

## Conditional Decisions

- Legacy remains public and archived only if exposure review supports that
  disposition.
- A Tier 1 platform passes or is explicitly demoted before release.
- Specialist review is triggered by ambiguous rights, a plausible name
  conflict, or material exposure the maintainer cannot evaluate.
- Live public pilot checks require separately approved repository setup.
- Reuse of the original public `octon` name is conditional on known-writer
  cutover, stale-endpoint negative testing, immutable repository-ID binding,
  and explicit maintainer acceptance of residual unknown-clone risk.

## Superseded Recommendations

- Public use of `bootstrap_core`, `repo_snapshot`, `pack_bundle`, or
  `full_fidelity`.
- Publishing or cloning workspace history.
- Exporting all framework content by path role alone.
- Committing live downstream framework snapshots by default.
- Tracking raw evidence, state, generated output, and host projections by
  default.
- Two-person release approval for the solo-maintainer phase.

## Removed Controls

- GitHub organization as a first-release requirement.
- GitHub App or cross-repository PAT.
- Separately managed signing key.
- Ceremonial self-approval environment.
- Hosted evidence service.
- Automatic publication on merge.

## Deferred Controls And Triggers

- Organization ownership: multiple maintainers or organizational custody.
- Public contributions: approved intake, review, and governance model.
- GitHub App: repeated cross-repository automation justifies isolation.
- Independent trust root: regulated, air-gapped, or independent registry need.
- Evidence compaction execution: material evidence volume and review burden.
- Hosted immutable evidence: collaboration, regulatory, or recovery need.
- Committed vendoring or internal mirror: verified offline or policy need.
- Automatic instance migration: a real instance schema transition.
- Tier 2 gating: reliable lifecycle results on preview platforms.

## Unresolved Human Judgment Gates

These are deliberate operating decisions, not missing implementation
requirements:

- Final legacy exposure and visibility disposition.
- Exact first-release component clearance and ambiguous provenance acceptance.
- Basic name-conflict acceptance.
- Exact GitHub API operations plan approval.
- Account recovery, encryption key, and physical backup custody.
- Evidence deletion.
- First public-tree push.
- Tier 1 demotion, if any.
- Final release publication.

## Conflict Resolution

The adopted final calibration supersedes earlier broader framework export,
enterprise approval, and hosted-storage suggestions. Repository evidence
confirmed the target architecture is feasible but not currently implemented.
One decomposition change was required: self-hosting migration is split into
root repo-local and `.octon/**` internal children to comply with canonical
promotion-scope rules and separate rollback domains.

## Independent Architecture Review Adjustments (2026-07-09)

An independent architecture review (findings AR-001..AR-020, recorded in
`support/revisions/`) adjusted program coordination without changing any
adopted sponsor decision:

- **PD-025 ownership** moved from `public-distribution-public-repository-controls`
  to `public-distribution-portable-dropin-export`: the installable versus
  public-repository-only distinction is defined by the export manifest labels;
  downstream install enforces exclusion; public controls consume the labels.
  Previous position: controls owned the decision with an acceptance test it
  could not implement inside its own write scopes. The maintainer subsequently
  confirmed the exporter ownership assignment.
- **PD-008/PD-024 precedence** is now explicit: the first release permits zero
  provenance exceptions (PD-024 governs); the PD-008 path-override mechanism
  activates only after a maintainer baseline revision.
- **PD-026** (two-way self-hosting migration split), classified in the intake
  as a recommendation subject to external review, is confirmed: canonical
  validation hard-fails packets that mix `.octon/**` and repo-root target
  families, so the split is structurally mandatory.
- **Promotion-target convention**: children declare exact deliverable files
  inside registry write scopes plus a child evidence root; the parent holds a
  single aggregate program-evidence root. Previous position: the parent listed
  six durable framework/instance directories that were also child write scopes,
  and children declared whole-directory targets wider than their registry
  grants.
- **Blocker-graph semantics**: blocker dependencies order release-readiness
  proofs while registry dependencies order implementation; the intentional
  divergences are documented in `resources/first-release-blocker-map.yml`.

## Independent Architecture Re-Review Adjustments (2026-07-10)

The accepted baseline remained structurally sound, but current evidence found
five implementation-blocking omissions and two review-state observations:

- **IAR2-001:** truthful local-private evidence was not dependency-closed
  across active schemas, shell and Rust producers, consumers, validators, and
  tests. The existing local-storage child now owns that exact atomic closure.
- **IAR2-002:** the repository transition omitted GitHub's stale-remote hazard
  when the current public name is renamed and then reused. The legacy,
  workspace, and public-controls children now share explicit inventory,
  cutover, negative-test, and maintainer-risk gates without changing sponsor
  repository names.
- **IAR2-003:** exposure review covered Git objects but not every enabled hosted
  surface. The legacy child now inventories and dispositions those surfaces.
- **IAR2-004:** root ignore and Octon migration scope could re-track local-only
  material and omitted heterogeneous input subtypes. Existing migration
  children now cover subtype-aware ignore and index transitions without
  inspecting human-led ideation content.
- **IAR2-005:** the committed core lock lacked a machine-readable schema target.
  The delivery child now owns `core-lock-v1.schema.json`.
- **IAR2-006:** accepted packet narratives and catalogs have lifecycle
  presentation drift. Affected revised packets are refreshed; unchanged
  accepted packets are not churned solely for this non-authority issue.
- **IAR2-007:** generated proposal discovery was stale because of unrelated
  pre-existing proposal work. Registry refresh remains a generated projection,
  not proposal acceptance or implementation authority.
